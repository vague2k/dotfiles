---
name: wow-analyzer
description: Analyze World of Warcraft combat logs for a raid night or key run. Surfaces what a player or group does well and what to fix, as a visual HTML report, then grills through whichever fix you pick.
disable-model-invocation: true
---

# WoW Analyzer

Read a combat log and answer two questions: what did this player or group do well, and what should they change next pull. The output is a list of fixes, ranked by how much performance each one costs.

## Vocabulary

Logs have their own terms. Use them exactly, don't drift into code or construction metaphors:

- **throughput**: raw DPS/HPS. Never the whole story on its own.
- **parse**: your percentile against same class, spec, and boss. `ilvl parse` compares you only to players at similar item level. A low parse with a high ilvl parse means gear is the gap, not your play.
- **uptime**: how much of the fight a buff, debuff, or DoT was active. Core buffs should sit near 100%.
- **active time**: how much of the fight you spent casting or attacking. Below 90% usually means movement loss or hesitation.
- **cooldown alignment**: whether major cooldowns landed on the boss's vulnerable window (Bloodlust, execute phase, damage amp debuffs) or drifted past it.
- **avoidable damage**: damage from mechanics you can walk out of, dodge, or soak. Reported separately from unavoidable raid damage.
- **overheal**: healing that landed on a full-health target. Above roughly 30-40% is wasted.
- **effective damage/healing**: excludes absorbs and overkill. The number that mattered.
- **death recap**: the last few seconds before a death. Incoming damage, overkill, health curve, which defensives were active.
- **assignment**: a named job in the fight plan. Soak, kick, dispel, tank swap, priority add.

## Process

### 1. Get the log and scope the pull

Decide what to analyze before you analyze it.

- A log file? `WoWCombatLog.txt`, usually in `World of Warcraft/_retail_/Logs/`. Ask for the path if it isn't given. Files are large, so filter to the `ENCOUNTER_START` and `ENCOUNTER_END` you care about.
- A Warcraft Logs report? Ask for the URL. If you can't fetch it, ask the user to export the fights you need or point you at the raw file.
- No log yet? Ask which fight and which player. Don't analyze a whole night indiscriminately.

Then pick the right pull. A wipe at 40% and a clean kill are not comparable. A wipe answers "why did we die". A kill answers "how do we do more". Say which one you're looking at and don't mix them.

If the user named a direction (a boss, a player, a phase, a mechanic), take it and skip the guessing. Otherwise ask which fight they care about most.

You also need to know the encounter, not just the numbers. If the strategy isn't obvious, look it up on Wowhead or the Warcraft Logs encounter page: phase timings, vulnerable windows, required assignments. A number you can't explain against the fight plan is noise.

### 2. Analyze, don't summarize

Spawn a sub-agent to work the log. Read it in this order, which is roughly the order that separates signal from noise.

1. Deaths first. Who died, when, and what killed them. The first death usually starts the chain. For each one, ask: avoidable or unavoidable, was a defensive up, was a heal coming. A death at 0:30 is a mechanical failure. A death at 4:00 into a 4:30 fight is accumulated damage pressure.
2. Assignments. Kicks, dispels, soaks, tank swaps. Who executed and who missed. A missed kick is a damage event on someone else.
3. Avoidable damage. Who stood in what, how much, and how many ticks. Rank players. This creates healer work that shows up as someone else's problem.
4. Cooldowns. For each major offensive and defensive CD, compare uses against uses available in the fight length, then check whether they landed on the vulnerable window. A 2-minute CD used twice in a 6-minute fight is a missed use. A defensive used one GCD after the damage spike is a timing miss.
5. Uptime. Core buffs, DoTs, active time. Long gaps with no casts are movement loss or hesitation.
6. Throughput. DPS, HPS, and parse, last, and always in context: fight length, priority-target damage versus padding, externals received, spec.
7. What went right. Do not skip this. Clean executions, a raid CD that landed on time, a player at 98% uptime, a healer with low overheal.

Do not run heuristics past the data. Every claim in the report needs a timestamp or a number behind it. If the log doesn't show it, say so.

### 3. Present fixes as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/wow-review-<timestamp>.html` so each run gets a fresh file. Open it for the user (`xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows) and tell them the absolute path.

Use the `/unslop` skill for the report to keep presented information understandable without unnecessary jargon and AI speak.

The report uses Tailwind via CDN for layout and styling, and Mermaid via CDN for diagrams where a timeline or sequence tells the story. Mix Mermaid with hand-crafted CSS/SVG visuals. Use Mermaid when the story is a timeline or an ordered sequence (cooldown alignment, death recap, phase flow). Use hand-built divs and SVG when a number deserves an editorial visual (uptime bars, throughput comparison, avoidable-damage ranking). Every fix gets a before/after visualisation: what the log shows, and what it should have shown.

Open with a "What went right" section, in the same visual language as the rest. Don't bury it at the bottom.

For each fix, render a card with:

- Where: fight, boss phase, player, ability, timestamps
- What happened: the log, plainly. The number and the moment.
- What it's costing you: lost throughput, extra healing, a death, a failed assignment
- The fix: plain English, concrete and repeatable. "Use the defensive one GCD earlier, before the damage spike" beats "improve defensive usage".
- Before and after visualisations: side by side, the pull you had against the pull you want
- Priority: one of `Strong`, `Worth exploring`, `Speculative`, as a badge

Priority is about cost, not difficulty. A death on every pull is `Strong`. A 2% parse gain from a rotation tweak is `Speculative`.

End the report with a "One thing to change next pull" section: the single fix with the best return, and why.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

Do not write out a full new rotation or fight plan yet. After the file is written, ask the user: "Which of these would you like to dig into?"

### 4. Grilling loop

Once the user picks a fix, walk the decision tree with them: what the encounter demands at that moment, what their spec and talents allow, gear and stat constraints, what the other players are doing in the same window, and what changes on the next pull. One or two things at a time. Changing everything at once produces no signal in the next log.

Log the decision, not just the discussion. Keep an encounter notes file (create it lazily, something like `wow-notes/<boss>.md`) as fixes crystallize.

- A confirmed fix? Record what the log showed and what to do instead.
- A pattern across pulls? Record it once, with the timestamps that prove it's a pattern and not one bad pull.
- The user rejects a fix for a real reason? ("our comp can't run that strategy", "the tank is assigned elsewhere in that window") Record the reason so the next analysis doesn't re-suggest it.

If the user wants alternatives for the same window, present two or three concrete options side by side with the trade-off each one makes.