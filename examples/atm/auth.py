from fastapi import Header, HTTPException, Depends
from sqlalchemy.orm import Session

from database import get_db
from models import Account


def verify_pin(x_account_number: str = Header(...), x_pin: str = Header(...), db: Session = Depends(get_db)):
    """Authenticate by checking PIN against stored value.
    No rate limiting on attempts.
    """
    account = db.query(Account).filter(Account.account_number == x_account_number).first()
    if not account:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if account.pin != x_pin:  # plain text comparison
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return account
