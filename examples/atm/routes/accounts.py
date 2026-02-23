from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

from database import get_db
from models import Account, Transaction
from auth import verify_pin

router = APIRouter(prefix="/accounts", tags=["accounts"])


class AccountCreate(BaseModel):
    account_number: str
    holder_name: str
    pin: str


class AccountResponse(BaseModel):
    id: int
    account_number: str
    holder_name: str
    balance: float


@router.post("/", response_model=AccountResponse, status_code=201)
def create_account(account: AccountCreate, db: Session = Depends(get_db)):
    existing = db.query(Account).filter(Account.account_number == account.account_number).first()
    if existing:
        raise HTTPException(status_code=400, detail="Account number already exists")
    db_account = Account(
        account_number=account.account_number,
        holder_name=account.holder_name,
        pin=account.pin,  # stored as plain text - no hashing
    )
    db.add(db_account)
    db.commit()
    db.refresh(db_account)
    return db_account


@router.get("/balance", response_model=dict)
def get_balance(account: Account = Depends(verify_pin)):
    return {"account_number": account.account_number, "balance": account.balance}


@router.get("/history")
def get_history(account: Account = Depends(verify_pin), db: Session = Depends(get_db)):
    transactions = (
        db.query(Transaction)
        .filter(Transaction.account_id == account.id)
        .order_by(Transaction.timestamp.desc())
        .all()
    )
    return [
        {
            "id": t.id,
            "type": t.type.value,
            "amount": t.amount,
            "timestamp": t.timestamp.isoformat(),
            "description": t.description,
        }
        for t in transactions
    ]
