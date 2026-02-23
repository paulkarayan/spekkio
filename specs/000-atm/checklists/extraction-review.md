# Extraction Review Checklist

**Project**: ATM API (`examples/atm/`)
**Extracted**: 2026-02-22
**Reviewer**: _______________
**Status**: Pending Review

## Summary

| Metric | Count |
|--------|-------|
| User Stories Inferred | 8 |
| Acceptance Criteria | 36 |
| Characterization Scenarios | 36 |
| Anomalies Detected | 16 |
| Uncovered Code Paths | 9 (infrastructure/models only) |

## User Story Review

For each inferred user story, mark:
- ✓ Correct -- accurately describes intended behavior
- ✎ Revise -- needs modification (note changes needed)
- ✗ Remove -- accidental/unwanted behavior
- + Split -- should be multiple stories

| ID | User Story | Status | Notes |
|----|------------|--------|-------|
| US-001 | Health Check | [ ] | |
| US-002 | Account Creation | [ ] | |
| US-003 | Balance Inquiry | [ ] | |
| US-004 | Transaction History | [ ] | |
| US-005 | Deposit Funds | [ ] | |
| US-006 | Withdraw Funds | [ ] | |
| US-007 | Transfer Funds | [ ] | |
| US-008 | PIN Authentication | [ ] | |

## Anomaly Resolution

### ANO-01: Plain-text PIN storage

- **Observed**: PINs are stored as plain text in the database (`models.py:21`, `routes/accounts.py:33`)
- **Source**: `routes/accounts.py:33`, `auth.py:15`
- **Question**: Is this intentional for a demo app, or a security defect that needs fixing?
- **Decision**:
  - [ ] Intended behavior (demo app, document as known limitation)
  - [ ] Bug -- hash PINs with bcrypt or argon2
  - [ ] Defer -- add to backlog

### ANO-02: No rate limiting on PIN attempts

- **Observed**: Unlimited failed PIN attempts are allowed with no lockout or delay (`auth.py:8-17`)
- **Source**: `auth.py:8-17`
- **Question**: Should there be brute-force protection (lockout after N attempts)?
- **Decision**:
  - [ ] Intended behavior (demo app)
  - [ ] Bug -- add rate limiting or account lockout
  - [ ] Defer -- add to backlog

### ANO-03: No withdrawal limit

- **Observed**: Any amount can be withdrawn in a single transaction, up to the full balance (`routes/transactions.py:45`)
- **Source**: `routes/transactions.py:42-57`
- **Question**: Should there be per-transaction or daily withdrawal limits?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- add withdrawal limits
  - [ ] Defer -- add to backlog

### ANO-04: No transfer limit

- **Observed**: Any amount can be transferred in a single transaction, up to the full balance
- **Source**: `routes/transactions.py:61-93`
- **Question**: Should there be per-transaction or daily transfer limits?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- add transfer limits
  - [ ] Defer -- add to backlog

### ANO-05: Float used for monetary amounts

- **Observed**: Account balance and transaction amounts use Python `float` / SQLAlchemy `Float`, which can introduce rounding errors (`models.py:22,34`)
- **Source**: `models.py:22`, `models.py:34`
- **Question**: Should monetary values use `Decimal` or integer cents to avoid precision issues?
- **Decision**:
  - [ ] Intended behavior (acceptable precision for demo)
  - [ ] Bug -- switch to Decimal/integer cents
  - [ ] Defer -- add to backlog

### ANO-06: No input format validation on account_number

- **Observed**: Account numbers have no format constraints (could be empty string, special characters, any length)
- **Source**: `routes/accounts.py:12-15`
- **Question**: Should account numbers follow a specific format?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- add format validation
  - [ ] Defer -- add to backlog

### ANO-07: No PIN complexity validation

- **Observed**: PINs have no length or format requirements (could be a single character or empty)
- **Source**: `routes/accounts.py:12-15`
- **Question**: Should PINs be required to be exactly 4 digits?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- add PIN format validation
  - [ ] Defer -- add to backlog

### ANO-08: No holder_name validation

