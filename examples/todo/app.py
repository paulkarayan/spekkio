from flask import Flask, request, jsonify
from models import db, Todo, User
from datetime import datetime

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///todo.db"
app.config["SECRET_KEY"] = "super-secret-key-123"  # hardcoded secret
db.init_app(app)

with app.app_context():
    db.create_all()


@app.route("/health")
def health():
    return {"status": "ok"}


# ---------- Users ----------

@app.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()
    # No duplicate check on email
    user = User(
        name=data["name"],
        email=data["email"],
        password=data["password"],  # stored as plain text
    )
    db.session.add(user)
    db.session.commit()
    return jsonify({"id": user.id, "name": user.name, "email": user.email}), 201


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data["email"]).first()
    if not user or user.password != data["password"]:
        return jsonify({"error": "Bad credentials"}), 401
    # Returns user ID as "token" - not a real auth system
    return jsonify({"token": user.id})


# ---------- Todos ----------

@app.route("/todos", methods=["GET"])
def list_todos():
    user_id = request.headers.get("X-User-Id")
    if not user_id:
        return jsonify({"error": "Missing X-User-Id header"}), 401
    # No validation that user_id is a real user
    todos = Todo.query.filter_by(user_id=int(user_id)).all()
    return jsonify([t.to_dict() for t in todos])


@app.route("/todos", methods=["POST"])
def create_todo():
    user_id = request.headers.get("X-User-Id")
    if not user_id:
        return jsonify({"error": "Missing X-User-Id header"}), 401
    data = request.get_json()
    todo = Todo(
        title=data["title"],
        description=data.get("description", ""),
        user_id=int(user_id),
        # No validation on priority values
        priority=data.get("priority", "medium"),
        due_date=datetime.fromisoformat(data["due_date"]) if data.get("due_date") else None,
    )
    db.session.add(todo)
    db.session.commit()
    return jsonify(todo.to_dict()), 201


@app.route("/todos/<int:todo_id>", methods=["PUT"])
def update_todo(todo_id):
    user_id = request.headers.get("X-User-Id")
    if not user_id:
        return jsonify({"error": "Missing X-User-Id header"}), 401
    todo = Todo.query.get(todo_id)
    if not todo:
        return jsonify({"error": "Not found"}), 404
    # BUG: No check that todo belongs to requesting user - IDOR vulnerability
    data = request.get_json()
    if "title" in data:
        todo.title = data["title"]
    if "description" in data:
        todo.description = data["description"]
    if "completed" in data:
        todo.completed = data["completed"]
        if data["completed"]:
            todo.completed_at = datetime.utcnow()
    if "priority" in data:
        todo.priority = data["priority"]
    db.session.commit()
    return jsonify(todo.to_dict())


@app.route("/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    user_id = request.headers.get("X-User-Id")
    if not user_id:
        return jsonify({"error": "Missing X-User-Id header"}), 401
    todo = Todo.query.get(todo_id)
    if not todo:
        return jsonify({"error": "Not found"}), 404
    # BUG: Same IDOR - any user can delete any todo
    db.session.delete(todo)
    db.session.commit()
    return "", 204


@app.route("/todos/search", methods=["GET"])
def search_todos():
    user_id = request.headers.get("X-User-Id")
    if not user_id:
        return jsonify({"error": "Missing X-User-Id header"}), 401
    q = request.args.get("q", "")
    # SQL injection via string formatting
    todos = db.session.execute(
        db.text(f"SELECT * FROM todos WHERE user_id = {user_id} AND title LIKE '%{q}%'")
    ).fetchall()
    return jsonify([dict(row._mapping) for row in todos])


if __name__ == "__main__":
    app.run(debug=True)  # Debug mode in "production"
