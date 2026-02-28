# Extraction Review Checklist

**Project**: ATM API (`examples/atm/`)
**Extracted**: 2026-02-22
**Reviewer**: _______________
**Status**: Pending Review

## Summary

| Metric | Count |
|--------|-------|
| User Stories Inferred | 8 |
| Acceptance Criteria | 36 |
| Characterization Scenarios | 36 |
| Anomalies Detected | 16 |
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

Questions that could not be answered from code alone:

| Question | Why It Matters | Answer |
|----------|----------------|--------|
| What is the intended deployment environment? | Determines if SQLite is acceptable or a real DB is needed | |
| What are the regulatory requirements for PIN storage? | Determines if plain-text PIN is a compliance violation | |
| What are the expected transaction volumes? | Affects pagination and concurrency decisions | |
| Should there be daily withdrawal/transfer limits? | Common ATM requirement; not implemented | |
| Is this a demo/prototype or production-bound code? | Affects severity of all anomalies | |
| Who are the intended users (bank customers, internal staff, both)? | Affects auth and access control decisions | |
| Should transactions support rollback or dispute? | No mechanism exists for reversing transactions | |

## Dead Code Review

| Function | Location | Action |
|----------|----------|--------|
| No dead code detected | N/A | N/A |

All functions and classes are reachable from the application entry point (`main.py`).

