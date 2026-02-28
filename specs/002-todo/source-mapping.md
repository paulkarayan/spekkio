# Source Mapping

**Project**: Todo API
**Extracted**: 2026-02-28

---

## Table 1: Scenario to Source

| Scenario | Source File | Lines | Function |
|----------|------------|-------|----------|
| Health endpoint returns OK | `app.py` | 15-16 | `health` |
| Successfully create a new user | `app.py` | 21-33 | `create_user` |
| Response excludes password | `app.py` | 32 | `create_user` |
| Password stored as plain text | `app.py` | 28 | `create_user` |
| Duplicate emails are allowed | `app.py` | 23 | `create_user` |
| Missing fields cause server error | `app.py` | 25-28 | `create_user` |
| Successful login returns user ID as token | `app.py` | 36-43 | `login` |
| Wrong password returns 401 | `app.py` | 40-41 | `login` |
| Nonexistent email returns 401 | `app.py` | 40 | `login` |
| Token is actually the user ID | `app.py` | 42 | `login` |
| List todos for a user | `app.py` | 48-54 | `list_todos` |
| Missing X-User-Id returns 401 (list) | `app.py` | 50-51 | `list_todos` |
| Create a todo with all fields | `app.py` | 57-72 | `create_todo` |
| Any string accepted as priority | `app.py` | 67 | `create_todo` |
| Invalid due_date causes server error | `app.py` | 68 | `create_todo` |
| Update todo title | `app.py` | 75-93 | `update_todo` |
| Mark todo as completed sets completed_at | `app.py` | 88-89 | `update_todo` |
| Update nonexistent todo returns 404 | `app.py` | 81-82 | `update_todo` |
| Any user can update another user's todo (IDOR) | `app.py` | 82 | `update_todo` |
| Delete a todo returns 204 | `app.py` | 96-105 | `delete_todo` |
| Delete nonexistent todo returns 404 | `app.py` | 101-102 | `delete_todo` |
| Any user can delete another user's todo (IDOR) | `app.py` | 103 | `delete_todo` |
| Search todos by title | `app.py` | 108-115 | `search_todos` |
| Empty query returns all todos | `app.py` | 112 | `search_todos` |
| Missing X-User-Id returns 401 (search) | `app.py` | 110-111 | `search_todos` |
| Search query is vulnerable to SQL injection | `app.py` | 113 | `search_todos` |

---

## Table 2: Source to Scenario Coverage

| File | Functions | Scenarios | Coverage |
|------|-----------|-----------|----------|
| `app.py` | 8 (`health`, `create_user`, `login`, `list_todos`, `create_todo`, `update_todo`, `delete_todo`, `search_todos`) | 26 | 100% |
| `models.py` | 0 (declarative models + `to_dict`) | 0 (exercised implicitly) | N/A |

**Overall**: All 8 route handlers covered by at least one scenario.

---

## Table 3: Uncovered Code

| File | Function | Lines | Reason |
|------|----------|-------|--------|
| `models.py` | `User` (class) | 8-16 | ORM model declaration. Covered implicitly through user creation/login. |
| `models.py` | `Todo` (class) | 19-33 | ORM model declaration. Covered implicitly through todo CRUD. |
| `models.py` | `Todo.to_dict` | 35-46 | Serialization helper. Exercised by all todo endpoint tests. |
| `app.py` | `db.create_all()` | 10-11 | App initialization. Infrastructure. |

All uncovered items are infrastructure or declarative.
