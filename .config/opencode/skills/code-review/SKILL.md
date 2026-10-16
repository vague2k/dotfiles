---
name: code-review
description: "Review the diff since a fixed point (commit, branch, tag, or merge-base) on two axes. Standards: does the code follow this repo's documented coding standards? Spec: does the code match the originating issue or spec? Both run as parallel sub-agents and report their findings side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Review the diff from a user-supplied fixed point to `HEAD` on two axes:

- **Standards**: does the code follow this repo's documented coding standards?
- **Spec**: does the code implement the originating issue or spec?

Each axis runs in its own **parallel sub-agent**, so the two contexts stay separate. This skill then aggregates the findings.

Use the issue tracker if the repo has one.

## Process

### 1. Pin the fixed point

The fixed point is whatever the user named (a commit SHA, branch name, tag, `main`, `HEAD~5`, ...). If they didn't name one, ask.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so it compares against the merge-base). Also capture the commit list: `git log <fixed-point>..HEAD --oneline`.

Confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty before going further. A bad ref or empty diff must fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

Find the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, ...), fetched with the workflow in the tracker doc.
2. A path the user passed in.
3. A spec file under `docs/`, `specs/`, or `.scratch/` that matches the branch name or feature.
4. If you find nothing, ask the user where the spec is. If they say there isn't one, skip the **Spec** sub-agent and report "no spec available".

### 3. Identify the standards sources

Search the repo for files that document how to write code. If `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it belongs on the list.

Whatever the repo documents, the Standards axis also carries the **smell baseline** below. The baseline is a fixed set of Fowler code smells (_Refactoring_, ch.3), applied even when the repo documents nothing. Two rules bound it:

- **The repo overrides.** A documented repo standard always wins. When it endorses something the baseline would flag, suppress the smell.
- **A smell is a judgement call, not a violation.** Name it as a possibility ("possible Feature Envy"). As with any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*. Match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it. If no honest name comes to mind, the design is murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape and call it from both sites.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type and pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module changes for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it and inline back until a real need appears.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly delegates onward. → cut it and call the real target directly.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

Issue both sub-agent calls in the foreground, in the same message, then aggregate the reports they return.

**Standards sub-agent prompt:**

- The diff command and the commit list.
- The standards-source files from step 3, plus the **full smell baseline** pasted in (the sub-agent cannot see it any other way).
- The brief: "Report each finding with its file or hunk. (a) Documented-standard violations: cite the standard (file + rule). (b) Baseline smells: name the smell and quote the hunk. Documented-standard breaches can be hard violations. Baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt:**

- The diff command and the commit list.
- The path to the spec, or its fetched contents.
- The brief: "Report three things. (a) Spec requirements that are missing or incomplete. (b) Behaviour in the diff that the spec didn't ask for (scope creep). (c) Requirements whose implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec`, verbatim or lightly cleaned. Do **not** merge or rerank findings. The two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue in each axis, if any. Don't pick a single winner across axes. That would undo the separation.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
