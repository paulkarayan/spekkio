from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

from database import get_db
from models import Account, Transaction, TransactionType
from auth import verify_pin

router = APIRouter(prefix="/transactions", tags=["transactions"])


class DepositRequest(BaseModel):
    amount: float


class WithdrawRequest(BaseModel):
    amount: float


class TransferRequest(BaseModel):
    target_account_number: str
    amount: float


@router.post("/deposit", status_code=201)
def deposit(request: DepositRequest, account: Account = Depends(verify_pin), db: Session = Depends(get_db)):
    if request.amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be positive")
    account.balance += request.amount
    transaction = Transaction(
        account_id=account.id,
        type=TransactionType.DEPOSIT,
        amount=request.amount,
        description=f"Deposit of ${request.amount:.2f}",
    )
    db.add(transaction)
    db.commit()
    return {"message": "Deposit successful", "new_balance": account.balance}


@router.post("/withdraw", status_code=201)
def withdraw(request: WithdrawRequest, account: Account = Depends(verify_pin), db: Session = Depends(get_db)):
    if request.amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be positive")
    # NOTE: No withdrawal limit check - can withdraw any amount
    if account.balance < request.amount:
        raise HTTPException(status_code=400, detail="Insufficient funds")
    account.balance -= request.amount
    transaction = Transaction(
        account_id=account.id,
        type=TransactionType.WITHDRAWAL,
        amount=request.amount,
        description=f"Withdrawal of ${request.amount:.2f}",
    )
    db.add(transaction)
    db.commit()
    return {"message": "Withdrawal successful", "new_balance": account.balance}


@router.post("/transfer", status_code=201)
def transfer(request: TransferRequest, account: Account = Depends(verify_pin), db: Session = Depends(get_db)):
    if request.amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be positive")
    # NOTE: No overdraft protection - only checks current balance
    if account.balance < request.amount:
        raise HTTPException(status_code=400, detail="Insufficient funds")
    target = db.query(Account).filter(Account.account_number == request.target_account_number).first()
    if not target:
        raise HTTPException(status_code=404, detail="Target account not found")
    if target.id == account.id:
        raise HTTPException(status_code=400, detail="Cannot transfer to same account")

    account.balance -= request.amount
    target.balance += request.amount

    send_txn = Transaction(
        account_id=account.id,
        type=TransactionType.TRANSFER,
        amount=request.amount,
        target_account_id=target.id,
        description=f"Transfer to {target.account_number}",
    )
    recv_txn = Transaction(
        account_id=target.id,
        type=TransactionType.TRANSFER,
        amount=request.amount,
        target_account_id=account.id,
        description=f"Transfer from {account.account_number}",
    )
    db.add(send_txn)
    db.add(recv_txn)
    db.commit()
    return {"message": "Transfer successful", "new_balance": account.balance}
