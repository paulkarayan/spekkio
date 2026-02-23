# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/transactions.py
# Generated: 2026-02-22T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Transfer Funds
  Account holders can transfer money to other accounts.

  Background:
    Given an account exists with account_number "ACC001", holder_name "Alice", pin "1234", and balance 1000.00
    And an account exists with account_number "ACC002", holder_name "Bob", pin "5678", and balance 200.00

  @characterization @extracted @source:routes/transactions.py:73-74 @criterion:AC-007-01 @confidence:high
  Scenario: Successful transfer updates both balances
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC002", "amount": 300.00}
      """
    Then the response status should be 201
    And the response body should contain "new_balance" with value 700.00
    And the balance of account "ACC002" should be 500.00

  @characterization @extracted @source:routes/transactions.py:93 @criterion:AC-007-02 @confidence:high
  Scenario: Transfer returns success message with new source balance
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC002", "amount": 100.00}
      """
    Then the response status should be 201
    And the response body should contain "message" with value "Transfer successful"
    And the response body should contain "new_balance" with value 900.00

  @characterization @extracted @source:routes/transactions.py:62-63 @criterion:AC-007-03 @confidence:high
  Scenario: Reject transfer with zero amount
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC002", "amount": 0}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Amount must be positive"

  @characterization @extracted @source:routes/transactions.py:65-66 @criterion:AC-007-04 @confidence:high
  Scenario: Reject transfer exceeding source balance
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC002", "amount": 1500.00}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Insufficient funds"

  @characterization @extracted @source:routes/transactions.py:67-69 @criterion:AC-007-05 @confidence:high
  Scenario: Reject transfer to nonexistent account
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "NONEXISTENT", "amount": 100.00}
      """
    Then the response status should be 404
    And the response body should contain "detail" with value "Target account not found"

  @characterization @extracted @source:routes/transactions.py:70-71 @criterion:AC-007-06 @confidence:high
  Scenario: Reject self-transfer
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC001", "amount": 100.00}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Cannot transfer to same account"

  @characterization @extracted @source:routes/transactions.py:76-91 @criterion:AC-007-07 @confidence:high
  Scenario: Transfer creates two transaction records
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC002", "amount": 100.00}
      """
    Then the response status should be 201
    And a TRANSFER transaction record should exist for account "ACC001" with target "ACC002"
    And a TRANSFER transaction record should exist for account "ACC002" with target "ACC001"

  @characterization @extracted @source:routes/transactions.py:81 @criterion:AC-007-08 @confidence:high
  Scenario: Sender transaction has descriptive text with target account
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC002", "amount": 100.00}
      """
    Then the response status should be 201
    And the sender transaction description should be "Transfer to ACC002"

  @characterization @extracted @source:routes/transactions.py:88 @criterion:AC-007-09 @confidence:high
  Scenario: Receiver transaction has descriptive text with source account
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC001 |
      | x-pin            | 1234   |
    And body:
      """
      {"target_account_number": "ACC002", "amount": 100.00}
      """
    Then the response status should be 201
    And the receiver transaction description should be "Transfer from ACC001"

  @characterization @extracted @source:routes/transactions.py:65-66 @criterion:AC-007-04 @confidence:medium @anomaly @needs-review
  # ANOMALY: Balance check happens BEFORE target account lookup.
  # If the user has insufficient funds AND the target does not exist,
  # they get "Insufficient funds" instead of "Target account not found".
  # Question: Is this error priority order intentional?
  Scenario: Insufficient funds error takes priority over invalid target
    Given an account exists with account_number "ACC003", holder_name "Broke", pin "0000", and balance 0.00
    When I send a POST request to "/transactions/transfer" with headers:
      | x-account-number | ACC003 |
      | x-pin            | 0000   |
    And body:
      """
      {"target_account_number": "NONEXISTENT", "amount": 100.00}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Insufficient funds"
