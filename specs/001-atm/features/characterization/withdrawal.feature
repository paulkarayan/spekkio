# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/transactions.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Withdraw Funds
  Account holders can withdraw money from their accounts.

  Background:
    Given an account exists with account_number "ACC001", holder_name "Alice", pin "1234", and balance 500.00

  @characterization @extracted @source:routes/transactions.py:41-57 @criterion:AC-006-01 @confidence:high
  Scenario: Successful withdrawal decreases balance
    When I send a POST request to "/transactions/withdraw" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 200.00}
      """
    Then the response status should be 201
    And the response body should contain "new_balance" with value 300.00

  @characterization @extracted @source:routes/transactions.py:57 @criterion:AC-006-02 @confidence:high
  Scenario: Withdrawal returns success message
    When I send a POST request to "/transactions/withdraw" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 100.00}
      """
    Then the response status should be 201
    And the response body should contain "message" with value "Withdrawal successful"

  @characterization @extracted @source:routes/transactions.py:43-44 @criterion:AC-006-03 @confidence:high
  Scenario: Reject withdrawal with zero amount
    When I send a POST request to "/transactions/withdraw" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 0}
      """
    Then the response status should be 400

  @characterization @extracted @source:routes/transactions.py:43-44 @criterion:AC-006-03 @confidence:high
  Scenario: Reject withdrawal with negative amount
    When I send a POST request to "/transactions/withdraw" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": -50}
      """
    Then the response status should be 400

  @characterization @extracted @source:routes/transactions.py:46-47 @criterion:AC-006-04 @confidence:high
  Scenario: Reject withdrawal exceeding balance
    When I send a POST request to "/transactions/withdraw" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 600.00}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Insufficient funds"

  @characterization @extracted @source:routes/transactions.py:49-54 @criterion:AC-006-05 @confidence:high
  Scenario: Withdrawal creates a transaction record
    When I send a POST request to "/transactions/withdraw" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 100.00}
      """
    Then the response status should be 201
    And a WITHDRAWAL transaction record should exist for account "ACC001" with amount 100.00

  @characterization @extracted @source:routes/transactions.py:45 @criterion:AC-006-01 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-024 source=routes/transactions.py:45]
  # No withdrawal limit per transaction or per day.
  # Question: Should there be a maximum withdrawal amount (e.g., $500/day for ATM)?
  # Recommendation: Add configurable withdrawal limits.
  # [/ANOMALY]
  Scenario: Large withdrawal has no limit
    Given an account exists with account_number "ACC900", holder_name "Rich", pin "1234", and balance 1000000.00
    When I send a POST request to "/transactions/withdraw" with headers:
      | x-account-number | ACC900 |
      | x-pin            | 1234   |
    And body:
      """
      {"amount": 999999.00}
      """
    Then the response status should be 201
    And the response body should contain "new_balance" with value 1.00
