# Inferred Specification

**Project**: Todo API
**Extracted**: 2026-02-28
**Status**: Draft -- requires human review

---

## US-001: Health Check (inferred)

**Confidence**: High
**Source**: `GET /health` -- `app.py:15-16`

**As a** system operator
**I want to** check if the Todo API is running
**So that** [HUMAN_INPUT id=HI-001 source=app.py:15-16]
Why does the user need this capability? Monitoring? Load balancer probe?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-001-01 | GET /health returns 200 with `{"status": "ok"}` | `app.py:15-16` | High |

### Anomalies Detected

None for this story.

---

## US-002: User Registration (inferred)

**Confidence**: High
**Source**: `POST /users` -- `app.py:21-33`

**As a** new user
**I want to** create an account with my name, email, and password
**So that** [HUMAN_INPUT id=HI-002 source=app.py:21-33]
Why does the user need to register? What capabilities does registration unlock?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-002-01 | User is created with name, email, and password; returns 201 | `app.py:24-32` | High |
| AC-002-02 | Response includes id, name, email but NOT password | `app.py:32` | High |
| AC-002-03 | Password stored as plain text (no hashing) | `app.py:28` | High |
| AC-002-04 | Duplicate emails are allowed (no uniqueness check) | `app.py:23` | High |
| AC-002-05 | Missing required fields cause 500 error (unhandled KeyError) | `app.py:25-28` | High |

### Anomalies Detected

[ANOMALY id=ANO-016 source=app.py:28]
Password stored as plain text — no hashing applied.
Question: Is this intentional for a prototype?
Recommendation: Hash passwords with bcrypt or argon2.
[/ANOMALY]

[ANOMALY id=ANO-017 source=app.py:23]
No duplicate email check — multiple accounts with same email allowed.
Question: Should emails be unique per user?
Recommendation: Add unique constraint and pre-insert check.
[/ANOMALY]

[ANOMALY id=ANO-018 source=app.py:25-28]
Missing required fields cause unhandled KeyError resulting in 500 error.
Question: Should missing fields return 400 with descriptive error?
Recommendation: Add input validation and proper error handling.
[/ANOMALY]

[ANOMALY id=ANO-019 source=app.py:7]
SECRET_KEY hardcoded in source code: "super-secret-key-123".
Question: Should this come from an environment variable?
Recommendation: Move to env var or config file, never commit secrets.
[/ANOMALY]

---

## US-003: User Login (inferred)

**Confidence**: High
**Source**: `POST /login` -- `app.py:36-43`

**As a** registered user
**I want to** log in with my email and password
**So that** [HUMAN_INPUT id=HI-003 source=app.py:36-43]
Why does the user need to log in? What does the returned token enable?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-003-01 | Successful login returns 200 with `{"token": user_id}` | `app.py:42` | High |
| AC-003-02 | Wrong email or password returns 401 | `app.py:40-41` | High |
| AC-003-03 | "Token" is actually the user's integer ID, not a real token | `app.py:42` | High |
| AC-003-04 | Password compared as plain text equality | `app.py:40` | High |

### Anomalies Detected

[ANOMALY id=ANO-020 source=app.py:42]
"Token" returned is just the user ID integer — not a real authentication token.
Question: Should this use JWT or session-based auth?
Recommendation: Implement proper token-based authentication.
[/ANOMALY]

[ANOMALY id=ANO-021 source=app.py:40]
Plain text password comparison — no hashing.
Question: Is this intentional for a prototype?
Recommendation: Compare hashed passwords using constant-time comparison.
[/ANOMALY]

[ANOMALY id=ANO-022 source=app.py:36-43]
No rate limiting on login attempts — brute-force possible.
Question: Should there be brute-force protection?
Recommendation: Add rate limiting or account lockout.
[/ANOMALY]

---

## US-004: List My Todos (inferred)

**Confidence**: High
**Source**: `GET /todos` -- `app.py:48-54`

**As a** registered user
**I want to** see all my todo items
**So that** [HUMAN_INPUT id=HI-004 source=app.py:48-54]
Why does the user need to list their todos?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-004-01 | Returns list of todos for the given X-User-Id | `app.py:52-53` | High |
| AC-004-02 | Requires X-User-Id header; returns 401 if missing | `app.py:50-51` | High |
| AC-004-03 | X-User-Id is not validated against database — any integer accepted | `app.py:52` | High |

### Anomalies Detected

[ANOMALY id=ANO-023 source=app.py:52]
X-User-Id header not validated — any integer accepted, even non-existent users.
Question: Should the user ID be verified as a real user?
Recommendation: Validate user exists before querying.
[/ANOMALY]

---

## US-005: Create a Todo (inferred)

**Confidence**: High
**Source**: `POST /todos` -- `app.py:57-72`

**As a** registered user
**I want to** create a new todo item with title, description, priority, and due date
**So that** [HUMAN_INPUT id=HI-005 source=app.py:57-72]
Why does the user need to create todos?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-005-01 | Todo is created with title, optional description, priority, and due_date | `app.py:63-69` | High |
| AC-005-02 | Returns 201 with the created todo object | `app.py:72` | High |
| AC-005-03 | Requires X-User-Id header | `app.py:59-60` | High |
| AC-005-04 | Priority defaults to "medium" but accepts any string | `app.py:67` | High |
| AC-005-05 | due_date parsed via datetime.fromisoformat(); invalid format causes 500 | `app.py:68` | High |
| AC-005-06 | Missing title causes 500 error (unhandled KeyError) | `app.py:63` | High |

