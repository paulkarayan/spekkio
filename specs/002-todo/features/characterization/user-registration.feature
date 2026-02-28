# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: app.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: User Registration
  New users can create accounts.

  @characterization @extracted @source:app.py:21-33 @criterion:AC-002-01 @confidence:high
  Scenario: Successfully create a new user
    When I send a POST request to "/users" with body:
      """
      {"name": "Alice", "email": "alice@example.com", "password": "pass123"}
      """
    Then the response status should be 201
    And the response body should contain "name" with value "Alice"
    And the response body should contain "email" with value "alice@example.com"

  @characterization @extracted @source:app.py:32 @criterion:AC-002-02 @confidence:high
  Scenario: Response excludes password
    When I send a POST request to "/users" with body:
      """
      {"name": "Bob", "email": "bob@example.com", "password": "secret"}
      """
    Then the response status should be 201
    And the response body should not contain field "password"

  @characterization @extracted @source:app.py:28 @criterion:AC-002-03 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-016 source=app.py:28]
  # Password stored as plain text — no hashing applied.
  # Question: Is this intentional for a prototype?
  # Recommendation: Hash passwords with bcrypt or argon2.
  # [/ANOMALY]
  Scenario: Password stored as plain text
    When I send a POST request to "/users" with body:
      """
      {"name": "Test", "email": "test@example.com", "password": "mypass"}
      """
    Then the response status should be 201
    And the database should contain the password "mypass" as plain text

  @characterization @extracted @source:app.py:23 @criterion:AC-002-04 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-017 source=app.py:23]
  # No duplicate email check — multiple accounts with same email allowed.
  # Question: Should emails be unique?
  # Recommendation: Add unique constraint on email column.
  # [/ANOMALY]
  Scenario: Duplicate emails are allowed
    Given a user exists with email "dup@example.com"
    When I send a POST request to "/users" with body:
      """
      {"name": "Dup User", "email": "dup@example.com", "password": "pass"}
      """
    Then the response status should be 201

  @characterization @extracted @source:app.py:25-28 @criterion:AC-002-05 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-018 source=app.py:25-28]
  # Missing required fields cause unhandled KeyError (500 error).
  # Question: Should missing fields return 400?
  # Recommendation: Add input validation.
  # [/ANOMALY]
  Scenario: Missing fields cause server error
    When I send a POST request to "/users" with body:
      """
      {"name": "Only Name"}
      """
    Then the response status should be 500
