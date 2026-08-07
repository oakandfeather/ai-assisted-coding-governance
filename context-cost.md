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
| `core-rules.md` | 1,614 | ~2,800 |
| `coding-rules.md` | 704 | ~1,250 |
| `writing-rules.md` | 1,275 | ~2,200 |
| `coding-patterns.md` | 1,085 | ~1,900 |
| `writing-patterns.md` | 1,622 | ~2,700 |
| `agent-workflow.md` | 2,555 | ~4,150 |
| `client-profiles.md` + one profile | 446 | ~800 |
| entry file (`AGENTS.md`, placeholders filled) | 973 | ~1,800 |

`agent-workflow.md` is still the single largest file — over a fifth of the cost of a full load — after the v1.9 compression pass cut it ~16% (3,039 → 2,555 words) without dropping a rule. The same treatment has since run over `writing-rules.md` at v1.5, ~14% (1,481 → 1,275 words); `writing-patterns.md` at v1.1, ~9% (1,792 → 1,622 words); `coding-rules.md` at v2.3, ~12% (799 → 704 words); and `coding-patterns.md` at v1.4, ~15% (1,272 → 1,085 words) — none of the five dropped a rule. The `coding-patterns.md` pass was briefed to favor agent consumption over human readability and so also cut trailing clauses that only restated their own bold lead-in; it still landed in the same band as the others, because the bulk of what remains is rationale clauses that shape how a model applies the rule rather than prose written for human comfort.

## Scenario totals

Per the graduated loading rule in `AGENTS.md` ("scale that set to the blast radius"):

| Scenario | Files loaded | Est. tokens |
|---|---|---:|
| Trivial edit | entry file + `core-rules.md` | ~4,600 |
| Non-trivial coding task | entry + core-rules + coding-rules + coding-patterns + agent-workflow + client profile | ~12,700 |
| Non-trivial writing task | entry + core-rules + writing-rules + writing-patterns + agent-workflow + client profile | ~14,450 |
| Everything at once | entry + all seven `ai-docs/` files | ~17,600 |

## Caveats

- This is a one-time context-window cost **per session**, paid when files are actually `Read` — not merely linked to. The graduated-loading rule exists specifically to avoid paying the ~17.6k full cost on every task.
- Prompt caching (where the harness supports it) makes repeat reference *cheap in billing* within a session once a file is cached, but it does not reduce how much of the context window that file occupies.
- These numbers reflect `ai-docs/` as of 2026-08-07. Re-measure after any material edit to a file listed above.
