# Inferred Specification

**Project**: ATM API
**Extracted**: 2026-02-28
**Status**: Draft -- requires human review

---

## US-001: Health Check (inferred)

**Confidence**: High
**Source**: `GET /health` -- `main.py:13-15`

**As a** system operator
**I want to** check if the ATM API is running
**So that** [HUMAN_INPUT id=HI-001 source=main.py:13-15]
Why does the user need this capability? Monitoring? Load balancer health probe?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-001-01 | GET /health returns 200 with `{"status": "ok"}` | `main.py:14-15` | High |

### Anomalies Detected

[ANOMALY id=ANO-015 source=main.py:13-15]
Health check does not verify database connectivity.
Question: Should it verify the DB is reachable?
Recommendation: Consider adding a DB ping to the health check.
[/ANOMALY]

---

## US-002: Account Creation (inferred)

**Confidence**: High
**Source**: `POST /accounts/` -- `routes/accounts.py:25-38`

**As a** new customer
**I want to** create a bank account with my name and a PIN
**So that** [HUMAN_INPUT id=HI-002 source=routes/accounts.py:25-38]
Why does the user need to create an account? What is the onboarding flow?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-002-01 | Account is created with account_number, holder_name, and pin; returns 201 with account details | `routes/accounts.py:25-38` | High |
| AC-002-02 | New account starts with balance of 0.0 | `models.py:22` | High |
| AC-002-03 | Duplicate account_number is rejected with 400 | `routes/accounts.py:27-29` | High |
| AC-002-04 | PIN is stored as plain text (no hashing) | `routes/accounts.py:33` | High |
| AC-002-05 | Response excludes PIN field (AccountResponse model) | `routes/accounts.py:18-22` | High |
| AC-002-06 | No validation on account_number format | `routes/accounts.py:12-15` | Medium |
| AC-002-07 | No validation on PIN complexity or length | `routes/accounts.py:12-15` | Medium |
| AC-002-08 | No validation on holder_name (empty strings accepted) | `routes/accounts.py:12-15` | Medium |

### Anomalies Detected

[ANOMALY id=ANO-016 source=routes/accounts.py:33]
PIN stored as plain text in database.
Question: Is this intentional for a demo, or a security bug?
Recommendation: Hash PINs with bcrypt or similar.
[/ANOMALY]

[ANOMALY id=ANO-017 source=routes/accounts.py:12-15]
No validation on account_number format — accepts empty strings, special characters, any length.
Question: Should account numbers follow a specific format?
Recommendation: Add regex or length validation.
[/ANOMALY]

[ANOMALY id=ANO-018 source=routes/accounts.py:12-15]
No validation on PIN complexity or length — single character or empty string accepted.
Question: Should PINs be exactly 4 digits?
Recommendation: Add PIN format constraint.
[/ANOMALY]

[ANOMALY id=ANO-019 source=routes/accounts.py:12-15]
No validation on holder_name — empty strings accepted.
Question: Should empty names be rejected?
Recommendation: Add minimum length validation.
[/ANOMALY]

---

## US-003: Balance Inquiry (inferred)

**Confidence**: High
**Source**: `GET /accounts/balance` -- `routes/accounts.py:41-43`

**As an** account holder
**I want to** check my account balance
**So that** [HUMAN_INPUT id=HI-003 source=routes/accounts.py:41-43]
Why does the user need to check their balance?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-003-01 | Returns account_number and balance for authenticated user | `routes/accounts.py:42-43` | High |
| AC-003-02 | Requires valid x-account-number and x-pin headers | `auth.py:8` | High |
| AC-003-03 | Returns 401 for invalid credentials (wrong PIN or nonexistent account) | `auth.py:13-16` | High |

### Anomalies Detected

[ANOMALY id=ANO-020 source=auth.py:8-17]
No rate limiting on PIN attempts — brute-force attack possible.
Question: Is brute-force protection needed?
Recommendation: Add rate limiting or account lockout after N failed attempts.
[/ANOMALY]

---

## US-004: Transaction History (inferred)

