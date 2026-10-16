---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
disable-model-invocation: true
---

# Improve Codebase Architecture

Find architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Process

### 1. Explore

**Scope before you scan (YAGNI).** Deepening a module pays off by making future changes easier, so weight the parts of the codebase that changed recently.

- If the user named a direction (a module, subsystem, or pain point), take it and skip the inference below.
- Otherwise, read back through `git log --oneline` to find the hot spots, the files and areas that keep coming up, and look there first. If there is no clear hot spot, widen the search.

Read the codebase's docs for any useful context like terms or concept specific to the project, or ADRs for the area first.

Then spawn a sub-agent to walk the codebase. Explore organically instead of following rigid heuristics, and note where you hit friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where do pure functions exist only for testability, while the real bugs hide in how they're called (no **locality**)?
- Where do tightly coupled modules leak across their seams?
- Which parts have no tests, or are hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it around? A "concentrates" answer is the signal you want.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, then `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it (`xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows) and tell the user the absolute path.

Use the `/unslop` skill for the report: keep it free of unnecessary jargon and AI-speak.

The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via CDN** for diagrams. Use Mermaid when relationships are graph-shaped (call graphs, dependencies, sequences). Use hand-built divs or SVG for something more editorial (mass diagrams, cross-sections, collapse animations). Each candidate gets a **before/after visualisation**. Be visual.

For each candidate, render a card with:

- **Files**: the files and modules involved
- **Problem**: why the current architecture causes friction
- **Solution**: plain-English description of the change
- **Benefits**: in terms of locality, leverage, and how tests improve
- **Before/After diagram**: side-by-side and custom-drawn, showing the shallowness and the deepening
- **Recommendation strength**: `Strong`, `Worth exploring`, or `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**ADR conflicts**: If the project uses ADRs, surface a candidate that contradicts an existing ADR only when the friction is real enough to warrant revisiting the ADR. Mark it in the card (e.g. a warning callout: _"contradicts ADR-0007, but worth reopening because…"_). Don't list every refactor an ADR forbids.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.
