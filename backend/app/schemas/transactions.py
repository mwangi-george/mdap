from pydantic import BaseModel


class TransactionCreate(BaseModel):
    mpesa_message: str

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "mpesa_message": "SEA3IRdTsD Confirmed. Your account balance was: M-PESA Account : Ksh0.00 Business Account : Ksh0.00 on 27/5/24 at 10:18 AM. Buy Airtime easily via M-PESA App. Click https://bit.ly/bampesa"
            }
        }


class TransactionSchema(BaseModel):
    id: int
    transaction_code: str
    transaction_amount: str
    counterparty: str
    date: str
    time: str
    new_balance: str
    transaction_cost: str
    transaction_type: str
    user_id: int

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 1,
                "transaction_code": "SEA3IRdTsD",
                "transaction_amount": "0.00",
                "counterparty": "N/A",
                "date": "27/5/24",
                "time": "10:18 AM",
                "new_balance": "0.00",
                "transaction_cost": "0.00",
                "transaction_type": "balance inquiry",
                "user_id": 1,
            }
        }


class ManyTransactions(BaseModel):
    transactions: list[TransactionSchema]
