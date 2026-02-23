# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: auth.py
# Generated: 2026-02-22T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: PIN Authentication
  All protected endpoints require PIN-based authentication via HTTP headers.

  Background:
    Given an account exists with account_number "ACC001", holder_name "Alice", pin "1234", and balance 500.00

  @characterization @extracted @source:auth.py:8 @criterion:AC-008-01 @confidence:high
  Scenario: Authentication uses x-account-number and x-pin headers
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200

  @characterization @extracted @source:auth.py:13-14 @criterion:AC-008-02 @confidence:high
  Scenario: Nonexistent account returns 401
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | NOSUCHACCOUNT |
      | x-pin            | 1234          |
    Then the response status should be 401
    And the response body should contain "detail" with value "Invalid credentials"

  @characterization @extracted @source:auth.py:15-16 @criterion:AC-008-03 @confidence:high
  Scenario: Wrong PIN returns 401
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 9999   |
    Then the response status should be 401
    And the response body should contain "detail" with value "Invalid credentials"

  @characterization @extracted @source:auth.py:14,16 @criterion:AC-008-04 @confidence:high
  Scenario: Same error message for wrong PIN and nonexistent account
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | NOSUCHACCOUNT |
      | x-pin            | 1234          |
    Then the response body should contain "detail" with value "Invalid credentials"
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 9999   |
    Then the response body should contain "detail" with value "Invalid credentials"

  @characterization @extracted @source:auth.py:15 @criterion:AC-008-05 @confidence:high @anomaly @needs-review
  # ANOMALY: PIN is compared as plain text, not via hash comparison.
  # Question: Should PINs be hashed and compared with constant-time comparison?
  Scenario: PIN compared as plain text equality
    Given an account exists with account_number "ACC001" and pin stored as "1234" in plain text
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200

  @characterization @extracted @source:auth.py:8-17 @criterion:AC-008-01 @confidence:high @anomaly @needs-review
  # ANOMALY: No rate limiting on authentication attempts.
  # Question: Should there be a lockout after N failed PIN attempts?
  Scenario: Unlimited failed PIN attempts allowed
    When I send 10 GET requests to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 0000   |
    Then all 10 responses should have status 401
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
