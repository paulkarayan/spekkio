# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: app.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: User Login
  Registered users can log in.

  Background:
    Given a user exists with name "Alice", email "alice@example.com", and password "pass123"

  @characterization @extracted @source:app.py:36-43 @criterion:AC-003-01 @confidence:high
  Scenario: Successful login returns user ID as token
    When I send a POST request to "/login" with body:
      """
      {"email": "alice@example.com", "password": "pass123"}
      """
    Then the response status should be 200
    And the response body should contain "token"

  @characterization @extracted @source:app.py:40-41 @criterion:AC-003-02 @confidence:high
  Scenario: Wrong password returns 401
    When I send a POST request to "/login" with body:
      """
      {"email": "alice@example.com", "password": "wrong"}
      """
    Then the response status should be 401

  @characterization @extracted @source:app.py:40 @criterion:AC-003-02 @confidence:high
  Scenario: Nonexistent email returns 401
    When I send a POST request to "/login" with body:
      """
      {"email": "nobody@example.com", "password": "pass"}
      """
    Then the response status should be 401

  @characterization @extracted @source:app.py:42 @criterion:AC-003-03 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-020 source=app.py:42]
  # "Token" is just the user ID integer — not a real authentication token.
  # Question: Should this use JWT or session-based auth?
  # Recommendation: Implement proper token-based authentication.
  # [/ANOMALY]
  Scenario: Token is actually the user ID
    When I send a POST request to "/login" with body:
      """
      {"email": "alice@example.com", "password": "pass123"}
      """
    Then the response body "token" should equal the user's database ID
