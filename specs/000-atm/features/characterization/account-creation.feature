# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/accounts.py
# Generated: 2026-02-22T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Account Creation
  Customers can create new bank accounts with an account number, name, and PIN.

  @characterization @extracted @source:routes/accounts.py:26-38 @criterion:AC-002-01 @confidence:high
  Scenario: Successfully create a new account
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC100", "holder_name": "Alice", "pin": "1234"}
      """
    Then the response status should be 201
    And the response body should contain "id"
    And the response body should contain "account_number" with value "ACC100"
    And the response body should contain "holder_name" with value "Alice"
    And the response body should contain "balance" with value 0.0

  @characterization @extracted @source:models.py:22 @criterion:AC-002-02 @confidence:high
  Scenario: New account starts with zero balance
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC101", "holder_name": "Bob", "pin": "5678"}
      """
    Then the response status should be 201
    And the response body should contain "balance" with value 0.0

  @characterization @extracted @source:routes/accounts.py:27-29 @criterion:AC-002-03 @confidence:high
  Scenario: Reject duplicate account number
    Given an account exists with account_number "ACC200"
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC200", "holder_name": "Charlie", "pin": "0000"}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Account number already exists"

  @characterization @extracted @source:routes/accounts.py:33 @criterion:AC-002-04 @confidence:high @anomaly @needs-review
  # ANOMALY: PIN is stored as plain text in the database.
  # Question: Is plain-text PIN storage intentional (demo) or a security defect?
  Scenario: PIN is stored as plain text
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC300", "holder_name": "Dave", "pin": "9999"}
      """
    Then the response status should be 201
    And the PIN in the database for account "ACC300" should be "9999" in plain text

  @characterization @extracted @source:routes/accounts.py:18-23 @criterion:AC-002-05 @confidence:high
  Scenario: Response does not include PIN field
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC400", "holder_name": "Eve", "pin": "1111"}
      """
    Then the response status should be 201
    And the response body should not contain "pin"

  @characterization @extracted @source:routes/accounts.py:12-15 @criterion:AC-002-06 @confidence:medium @anomaly @needs-review
  # ANOMALY: No validation on account_number format.
  # Question: Should account numbers have a required format (e.g., alphanumeric, fixed length)?
  Scenario: Account number with no format validation
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "", "holder_name": "Test", "pin": "1234"}
      """
    Then the response status should be 201

  @characterization @extracted @source:routes/accounts.py:12-15 @criterion:AC-002-07 @confidence:medium @anomaly @needs-review
  # ANOMALY: No PIN complexity or length validation.
  # Question: Should PINs be required to be exactly 4 digits?
  Scenario: PIN with no complexity validation
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC500", "holder_name": "Test", "pin": "a"}
      """
    Then the response status should be 201
