# Triage Summary

**Spec Directory**: /Users/pk/side/spekkio/specs/001-atm
**Generated**: 2026-02-28T19:06:44Z

## Overview

| Type | Count |
|------|-------|
| HUMAN_INPUT | 15 |
| ANOMALY | 40 |
| **Total** | **55** |

## Items Requiring Human Input

### HI-001
- **File**: spec.md (line 16)
- **Source**: `main.py:13-15`
- **Context**: Why does the user need this capability? Monitoring? Load balancer health probe?

### HI-002
- **File**: spec.md (line 43)
- **Source**: `routes/accounts.py:25-38`
- **Context**: Why does the user need to create an account? What is the onboarding flow?

### HI-003
- **File**: spec.md (line 95)
- **Source**: `routes/accounts.py:41-43`
- **Context**: Why does the user need to check their balance?

### HI-004
- **File**: spec.md (line 124)
- **Source**: `routes/accounts.py:46-63`
- **Context**: Why does the user need to view transaction history?

### HI-005
- **File**: spec.md (line 155)
- **Source**: `routes/transactions.py:25-38`
- **Context**: Why does the user need to deposit funds?

### HI-006
- **File**: spec.md (line 192)
- **Source**: `routes/transactions.py:41-57`
- **Context**: Why does the user need to withdraw funds?

### HI-007
- **File**: spec.md (line 230)
- **Source**: `routes/transactions.py:60-93`
- **Context**: Why does the user need to transfer funds between accounts?

### HI-008
- **File**: spec.md (line 278)
- **Source**: `auth.py:8-17`
- **Context**: Why does the user need PIN authentication? To prove identity before accessing account operations?

### HI-009
- **File**: checklists/extraction-review.md (line 40)
- **Source**: `database.py:4-8`
- **Context**: What is the intended deployment environment?
Why it matters: Determines if SQLite is acceptable or a real DB is needed.

### HI-010
- **File**: checklists/extraction-review.md (line 45)
- **Source**: `auth.py:8-17`
- **Context**: What are the regulatory requirements for PIN storage?
Why it matters: Determines if plain-text PIN is a compliance violation.

### HI-011
- **File**: checklists/extraction-review.md (line 50)
- **Source**: `routes/transactions.py:25-93`
- **Context**: What are the expected transaction volumes?
Why it matters: Affects pagination and concurrency decisions.

### HI-012
- **File**: checklists/extraction-review.md (line 55)
- **Source**: `routes/transactions.py:41-57`
- **Context**: Should there be daily withdrawal/transfer limits?
Why it matters: Common ATM requirement; not implemented.

### HI-013
- **File**: checklists/extraction-review.md (line 60)
- **Source**: `main.py:1-16`
- **Context**: Is this a demo/prototype or production-bound code?
Why it matters: Affects severity assessment of all anomalies.

### HI-014
- **File**: checklists/extraction-review.md (line 65)
- **Source**: `auth.py:8-17`
- **Context**: Who are the intended users (bank customers, internal staff, both)?
Why it matters: Affects auth and access control decisions.

### HI-015
- **File**: checklists/extraction-review.md (line 70)
- **Source**: `routes/transactions.py:25-93`
- **Context**: Should transactions support rollback or dispute?
Why it matters: No mechanism exists for reversing transactions.

## Anomalies Detected

### ANO-001
- **File**: inventory.yml (line 37)
- **Source**: `main.py:13-15`
- **Observation**: Health check does not verify database connectivity.
      Question: Should the health endpoint confirm the DB is reachable?
      Recommendation: Add a DB ping to the health check.

### ANO-002
- **File**: inventory.yml (line 90)
- **Source**: `routes/accounts.py:33`
- **Observation**: PIN is stored as plain text in the database.
      Question: Is this intentional for a demo, or a security bug?
      Recommendation: Hash PINs with bcrypt or argon2.

### ANO-003
- **File**: inventory.yml (line 96)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on account_number format — could be empty string, special characters, any length.
      Question: Should account numbers follow a specific format (e.g., numeric, fixed length)?
      Recommendation: Add regex or length validation.

### ANO-004
- **File**: inventory.yml (line 102)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on PIN complexity or length — could be empty string or single character.
      Question: Should PINs be required to be exactly 4 digits?
      Recommendation: Add PIN format constraint.

### ANO-005
- **File**: inventory.yml (line 108)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on holder_name — empty strings accepted.
      Question: Should holder names have a minimum length?
      Recommendation: Add minimum length validation.

### ANO-006
- **File**: inventory.yml (line 145)
- **Source**: `auth.py:8-17`
- **Observation**: No rate limiting on authentication attempts — unlimited failed PIN tries allowed.
      Question: Is brute-force protection needed?
      Recommendation: Add rate limiting or account lockout after N failed attempts.

