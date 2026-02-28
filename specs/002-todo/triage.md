# Triage Summary

**Spec Directory**: /Users/pk/side/spekkio/specs/002-todo
**Generated**: 2026-02-28T19:06:44Z

## Overview

| Type | Count |
|------|-------|
| HUMAN_INPUT | 12 |
| ANOMALY | 40 |
| **Total** | **52** |

## Items Requiring Human Input

### HI-001
- **File**: spec.md (line 16)
- **Source**: `app.py:15-16`
- **Context**: Why does the user need this capability? Monitoring? Load balancer probe?

### HI-002
- **File**: spec.md (line 39)
- **Source**: `app.py:21-33`
- **Context**: Why does the user need to register? What capabilities does registration unlock?

### HI-003
- **File**: spec.md (line 88)
- **Source**: `app.py:36-43`
- **Context**: Why does the user need to log in? What does the returned token enable?

### HI-004
- **File**: spec.md (line 130)
- **Source**: `app.py:48-54`
- **Context**: Why does the user need to list their todos?

### HI-005
- **File**: spec.md (line 159)
- **Source**: `app.py:57-72`
- **Context**: Why does the user need to create todos?

### HI-006
- **File**: spec.md (line 197)
- **Source**: `app.py:75-93`
- **Context**: Why does the user need to update todos? Track progress?

### HI-007
- **File**: spec.md (line 230)
- **Source**: `app.py:96-105`
- **Context**: Why does the user need to delete todos?

### HI-008
- **File**: spec.md (line 268)
- **Source**: `app.py:108-115`
- **Context**: Why does the user need to search todos?

### HI-009
- **File**: checklists/extraction-review.md (line 40)
- **Source**: `app.py:1-117`
- **Context**: Is this a prototype/demo or production-bound code?
Why it matters: Affects severity of all anomalies, especially security ones.

### HI-010
- **File**: checklists/extraction-review.md (line 45)
- **Source**: `app.py:7`
- **Context**: Where should the SECRET_KEY and DB configuration come from?
Why it matters: Hardcoded secrets are a security risk in any shared repository.

### HI-011
- **File**: checklists/extraction-review.md (line 50)
- **Source**: `app.py:48-54`
- **Context**: Should the API support pagination for todo lists?
Why it matters: Performance degrades with large numbers of todos.

### HI-012
- **File**: checklists/extraction-review.md (line 55)
- **Source**: `models.py:19-33`
- **Context**: Should todos support additional fields (tags, categories, attachments)?
Why it matters: Affects data model and API design decisions.

## Anomalies Detected

### ANO-001
- **File**: inventory.yml (line 82)
- **Source**: `app.py:28`
- **Observation**: Password stored as plain text — no hashing.
      Question: Is this intentional for a prototype?
      Recommendation: Hash passwords with bcrypt or argon2.

### ANO-002
- **File**: inventory.yml (line 88)
- **Source**: `app.py:23`
- **Observation**: No duplicate email check — multiple accounts with same email allowed.
      Question: Should emails be unique?
      Recommendation: Add unique constraint on email column and check before insert.

### ANO-003
- **File**: inventory.yml (line 94)
- **Source**: `app.py:21-33`
- **Observation**: No input validation — missing fields cause unhandled KeyError (500).
      Question: Should missing fields return 400 with helpful message?
      Recommendation: Validate required fields and return proper error responses.

### ANO-004
- **File**: inventory.yml (line 100)
- **Source**: `app.py:7`
- **Observation**: Hardcoded SECRET_KEY in source code: "super-secret-key-123".
      Question: Should this come from environment variables?
      Recommendation: Move secret to environment variable or config file.

### ANO-005
- **File**: inventory.yml (line 145)
- **Source**: `app.py:42`
- **Observation**: "Token" is just the user ID — not a real authentication token.
      Question: Should this use JWT or session tokens?
      Recommendation: Implement proper token-based auth.

### ANO-006
- **File**: inventory.yml (line 151)
- **Source**: `app.py:40`
- **Observation**: Plain text password comparison — no hashing.
      Question: Is this intentional for a prototype?
      Recommendation: Compare hashed passwords.

### ANO-007
- **File**: inventory.yml (line 157)
- **Source**: `app.py:36-43`
- **Observation**: No rate limiting on login attempts.
      Question: Should there be brute-force protection?
      Recommendation: Add rate limiting or progressive delays.

### ANO-008
- **File**: inventory.yml (line 194)
- **Source**: `app.py:50`
- **Observation**: X-User-Id header not validated against database — any integer accepted.
      Question: Should the user ID be verified as a real user?
      Recommendation: Validate user exists before querying todos.

