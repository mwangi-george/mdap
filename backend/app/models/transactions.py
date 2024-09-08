from sqlalchemy import Column, Integer, String, Date, Time, Float, ForeignKey

from .base import Base


class Transaction(Base):
    __tablename__ = 'transactions'

    id = Column(Integer, primary_key=True, autoincrement=True)
    transaction_code = Column(String, unique=True, nullable=False, index=True)
    transaction_amount = Column(String, nullable=True)
    counterparty = Column(String, nullable=True)
    date = Column(String, nullable=False)
    time = Column(String, nullable=False)
    new_balance = Column(String, nullable=False)
    transaction_cost = Column(String, nullable=False)
    transaction_type = Column(String, nullable=False, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
