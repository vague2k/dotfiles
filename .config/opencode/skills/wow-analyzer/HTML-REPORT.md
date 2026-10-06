# HTML report format

The WoW review is one self-contained HTML file in the OS temp directory. Tailwind and Mermaid both come from CDNs. Mermaid handles timeline- and sequence-shaped diagrams reliably. Hand-built divs and inline SVG handle the editorial visuals: uptime bars, throughput comparison, damage rankings. Mix the two. Don't lean on Mermaid for everything, it starts to look generic.

## Scaffold

```html
<!doctype html>
<html lang="en" class="dark">
  <head>
    <meta charset="utf-8" />
    <title>WoW review - {{boss}} {{date}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "dark", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         uptime tracks, cast-gap hatching, avoidable-damage heat, etc. */
      .track { background: repeating-linear-gradient(90deg, #1e293b, #1e293b 2px, #0f172a 2px, #0f172a 4px); }
      .gap { background: repeating-linear-gradient(45deg, #7f1d1d, #7f1d1d 3px, #450a0a 3px, #450a0a 6px); }
      .good { stroke: #34d399; }
      .bad { stroke: #fb7185; }
    </style>
  </head>
  <body class="bg-slate-950 text-slate-100 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="went-right" class="space-y-10">...</section>
      <section id="fixes" class="space-y-10">...</section>
      <section id="one-thing">...</section>
    </main>
  </body>
</html>
```

## Header

Boss or encounter name, difficulty, kill or wipe, fight length, date, and the players in scope. Legend: green for clean, rose for damage or loss, amber for timing and uncertain calls, hatched for downtime. No introduction paragraph. Straight into the report.

If the pull is a wipe, say so, and say the goal is "why did we die", not "how do we do more". Never compare wipe numbers to kill numbers.

## What went right

A row of small cards in the same visual language as the fixes. Each one holds the good thing, the number that proves it, and the timestamp. "98% uptime on the core buff", "interrupted every cast on the tank swap", "healer at 11% overheal", "raid CD landed on the phase 2 blast". No explanation of why it's good. The number says it.

## Fix card

The diagrams carry the weight. Prose is sparse and plain. Each fix is one `<article>`:

- Title: short, says the fix. "Kick the second cast, not the first".
- Badge row: priority (`Strong` rose, `Worth exploring` amber, `Speculative` slate), plus a category tag (`death`, `avoidable`, `cooldowns`, `uptime`, `assignments`, `throughput`).
- Where: monospaced, `font-mono text-sm`. Fight, phase, player, ability, timestamps.
- Before and after diagram: the centrepiece. Two columns, side by side.
- What happened: one sentence. The log, plainly.
- What it's costing: one sentence. The consequence.
- The fix: one sentence, concrete and repeatable.
- Wins: bullets, six words or fewer each. "No defensive wasted", "Kicks land before the cast", "Uptime 84% to 96%".

No paragraphs of explanation. If the diagram needs a paragraph, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the fix. Mix them. Don't make every diagram look the same. Variety is part of the point.

### Mermaid timeline (cooldown alignment and death recaps)

Use a Mermaid timeline or sequence diagram when the point is "this happened at the wrong moment" or "look at the order of these events". This is the strongest pattern for a death or a missed window.

```html
<div class="rounded-lg border border-slate-800 bg-slate-900 p-4 overflow-x-auto">
  <pre class="mermaid">
    timeline
      title Pull 4 - spike at 1:12
      1:08 : tank swap begins
      1:10 : boss windup
      1:11.5 : lethal damage lands
      1:12 : Guardian Spirit cast (too late)
  </pre>
</div>
```

### Uptime bars (a buff sitting at 60% when it should be 100%)

One horizontal track per buff, DoT, or active time. Before: the bar stops short and leaves a hatched gap. After: the bar runs the full width. Stack several so the eye scans down them. Put the percentage at the end of each track.

```html
<div class="space-y-2">
  <div class="flex items-center gap-3">
    <span class="w-40 text-xs uppercase tracking-wider text-slate-400">Core buff</span>
    <div class="flex-1 h-4 rounded track overflow-hidden">
      <div class="h-full bg-rose-500/70" style="width:61%"></div>
    </div>
    <span class="w-10 text-right font-mono text-xs text-rose-400">61%</span>
  </div>
</div>
```

### Cast-gap strip (active time and hesitation)

One row representing the fight, ticked per second or per few seconds. Green where casts happened, hatched where nothing did. One row per pull, so two pulls stack into a comparison. This turns "84% active" into a picture of where the loss happened.

### Before and after timeline (rotation and cooldown fixes)

Two Mermaid timelines or two hand-built strips, stacked. Before: your cooldowns, with the boss's vulnerable window marked. After: the same cooldowns shifted onto the window. Mark the window with a red band in both, so the misalignment is obvious at a glance.

### Death recap (why did I die)

A vertical sequence of the final six seconds. Each incoming hit is a labelled box, a health bar shrinking beside it, and overkill marked red at the end. Defensives that were cast appear as green pills. Defensives that existed but went unused appear as grey dashed pills. This answers "was it avoidable" without any prose.

### Throughput comparison (parse gaps)

Two horizontal bars per player or per pull: total throughput, and effective throughput after overheal or avoidable damage. Pair each with its parse number. Keep it to the players in scope so it doesn't turn into a scoreboard. Never show raw DPS alone, it's the most misread number in the game.

### Avoidable damage ranking (who stood in what)

Horizontal bars per player, one bar per avoidable ability, stacked. Longer bar means more damage taken from mechanics. The player at the top is creating the most healer work. Pair with tick counts, because four big ticks and forty small ones are different problems.

## Style guidance

- Dark mode.
- Inter as the font.
- Colour sparingly. Green for what's clean, rose for damage and mistakes, amber for timing and uncertain calls, slate for everything structural. Class colours are fair game for player names since the game uses them, but keep them muted so the green and rose story still reads.
- Keep diagrams around 320px tall so before and after sits side by side without scrolling.
- Use `text-xs uppercase tracking-wider` for labels inside diagrams, so they read as schematic, not as UI.
- Put the raw number next to every visual. A bar without a value is decoration.
- The only scripts are the Tailwind CDN and the Mermaid ESM import. Everything else is static. No app code, no interactivity beyond Mermaid's own rendering.

## One thing to change next pull

One larger card. The fix, one sentence on why it has the best return, and an anchor link to its card. That's it.

## Tone

Plain English, concise. Talk like a raid lead going through the log with the player, not like a tool printing metrics.

Use exactly: throughput, parse, ilvl parse, uptime, active time, cooldown alignment, avoidable damage, overheal, effective damage and healing, death recap, assignment, pull, wipe, kill, vulnerable window.

Never substitute: dps for throughput unless you mean the literal column, "score" for parse, "rotation optimization" for the actual fix, "play better" for anything, "utilize" for use.

Phrasings that fit the style:

- "Defensive landed 0.5s after the spike. Use it one GCD earlier."
- "Core buff sat at 61% uptime. Every second it's down is lost damage."
- "First death at 1:12, avoidable, no defensive up. That's the wipe."
- "Parse 42, ilvl parse 78. Gear is the gap, not play."

Wins bullets name the gain in log terms: "uptime 84% to 96%", "no wasted cooldown", "kicks land before the cast", "overheal 34% to 12%". Don't write "better performance" or "improved execution", because neither is measurable on the next pull.

No hedging, no throat-clearing, no "it's worth noting that". If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it.