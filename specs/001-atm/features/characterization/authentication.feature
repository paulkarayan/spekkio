# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: auth.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: PIN Authentication
  Account holders authenticate using account number and PIN headers.

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
      | x-account-number | NOPE999 |
      | x-pin            | 1234    |
    Then the response status should be 401
    And the response body should contain "detail" with value "Invalid credentials"

  @characterization @extracted @source:auth.py:15-16 @criterion:AC-008-03 @confidence:high
  Scenario: Wrong PIN returns 401
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 0000   |
    Then the response status should be 401
    And the response body should contain "detail" with value "Invalid credentials"

  @characterization @extracted @source:auth.py:14,16 @criterion:AC-008-04 @confidence:high
  Scenario: Same error message for wrong PIN and nonexistent account
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | NOPE999 |
      | x-pin            | 1234    |
    Then the response body should contain "detail" with value "Invalid credentials"
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 0000   |
    Then the response body should contain "detail" with value "Invalid credentials"

  @characterization @extracted @source:auth.py:15 @criterion:AC-008-05 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-030 source=auth.py:15]
  # PIN compared as plain text equality — not using constant-time comparison.
  # Question: Is this intentional for a demo?
  # Recommendation: Hash PINs and use constant-time comparison.
  # [/ANOMALY]
  Scenario: PIN compared as plain text equality
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200

  @characterization @extracted @source:auth.py:8-17 @criterion:AC-008-01 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-029 source=auth.py:8-17]
  # No rate limiting on authentication attempts — unlimited failed PIN tries allowed.
  # Question: How many failed attempts before lockout?
  # Recommendation: Add rate limiting or progressive delays.
  # [/ANOMALY]
  Scenario: Unlimited failed PIN attempts allowed
    When I send 100 GET requests to "/accounts/balance" with wrong PIN
    Then all 100 requests should return 401
    And no lockout or rate limiting should occur
