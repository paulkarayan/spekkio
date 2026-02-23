# Project Discovery

**Project**: ATM API
**Source**: `examples/atm/`
**Extracted**: 2026-02-22

---

## Language & Framework

| Attribute        | Value                          |
|------------------|--------------------------------|
| Language         | Python 3                       |
| Framework        | FastAPI 0.104.1                |
| ORM              | SQLAlchemy 2.0.23              |
| Validation       | Pydantic 2.5.2                 |
| Server           | Uvicorn 0.24.0                 |
| Database         | SQLite (file: `atm.db`)        |
| Manifest         | `requirements.txt`             |

---

## Entry Points

| File       | Role                                      |
|------------|-------------------------------------------|
| `main.py`  | FastAPI application bootstrap, router registration, table creation |

---

## Project Structure Map

### API Layer (routes, controllers)

| File                      | Description                          |
|---------------------------|--------------------------------------|
| `main.py:13-15`           | Health check endpoint (`GET /health`) |
| `routes/accounts.py`      | Account CRUD and query endpoints     |
| `routes/transactions.py`  | Deposit, withdrawal, transfer endpoints |

### Business Logic

Business logic is co-located with route handlers. There is no separate service or use-case layer.

### Data Layer

| File           | Description                                          |
|----------------|------------------------------------------------------|
| `database.py`  | SQLAlchemy engine, session factory, Base declaration  |
| `models.py`    | ORM models: `Account`, `Transaction`, `TransactionType` enum |

### Authentication / Middleware

| File      | Description                                      |
|-----------|--------------------------------------------------|
| `auth.py` | PIN-based authentication via HTTP headers (`verify_pin` dependency) |

### Tests

| File                 | Description                                     |
|----------------------|-------------------------------------------------|
| `test_anomalies.sh`  | Bash script exercising endpoints and verifying anomalies (not automated test suite) |

No Python test files (`pytest`, `unittest`) exist. **Test coverage: 0%** (no automated tests).

---

## External Interfaces Catalog

### HTTP Endpoints

| # | Method | Path                    | Handler Function  | Source File                 | Auth Required |
|---|--------|-------------------------|-------------------|-----------------------------|---------------|
| 1 | GET    | `/health`               | `health_check`    | `main.py:14-15`             | No            |
| 2 | POST   | `/accounts/`            | `create_account`  | `routes/accounts.py:26-38`  | No            |
| 3 | GET    | `/accounts/balance`     | `get_balance`     | `routes/accounts.py:42-43`  | Yes (PIN)     |
| 4 | GET    | `/accounts/history`     | `get_history`     | `routes/accounts.py:47-63`  | Yes (PIN)     |
| 5 | POST   | `/transactions/deposit` | `deposit`         | `routes/transactions.py:26-38` | Yes (PIN)  |
| 6 | POST   | `/transactions/withdraw`| `withdraw`        | `routes/transactions.py:42-57` | Yes (PIN)  |
| 7 | POST   | `/transactions/transfer`| `transfer`        | `routes/transactions.py:61-93` | Yes (PIN)  |

### CLI Commands

None.

### Event / Message Handlers

None.

### Scheduled Jobs / Cron

None.

### WebSocket Handlers

None.

---

## Key Dependencies and Roles

| Dependency   | Version  | Role                                     |
|--------------|----------|------------------------------------------|
| FastAPI      | 0.104.1  | Web framework, routing, dependency injection |
| Uvicorn      | 0.24.0   | ASGI server                              |
| SQLAlchemy   | 2.0.23   | ORM, database engine, session management |
| Pydantic     | 2.5.2    | Request/response validation and serialization |
| SQLite       | (stdlib) | Embedded relational database             |
