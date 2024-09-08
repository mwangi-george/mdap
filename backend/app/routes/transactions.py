from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from ..models import get_db, User
from ..schemas import TransactionCreate, ActionConfirm, TransactionSchema, ManyTransactions
from ..services.transactions import TransactionsServices
from ..security import Security

security = Security()


def create_transaction_router() -> APIRouter:
    """ Register the routes for the transactions endpoints """
    router = APIRouter(
        prefix="/transactions",
        tags=["transactions"],
    )
    transaction_services = TransactionsServices()

    @router.post("/new", response_model=ActionConfirm, status_code=status.HTTP_201_CREATED)
    async def register_transaction(
            transaction: TransactionCreate,
            db: Session = Depends(get_db),
            current_user: User = Depends(security.get_current_user)
    ):
        user_id = current_user.id
        msg = transaction_services.register_transaction(transaction, user_id, db)
        formatted_msg = ActionConfirm(msg=msg)
        return formatted_msg

    @router.get("/retrieve", response_model=TransactionSchema, status_code=status.HTTP_200_OK)
    async def retrieve_transaction_by_code(
            code: str,
            db: Session = Depends(get_db),
            current_user: User = Depends(security.get_current_user)
    ):
        transaction = transaction_services.retrieve_transaction_by_code(code, current_user.id, db)
        return transaction

    @router.get("/retrieve/all", response_model=ManyTransactions, status_code=status.HTTP_200_OK)
    async def retrieve_all_transactions_by_user(
            db: Session = Depends(get_db),
            current_user: User = Depends(security.get_current_user)
    ):
        user_id = current_user.id
        transactions = transaction_services.retrieve_all_transactions_by_user_id(user_id, db)
        formatted_transactions = ManyTransactions(transactions=transactions)
        return formatted_transactions

    return router
