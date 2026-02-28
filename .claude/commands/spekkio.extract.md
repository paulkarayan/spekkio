---
description: "Reverse-engineer a specification from an existing codebase"
---

# /spekkio.extract

Reverse-engineer a specification from an existing codebase. Produces a baseline spec, characterization scenarios, and a review checklist for human validation.

## User Input

$ARGUMENTS

If no arguments provided, extract from the current project root. Arguments may specify a subdirectory or specific focus area.

## When to Use

- Bringing a vibe-coded project under spec discipline
- Onboarding a legacy codebase with no documentation
- Creating a behavioral baseline before refactoring
- Documenting an inherited project

## Inputs

**Required:**
- Source code in the target directory

**Optional (improve extraction quality):**
- `README.md` — project description and intent
- `docs/` — any existing documentation
- Existing tests in `tests/` or `__tests__/`
- API definitions (`openapi.yaml`, `schema.graphql`)
- Database schema (`schema.sql`, migrations, ORM models)
- `.env.example` — environment variables hint at integrations

If `.specify/memory/constitution.md` exists, read it for project conventions.

## Execution Flow

Execute the following 7 phases (Phase 0 through Phase 6) in order. After each phase, print a progress summary to stdout before continuing.

**Output directory naming:** `specs/{NNN}-{app-name}/` where:
- `{NNN}` is a zero-padded 3-digit counter based on the number of existing directories in `specs/` (first run = `001`, second = `002`, etc.). Count all existing directories, not just extraction ones.
- `{app-name}` is the name of the target directory being extracted (e.g., `atm` if extracting `examples/atm/`). If extracting from the project root, use the project directory name.

Determine the output directory before starting Phase 0 and use it for all outputs.

---

### Phase 0: Project Discovery

Scan the project to understand its shape.

**Steps:**
1. Detect language and framework from manifest files (package.json, requirements.txt, pyproject.toml, go.mod, Cargo.toml, Gemfile, etc.)
2. Identify entry points (main.py, index.ts, cmd/main.go, app.py, etc.)
3. Map project structure into layers:
   - **API layer**: routes, controllers, resolvers, CLI commands
   - **Business logic**: services, use cases, domain models
   - **Data layer**: ORM models, repositories, schemas, migrations
   - **Tests**: existing test files and approximate coverage
4. Catalog external interfaces:
   - HTTP endpoints (method + path + handler)
   - CLI commands
   - Event/message handlers
   - Scheduled jobs / cron
   - WebSocket handlers

**Output:** Write `specs/{NNN}-{app-name}/discovery.md` with:
- Language/framework detected
- Entry points
- Project structure map (layer breakdown)
- External interfaces catalog
- Key dependencies and their roles

**Stdout:** Print count of endpoints, models, and test files found.

---

### Phase 1: Behavioral Inventory

For each external interface found in Phase 0, extract a structured behavioral record.

**For each HTTP endpoint, capture:**

```yaml
endpoint:
  method: GET|POST|PUT|DELETE|PATCH
  path: /the/route/{with_params}
  source: path/to/file.py:line_start-line_end
  handler_function: function_name

authentication:
  required: true|false
  method: description of auth mechanism

inputs:
  path_params:
    - name: param_name
      type: inferred_type
      validation: describe any validation found
  query_params:
    - name: param_name
      type: inferred_type
      required: true|false
  body:
    - name: field_name
      type: inferred_type
      validation: describe any validation found
      constraints: any limits, regex, etc.

outputs:
  success:
    status: HTTP status code
    body: description of response shape
  errors:
    - status: code
      condition: when this error occurs

side_effects:
  - description of database writes, events published, external calls, etc.

observations:
  - |
    [ANOMALY id=ANO-NNN source=path/to/file.py:line]
    Description of the anomaly.
    Question: What the reviewer should consider.
    Recommendation: Suggested action.
    [/ANOMALY]
```

Use `[ANOMALY]` tags inside YAML literal block scalars (`|`) for all observations that describe missing validations, inconsistencies, or potential bugs. Plain non-anomalous observations can remain as simple strings.

**For non-HTTP interfaces** (CLI commands, event handlers, cron jobs), adapt the format to capture: trigger, inputs, outputs, side effects, observations.

**Output:** Write `specs/{NNN}-{app-name}/inventory.yml` with all behavioral records.

**Stdout:** Print count of interfaces inventoried and observations noted.

---

### Phase 2: Infer User Stories

Group related behaviors from the inventory into user stories.

**For each user story, produce:**

```markdown
## US-{NNN}: {Title} (inferred)

**Confidence**: High | Medium | Low
**Source**: {primary endpoint or interface}

**As a** {inferred actor}
**I want to** {inferred action}
**So that** [HUMAN_INPUT id=HI-NNN source={primary endpoint source}]
Why does the user need this capability?
[/HUMAN_INPUT]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-{NNN}-01 | {what the code does} | {file:line} | High/Medium/Low |

### Anomalies Detected

[ANOMALY id=ANO-NNN source={file:line}]
{what's unusual}
Question: {question for reviewer}
Recommendation: {suggested action}
[/ANOMALY]
```