### ANO-007
- **File**: inventory.yml (line 182)
- **Source**: `routes/accounts.py:46-63`
- **Observation**: No pagination support — returns all transactions without limit/offset.
      Question: Will this cause performance issues for accounts with many transactions?
      Recommendation: Add limit/offset or cursor-based pagination.

### ANO-008
- **File**: inventory.yml (line 230)
- **Source**: `routes/transactions.py:25-38`
- **Observation**: No maximum deposit limit — arbitrarily large amounts can be deposited.
      Question: Should there be a per-transaction or daily deposit cap?
      Recommendation: Add configurable deposit limits.

### ANO-009
- **File**: inventory.yml (line 236)
- **Source**: `models.py:22`
- **Observation**: Float used for monetary amounts — potential floating-point precision issues.
      Question: Could rounding cause balance discrepancies?
      Recommendation: Use Decimal or integer cents for monetary values.

### ANO-010
- **File**: inventory.yml (line 285)
- **Source**: `routes/transactions.py:45`
- **Observation**: No withdrawal limit per transaction or per day — can withdraw any amount up to full balance.
      Question: Should ATM-style withdrawal limits exist?
      Recommendation: Add configurable withdrawal limits.

### ANO-011
- **File**: inventory.yml (line 291)
- **Source**: `routes/transactions.py:46-48`
- **Observation**: No concurrency control on balance check and update — race condition possible.
      Question: Could concurrent withdrawals cause overdraft?
      Recommendation: Add optimistic locking or SELECT FOR UPDATE.

### ANO-012
- **File**: inventory.yml (line 349)
- **Source**: `routes/transactions.py:60-93`
- **Observation**: No transfer limit per transaction or per day.
      Question: Should transfer limits exist?
      Recommendation: Add configurable transfer limits.

### ANO-013
- **File**: inventory.yml (line 355)
- **Source**: `routes/transactions.py:65-69`
- **Observation**: Balance check occurs before target account lookup — error priority may confuse users.
      Question: Is this error ordering intentional?
      Recommendation: Check target account first for better UX.

### ANO-014
- **File**: inventory.yml (line 361)
- **Source**: `routes/transactions.py:73-74`
- **Observation**: No concurrency control on dual balance update — race condition on concurrent transfers.
      Question: Could concurrent transfers cause inconsistent balances?
      Recommendation: Add database-level locking.

### ANO-015
- **File**: spec.md (line 28)
- **Source**: `main.py:13-15`
- **Observation**: Health check does not verify database connectivity.
Question: Should it verify the DB is reachable?
Recommendation: Consider adding a DB ping to the health check.

### ANO-016
- **File**: spec.md (line 62)
- **Source**: `routes/accounts.py:33`
- **Observation**: PIN stored as plain text in database.
Question: Is this intentional for a demo, or a security bug?
Recommendation: Hash PINs with bcrypt or similar.

### ANO-016
- **File**: features/characterization/account-creation.feature (line 44)
- **Source**: `routes/accounts.py:33`
- **Observation**: PIN is stored as plain text in the database — no hashing applied.
  Question: Is this intentional for a demo, or a security bug?
  Recommendation: Hash PINs with bcrypt or similar.

### ANO-017
- **File**: spec.md (line 68)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on account_number format — accepts empty strings, special characters, any length.
Question: Should account numbers follow a specific format?
Recommendation: Add regex or length validation.

### ANO-017
- **File**: features/characterization/account-creation.feature (line 67)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on account_number format — empty strings and special characters accepted.
  Question: Should account numbers follow a specific format?
  Recommendation: Add regex or length validation.

### ANO-018
- **File**: spec.md (line 74)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on PIN complexity or length — single character or empty string accepted.
Question: Should PINs be exactly 4 digits?
Recommendation: Add PIN format constraint.

### ANO-018
- **File**: features/characterization/account-creation.feature (line 80)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on PIN complexity or length.
  Question: Should PINs be exactly 4 digits?
  Recommendation: Add PIN format constraint.

### ANO-019
- **File**: spec.md (line 80)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on holder_name — empty strings accepted.
Question: Should empty names be rejected?
Recommendation: Add minimum length validation.

### ANO-019
- **File**: features/characterization/account-creation.feature (line 93)
- **Source**: `routes/accounts.py:12-15`
- **Observation**: No validation on holder_name — empty strings accepted.
  Question: Should holder names have a minimum length?
  Recommendation: Add minimum length validation.

### ANO-020
- **File**: spec.md (line 109)
- **Source**: `auth.py:8-17`
- **Observation**: No rate limiting on PIN attempts — brute-force attack possible.
Question: Is brute-force protection needed?
Recommendation: Add rate limiting or account lockout after N failed attempts.

