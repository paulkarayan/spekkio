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

