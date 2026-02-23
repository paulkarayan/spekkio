from fastapi import FastAPI
from database import engine, Base
from routes import accounts, transactions

Base.metadata.create_all(bind=engine)

app = FastAPI(title="ATM API", version="0.1.0")

app.include_router(accounts.router)
app.include_router(transactions.router)


@app.get("/health")
def health_check():
    return {"status": "ok"}
