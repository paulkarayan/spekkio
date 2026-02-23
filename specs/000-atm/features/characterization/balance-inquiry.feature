# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/accounts.py, auth.py
# Generated: 2026-02-22T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Balance Inquiry
  Account holders can check their balance using PIN authentication.

  Background:
    Given an account exists with account_number "ACC001", holder_name "Alice", pin "1234", and balance 500.00

  @characterization @extracted @source:routes/accounts.py:42-43 @criterion:AC-003-01 @confidence:high
  Scenario: Successfully retrieve balance
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And the response body should contain "account_number" with value "ACC001"
    And the response body should contain "balance" with value 500.00

  @characterization @extracted @source:auth.py:8-17 @criterion:AC-003-02 @confidence:high
  Scenario: Reject request with missing headers
    When I send a GET request to "/accounts/balance" without authentication headers
    Then the response status should be 422

  @characterization @extracted @source:auth.py:13-16 @criterion:AC-003-03 @confidence:high
  Scenario: Reject request with wrong PIN
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 0000   |
    Then the response status should be 401
    And the response body should contain "detail" with value "Invalid credentials"

  @characterization @extracted @source:auth.py:13-14 @criterion:AC-003-03 @confidence:high
  Scenario: Reject request with nonexistent account
    When I send a GET request to "/accounts/balance" with headers:
      | x-account-number | NONEXISTENT |
      | x-pin            | 1234        |
    Then the response status should be 401
    And the response body should contain "detail" with value "Invalid credentials"
