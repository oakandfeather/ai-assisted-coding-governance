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
| `agent-workflow.md` | 2,481 | ~4,050 |
| `client-profiles.md` + one profile | 414 | ~750 |
| entry file (`AGENTS.md`, placeholders filled) | 909 | ~1,700 |

`agent-workflow.md` is still the single largest file — over a fifth of the cost of a full load — after two compression passes: v1.9 cut it ~16% (3,039 → 2,555 words), and v1.10 a further ~3% (2,555 → 2,481 words). The same treatment has run over `writing-rules.md` at v1.5, ~14% (1,481 → 1,275 words); `writing-patterns.md` at v1.1, ~9% (1,792 → 1,622 words); `coding-rules.md` at v2.3, ~12% (799 → 704 words); `coding-patterns.md` at v1.4, ~15% (1,272 → 1,085 words); `core-rules.md` at v1.3, ~5% (1,614 → 1,531 words); the entry file (`AGENTS.template.md` at v1.10), ~6.5% (973 → 909 words as measured on `build/AGENTS.md`); and `client-profiles.md` at v1.4, ~17% (192 → 160 words) — no pass dropped a rule. The `coding-patterns.md`, `core-rules.md`, entry-file, and `client-profiles.md` passes were briefed to favor agent consumption over human readability, and so also cut trailing clauses that only restated their own bold lead-in.

**`agent-workflow.md`'s second pass returned ~3%, and that number is the finding.** Applied to already-compressed prose, it reached the floor `core-rules.md` hit at ~5%: what remained after v1.9 was rule text, the citations that route between sections, and one clause of rationale each on the rules an agent would otherwise pattern-match past. The available structural cuts were all *cross-section* — §6's and §7's blast-radius paragraphs state the same scaling rule, and §7's floor list restates `core-rules.md` TL;DR 1–2, §3, `core-rules.md` §5, and §6 — and they were **deliberately not taken**, for the reason [`coverage-matrix.md`](./testing/coverage-matrix.md) records against B-F10: an agent reaches these sections independently, so a rule that survives only as a pointer is unreachable at the moment it is needed. That is the same argument that put the blast-radius gate inline in the entry file rather than delegating it to §7. What the pass did take was within-section: §8's four bullet groups folded to three (660 → 610 words, the largest single saving), and restatement tails throughout. Treat ~3% as this file's floor under the reachability constraint, not a pass left unfinished — the next real reduction would have to come from removing a rule, which is a governance decision, not a density one.

**`client-profiles.md`'s headline 17% overstates what an agent saves.** Measured on the *source* file, but roughly half of it never reaches an installed repo: both build scripts replace the `*(none yet)*` paragraph and strip the `## Sample profile` section, so compressing those costs an agent nothing. On the installed file the pass is 117 → 102 words (~13%), and only the banner and the "Add each client as…" paragraph are compressible at all — everything else is a heading, the version line, or the generated client list. That ~15-word ceiling is under 1% of a full load; the file is already the smallest in the package, so measure this pass against the source-repo reader, not the context window.

**The entry file's ~6.5% is capped by duplication, not by density.** Its mandatory-rules block fell ~12% (351 → 309 words) once the six rule-file references were folded from two prose paragraphs into one bulleted routing list, each file named once. But 126 words of that block are the always-on core — the paragraph root `AGENTS.md` requires to stay in sync across `AGENTS.template.md`, `copilot-instructions.template.md`, and both of this repo's own entry files. Compressing it means a four-file change to the package's highest-risk text, so it was left verbatim; that paragraph is ~42% of the block and sets the floor here.

**`core-rules.md`'s ~5% is the outlier, and it is the informative one.** The same brief that yielded 15% on `coding-patterns.md` yielded a third as much here, because `core-rules.md` carries almost no prose written for human comfort to begin with — what fills it is rule text and *conditions on* rule text. Its §9 in particular is built almost entirely of qualifiers ("when a claim is time-sensitive… or surprising," "check a second source when… the first source is thin," "don't spiral into open-ended research on claims the task doesn't hinge on"); strip those and the remainder reads as an unconditional mandate to search and double-source everything, which is a different and worse rule. §9 and §0 were therefore left substantially intact by design. Treat ~5% as the floor this file can reach, not as a pass left unfinished.

## Scenario totals

Per the graduated loading rule in `AGENTS.md` ("scale that set to the blast radius"):

| Scenario | Files loaded | Est. tokens |
|---|---|---:|
| Trivial edit | entry file + `core-rules.md` | ~4,400 |
| Non-trivial coding task | entry + core-rules + coding-rules + coding-patterns + agent-workflow + client profile | ~12,350 |
| Non-trivial writing task | entry + core-rules + writing-rules + writing-patterns + agent-workflow + client profile | ~14,100 |
| Everything at once | entry + all seven `ai-docs/` files | ~17,250 |

## Caveats

- This is a one-time context-window cost **per session**, paid when files are actually `Read` — not merely linked to. The graduated-loading rule exists specifically to avoid paying the ~17.3k full cost on every task.
- Prompt caching (where the harness supports it) makes repeat reference *cheap in billing* within a session once a file is cached, but it does not reduce how much of the context window that file occupies.
- These numbers reflect `ai-docs/` as of 2026-08-07. Re-measure after any material edit to a file listed above.
