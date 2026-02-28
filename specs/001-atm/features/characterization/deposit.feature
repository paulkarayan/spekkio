# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/transactions.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Deposit Funds
  Account holders can deposit money into their accounts.

  Background:
    Given an account exists with account_number "ACC001", holder_name "Alice", pin "1234", and balance 500.00

  @characterization @extracted @source:routes/transactions.py:25-38 @criterion:AC-005-01 @confidence:high
  Scenario: Successful deposit increases balance
    When I send a POST request to "/transactions/deposit" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 200.00}
      """
    Then the response status should be 201
    And the response body should contain "new_balance" with value 700.00

  @characterization @extracted @source:routes/transactions.py:38 @criterion:AC-005-02 @confidence:high
  Scenario: Deposit returns success message
    When I send a POST request to "/transactions/deposit" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 100.00}
      """
    Then the response status should be 201
    And the response body should contain "message" with value "Deposit successful"

  @characterization @extracted @source:routes/transactions.py:27-28 @criterion:AC-005-03 @confidence:high
  Scenario: Reject deposit with zero amount
    When I send a POST request to "/transactions/deposit" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 0}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Amount must be positive"

  @characterization @extracted @source:routes/transactions.py:27-28 @criterion:AC-005-03 @confidence:high
  Scenario: Reject deposit with negative amount
    When I send a POST request to "/transactions/deposit" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": -50}
      """
    Then the response status should be 400

  @characterization @extracted @source:routes/transactions.py:30-35 @criterion:AC-005-04 @confidence:high
  Scenario: Deposit creates a transaction record
    When I send a POST request to "/transactions/deposit" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 100.00}
      """
    Then the response status should be 201
    And a DEPOSIT transaction record should exist for account "ACC001" with amount 100.00
