# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: app.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Health Check
  Operators can verify the API is running.

  @characterization @extracted @source:app.py:15-16 @criterion:AC-001-01 @confidence:high
  Scenario: Health endpoint returns OK
    When I send a GET request to "/health"
    Then the response status should be 200
    And the response body should contain "status" with value "ok"
