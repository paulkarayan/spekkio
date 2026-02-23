# Inferred Specification

**Project**: ATM API
**Extracted**: 2026-02-22
**Status**: Draft -- requires human review

---

## US-001: Health Check (inferred)

**Confidence**: High
**Source**: `GET /health` -- `main.py:14-15`

**As a** system operator
**I want to** check if the ATM API is running
**So that** [NEEDS HUMAN INPUT: why? monitoring? load balancer health probe?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-001-01 | GET /health returns 200 with `{"status": "ok"}` | `main.py:14-15` | High |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| Health check does not verify database connectivity | Should it verify the DB is reachable? | Consider adding a DB ping to the health check |

---

## US-002: Account Creation (inferred)

**Confidence**: High
**Source**: `POST /accounts/` -- `routes/accounts.py:26-38`

**As a** new customer
**I want to** create a bank account with my name and a PIN
**So that** [NEEDS HUMAN INPUT: why?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-002-01 | Account is created with account_number, holder_name, and pin; returns 201 with account details | `routes/accounts.py:26-38` | High |
| AC-002-02 | New account starts with balance of 0.0 | `models.py:22` | High |
| AC-002-03 | Duplicate account_number is rejected with 400 | `routes/accounts.py:27-29` | High |
| AC-002-04 | PIN is stored as plain text (no hashing) | `routes/accounts.py:33` | High |
| AC-002-05 | Response excludes PIN field (AccountResponse model) | `routes/accounts.py:18-23` | High |
| AC-002-06 | No validation on account_number format | `routes/accounts.py:12-15` | Medium |
| AC-002-07 | No validation on PIN complexity or length | `routes/accounts.py:12-15` | Medium |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| PIN stored as plain text in database | Is this intentional for a demo, or a security bug? | Hash PINs with bcrypt or similar |
| No validation on account_number format | Should account numbers follow a specific format? | Add regex or length validation |
| No validation on PIN length or complexity | Should PINs be exactly 4 digits? | Add PIN format constraint |
| No validation on holder_name | Should empty names be rejected? | Add minimum length validation |

---

## US-003: Balance Inquiry (inferred)

**Confidence**: High
**Source**: `GET /accounts/balance` -- `routes/accounts.py:42-43`

**As an** account holder
**I want to** check my account balance
**So that** [NEEDS HUMAN INPUT: why?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-003-01 | Returns account_number and balance for authenticated user | `routes/accounts.py:42-43` | High |
| AC-003-02 | Requires valid x-account-number and x-pin headers | `auth.py:8-17` | High |
| AC-003-03 | Returns 401 for invalid credentials (wrong PIN or nonexistent account) | `auth.py:13-16` | High |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| No rate limiting on PIN attempts | Is brute-force protection needed? | Add rate limiting or account lockout after N failed attempts |

---

## US-004: Transaction History (inferred)

**Confidence**: High
**Source**: `GET /accounts/history` -- `routes/accounts.py:47-63`

**As an** account holder
**I want to** view my transaction history
**So that** [NEEDS HUMAN INPUT: why?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-004-01 | Returns list of transactions for the authenticated account | `routes/accounts.py:48-63` | High |
| AC-004-02 | Transactions are ordered by timestamp descending (newest first) | `routes/accounts.py:52` | High |
| AC-004-03 | Each transaction includes id, type, amount, timestamp (ISO 8601), and description | `routes/accounts.py:55-61` | High |
| AC-004-04 | Requires valid x-account-number and x-pin headers | `auth.py:8-17` | High |
| AC-004-05 | Returns 401 for invalid credentials | `auth.py:13-16` | High |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| No pagination -- returns all transactions | Will this cause performance issues with many transactions? | Add limit/offset or cursor-based pagination |

---

## US-005: Deposit Funds (inferred)

**Confidence**: High
**Source**: `POST /transactions/deposit` -- `routes/transactions.py:26-38`

**As an** account holder
**I want to** deposit money into my account
**So that** [NEEDS HUMAN INPUT: why?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-005-01 | Deposit increases account balance by the specified amount | `routes/transactions.py:29` | High |
| AC-005-02 | Returns 201 with success message and new balance | `routes/transactions.py:38` | High |
| AC-005-03 | Amount must be greater than zero; returns 400 otherwise | `routes/transactions.py:27-28` | High |
| AC-005-04 | Creates a DEPOSIT transaction record with description | `routes/transactions.py:30-35` | High |
| AC-005-05 | Requires authentication via PIN headers | `auth.py:8-17` | High |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| No maximum deposit limit | Should there be a per-transaction or daily deposit cap? | Consider adding deposit limits |
| Float used for monetary amounts | Could floating-point rounding cause balance discrepancies? | Consider using Decimal or integer cents |

---

## US-006: Withdraw Funds (inferred)

**Confidence**: High
**Source**: `POST /transactions/withdraw` -- `routes/transactions.py:42-57`

**As an** account holder
**I want to** withdraw money from my account
**So that** [NEEDS HUMAN INPUT: why?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-006-01 | Withdrawal decreases account balance by the specified amount | `routes/transactions.py:48` | High |
| AC-006-02 | Returns 201 with success message and new balance | `routes/transactions.py:57` | High |
| AC-006-03 | Amount must be greater than zero; returns 400 otherwise | `routes/transactions.py:43-44` | High |
| AC-006-04 | Insufficient funds (balance < amount) returns 400 | `routes/transactions.py:46-47` | High |
| AC-006-05 | Creates a WITHDRAWAL transaction record with description | `routes/transactions.py:49-54` | High |
| AC-006-06 | Requires authentication via PIN headers | `auth.py:8-17` | High |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| No withdrawal limit per transaction or per day | Should ATM-style withdrawal limits exist? | Add configurable withdrawal limits |
| No concurrency control on balance check and update | Could concurrent withdrawals cause overdraft? | Add optimistic locking or SELECT FOR UPDATE |
| Float used for monetary amounts | Could floating-point rounding cause balance discrepancies? | Consider using Decimal or integer cents |

---

## US-007: Transfer Funds (inferred)

**Confidence**: High
**Source**: `POST /transactions/transfer` -- `routes/transactions.py:61-93`

**As an** account holder
**I want to** transfer money to another account
**So that** [NEEDS HUMAN INPUT: why?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-007-01 | Transfer decreases source balance and increases target balance by the specified amount | `routes/transactions.py:73-74` | High |
| AC-007-02 | Returns 201 with success message and new source balance | `routes/transactions.py:93` | High |
| AC-007-03 | Amount must be greater than zero; returns 400 otherwise | `routes/transactions.py:62-63` | High |
| AC-007-04 | Insufficient funds (source balance < amount) returns 400 | `routes/transactions.py:65-66` | High |
| AC-007-05 | Target account must exist; returns 404 otherwise | `routes/transactions.py:67-69` | High |
| AC-007-06 | Self-transfer (same account) is rejected with 400 | `routes/transactions.py:70-71` | High |
| AC-007-07 | Creates two TRANSFER transaction records (one per account) with cross-references | `routes/transactions.py:76-91` | High |
| AC-007-08 | Sender transaction description includes target account number | `routes/transactions.py:81` | High |
| AC-007-09 | Receiver transaction description includes source account number | `routes/transactions.py:88` | High |
| AC-007-10 | Requires authentication via PIN headers | `auth.py:8-17` | High |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| No transfer limit per transaction or per day | Should transfer limits exist? | Add configurable transfer limits |
| Balance check occurs before target account lookup | Is the error priority order intentional? | Consider checking target account first for better UX |
| No concurrency control on dual balance update | Could concurrent transfers cause inconsistent balances? | Add database-level locking |
| Float used for monetary amounts | Could floating-point rounding cause balance discrepancies? | Consider using Decimal or integer cents |

---

## US-008: PIN Authentication (inferred)

**Confidence**: High
**Source**: `auth.py:8-17`

**As an** account holder
**I want to** authenticate with my account number and PIN
**So that** [NEEDS HUMAN INPUT: why? -- to prove identity before accessing account operations]

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

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| No rate limiting on authentication attempts | How many failed attempts before lockout? | Add rate limiting or progressive delays |
| PIN compared as plain text | Is this intentional for a demo? | Hash PINs and use constant-time comparison |
| No session or token mechanism | Should the API use tokens instead of per-request PIN? | Consider JWT or session-based auth |