For acceptance criteria with Low or Unknown confidence, add a `[HUMAN_INPUT]` tag asking for verification:

```markdown
| AC-NNN-NN | {criterion} | {file:line} | Low |

[HUMAN_INPUT id=HI-NNN source={file:line}]
Low confidence: {why this is uncertain}. Please verify this criterion.
[/HUMAN_INPUT]
```

**Confidence scoring rules:**
- **High**: Behavior is explicit in code with clear paths (e.g., validation checks, explicit error responses)
- **Medium**: Behavior inferred from code patterns but not explicitly tested
- **Low**: Behavior guessed from naming, comments, or conventions
- **Unknown**: Cannot determine — add a `[HUMAN_INPUT]` tag requesting clarification

**Output:** Write `specs/{NNN}-{app-name}/spec.md`

**Stdout:** Print count of user stories, acceptance criteria, and anomalies.

---

### Phase 3: Generate Characterization Scenarios

For each acceptance criterion from Phase 2, generate a Gherkin scenario that describes the **current** behavior.

**Rules:**
- Tag every scenario with `@characterization` and `@extracted`
- Tag with `@source:{file}:{lines}` for traceability
- Tag with `@criterion:{AC-ID}` to link back to acceptance criteria
- Tag with `@confidence:{level}`
- Tag anomalous behaviors with `@anomaly` and `@needs-review`
- Add a file-level comment block:

```gherkin
# ============================================================
# CHARACTERIZATION TESTS - Extracted from existing behavior
# Source: {source_file}
# Generated: {ISO 8601 timestamp}
#
# WARNING: These scenarios describe CURRENT behavior.
# Bugs may be encoded as expected behavior.
# Review carefully before promoting to intended/.
# ============================================================
```

- For anomalies, use `[ANOMALY]` comment blocks (each line prefixed `# `) immediately before the scenario:

```gherkin
  # [ANOMALY id=ANO-NNN source={file:line}]
  # {Description of the anomaly.}
  # Question: {What the reviewer should consider.}
  # Recommendation: {Suggested action.}
  # [/ANOMALY]
  Scenario: {anomalous behavior description}
```

- Group scenarios into `.feature` files by functional area (one feature file per logical grouping)

**Output:** Write feature files to `specs/{NNN}-{app-name}/features/characterization/`
Also create `specs/{NNN}-{app-name}/features/intended/.gitkeep` (empty — filled after human review)

**Stdout:** Print count of scenarios generated, broken down by confidence level.

---

### Phase 4: Generate Source Mapping

Create bidirectional traceability between scenarios and source code.

**Produce two tables:**

**Table 1: Scenario → Source**

| Scenario | Source File | Lines | Function |
|----------|------------|-------|----------|
| {scenario name} | {file path} | {line range} | {function name} |

**Table 2: Source → Scenario Coverage**

| File | Functions | Scenarios | Coverage |
|------|-----------|-----------|----------|
| {file} | {count} | {count} | {percentage} |

**Table 3: Uncovered Code**

| File | Function | Lines | Reason |
|------|----------|-------|--------|
| {file} | {function name} | {lines} | {why no scenario: dead code, internal helper, etc.} |

For uncovered code that is NOT pure infrastructure (i.e., has behavioral logic), add a `[HUMAN_INPUT]` tag:

```markdown
[HUMAN_INPUT id=HI-NNN source={file:lines}]
Function `{name}` has no corresponding scenario. Is this dead code, an internal helper, or missing coverage?
[/HUMAN_INPUT]
```

**Output:** Write `specs/{NNN}-{app-name}/source-mapping.md`

**Stdout:** Print coverage summary and count of uncovered functions.

---

### Phase 5: Generate Review Checklist

Create a structured checklist for human validation of the extraction.

**Format:**

```markdown
# Extraction Review Checklist

**Project**: {project name or directory}
**Extracted**: {date}
**Reviewer**: _______________
**Status**: Pending Review

## Summary

| Metric | Count |
|--------|-------|
| User Stories Inferred | {n} |
| Acceptance Criteria | {n} |
| Characterization Scenarios | {n} |
| Anomalies Detected | {n} |
| Uncovered Code Paths | {n} |

## User Story Review

For each inferred user story, mark:
- ✓ Correct — accurately describes intended behavior
- ✎ Revise — needs modification (note changes needed)
- ✗ Remove — accidental/unwanted behavior
- ⊕ Split — should be multiple stories

| ID | User Story | Status | Notes |
|----|------------|--------|-------|
| {ID} | {title} | [ ] | |

## Missing Context

For each question that cannot be answered from code alone, emit a `[HUMAN_INPUT]` tag:

[HUMAN_INPUT id=HI-NNN source={relevant file if any}]
{Question that could not be answered from code alone.}
Why it matters: {impact on spec accuracy or system design}
[/HUMAN_INPUT]

## Dead Code Review

| Function | Location | Action |
|----------|----------|--------|
| {name} | {file:line} | [ ] Keep  [ ] Remove |

```