**Confidence**: High
**Source**: `GET /accounts/history` -- `routes/accounts.py:46-63`

**As an** account holder
**I want to** view my transaction history
**So that** [HUMAN_INPUT id=HI-004 source=routes/accounts.py:46-63]
Why does the user need to view transaction history?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-004-01 | Returns list of transactions for the authenticated account | `routes/accounts.py:48-52` | High |
| AC-004-02 | Transactions are ordered by timestamp descending (newest first) | `routes/accounts.py:51` | High |
| AC-004-03 | Each transaction includes id, type, amount, timestamp (ISO 8601), and description | `routes/accounts.py:55-61` | High |
| AC-004-04 | Requires valid x-account-number and x-pin headers | `auth.py:8` | High |
| AC-004-05 | Returns 401 for invalid credentials | `auth.py:13-16` | High |

### Anomalies Detected

[ANOMALY id=ANO-021 source=routes/accounts.py:46-63]
No pagination — returns all transactions without limit/offset.
Question: Will this cause performance issues with many transactions?
Recommendation: Add limit/offset or cursor-based pagination.
[/ANOMALY]

---

## US-005: Deposit Funds (inferred)

**Confidence**: High
**Source**: `POST /transactions/deposit` -- `routes/transactions.py:25-38`

**As an** account holder
**I want to** deposit money into my account
**So that** [HUMAN_INPUT id=HI-005 source=routes/transactions.py:25-38]
Why does the user need to deposit funds?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-005-01 | Deposit increases account balance by the specified amount | `routes/transactions.py:29` | High |
| AC-005-02 | Returns 201 with success message and new balance | `routes/transactions.py:38` | High |
| AC-005-03 | Amount must be greater than zero; returns 400 otherwise | `routes/transactions.py:27-28` | High |
| AC-005-04 | Creates a DEPOSIT transaction record with description | `routes/transactions.py:30-35` | High |
| AC-005-05 | Requires authentication via PIN headers | `auth.py:8` | High |

### Anomalies Detected

[ANOMALY id=ANO-022 source=routes/transactions.py:25-38]
No maximum deposit limit — arbitrarily large amounts can be deposited.
Question: Should there be a per-transaction or daily deposit cap?
Recommendation: Consider adding deposit limits.
[/ANOMALY]

[ANOMALY id=ANO-023 source=models.py:22]
Float used for monetary amounts — floating-point rounding may cause balance discrepancies.
Question: Could this cause real financial errors?
Recommendation: Use Decimal or integer cents.
[/ANOMALY]

---

## US-006: Withdraw Funds (inferred)

**Confidence**: High
**Source**: `POST /transactions/withdraw` -- `routes/transactions.py:41-57`

**As an** account holder
**I want to** withdraw money from my account
**So that** [HUMAN_INPUT id=HI-006 source=routes/transactions.py:41-57]
Why does the user need to withdraw funds?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-006-01 | Withdrawal decreases account balance by the specified amount | `routes/transactions.py:48` | High |
| AC-006-02 | Returns 201 with success message and new balance | `routes/transactions.py:57` | High |
| AC-006-03 | Amount must be greater than zero; returns 400 otherwise | `routes/transactions.py:43-44` | High |
| AC-006-04 | Insufficient funds (balance < amount) returns 400 | `routes/transactions.py:46-47` | High |
| AC-006-05 | Creates a WITHDRAWAL transaction record with description | `routes/transactions.py:49-54` | High |
| AC-006-06 | Requires authentication via PIN headers | `auth.py:8` | High |

### Anomalies Detected

[ANOMALY id=ANO-024 source=routes/transactions.py:45]
No withdrawal limit per transaction or per day — can withdraw any amount up to full balance.
Question: Should ATM-style withdrawal limits exist?
Recommendation: Add configurable withdrawal limits.
[/ANOMALY]

[ANOMALY id=ANO-025 source=routes/transactions.py:46-48]
No concurrency control on balance check and update — concurrent withdrawals could cause overdraft.
Question: Could concurrent requests cause negative balances?
Recommendation: Add optimistic locking or SELECT FOR UPDATE.
[/ANOMALY]

