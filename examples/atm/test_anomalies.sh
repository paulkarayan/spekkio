#!/usr/bin/env bash
# Test ATM app functionality and verify intentional anomalies.
# Usage: start the server first with `uvicorn main:app --port 8787`, then run this script.

BASE=http://127.0.0.1:8787

echo "=== BASIC FUNCTIONALITY ==="
echo "Health:"
curl -s $BASE/health | python -m json.tool

echo -e "\nCreate Alice:"
curl -s -X POST $BASE/accounts/ -H 'Content-Type: application/json' -d '{"account_number":"ACC001","holder_name":"Alice","pin":"1234"}' | python -m json.tool

echo -e "\nCreate Bob:"
curl -s -X POST $BASE/accounts/ -H 'Content-Type: application/json' -d '{"account_number":"ACC002","holder_name":"Bob","pin":"5678"}' | python -m json.tool

echo -e "\nDeposit 10000:"
curl -s -X POST $BASE/transactions/deposit -H 'Content-Type: application/json' -H 'x-account-number: ACC001' -H 'x-pin: 1234' -d '{"amount":10000}' | python -m json.tool

echo -e "\n=== ANOMALY 1: No withdrawal limit ==="
curl -s -X POST $BASE/transactions/withdraw -H 'Content-Type: application/json' -H 'x-account-number: ACC001' -H 'x-pin: 1234' -d '{"amount":9999}' | python -m json.tool

echo -e "\nRe-deposit 5000:"
curl -s -X POST $BASE/transactions/deposit -H 'Content-Type: application/json' -H 'x-account-number: ACC001' -H 'x-pin: 1234' -d '{"amount":5000}' | python -m json.tool

echo -e "\n=== ANOMALY 2: No overdraft protection on transfers ==="
echo "(Transfer more than balance):"
curl -s -X POST $BASE/transactions/transfer -H 'Content-Type: application/json' -H 'x-account-number: ACC001' -H 'x-pin: 1234' -d '{"target_account_number":"ACC002","amount":5002}' | python -m json.tool

echo -e "\n=== ANOMALY 3: Plain text PIN ==="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python -c "
import sys; sys.path.insert(0, '$SCRIPT_DIR')
from database import SessionLocal
from models import Account
db = SessionLocal()
a = db.query(Account).filter(Account.account_number == 'ACC001').first()
print(f'PIN stored in DB: \"{a.pin}\" (plain text, not hashed)')
db.close()
"

echo -e "\n=== ANOMALY 4: No rate limiting ==="
for i in 1 2 3 4 5; do
  echo -n "Wrong PIN attempt $i: "
  curl -s $BASE/accounts/balance -H 'x-account-number: ACC001' -H 'x-pin: wrong' | python -c "import sys,json; print(json.load(sys.stdin)['detail'])"
done
echo -n "Correct PIN after brute force: "
curl -s $BASE/accounts/balance -H 'x-account-number: ACC001' -H 'x-pin: 1234' | python -m json.tool

echo -e "\n=== Transaction history ==="
curl -s $BASE/accounts/history -H 'x-account-number: ACC001' -H 'x-pin: 1234' | python -m json.tool
