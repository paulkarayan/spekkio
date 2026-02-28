# Extraction Review Checklist

**Project**: ATM API (`examples/atm/`)
**Extracted**: 2026-02-28
**Reviewer**: _______________
**Status**: Pending Review

## Summary

| Metric | Count |
|--------|-------|
| User Stories Inferred | 8 |
| Acceptance Criteria | 36 |
| Characterization Scenarios | 36 |
| Anomalies Detected | 17 |
| Uncovered Code Paths | 9 (infrastructure/models only) |

## User Story Review

For each inferred user story, mark:
- ✓ Correct -- accurately describes intended behavior
- ✎ Revise -- needs modification (note changes needed)
- ✗ Remove -- accidental/unwanted behavior
- + Split -- should be multiple stories

| ID | User Story | Status | Notes |
|----|------------|--------|-------|
| US-001 | Health Check | [ ] | |
| US-002 | Account Creation | [ ] | |
| US-003 | Balance Inquiry | [ ] | |
| US-004 | Transaction History | [ ] | |
| US-005 | Deposit Funds | [ ] | |
| US-006 | Withdraw Funds | [ ] | |
| US-007 | Transfer Funds | [ ] | |
| US-008 | PIN Authentication | [ ] | |


## Missing Context

[HUMAN_INPUT id=HI-009 source=database.py:4-8]
What is the intended deployment environment?
Why it matters: Determines if SQLite is acceptable or a real DB is needed.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-010 source=auth.py:8-17]
What are the regulatory requirements for PIN storage?
Why it matters: Determines if plain-text PIN is a compliance violation.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-011 source=routes/transactions.py:25-93]
What are the expected transaction volumes?
Why it matters: Affects pagination and concurrency decisions.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-012 source=routes/transactions.py:41-57]
Should there be daily withdrawal/transfer limits?
Why it matters: Common ATM requirement; not implemented.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-013 source=main.py:1-16]
Is this a demo/prototype or production-bound code?
Why it matters: Affects severity assessment of all anomalies.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-014 source=auth.py:8-17]
Who are the intended users (bank customers, internal staff, both)?
Why it matters: Affects auth and access control decisions.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-015 source=routes/transactions.py:25-93]
Should transactions support rollback or dispute?
Why it matters: No mechanism exists for reversing transactions.
[/HUMAN_INPUT]

## Dead Code Review

| Function | Location | Action |
|----------|----------|--------|
| No dead code detected | N/A | N/A |

All functions and classes are reachable from the application entry point (`main.py`).