### Anomalies Detected

[ANOMALY id=ANO-024 source=app.py:67]
No validation on priority values — any string accepted, not limited to low/medium/high.
Question: Should priority be constrained to an enum?
Recommendation: Validate against allowed values.
[/ANOMALY]

[ANOMALY id=ANO-025 source=app.py:68]
Invalid due_date format causes unhandled ValueError (500 error).
Question: Should invalid dates return 400 with a helpful message?
Recommendation: Add try/except and return proper error response.
[/ANOMALY]

---

## US-006: Update a Todo (inferred)

**Confidence**: High
**Source**: `PUT /todos/<todo_id>` -- `app.py:75-93`

**As a** registered user
**I want to** update my todo (title, description, completion, priority)
**So that** [HUMAN_INPUT id=HI-006 source=app.py:75-93]
Why does the user need to update todos? Track progress?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-006-01 | Updates todo fields that are present in request body | `app.py:83-91` | High |
| AC-006-02 | Setting completed=true also sets completed_at timestamp | `app.py:88-89` | High |
| AC-006-03 | Returns 200 with updated todo object | `app.py:93` | High |
| AC-006-04 | Returns 404 if todo not found | `app.py:81-82` | High |
| AC-006-05 | Requires X-User-Id header | `app.py:77-78` | High |
| AC-006-06 | NO ownership check — any user can update any todo (IDOR) | `app.py:82` | High |

### Anomalies Detected

[ANOMALY id=ANO-026 source=app.py:82]
IDOR vulnerability: No check that todo.user_id matches requesting user.
Any authenticated user can update any other user's todo by knowing the ID.
Question: Is this a security bug?
Recommendation: Add ownership check — if todo.user_id != int(user_id): return 403.
[/ANOMALY]

---

## US-007: Delete a Todo (inferred)

**Confidence**: High
**Source**: `DELETE /todos/<todo_id>` -- `app.py:96-105`

**As a** registered user
**I want to** delete a todo item
**So that** [HUMAN_INPUT id=HI-007 source=app.py:96-105]
Why does the user need to delete todos?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-007-01 | Deletes the todo and returns 204 (no content) | `app.py:103-105` | High |
| AC-007-02 | Returns 404 if todo not found | `app.py:101-102` | High |
| AC-007-03 | Requires X-User-Id header | `app.py:98-99` | High |
| AC-007-04 | NO ownership check — any user can delete any todo (IDOR) | `app.py:103` | High |
| AC-007-05 | Hard delete — no soft-delete or undo mechanism | `app.py:103` | High |

### Anomalies Detected

[ANOMALY id=ANO-027 source=app.py:103]
IDOR vulnerability: No check that todo.user_id matches requesting user.
Any authenticated user can delete any other user's todo by knowing the ID.
Question: Is this a security bug?
Recommendation: Add ownership check before deletion.
[/ANOMALY]

[ANOMALY id=ANO-028 source=app.py:103-104]
Hard delete with no audit trail — deleted todos are unrecoverable.
Question: Should deleted todos be recoverable?
Recommendation: Consider soft-delete with a deleted_at column.
[/ANOMALY]

---

## US-008: Search Todos (inferred)

**Confidence**: High
**Source**: `GET /todos/search` -- `app.py:108-115`

**As a** registered user
**I want to** search my todos by title
**So that** [HUMAN_INPUT id=HI-008 source=app.py:108-115]
Why does the user need to search todos?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-008-01 | Searches todos by title using LIKE '%q%' pattern | `app.py:113` | High |
| AC-008-02 | Filters by user_id from X-User-Id header | `app.py:113` | High |
| AC-008-03 | Returns raw SQL rows (different format than other endpoints) | `app.py:114` | High |
| AC-008-04 | Requires X-User-Id header | `app.py:110-111` | High |
| AC-008-05 | Query parameter q defaults to empty string if not provided | `app.py:112` | High |

### Anomalies Detected

[ANOMALY id=ANO-029 source=app.py:113]
CRITICAL: SQL injection vulnerability. User input (both user_id and q) interpolated
directly into SQL query via f-string. An attacker can execute arbitrary SQL.
Question: Is this a critical security vulnerability that must be fixed immediately?
Recommendation: Use parameterized queries (db.text with :param syntax) immediately.
[/ANOMALY]

[ANOMALY id=ANO-030 source=app.py:108-115]
Search returns raw SQL result dicts, not ORM-based to_dict() output — inconsistent
response shape compared to other todo endpoints.
Question: Should search use the same response format?
Recommendation: Use ORM query with to_dict() for consistency.
[/ANOMALY]

[ANOMALY id=ANO-031 source=app.py:117]
Flask debug mode enabled in production entry point: `app.run(debug=True)`.
Question: Is this intentional for development only?
Recommendation: Disable debug mode for production; use environment variable.
[/ANOMALY]