### ANO-021
- **File**: spec.md (line 140)
- **Source**: `routes/accounts.py:46-63`
- **Observation**: No pagination — returns all transactions without limit/offset.
Question: Will this cause performance issues with many transactions?
Recommendation: Add limit/offset or cursor-based pagination.

### ANO-021
- **File**: features/characterization/transaction-history.feature (line 51)
- **Source**: `routes/accounts.py:46-63`
- **Observation**: No pagination — returns all transactions without limit/offset.
  Question: Will this cause performance issues with many transactions?
  Recommendation: Add limit/offset or cursor-based pagination.

### ANO-022
- **File**: spec.md (line 171)
- **Source**: `routes/transactions.py:25-38`
- **Observation**: No maximum deposit limit — arbitrarily large amounts can be deposited.
Question: Should there be a per-transaction or daily deposit cap?
Recommendation: Consider adding deposit limits.

### ANO-023
- **File**: spec.md (line 177)
- **Source**: `models.py:22`
- **Observation**: Float used for monetary amounts — floating-point rounding may cause balance discrepancies.
Question: Could this cause real financial errors?
Recommendation: Use Decimal or integer cents.

### ANO-024
- **File**: spec.md (line 209)
- **Source**: `routes/transactions.py:45`
- **Observation**: No withdrawal limit per transaction or per day — can withdraw any amount up to full balance.
Question: Should ATM-style withdrawal limits exist?
Recommendation: Add configurable withdrawal limits.

### ANO-024
- **File**: features/characterization/withdrawal.feature (line 88)
- **Source**: `routes/transactions.py:45`
- **Observation**: No withdrawal limit per transaction or per day.
  Question: Should there be a maximum withdrawal amount (e.g., $500/day for ATM)?
  Recommendation: Add configurable withdrawal limits.

### ANO-025
- **File**: spec.md (line 215)
- **Source**: `routes/transactions.py:46-48`
- **Observation**: No concurrency control on balance check and update — concurrent withdrawals could cause overdraft.
Question: Could concurrent requests cause negative balances?
Recommendation: Add optimistic locking or SELECT FOR UPDATE.

### ANO-026
- **File**: spec.md (line 251)
- **Source**: `routes/transactions.py:60-93`
- **Observation**: No transfer limit per transaction or per day.
Question: Should transfer limits exist?
Recommendation: Add configurable transfer limits.

### ANO-027
- **File**: spec.md (line 257)
- **Source**: `routes/transactions.py:65-69`
- **Observation**: Balance check occurs before target account lookup — insufficient funds error returned before checking if target exists.
Question: Is this error priority order intentional?
Recommendation: Check target account first for better UX.

### ANO-027
- **File**: features/characterization/transfer.feature (line 126)
- **Source**: `routes/transactions.py:65-69`
- **Observation**: Balance check occurs before target account lookup.
  Question: Is this error priority order intentional?
  Recommendation: Check target account first for better UX.

### ANO-028
- **File**: spec.md (line 263)
- **Source**: `routes/transactions.py:73-74`
- **Observation**: No concurrency control on dual balance update — concurrent transfers could cause inconsistent balances.
Question: Could concurrent transfers cause data corruption?
Recommendation: Add database-level locking.

### ANO-029
- **File**: spec.md (line 295)
- **Source**: `auth.py:8-17`
- **Observation**: No rate limiting on authentication attempts — unlimited failed PIN tries allowed.
Question: How many failed attempts before lockout?
Recommendation: Add rate limiting or progressive delays.

### ANO-029
- **File**: features/characterization/authentication.feature (line 64)
- **Source**: `auth.py:8-17`
- **Observation**: No rate limiting on authentication attempts — unlimited failed PIN tries allowed.
  Question: How many failed attempts before lockout?
  Recommendation: Add rate limiting or progressive delays.

### ANO-030
- **File**: spec.md (line 301)
- **Source**: `auth.py:15`
- **Observation**: PIN compared as plain text — not using constant-time comparison.
Question: Is this intentional for a demo?
Recommendation: Hash PINs and use constant-time comparison.

### ANO-030
- **File**: features/characterization/authentication.feature (line 52)
- **Source**: `auth.py:15`
- **Observation**: PIN compared as plain text equality — not using constant-time comparison.
  Question: Is this intentional for a demo?
  Recommendation: Hash PINs and use constant-time comparison.

### ANO-031
- **File**: spec.md (line 307)
- **Source**: `auth.py:8`
- **Observation**: No session or token mechanism — every request requires sending PIN in headers.
Question: Should the API use JWT or session tokens instead of per-request PIN?
Recommendation: Consider token-based auth.
