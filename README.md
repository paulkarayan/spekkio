# spekkio
extract value out of a slapp (ai "slop app") through reverse engineering a spec

## handling vibe-coded apps that get out over their skis

Along with many other industry veterans, I anticipate seeing this problem occur over and over again:

You have a vibe-coded app. It works (mostly), until it doesn't.

But the slapp is still really useful. It's like getting a sketch on a paper napkin with a domain expert who can really articulate what they're looking for - a working example just like the Agile Manifesto promised.

## So how can we get the most out of this?

Here's my approach:
1. Collect any information about the intent of the builder(s)
2. Understand what it actually does (not what you think it does)
3. Keep the slapp as a behavioral baseline for safe refactoring or regeneration
4. Generate BDD scenarios that pass against the current behavior
5. Rebuild/regenerate, as necessary, and evolve intentionally from a known state

## Enter Spekkio

Spekkio contemplates the steps 1-4.

Let's watch this play out in the context of spec-kit https://github.com/github/spec-kit

```
Existing code (vibe-coded)
    ↓
/spekkio.extract
    ↓
spec.md (inferred user stories, acceptance criteria)
features/*.feature (characterization scenarios)
    ↓
Human review: "Is this what we actually want?"
    ↓
Adjust spec (remove bugs-as-features, add missing intent)
    ↓
Normal Spec Kit flow from here
```

## how to run it

Spekkio is a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) project command. Run it from any project directory:

```
/spekkio.extract path/to/your/app
```

It reads your source code and produces a full behavioral extraction in 6 phases:

| Phase | Output | What it does |
|-------|--------|-------------|
| 0 | `discovery.md` | Detects language/framework, maps project structure, catalogs endpoints |
| 1 | `inventory.yml` | Structured behavioral record for every external interface |
| 2 | `spec.md` | Inferred user stories with acceptance criteria and confidence scores |
| 3 | `features/characterization/*.feature` | Gherkin scenarios describing current behavior (not intended behavior) |
| 4 | `source-mapping.md` | Bidirectional traceability between scenarios and source code |
| 5 | `checklists/extraction-review.md` | Human review checklist: anomalies, missing context, dead code |

Output lands in `specs/{NNN}-{app-name}/` where the number auto-increments per run.

Spekkio surfaces the kinds of anomalies that vibe-coded apps tend to accumulate: missing validations, security gaps, dead code, inconsistent error handling, no test coverage. Every anomaly gets a decision checkbox in the review checklist.

### after extraction

1. Review `checklists/extraction-review.md` -- confirm, revise, or remove each user story
2. Resolve anomalies -- decide what's intentional vs. what's a bug
3. Move approved scenarios from `characterization/` to `intended/`
4. Evolve from a known state using the spec as your source of truth

## end to end example

The `examples/atm/` directory contains a small FastAPI ATM app with intentional anomalies (no withdrawal limits, plain-text PINs, no rate limiting on auth). Try it:

```
/spekkio.extract examples/atm
```