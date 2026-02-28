# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: app.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Todo Search
  Users can search their todos by title.

  Background:
    Given a user exists with id 1, name "Alice"
    And todos exist: "Buy groceries", "Buy birthday gift", "Clean house" for user 1

  @characterization @extracted @source:app.py:108-115 @criterion:AC-008-01 @confidence:high
  Scenario: Search todos by title
    When I send a GET request to "/todos/search?q=Buy" with headers:
      | X-User-Id | 1 |
    Then the response status should be 200
    And the response should contain 2 results

  @characterization @extracted @source:app.py:112 @criterion:AC-008-05 @confidence:high
  Scenario: Empty query returns all todos
    When I send a GET request to "/todos/search" with headers:
      | X-User-Id | 1 |
    Then the response status should be 200
    And the response should contain 3 results

  @characterization @extracted @source:app.py:110-111 @criterion:AC-008-04 @confidence:high
  Scenario: Missing X-User-Id returns 401
    When I send a GET request to "/todos/search?q=test"
    Then the response status should be 401

  @characterization @extracted @source:app.py:113 @criterion:AC-008-01 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-029 source=app.py:113]
  # CRITICAL: SQL injection vulnerability. User input interpolated directly
  # into SQL query via f-string. An attacker can execute arbitrary SQL.
  # Question: Is this a critical security vulnerability?
  # Recommendation: Use parameterized queries immediately.
  # [/ANOMALY]
  Scenario: Search query is vulnerable to SQL injection
    When I send a GET request to "/todos/search?q=' OR 1=1 --" with headers:
      | X-User-Id | 1 |
    Then the response may return all todos regardless of user
