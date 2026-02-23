# Source Mapping

**Project**: ATM API
**Extracted**: 2026-02-22

---

## Table 1: Scenario to Source

| Scenario | Source File | Lines | Function |
|----------|------------|-------|----------|
| Health endpoint returns OK | `main.py` | 14-15 | `health_check` |
| Successfully create a new account | `routes/accounts.py` | 26-38 | `create_account` |
| New account starts with zero balance | `models.py` | 22 | `create_account` |
| Reject duplicate account number | `routes/accounts.py` | 27-29 | `create_account` |
| PIN is stored as plain text | `routes/accounts.py` | 33 | `create_account` |
| Response does not include PIN field | `routes/accounts.py` | 18-23 | `create_account` |
| Account number with no format validation | `routes/accounts.py` | 12-15 | `create_account` |
| PIN with no complexity validation | `routes/accounts.py` | 12-15 | `create_account` |
| Successfully retrieve balance | `routes/accounts.py` | 42-43 | `get_balance` |
| Reject request with missing headers | `auth.py` | 8 | `verify_pin` |
| Reject request with wrong PIN | `auth.py` | 15-16 | `verify_pin` |
| Reject request with nonexistent account | `auth.py` | 13-14 | `verify_pin` |
| Retrieve transaction history for an account | `routes/accounts.py` | 48-63 | `get_history` |
| Transactions are ordered newest first | `routes/accounts.py` | 52 | `get_history` |
| Transaction fields include ISO 8601 timestamp | `routes/accounts.py` | 55-61 | `get_history` |
| Reject history request with invalid credentials | `auth.py` | 8-17 | `verify_pin` |
| All transactions returned without pagination | `routes/accounts.py` | 48-63 | `get_history` |
| Successful deposit increases balance | `routes/transactions.py` | 26-38 | `deposit` |
| Deposit returns success message | `routes/transactions.py` | 38 | `deposit` |
| Reject deposit with zero amount | `routes/transactions.py` | 27-28 | `deposit` |
| Reject deposit with negative amount | `routes/transactions.py` | 27-28 | `deposit` |
| Deposit creates a transaction record | `routes/transactions.py` | 30-35 | `deposit` |
| Successful withdrawal decreases balance | `routes/transactions.py` | 42-57 | `withdraw` |
| Withdrawal returns success message | `routes/transactions.py` | 57 | `withdraw` |
| Reject withdrawal with zero amount | `routes/transactions.py` | 43-44 | `withdraw` |
| Reject withdrawal with negative amount | `routes/transactions.py` | 43-44 | `withdraw` |
| Reject withdrawal exceeding balance | `routes/transactions.py` | 46-47 | `withdraw` |
| Withdrawal creates a transaction record | `routes/transactions.py` | 49-54 | `withdraw` |
| Large withdrawal has no limit | `routes/transactions.py` | 45 | `withdraw` |
| Successful transfer updates both balances | `routes/transactions.py` | 73-74 | `transfer` |
| Transfer returns success message with new source balance | `routes/transactions.py` | 93 | `transfer` |
| Reject transfer with zero amount | `routes/transactions.py` | 62-63 | `transfer` |
| Reject transfer exceeding source balance | `routes/transactions.py` | 65-66 | `transfer` |
| Reject transfer to nonexistent account | `routes/transactions.py` | 67-69 | `transfer` |
| Reject self-transfer | `routes/transactions.py` | 70-71 | `transfer` |
| Transfer creates two transaction records | `routes/transactions.py` | 76-91 | `transfer` |
| Sender transaction has descriptive text with target account | `routes/transactions.py` | 81 | `transfer` |
| Receiver transaction has descriptive text with source account | `routes/transactions.py` | 88 | `transfer` |
| Insufficient funds error takes priority over invalid target | `routes/transactions.py` | 65-66 | `transfer` |
| Authentication uses x-account-number and x-pin headers | `auth.py` | 8 | `verify_pin` |
| Nonexistent account returns 401 | `auth.py` | 13-14 | `verify_pin` |
| Wrong PIN returns 401 | `auth.py` | 15-16 | `verify_pin` |
| Same error message for wrong PIN and nonexistent account | `auth.py` | 14,16 | `verify_pin` |
| PIN compared as plain text equality | `auth.py` | 15 | `verify_pin` |
| Unlimited failed PIN attempts allowed | `auth.py` | 8-17 | `verify_pin` |

---

## Table 2: Source to Scenario Coverage

| File | Functions | Scenarios | Coverage |
|------|-----------|-----------|----------|
| `main.py` | 1 (`health_check`) | 1 | 100% |
| `routes/accounts.py` | 3 (`create_account`, `get_balance`, `get_history`) | 12 | 100% |
| `routes/transactions.py` | 3 (`deposit`, `withdraw`, `transfer`) | 18 | 100% |
| `auth.py` | 1 (`verify_pin`) | 10 | 100% |
| `database.py` | 1 (`get_db`) | 0 | 0% (infrastructure) |
| `models.py` | 0 (declarative models only) | 1 (indirect) | N/A |

**Overall**: 8 handler/auth functions, all covered by at least one scenario.

---

## Table 3: Uncovered Code

| File | Function | Lines | Reason |
|------|----------|-------|--------|
| `database.py` | `get_db` | 14-19 | Internal infrastructure: FastAPI dependency injection session factory. Not directly testable via HTTP endpoints; exercised implicitly by all DB-dependent endpoints. |
| `models.py` | `Account` (class) | 15-25 | ORM model declaration. Covered implicitly through endpoint tests that create and query accounts. |
| `models.py` | `Transaction` (class) | 28-39 | ORM model declaration. Covered implicitly through endpoint tests that create transactions. |
| `models.py` | `TransactionType` (enum) | 9-12 | Enum declaration. Used by transaction endpoints; no standalone behavior to test. |
| `routes/accounts.py` | `AccountCreate` (Pydantic model) | 12-15 | Request schema. Exercised via account creation endpoint tests. |
| `routes/accounts.py` | `AccountResponse` (Pydantic model) | 18-22 | Response schema. Exercised via account creation endpoint tests. |
| `routes/transactions.py` | `DepositRequest` (Pydantic model) | 12-13 | Request schema. Exercised via deposit endpoint tests. |
| `routes/transactions.py` | `WithdrawRequest` (Pydantic model) | 16-17 | Request schema. Exercised via withdraw endpoint tests. |
| `routes/transactions.py` | `TransferRequest` (Pydantic model) | 20-22 | Request schema. Exercised via transfer endpoint tests. |
