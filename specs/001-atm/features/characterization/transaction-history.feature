# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/accounts.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Transaction History
  Account holders can view their transaction history.

  Background:
    Given an account exists with account_number "ACC001", holder_name "Alice", pin "1234", and balance 500.00
    And the account has existing transactions

  @characterization @extracted @source:routes/accounts.py:48-52 @criterion:AC-004-01 @confidence:high
  Scenario: Retrieve transaction history for an account
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And the response body should be a list of transactions

  @characterization @extracted @source:routes/accounts.py:51 @criterion:AC-004-02 @confidence:high
  Scenario: Transactions are ordered newest first
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And the first transaction should have the most recent timestamp

  @characterization @extracted @source:routes/accounts.py:55-61 @criterion:AC-004-03 @confidence:high
  Scenario: Transaction fields include ISO 8601 timestamp
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And each transaction should contain "id", "type", "amount", "timestamp", "description"
    And the "timestamp" field should be in ISO 8601 format

  @characterization @extracted @source:auth.py:8-17 @criterion:AC-004-05 @confidence:high
  Scenario: Reject history request with invalid credentials
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 0000   |
    Then the response status should be 401

  @characterization @extracted @source:routes/accounts.py:48-52 @criterion:AC-004-01 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-021 source=routes/accounts.py:46-63]
  # No pagination — returns all transactions without limit/offset.
  # Question: Will this cause performance issues with many transactions?
  # Recommendation: Add limit/offset or cursor-based pagination.
  # [/ANOMALY]
  Scenario: All transactions returned without pagination
    Given the account has 1000 transactions
    When I send a GET request to "/accounts/history" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    Then the response status should be 200
    And the response should contain all 1000 transactions
