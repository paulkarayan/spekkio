from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from database import Base


class TransactionType(str, enum.Enum):
    DEPOSIT = "deposit"
    WITHDRAWAL = "withdrawal"
    TRANSFER = "transfer"


class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    account_number = Column(String, unique=True, index=True)
    holder_name = Column(String)
    pin = Column(String)  # NOTE: stored as plain text
    balance = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)

    transactions = relationship("Transaction", back_populates="account", foreign_keys="Transaction.account_id")


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    account_id = Column(Integer, ForeignKey("accounts.id"))
    type = Column(Enum(TransactionType))
    amount = Column(Float)
    target_account_id = Column(Integer, ForeignKey("accounts.id"), nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    description = Column(String, nullable=True)

    account = relationship("Account", back_populates="transactions", foreign_keys=[account_id])
