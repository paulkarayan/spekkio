# Extraction Review Checklist

**Project**: Todo API (`examples/todo/`)
**Extracted**: 2026-02-28
**Reviewer**: _______________
**Status**: Pending Review

## Summary

| Metric | Count |
|--------|-------|
| User Stories Inferred | 8 |
| Acceptance Criteria | 30 |
| Characterization Scenarios | 26 |
| Anomalies Detected | 16 |
| Uncovered Code Paths | 4 (infrastructure/models only) |

## User Story Review

For each inferred user story, mark:
- ✓ Correct -- accurately describes intended behavior
- ✎ Revise -- needs modification (note changes needed)
- ✗ Remove -- accidental/unwanted behavior
- + Split -- should be multiple stories

| ID | User Story | Status | Notes |
|----|------------|--------|-------|
| US-001 | Health Check | [ ] | |
| US-002 | User Registration | [ ] | |
| US-003 | User Login | [ ] | |
| US-004 | List My Todos | [ ] | |
| US-005 | Create a Todo | [ ] | |
| US-006 | Update a Todo | [ ] | |
| US-007 | Delete a Todo | [ ] | |
| US-008 | Search Todos | [ ] | |


## Missing Context

[HUMAN_INPUT id=HI-009 source=app.py:1-117]
Is this a prototype/demo or production-bound code?
Why it matters: Affects severity of all anomalies, especially security ones.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-010 source=app.py:7]
Where should the SECRET_KEY and DB configuration come from?
Why it matters: Hardcoded secrets are a security risk in any shared repository.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-011 source=app.py:48-54]
Should the API support pagination for todo lists?
Why it matters: Performance degrades with large numbers of todos.
[/HUMAN_INPUT]

[HUMAN_INPUT id=HI-012 source=models.py:19-33]
Should todos support additional fields (tags, categories, attachments)?
Why it matters: Affects data model and API design decisions.
[/HUMAN_INPUT]

## Dead Code Review

| Function | Location | Action |
|----------|----------|--------|
| No dead code detected | N/A | N/A |

