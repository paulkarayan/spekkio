# Project Discovery

**Project**: ATM API
**Source**: `examples/atm/`
**Extracted**: 2026-02-28

---

## Language & Framework

- **Language**: Python 3
- **Framework**: FastAPI 0.104.1
- **ORM**: SQLAlchemy 2.0.23
- **Validation**: Pydantic 2.5.2
- **Server**: Uvicorn 0.24.0
- **Database**: SQLite (file-based, `atm.db`)

## Entry Points

- `main.py` — FastAPI application bootstrap, mounts routers, creates DB tables on startup

## Project Structure

### API Layer
- `routes/accounts.py` — Account CRUD endpoints (`POST /accounts/`, `GET /accounts/balance`, `GET /accounts/history`)
- `routes/transactions.py` — Transaction endpoints (`POST /transactions/deposit`, `POST /transactions/withdraw`, `POST /transactions/transfer`)
- `main.py:13-15` — Health check endpoint (`GET /health`)

### Business Logic
- `auth.py` — PIN-based authentication dependency (header-based, plain text comparison)
- No dedicated service layer; business logic lives in route handlers

### Data Layer
- `models.py` — ORM models: `Account`, `Transaction`, `TransactionType` enum
- `database.py` — SQLAlchemy engine, session factory, `get_db` dependency

### Tests
- No pytest or unittest files found
- `test_anomalies.sh` — Bash script for manual curl-based testing (not automated)

## External Interfaces Catalog

| # | Method | Path | Handler | Source |
|---|--------|------|---------|--------|
| 1 | GET | /health | `health_check` | `main.py:13-15` |
| 2 | POST | /accounts/ | `create_account` | `routes/accounts.py:25-38` |
| 3 | GET | /accounts/balance | `get_balance` | `routes/accounts.py:41-43` |
| 4 | GET | /accounts/history | `get_history` | `routes/accounts.py:46-63` |
| 5 | POST | /transactions/deposit | `deposit` | `routes/transactions.py:25-38` |
| 6 | POST | /transactions/withdraw | `withdraw` | `routes/transactions.py:41-57` |
| 7 | POST | /transactions/transfer | `transfer` | `routes/transactions.py:60-93` |

## Key Dependencies

| Package | Role |
|---------|------|
| FastAPI | Web framework, routing, dependency injection |
| SQLAlchemy | ORM, database access |
| Pydantic | Request/response validation |
| Uvicorn | ASGI server |
