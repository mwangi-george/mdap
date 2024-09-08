from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_
import re

from ..schemas.transactions import TransactionCreate
from ..models import Transaction


class TransactionsServices:

    def __init__(self):
        pass

    @staticmethod
    def determine_transaction_type(message):
        if "paid to" in message.lower():
            return "paid"
        elif "sent to" in message.lower():
            return "sent"
        elif "withdraw" in message.lower():
            return "withdrawn"
        elif "received" in message.lower():
            return "received"
        elif "bought" in message and "airtime" in message:
            return "airtime purchase"
        elif "Give" in message and "cash to":
            return "deposit"
        elif "balance was" in message:
            return "balance inquiry"
        else:
            return "unknown"

    def process_single_transaction_message(self, message) -> dict:

        # Regular expression patterns to extract data (case-insensitive)
        patterns = {
            'confirmation_code': r'(\w{10})\s*confirmed',
            'amount': r'Ksh([\d,]+\.\d{2})',
            'counterparty': r'paid to ([\w\s]+)\.|sent to ([\w\s]+ \d+)|from ([\w\s&-]+)|from ([\w\s]+) on|from ([\w\s]+)\.',
            'date': r'on (\d{1,2}/\d{1,2}/\d{2})',
            'time': r'at (\d{1,2}:\d{2} [APM]{2})',
            'new_balance': r'New M-PESA balance is Ksh([\d,]+\.\d{2})',
            'transaction_cost': r'Transaction cost, Ksh([\d,]+\.\d{2})'
        }

        # Determine the transaction type
        transaction_type = self.determine_transaction_type(message)

        # Extract data using regex patterns with case insensitivity
        def safe_search(pattern, message, group=1, default="N/A"):
            match = re.search(pattern, message, re.IGNORECASE)
            return match.group(group) if match else default

        confirmation_code = safe_search(patterns['confirmation_code'], message)
        amount = safe_search(patterns['amount'], message)
        counterparty_match = re.search(patterns['counterparty'], message, re.IGNORECASE)
        counterparty = (counterparty_match.group(1) if counterparty_match and counterparty_match.group(1)
                        else counterparty_match.group(2) if counterparty_match and counterparty_match.group(2)
                        else counterparty_match.group(3) if counterparty_match and counterparty_match.group(3)
                        else counterparty_match.group(4) if counterparty_match and counterparty_match.group(4)
                        else counterparty_match.group(5) if counterparty_match and counterparty_match.group(5)
                        else "N/A")
        date = safe_search(patterns['date'], message)
        time = safe_search(patterns['time'], message)
        new_balance = safe_search(patterns['new_balance'], message)
        transaction_cost = safe_search(patterns['transaction_cost'], message, default="N/A")

        # Create a dictionary with the extracted data
        transaction_data = {
            'transaction_code': confirmation_code,
            'transaction_amount': amount,
            'counterparty': counterparty,
            'date': date,
            'time': time,
            'new_balance': new_balance,
            'transaction_cost': transaction_cost,
            'transaction_type': transaction_type
        }
        if transaction_data["transaction_code"] == "N/A":
            raise HTTPException(
                status_code=status.HTTP_406_NOT_ACCEPTABLE,
                detail=f"Invalid Mpesa message!"
            )
        return transaction_data

    def register_transaction(self, transaction: TransactionCreate, user_id: int, db: Session):
        transaction_info_dict = self.process_single_transaction_message(transaction.mpesa_message)

        db_transaction = db.query(Transaction)\
            .filter_by(transaction_code=transaction_info_dict["transaction_code"]).first()

        if db_transaction:
            raise HTTPException(
                status_code=status.HTTP_406_NOT_ACCEPTABLE,
                detail=f"Transaction with code {db_transaction.transaction_code} already exists!"
            )

        try:
            transaction_to_add = Transaction(**transaction_info_dict, user_id=user_id)
            db.add(transaction_to_add)
            db.commit()
            db.refresh(transaction_to_add)
            return f"Transaction with code {transaction_to_add.transaction_code} added successfully!"
        except Exception as e:
            print(e)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to add transaction!"
            )

    @staticmethod
    def retrieve_transaction_by_code(code: str, user_id: int, db: Session) -> [Transaction]:
        db_transaction = db.query(Transaction) .filter(
            and_(Transaction.transaction_code == code, Transaction.user_id == user_id)
        ).first()

        if db_transaction is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Transaction with code {code} does not exist!"
            )
        return db_transaction

    @staticmethod
    def retrieve_all_transactions_by_user_id(user_id: int, db: Session) -> [Transaction]:
        db_transactions = db.query(Transaction).filter_by(user_id=user_id).all()
        return db_transactions