### ANO-009
- **File**: inventory.yml (line 251)
- **Source**: `app.py:67`
- **Observation**: No validation on priority values — accepts any string, not just low/medium/high.
      Question: Should priority be constrained to an enum?
      Recommendation: Validate against allowed values.

### ANO-010
- **File**: inventory.yml (line 257)
- **Source**: `app.py:68`
- **Observation**: Invalid due_date format causes unhandled ValueError (500 error).
      Question: Should invalid dates return 400 with helpful message?
      Recommendation: Wrap in try/except and return proper error.

### ANO-011
- **File**: inventory.yml (line 317)
- **Source**: `app.py:82`
- **Observation**: IDOR vulnerability: No check that todo.user_id matches requesting user.
      Any authenticated user can update any other user's todo by ID.
      Question: Is this a security bug?
      Recommendation: Add ownership check: if todo.user_id != int(user_id): return 403.

### ANO-012
- **File**: inventory.yml (line 361)
- **Source**: `app.py:103`
- **Observation**: IDOR vulnerability: No check that todo.user_id matches requesting user.
      Any authenticated user can delete any other user's todo by ID.
      Question: Is this a security bug?
      Recommendation: Add ownership check before deletion.

### ANO-013
- **File**: inventory.yml (line 368)
- **Source**: `app.py:103-104`
- **Observation**: Hard delete — no soft-delete or audit trail.
      Question: Should deleted todos be recoverable?
      Recommendation: Consider soft-delete with a deleted_at column.

### ANO-014
- **File**: inventory.yml (line 409)
- **Source**: `app.py:113`
- **Observation**: SQL INJECTION: User input interpolated directly into SQL query via f-string.
      Both user_id and q parameters are unsanitized.
      Question: Is this a critical security vulnerability?
      Recommendation: Use parameterized queries immediately.

### ANO-015
- **File**: inventory.yml (line 416)
- **Source**: `app.py:108-115`
- **Observation**: Search returns raw SQL rows, not ORM objects — different response shape than other endpoints.
      Question: Should search use the same to_dict() format?
      Recommendation: Use ORM query for consistency.

### ANO-016
- **File**: spec.md (line 55)
- **Source**: `app.py:28`
- **Observation**: Password stored as plain text — no hashing applied.
Question: Is this intentional for a prototype?
Recommendation: Hash passwords with bcrypt or argon2.

### ANO-016
- **File**: features/characterization/user-registration.feature (line 34)
- **Source**: `app.py:28`
- **Observation**: Password stored as plain text — no hashing applied.
  Question: Is this intentional for a prototype?
  Recommendation: Hash passwords with bcrypt or argon2.

### ANO-017
- **File**: spec.md (line 61)
- **Source**: `app.py:23`
- **Observation**: No duplicate email check — multiple accounts with same email allowed.
Question: Should emails be unique per user?
Recommendation: Add unique constraint and pre-insert check.

### ANO-017
- **File**: features/characterization/user-registration.feature (line 48)
- **Source**: `app.py:23`
- **Observation**: No duplicate email check — multiple accounts with same email allowed.
  Question: Should emails be unique?
  Recommendation: Add unique constraint on email column.

### ANO-018
- **File**: spec.md (line 67)
- **Source**: `app.py:25-28`
- **Observation**: Missing required fields cause unhandled KeyError resulting in 500 error.
Question: Should missing fields return 400 with descriptive error?
Recommendation: Add input validation and proper error handling.

### ANO-018
- **File**: features/characterization/user-registration.feature (line 62)
- **Source**: `app.py:25-28`
- **Observation**: Missing required fields cause unhandled KeyError (500 error).
  Question: Should missing fields return 400?
  Recommendation: Add input validation.

### ANO-019
- **File**: spec.md (line 73)
- **Source**: `app.py:7`
- **Observation**: SECRET_KEY hardcoded in source code: "super-secret-key-123".
Question: Should this come from an environment variable?
Recommendation: Move to env var or config file, never commit secrets.

### ANO-020
- **File**: spec.md (line 103)
- **Source**: `app.py:42`
- **Observation**: "Token" returned is just the user ID integer — not a real authentication token.
Question: Should this use JWT or session-based auth?
Recommendation: Implement proper token-based authentication.

### ANO-020
- **File**: features/characterization/login.feature (line 43)
- **Source**: `app.py:42`
- **Observation**: "Token" is just the user ID integer — not a real authentication token.
  Question: Should this use JWT or session-based auth?
  Recommendation: Implement proper token-based authentication.

