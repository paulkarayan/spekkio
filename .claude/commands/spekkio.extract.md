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

Execute the following 6 phases in order. After each phase, print a progress summary to stdout before continuing.

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
  - notable things: missing validations, inconsistencies, potential bugs
```

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
**So that** [NEEDS HUMAN INPUT: why?]

### Acceptance Criteria (observed)

| ID | Criterion | Source | Confidence |
|----|-----------|--------|------------|
| AC-{NNN}-01 | {what the code does} | {file:line} | High/Medium/Low |

### Anomalies Detected

| Observation | Question | Recommendation |
|-------------|----------|----------------|
| {what's unusual} | {question for reviewer} | {suggested action} |
```

**Confidence scoring rules:**
- **High**: Behavior is explicit in code with clear paths (e.g., validation checks, explicit error responses)
- **Medium**: Behavior inferred from code patterns but not explicitly tested
- **Low**: Behavior guessed from naming, comments, or conventions
- **Unknown**: Cannot determine — mark with `[NEEDS REVIEW]`

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

- For anomalies, add inline comments explaining what's unusual and what question the reviewer should answer
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

## Anomaly Resolution

For each anomaly, provide:
- The observed behavior
- The source location
- The question to answer
- Decision options (checkboxes)

## Missing Context

Questions that could not be answered from code alone:

| Question | Why It Matters | Answer |
|----------|----------------|--------|
| {question} | {impact} | |

## Dead Code Review

| Function | Location | Action |
|----------|----------|--------|
| {name} | {file:line} | [ ] Keep  [ ] Remove |

## Sign-off

- [ ] All user stories reviewed
- [ ] All anomalies resolved
- [ ] Missing context documented or answered
- [ ] Dead code decisions made

Reviewer: _______________ Date: _______________
```

**Output:** Write `specs/{NNN}-{app-name}/checklists/extraction-review.md`

**Stdout:** Print summary of review items.

---

## Final Output Structure

After all phases complete, confirm this structure exists:

```
specs/{NNN}-{app-name}/
├── discovery.md                          # Phase 0: Project structure analysis
├── inventory.yml                         # Phase 1: Raw behavioral inventory
├── spec.md                               # Phase 2: Inferred specification
├── source-mapping.md                     # Phase 4: Code ↔ scenario traceability
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
- **DO NOT** make assumptions about intent — mark unknowns as `[NEEDS HUMAN INPUT]`

## Post-Extraction Workflow

After extraction is complete, print these next steps:

```
Next steps:
1. Review specs/{NNN}-{app-name}/checklists/extraction-review.md
2. Resolve all anomalies and confirm user stories
3. Move approved scenarios from characterization/ to intended/
4. Modify scenarios that encode bugs (fix expected behavior)
5. Add scenarios for missing functionality
6. Continue with normal spec-driven development workflow
```