- **Observed**: Holder name has no minimum length requirement; empty strings are accepted
- **Source**: `routes/accounts.py:12-15`
- **Question**: Should holder names be required and have minimum length?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- add name validation
  - [ ] Defer -- add to backlog

### ANO-09: No pagination on transaction history

- **Observed**: `GET /accounts/history` returns all transactions without limit/offset
- **Source**: `routes/accounts.py:48-63`
- **Question**: Will this cause performance issues for accounts with many transactions?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- add pagination
  - [ ] Defer -- add to backlog

### ANO-10: No maximum deposit limit

- **Observed**: Arbitrarily large amounts can be deposited
- **Source**: `routes/transactions.py:26-38`
- **Question**: Should there be a per-transaction or daily deposit cap?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- add deposit limits
  - [ ] Defer -- add to backlog

### ANO-11: No concurrency control on balance updates

- **Observed**: Balance check and update are not protected by database locks; concurrent requests could cause race conditions
- **Source**: `routes/transactions.py:46-48`, `routes/transactions.py:65-74`
- **Question**: Could concurrent withdrawals or transfers cause overdraft?
- **Decision**:
  - [ ] Intended behavior (single-user demo)
  - [ ] Bug -- add optimistic locking or SELECT FOR UPDATE
  - [ ] Defer -- add to backlog

### ANO-12: Health check does not verify database

- **Observed**: `GET /health` returns OK without checking database connectivity
- **Source**: `main.py:14-15`
- **Question**: Should the health check include a database ping?
- **Decision**:
  - [ ] Intended behavior (lightweight check)
  - [ ] Bug -- add DB verification
  - [ ] Defer -- add to backlog

### ANO-13: No session or token-based auth

- **Observed**: Every request requires sending account number and PIN in headers
- **Source**: `auth.py:8`
- **Question**: Should the API use JWT or session tokens instead of per-request PIN?
- **Decision**:
  - [ ] Intended behavior (simple ATM model)
  - [ ] Enhancement -- add token-based auth
  - [ ] Defer -- add to backlog

### ANO-14: Balance check before target account lookup in transfer

- **Observed**: When transferring, insufficient funds error is returned before checking if the target account exists
- **Source**: `routes/transactions.py:62-69`
- **Question**: Is this error priority order intentional?
- **Decision**:
  - [ ] Intended behavior
  - [ ] Bug -- check target first for better UX
  - [ ] Defer

### ANO-15: No automated test suite

- **Observed**: Only a bash script (`test_anomalies.sh`) exists; no pytest or unittest files
- **Source**: project root
- **Question**: Should automated tests be added?
- **Decision**:
  - [ ] Add automated tests
  - [ ] Defer -- add to backlog

### ANO-16: SQLite used as database

- **Observed**: SQLite file database (`atm.db`) with `check_same_thread=False`
- **Source**: `database.py:4-8`
- **Question**: Is SQLite appropriate, or should this use PostgreSQL/MySQL for production?
- **Decision**:
  - [ ] Intended behavior (demo/dev only)
  - [ ] Enhancement -- add production DB support
  - [ ] Defer

## Missing Context

Questions that could not be answered from code alone:

| Question | Why It Matters | Answer |
|----------|----------------|--------|
| What is the intended deployment environment? | Determines if SQLite is acceptable or a real DB is needed | |
| What are the regulatory requirements for PIN storage? | Determines if plain-text PIN is a compliance violation | |
| What are the expected transaction volumes? | Affects pagination and concurrency decisions | |
| Should there be daily withdrawal/transfer limits? | Common ATM requirement; not implemented | |
| Is this a demo/prototype or production-bound code? | Affects severity of all anomalies | |
| Who are the intended users (bank customers, internal staff, both)? | Affects auth and access control decisions | |
| Should transactions support rollback or dispute? | No mechanism exists for reversing transactions | |

## Dead Code Review

| Function | Location | Action |
|----------|----------|--------|
| No dead code detected | N/A | N/A |

All functions and classes are reachable from the application entry point (`main.py`).

## Sign-off

- [ ] All user stories reviewed
- [ ] All anomalies resolved
- [ ] Missing context documented or answered
- [ ] Dead code decisions made

Reviewer: _______________ Date: _______________
