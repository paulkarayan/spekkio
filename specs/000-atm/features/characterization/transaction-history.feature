# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/accounts.py
# Generated: 2026-02-22T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Transaction History
  Account holders can view their transaction history.

  Background:
    Given an account exists with account_number "ACC001", holder_name "Alice", pin "1234", and balance 1000.00

  @characterization @extracted @source:routes/accounts.py:48-63 @criterion:AC-004-01 @confidence:high
  Scenario: Retrieve transaction history for an account
    Given the account "ACC001" has the following transactions:
      | type       | amount | description          |
      | deposit    | 1000   | Deposit of $1000.00  |
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And the response body should be a list with 1 item
    And each item should contain "id", "type", "amount", "timestamp", "description"

  @characterization @extracted @source:routes/accounts.py:52 @criterion:AC-004-02 @confidence:high
  Scenario: Transactions are ordered newest first
    Given the account "ACC001" has multiple transactions at different times
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And the transactions should be ordered by timestamp descending

  @characterization @extracted @source:routes/accounts.py:55-61 @criterion:AC-004-03 @confidence:high
  Scenario: Transaction fields include ISO 8601 timestamp
    Given the account "ACC001" has at least one transaction
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And each transaction "timestamp" should be in ISO 8601 format

  @characterization @extracted @source:auth.py:8-17 @criterion:AC-004-04 @confidence:high
  Scenario: Reject history request with invalid credentials
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 0000   |
    Then the response status should be 401

  @characterization @extracted @source:routes/accounts.py:48-63 @criterion:AC-004-01 @confidence:medium @anomaly @needs-review
  # ANOMALY: No pagination support. All transactions returned in a single response.
  # Question: Should pagination (limit/offset) be added for accounts with many transactions?
  Scenario: All transactions returned without pagination
    Given the account "ACC001" has 500 transactions
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And the response body should be a list with 500 items
