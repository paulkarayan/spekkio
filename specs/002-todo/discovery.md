# Project Discovery

**Project**: Todo API
**Source**: `examples/todo/`
**Extracted**: 2026-02-28

---

## Language & Framework

- **Language**: Python 3
- **Framework**: Flask 3.0.0
- **ORM**: Flask-SQLAlchemy 3.1.1 (SQLAlchemy under the hood)
- **Database**: SQLite (file-based, `todo.db`)

## Entry Points

- `app.py` — Flask application, all routes defined in single file

## Project Structure

### API Layer
- `app.py` — All 8 HTTP endpoints defined directly (no blueprints)

### Business Logic
- No dedicated service layer; all logic inline in route handlers

### Data Layer
- `models.py` — ORM models: `User`, `Todo`
- `app.py:6-7` — SQLAlchemy config and initialization

### Tests
- No test files found

## External Interfaces Catalog

| # | Method | Path | Handler | Source |
|---|--------|------|---------|--------|
| 1 | GET | /health | `health` | `app.py:15-16` |
| 2 | POST | /users | `create_user` | `app.py:21-33` |
| 3 | POST | /login | `login` | `app.py:36-43` |
| 4 | GET | /todos | `list_todos` | `app.py:48-54` |
| 5 | POST | /todos | `create_todo` | `app.py:57-72` |
| 6 | PUT | /todos/<todo_id> | `update_todo` | `app.py:75-93` |
| 7 | DELETE | /todos/<todo_id> | `delete_todo` | `app.py:96-105` |
| 8 | GET | /todos/search | `search_todos` | `app.py:108-115` |

## Key Dependencies

| Package | Role |
|---------|------|
| Flask | Web framework |
| Flask-SQLAlchemy | ORM integration |
