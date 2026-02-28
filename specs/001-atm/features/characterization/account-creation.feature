# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: routes/accounts.py
# Generated: 2026-02-28T00:00:00Z
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================

Feature: Account Creation
  New customers can create bank accounts.

  @characterization @extracted @source:routes/accounts.py:25-38 @criterion:AC-002-01 @confidence:high
  Scenario: Successfully create a new account
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC001", "holder_name": "Alice", "pin": "1234"}
      """
    Then the response status should be 201
    And the response body should contain "account_number" with value "ACC001"
    And the response body should contain "balance" with value 0.0

  @characterization @extracted @source:models.py:22 @criterion:AC-002-02 @confidence:high
  Scenario: New account starts with zero balance
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC002", "holder_name": "Bob", "pin": "5678"}
      """
    Then the response status should be 201
    And the response body should contain "balance" with value 0.0

  @characterization @extracted @source:routes/accounts.py:27-29 @criterion:AC-002-03 @confidence:high
  Scenario: Reject duplicate account number
    Given an account exists with account_number "ACC001"
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC001", "holder_name": "Charlie", "pin": "0000"}
      """
    Then the response status should be 400
    And the response body should contain "detail" with value "Account number already exists"

  @characterization @extracted @source:routes/accounts.py:33 @criterion:AC-002-04 @confidence:high @anomaly @needs-review
  # [ANOMALY id=ANO-016 source=routes/accounts.py:33]
  # PIN is stored as plain text in the database — no hashing applied.
  # Question: Is this intentional for a demo, or a security bug?
  # Recommendation: Hash PINs with bcrypt or similar.
  # [/ANOMALY]
  Scenario: PIN is stored as plain text
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC003", "holder_name": "Dave", "pin": "9999"}
      """
    Then the response status should be 201
    And the database should contain the PIN "9999" as plain text for account "ACC003"

  @characterization @extracted @source:routes/accounts.py:18-22 @criterion:AC-002-05 @confidence:high
  Scenario: Response does not include PIN field
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC004", "holder_name": "Eve", "pin": "1111"}
      """
    Then the response status should be 201
    And the response body should not contain field "pin"

  @characterization @extracted @source:routes/accounts.py:12-15 @criterion:AC-002-06 @confidence:medium @anomaly @needs-review
  # [ANOMALY id=ANO-017 source=routes/accounts.py:12-15]
  # No validation on account_number format — empty strings and special characters accepted.
  # Question: Should account numbers follow a specific format?
  # Recommendation: Add regex or length validation.
  # [/ANOMALY]
  Scenario: Account number with no format validation
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "", "holder_name": "Test", "pin": "1234"}
      """
    Then the response status should be 201

  @characterization @extracted @source:routes/accounts.py:12-15 @criterion:AC-002-07 @confidence:medium @anomaly @needs-review
  # [ANOMALY id=ANO-018 source=routes/accounts.py:12-15]
  # No validation on PIN complexity or length.
  # Question: Should PINs be exactly 4 digits?
  # Recommendation: Add PIN format constraint.
  # [/ANOMALY]
  Scenario: PIN with no complexity validation
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC005", "holder_name": "Test", "pin": "x"}
      """
    Then the response status should be 201

  @characterization @extracted @source:routes/accounts.py:12-15 @criterion:AC-002-08 @confidence:medium @anomaly @needs-review
  # [ANOMALY id=ANO-019 source=routes/accounts.py:12-15]
  # No validation on holder_name — empty strings accepted.
  # Question: Should holder names have a minimum length?
  # Recommendation: Add minimum length validation.
  # [/ANOMALY]
  Scenario: Empty holder name accepted
    When I send a POST request to "/accounts/" with body:
      """
      {"account_number": "ACC006", "holder_name": "", "pin": "1234"}
      """
    Then the response status should be 201