---

## US-007: Transfer Funds (inferred)

**Confidence**: High
**Source**: `POST /transactions/transfer` -- `routes/transactions.py:60-93`

**As an** account holder
**I want to** transfer money to another account
**So that** [HUMAN_INPUT id=HI-007 source=routes/transactions.py:60-93]
Why does the user need to transfer funds between accounts?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-007-01 | Transfer decreases source balance and increases target balance | `routes/transactions.py:73-74` | High |
| AC-007-02 | Returns 201 with success message and new source balance | `routes/transactions.py:93` | High |
| AC-007-03 | Amount must be greater than zero; returns 400 otherwise | `routes/transactions.py:62-63` | High |
| AC-007-04 | Insufficient funds (source balance < amount) returns 400 | `routes/transactions.py:65-66` | High |
| AC-007-05 | Target account must exist; returns 404 otherwise | `routes/transactions.py:67-69` | High |
| AC-007-06 | Self-transfer (same account) is rejected with 400 | `routes/transactions.py:70-71` | High |
| AC-007-07 | Creates two TRANSFER transaction records (one per account) with cross-references | `routes/transactions.py:76-91` | High |
| AC-007-08 | Sender transaction description includes target account number | `routes/transactions.py:81` | High |
| AC-007-09 | Receiver transaction description includes source account number | `routes/transactions.py:88` | High |
| AC-007-10 | Requires authentication via PIN headers | `auth.py:8` | High |

### Anomalies Detected

[ANOMALY id=ANO-026 source=routes/transactions.py:60-93]
No transfer limit per transaction or per day.
Question: Should transfer limits exist?
Recommendation: Add configurable transfer limits.
[/ANOMALY]

[ANOMALY id=ANO-027 source=routes/transactions.py:65-69]
Balance check occurs before target account lookup — insufficient funds error returned before checking if target exists.
Question: Is this error priority order intentional?
Recommendation: Check target account first for better UX.
[/ANOMALY]

[ANOMALY id=ANO-028 source=routes/transactions.py:73-74]
No concurrency control on dual balance update — concurrent transfers could cause inconsistent balances.
Question: Could concurrent transfers cause data corruption?
Recommendation: Add database-level locking.
[/ANOMALY]

---

## US-008: PIN Authentication (inferred)

**Confidence**: High
**Source**: `auth.py:8-17`

**As an** account holder
**I want to** authenticate with my account number and PIN
**So that** [HUMAN_INPUT id=HI-008 source=auth.py:8-17]
Why does the user need PIN authentication? To prove identity before accessing account operations?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-008-01 | Authentication requires x-account-number and x-pin HTTP headers | `auth.py:8` | High |
| AC-008-02 | Returns 401 with "Invalid credentials" if account not found | `auth.py:13-14` | High |
| AC-008-03 | Returns 401 with "Invalid credentials" if PIN does not match | `auth.py:15-16` | High |
| AC-008-04 | Same error message for missing account and wrong PIN (no enumeration) | `auth.py:14,16` | High |
| AC-008-05 | PIN comparison is plain text equality check | `auth.py:15` | High |
| AC-008-06 | On success, returns the Account ORM object for use by downstream handlers | `auth.py:17` | High |

### Anomalies Detected

[ANOMALY id=ANO-029 source=auth.py:8-17]
No rate limiting on authentication attempts — unlimited failed PIN tries allowed.
Question: How many failed attempts before lockout?
Recommendation: Add rate limiting or progressive delays.
[/ANOMALY]

[ANOMALY id=ANO-030 source=auth.py:15]
PIN compared as plain text — not using constant-time comparison.
Question: Is this intentional for a demo?
Recommendation: Hash PINs and use constant-time comparison.
[/ANOMALY]

[ANOMALY id=ANO-031 source=auth.py:8]
No session or token mechanism — every request requires sending PIN in headers.
Question: Should the API use JWT or session tokens instead of per-request PIN?
Recommendation: Consider token-based auth.
[/ANOMALY]
