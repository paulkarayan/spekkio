# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: app.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Todo CRUD Operations
  Users can create, read, update, and delete todos.

  Background:
    Given a user exists with id 1, name "Alice", email "alice@example.com"
    And a todo exists with id 1, title "Buy groceries", user_id 1

  # --- List ---

  @characterization @extracted @source:app.py:48-54 @criterion:AC-004-01 @confidence:high
  Scenario: List todos for a user
    When I send a GET request to "/todos" with headers:
      | X-User-Id | 1 |
    Then the response status should be 200
    And the response body should be a list containing "Buy groceries"

  @characterization @extracted @source:app.py:50-51 @criterion:AC-004-02 @confidence:high
  Scenario: Missing X-User-Id returns 401
    When I send a GET request to "/todos" without headers
    Then the response status should be 401

  # --- Create ---

  @characterization @extracted @source:app.py:57-72 @criterion:AC-005-01 @confidence:high
  Scenario: Create a todo with all fields
    When I send a POST request to "/todos" with headers:
      | X-User-Id | 1 |
    And body:
      """
      {"title": "New task", "description": "Details", "priority": "high", "due_date": "2026-03-15T00:00:00"}
      """
    Then the response status should be 201
    And the response body should contain "title" with value "New task"
    And the response body should contain "priority" with value "high"

  @characterization @extracted @source:app.py:67 @criterion:AC-005-04 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-024 source=app.py:67]
  # No validation on priority values — any string accepted.
  # Question: Should priority be constrained to an enum?
  # Recommendation: Validate against allowed values (low/medium/high).
  # [/ANOMALY]
  Scenario: Any string accepted as priority
    When I send a POST request to "/todos" with headers:
      | X-User-Id | 1 |
    And body:
      """
      {"title": "Task", "priority": "super-ultra-critical"}
      """
    Then the response status should be 201
    And the response body should contain "priority" with value "super-ultra-critical"

  @characterization @extracted @source:app.py:68 @criterion:AC-005-05 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-025 source=app.py:68]
  # Invalid due_date format causes unhandled ValueError (500 error).
  # Question: Should invalid dates return 400?
  # Recommendation: Add try/except with proper error response.
  # [/ANOMALY]
  Scenario: Invalid due_date causes server error
    When I send a POST request to "/todos" with headers:
      | X-User-Id | 1 |
    And body:
      """
      {"title": "Task", "due_date": "not-a-date"}
      """
    Then the response status should be 500

  # --- Update ---

  @characterization @extracted @source:app.py:75-93 @criterion:AC-006-01 @confidence:high
  Scenario: Update todo title
    When I send a PUT request to "/todos/1" with headers:
      | X-User-Id | 1 |
    And body:
      """
      {"title": "Updated title"}
      """
    Then the response status should be 200
    And the response body should contain "title" with value "Updated title"

  @characterization @extracted @source:app.py:88-89 @criterion:AC-006-02 @confidence:high
  Scenario: Mark todo as completed sets completed_at
    When I send a PUT request to "/todos/1" with headers:
      | X-User-Id | 1 |
    And body:
      """
      {"completed": true}
      """
    Then the response status should be 200
    And the response body should contain "completed" with value true
    And the response body "completed_at" should not be null

  @characterization @extracted @source:app.py:81-82 @criterion:AC-006-04 @confidence:high
  Scenario: Update nonexistent todo returns 404
    When I send a PUT request to "/todos/9999" with headers:
      | X-User-Id | 1 |
    And body:
      """
      {"title": "Nope"}
      """
    Then the response status should be 404

  @characterization @extracted @source:app.py:82 @criterion:AC-006-06 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-026 source=app.py:82]
  # IDOR vulnerability: No ownership check. Any user can update any todo.
  # Question: Is this a security bug?
  # Recommendation: Add check that todo.user_id matches requesting user.
  # [/ANOMALY]
  Scenario: Any user can update another user's todo (IDOR)
    Given a user exists with id 2, name "Bob"
    When I send a PUT request to "/todos/1" with headers:
      | X-User-Id | 2 |
    And body:
      """
      {"title": "Hacked by Bob"}
      """
    Then the response status should be 200

  # --- Delete ---

  @characterization @extracted @source:app.py:96-105 @criterion:AC-007-01 @confidence:high
  Scenario: Delete a todo returns 204
    When I send a DELETE request to "/todos/1" with headers:
      | X-User-Id | 1 |
    Then the response status should be 204

  @characterization @extracted @source:app.py:101-102 @criterion:AC-007-02 @confidence:high
  Scenario: Delete nonexistent todo returns 404
    When I send a DELETE request to "/todos/9999" with headers:
      | X-User-Id | 1 |
    Then the response status should be 404

  @characterization @extracted @source:app.py:103 @criterion:AC-007-04 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-027 source=app.py:103]
  # IDOR vulnerability: No ownership check. Any user can delete any todo.
  # Question: Is this a security bug?
  # Recommendation: Add ownership check before deletion.
  # [/ANOMALY]
  Scenario: Any user can delete another user's todo (IDOR)
    Given a user exists with id 2, name "Bob"
    When I send a DELETE request to "/todos/1" with headers:
      | X-User-Id | 2 |
    Then the response status should be 204