**Output:** Write `specs/{NNN}-{app-name}/checklists/extraction-review.md`

**Stdout:** Print summary of review items.

---

### Phase 6: Tag Manifest & Triage

After all phases complete, print a tag manifest summarizing counts and ID ranges:

```
Tag manifest:
  HUMAN_INPUT: HI-001..HI-{N} ({N} items)
  ANOMALY:     ANO-001..ANO-{N} ({N} items)
  Total:       {N} items requiring human review
```

Then instruct the user to run the triage script:

```
Run: python tools/triage.py specs/{NNN}-{app-name}/
This will generate triage.md and report.html for interactive review.
```

**Stdout:** Print the tag manifest above.

---

## Final Output Structure

After all phases complete, confirm this structure exists:

```
specs/{NNN}-{app-name}/
├── discovery.md                          # Phase 0: Project structure analysis
├── inventory.yml                         # Phase 1: Raw behavioral inventory
├── spec.md                               # Phase 2: Inferred specification
├── source-mapping.md                     # Phase 4: Code ↔ scenario traceability
├── triage.md                             # Generated by tools/triage.py
├── report.html                           # Generated by tools/triage.py
├── features/
│   ├── characterization/                 # Phase 3: Current behavior scenarios
│   │   ├── {feature-area-1}.feature
│   │   ├── {feature-area-2}.feature
│   │   └── ...
│   └── intended/                         # Empty until review
│       └── .gitkeep
└── checklists/
    └── extraction-review.md              # Phase 5: Human review checklist
```

## Constraints

- **DO** extract what the code DOES, not what it SHOULD do
- **DO** mark all uncertainties explicitly with confidence scores
- **DO** preserve traceability to source file and line numbers
- **DO** generate scenarios that could theoretically be made executable
- **DO NOT** "fix" observed behavior in scenarios — describe it as-is
- **DO NOT** invent acceptance criteria not evidenced by code
- **DO NOT** skip anomalies — surface every one for human review
- **DO NOT** make assumptions about intent — mark unknowns with `[HUMAN_INPUT]` tags (see Tag Format Reference)

## Tag Format Reference

All actionable items use standardized inline tags with explicit open/close delimiters and metadata. Two tag types exist:

### HUMAN_INPUT

For missing information, low confidence, uncovered code, and unanswered questions:

```
[HUMAN_INPUT id=HI-001 source=routes/accounts.py:12]
What format should account numbers follow?
[/HUMAN_INPUT]
```

### ANOMALY

For suspicious or risky behavior detected in the code:

```
[ANOMALY id=ANO-001 source=routes/accounts.py:33]
PIN stored as plain text in database.
Question: Is this intentional for a demo, or a security bug?
Recommendation: Hash PINs with bcrypt or similar.
[/ANOMALY]
```

### ID Rules

- IDs are globally unique across ALL files in the extraction
- HUMAN_INPUT IDs: `HI-001`, `HI-002`, ... `HI-NNN` (sequential)
- ANOMALY IDs: `ANO-001`, `ANO-002`, ... `ANO-NNN` (sequential)
- Maintain a running counter as you work through phases — do NOT restart numbering per file
- The `source` attribute references the **original source code** (e.g., `routes/accounts.py:33`), NOT the spec file

### Placement by File Type

- **Markdown (.md)**: Inline in text
- **YAML (.yml)**: Inside literal block scalars (`|`)
- **Gherkin (.feature)**: As comment blocks, each line prefixed with `# `

Example in YAML:
```yaml
observations:
  - |
    [ANOMALY id=ANO-003 source=routes/transactions.py:45]
    No withdrawal limit per transaction or per day.
    Question: Should there be a maximum withdrawal amount?
    Recommendation: Add configurable withdrawal limits.
    [/ANOMALY]
```

Example in Gherkin:
```gherkin
  # [ANOMALY id=ANO-003 source=routes/transactions.py:45]
  # No withdrawal limit per transaction or per day.
  # Question: Should there be a maximum withdrawal amount?
  # Recommendation: Add configurable withdrawal limits.
  # [/ANOMALY]
  Scenario: Large withdrawal has no limit
```

---

## Post-Extraction Workflow

After extraction is complete, print these next steps:

```
Next steps:
1. Run: python tools/triage.py specs/{NNN}-{app-name}/
2. Open specs/{NNN}-{app-name}/report.html in a browser for interactive review
3. Work through triage.md — resolve all HUMAN_INPUT and ANOMALY items
4. Review specs/{NNN}-{app-name}/checklists/extraction-review.md
5. Move approved scenarios from characterization/ to intended/
6. Modify scenarios that encode bugs (fix expected behavior)
7. Add scenarios for missing functionality
8. Continue with normal spec-driven development workflow
```