### ANO-021
- **File**: spec.md (line 109)
- **Source**: `app.py:40`
- **Observation**: Plain text password comparison — no hashing.
Question: Is this intentional for a prototype?
Recommendation: Compare hashed passwords using constant-time comparison.

### ANO-022
- **File**: spec.md (line 115)
- **Source**: `app.py:36-43`
- **Observation**: No rate limiting on login attempts — brute-force possible.
Question: Should there be brute-force protection?
Recommendation: Add rate limiting or account lockout.

### ANO-023
- **File**: spec.md (line 144)
- **Source**: `app.py:52`
- **Observation**: X-User-Id header not validated — any integer accepted, even non-existent users.
Question: Should the user ID be verified as a real user?
Recommendation: Validate user exists before querying.

### ANO-024
- **File**: spec.md (line 176)
- **Source**: `app.py:67`
- **Observation**: No validation on priority values — any string accepted, not limited to low/medium/high.
Question: Should priority be constrained to an enum?
Recommendation: Validate against allowed values.

### ANO-024
- **File**: features/characterization/todo-crud.feature (line 47)
- **Source**: `app.py:67`
- **Observation**: No validation on priority values — any string accepted.
  Question: Should priority be constrained to an enum?
  Recommendation: Validate against allowed values (low/medium/high).

### ANO-025
- **File**: spec.md (line 182)
- **Source**: `app.py:68`
- **Observation**: Invalid due_date format causes unhandled ValueError (500 error).
Question: Should invalid dates return 400 with a helpful message?
Recommendation: Add try/except and return proper error response.

### ANO-025
- **File**: features/characterization/todo-crud.feature (line 63)
- **Source**: `app.py:68`
- **Observation**: Invalid due_date format causes unhandled ValueError (500 error).
  Question: Should invalid dates return 400?
  Recommendation: Add try/except with proper error response.

### ANO-026
- **File**: spec.md (line 214)
- **Source**: `app.py:82`
- **Observation**: IDOR vulnerability: No check that todo.user_id matches requesting user.
Any authenticated user can update any other user's todo by knowing the ID.
Question: Is this a security bug?
Recommendation: Add ownership check — if todo.user_id != int(user_id): return 403.

### ANO-026
- **File**: features/characterization/todo-crud.feature (line 113)
- **Source**: `app.py:82`
- **Observation**: IDOR vulnerability: No ownership check. Any user can update any todo.
  Question: Is this a security bug?
  Recommendation: Add check that todo.user_id matches requesting user.

### ANO-027
- **File**: spec.md (line 246)
- **Source**: `app.py:103`
- **Observation**: IDOR vulnerability: No check that todo.user_id matches requesting user.
Any authenticated user can delete any other user's todo by knowing the ID.
Question: Is this a security bug?
Recommendation: Add ownership check before deletion.

### ANO-027
- **File**: features/characterization/todo-crud.feature (line 143)
- **Source**: `app.py:103`
- **Observation**: IDOR vulnerability: No ownership check. Any user can delete any todo.
  Question: Is this a security bug?
  Recommendation: Add ownership check before deletion.

### ANO-028
- **File**: spec.md (line 253)
- **Source**: `app.py:103-104`
- **Observation**: Hard delete with no audit trail — deleted todos are unrecoverable.
Question: Should deleted todos be recoverable?
Recommendation: Consider soft-delete with a deleted_at column.

### ANO-029
- **File**: spec.md (line 284)
- **Source**: `app.py:113`
- **Observation**: CRITICAL: SQL injection vulnerability. User input (both user_id and q) interpolated
directly into SQL query via f-string. An attacker can execute arbitrary SQL.
Question: Is this a critical security vulnerability that must be fixed immediately?
Recommendation: Use parameterized queries (db.text with :param syntax) immediately.

### ANO-029
- **File**: features/characterization/search.feature (line 38)
- **Source**: `app.py:113`
- **Observation**: CRITICAL: SQL injection vulnerability. User input interpolated directly
  into SQL query via f-string. An attacker can execute arbitrary SQL.
  Question: Is this a critical security vulnerability?
  Recommendation: Use parameterized queries immediately.

### ANO-030
- **File**: spec.md (line 291)
- **Source**: `app.py:108-115`
- **Observation**: Search returns raw SQL result dicts, not ORM-based to_dict() output — inconsistent
response shape compared to other todo endpoints.
Question: Should search use the same response format?
Recommendation: Use ORM query with to_dict() for consistency.

### ANO-031
- **File**: spec.md (line 298)
- **Source**: `app.py:117`
- **Observation**: Flask debug mode enabled in production entry point: `app.run(debug=True)`.
Question: Is this intentional for development only?
Recommendation: Disable debug mode for production; use environment variable.
