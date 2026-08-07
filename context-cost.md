# Context cost of the governance package

**Last reviewed:** 2026-08-07

Tracks how much of an agent's context window the `ai-docs/` package consumes when it's loaded per `AGENTS.md`'s "load in one pass" instruction. Re-run the measurement below and update this table when `ai-docs/` files change size materially — it's a cost metric, not a governed rule file, so it doesn't need a version bump on every edit.

## Methodology

Word/char counts are exact (`wc -w -c` over each file). Token counts are an **approximation** at ~4 characters/token for English markdown — not a real tokenizer run, so treat these as ballpark, not precise.

```
wc -w -c ai-docs/*.md ai-docs/client-profiles/*.md
```

**The entry-file row is a separate measurement, not part of the command above.** `ai-docs/*.md` also matches `AGENTS.template.md`, but that file still carries its "how to use it" banner and unfilled `*(placeholders)*` — content an installed repo never actually loads. Run `scripts/build.ps1` first and measure `build/AGENTS.md` instead: banner stripped, placeholders filled, which is what an agent's context actually pays for.

## Per-file cost

| File | Words | Est. tokens |
|---|---:|---:|
| `core-rules.md` | 1,531 | ~2,700 |
| `coding-rules.md` | 704 | ~1,250 |
| `writing-rules.md` | 1,275 | ~2,200 |
| `coding-patterns.md` | 1,085 | ~1,900 |
| `writing-patterns.md` | 1,622 | ~2,700 |
| `agent-workflow.md` | 2,555 | ~4,150 |
| `client-profiles.md` + one profile | 446 | ~800 |
| entry file (`AGENTS.md`, placeholders filled) | 909 | ~1,700 |

`agent-workflow.md` is still the single largest file — over a fifth of the cost of a full load — after the v1.9 compression pass cut it ~16% (3,039 → 2,555 words) without dropping a rule. The same treatment has since run over `writing-rules.md` at v1.5, ~14% (1,481 → 1,275 words); `writing-patterns.md` at v1.1, ~9% (1,792 → 1,622 words); `coding-rules.md` at v2.3, ~12% (799 → 704 words); `coding-patterns.md` at v1.4, ~15% (1,272 → 1,085 words); `core-rules.md` at v1.3, ~5% (1,614 → 1,531 words); and the entry file (`AGENTS.template.md` at v1.10), ~6.5% (973 → 909 words as measured on `build/AGENTS.md`) — none of the seven dropped a rule. The `coding-patterns.md`, `core-rules.md`, and entry-file passes were briefed to favor agent consumption over human readability, and so also cut trailing clauses that only restated their own bold lead-in.

**The entry file's ~6.5% is capped by duplication, not by density.** Its mandatory-rules block fell ~12% (351 → 309 words) once the six rule-file references were folded from two prose paragraphs into one bulleted routing list, each file named once. But 126 words of that block are the always-on core — the paragraph root `AGENTS.md` requires to stay in sync across `AGENTS.template.md`, `copilot-instructions.template.md`, and both of this repo's own entry files. Compressing it means a four-file change to the package's highest-risk text, so it was left verbatim; that paragraph is ~42% of the block and sets the floor here.

**`core-rules.md`'s ~5% is the outlier, and it is the informative one.** The same brief that yielded 15% on `coding-patterns.md` yielded a third as much here, because `core-rules.md` carries almost no prose written for human comfort to begin with — what fills it is rule text and *conditions on* rule text. Its §9 in particular is built almost entirely of qualifiers ("when a claim is time-sensitive… or surprising," "check a second source when… the first source is thin," "don't spiral into open-ended research on claims the task doesn't hinge on"); strip those and the remainder reads as an unconditional mandate to search and double-source everything, which is a different and worse rule. §9 and §0 were therefore left substantially intact by design. Treat ~5% as the floor this file can reach, not as a pass left unfinished.

## Scenario totals

Per the graduated loading rule in `AGENTS.md` ("scale that set to the blast radius"):

| Scenario | Files loaded | Est. tokens |
|---|---|---:|
| Trivial edit | entry file + `core-rules.md` | ~4,400 |
| Non-trivial coding task | entry + core-rules + coding-rules + coding-patterns + agent-workflow + client profile | ~12,500 |
| Non-trivial writing task | entry + core-rules + writing-rules + writing-patterns + agent-workflow + client profile | ~14,250 |
| Everything at once | entry + all seven `ai-docs/` files | ~17,400 |

## Caveats

- This is a one-time context-window cost **per session**, paid when files are actually `Read` — not merely linked to. The graduated-loading rule exists specifically to avoid paying the ~17.4k full cost on every task.
- Prompt caching (where the harness supports it) makes repeat reference *cheap in billing* within a session once a file is cached, but it does not reduce how much of the context window that file occupies.
- These numbers reflect `ai-docs/` as of 2026-08-07. Re-measure after any material edit to a file listed above.
