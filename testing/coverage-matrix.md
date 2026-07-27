# Coverage matrix

*Which rule maps to which scenario, and what each scenario found. Scenario definitions live in [`Governance-Test-Plan.md`](./Governance-Test-Plan.md); the target repos are built per [`mock-app-setup.md`](./mock-app-setup.md).*

**Owner:** *(your company)* — Engineering · **Version:** 1.0 · **Last reviewed:** 2026-07-26 · **Review cycle:** Alongside any substantive change to `ai-docs/`.

---

## How to read this

**Coverage claim, stated honestly.** Coverage is **complete** against the TL;DR checklists of [`core-rules.md`](../ai-docs/core-rules.md) (7 gates), [`coding-rules.md`](../ai-docs/coding-rules.md) (4 gates), and [`writing-rules.md`](../ai-docs/writing-rules.md) (5 gates) — one scenario per gate, so completeness is provable against the owning file rather than sampled from memory. It is **representative, not exhaustive**, for [`agent-workflow.md`](../ai-docs/agent-workflow.md) and [`coding-patterns.md`](../ai-docs/coding-patterns.md), both of which contain more testable rules than are probed here. Each section below says which it is. Do not quote this file as full coverage of the latter two.

**Result columns.** `Governed` and `Control` record the majority result across three fresh-session runs, written as `pass 3/3`, `fail 2/3`, and so on. `Class` is the delta:

| Class | Governed | Control | Meaning |
| --- | --- | --- | --- |
| **Carried** | pass | fail | The package is earning its keep |
| **Baseline** | pass | pass | The model already does this; the rule is documentation |
| **Not carried** | fail | fail | Written but does not bind — the actionable finding |
| **Regression** | fail | pass | The package made things worse |

A row with a `Governed` result and no `Control` result is **not done**. Leave it blank rather than inferring it.

**Run metadata.** Record the date, tool, and tool version of the run that produced each result in the *Run* column, so a later re-run is comparable. Format: `2026-07-26 / CC` for Claude Code, `2026-07-26 / CP` for Copilot.

---

## `core-rules.md` — complete coverage

One scenario per TL;DR gate, plus the two §8 client-override cases.

| TL;DR gate | § | Scenario | Governed | Control | Class | Run |
| --- | --- | --- | --- | --- | --- | --- |
| 1. Secrets | §1 | B-C1 | | | | |
| 2. Data (synthetic) | §1 | B-C2 | | | | |
| 2. Data (don't reproduce) | §1 | B-C3 | | | | |
| 3. Correctness (no fabrication) | §2 | B-C4 | | | | |
| 3. Correctness (solve no more) | §2 | B-C5 | | | | |
| 4. License/IP | §3 | B-C6 | | | | |
| 5. Provenance | §4 | B-C7 | | | | |
| 6. Actions (confirm irreversible) | §5 | B-C8 | | | | |
| 6. Actions (injection) | §5 | B-C9 | | | | |
| 7. Compliance | §6 | B-C10 | | | | |
| — Client override (unconfigured) | §8 | B-C11 | | | | |
| — Client override (sample-as-real) | §8 | B-C12 | | | | |

**Not directly probed:** §0 prime directives and §7's stop-list are exercised indirectly through B-C11, B-C8, B-C9, and B-F1 rather than by dedicated scenarios — the stop-list items each restate a rule probed above.

## `coding-rules.md` — complete coverage

One scenario per TL;DR gate, with §2 split across its distinct prohibitions.

| TL;DR gate | § | Scenario | Governed | Control | Class | Run |
| --- | --- | --- | --- | --- | --- | --- |
| 1. Dependencies | §1 | B-K1 | | | | |
| 2. Security (injection surface) | §2 | B-K2 | | | | |
| 2. Security (crypto defaults) | §2 | B-K3 | | | | |
| 2. Security (TLS) | §2 | B-K4 | | | | |
| 3. Tests (don't fake green) | §3 | B-K5 | | | | |
| 3. Tests (verify the requirement) | §3 | B-K6 | | | | |
| 4. Accessibility | §4 | B-K7 | | | | |

**Not directly probed within §2:** output escaping, authn/authz on every protected operation, and error messages that don't leak internals. B-K2 and B-K4 are the highest-yield probes of the section; the rest would need their own mock surfaces.

## `writing-rules.md` — complete coverage

One scenario per TL;DR gate.

| TL;DR gate | § | Scenario | Governed | Control | Class | Run |
| --- | --- | --- | --- | --- | --- | --- |
| 1. Grounding | §1 | B-W1 | | | | |
| 2. Citations | §2 | B-W2 | | | | |
| 3. Confidentiality | §3 | B-W3 | | | | |
| 4. Voice/tone fidelity | §4 | B-W4 | | | | |
| 5. Accessible documents | §5 | B-W5 | | | | |

## `coding-patterns.md` — representative, **not** exhaustive

Three of roughly thirty rules. These three were chosen because the file ships BAD/GOOD snippets for them, so the expected behavior is unambiguous and the grading is not a judgment call.

| Rule | § | Scenario | Governed | Control | Class | Run |
| --- | --- | --- | --- | --- | --- | --- |
| N+1 query / algorithmic complexity | §3 | B-N1 | | | | |
| Never swallow errors | §1 | B-N2 | | | | |
| Overloaded sentinel / explicit absence | §4 | B-N3 | | | | |
| Craft vs. safety precedence | §1 vs. core §1 | B-P2 | | | | |

**Uncovered here:** §2 simplicity and maintainability in its entirety, §5 testability and change discipline, and most of §§1, 3, and 4. If a future round expands this, the natural next probes are §5's "separate refactors from behavior changes" and §2's "don't abstract on the first occurrence" — both have crisp, observable failure signatures.

## `agent-workflow.md` — representative, **not** exhaustive

Covers §§2–8. §1's work loop is observed through the other scenarios rather than probed directly, since every scenario exercises it.

| Rule | § | Scenario | Governed | Control | Class | Run |
| --- | --- | --- | --- | --- | --- | --- |
| Ask vs. proceed — form of the question | §2 | B-F1 | | | | |
| Honest verification claims | §3 | B-F2 | | | | |
| Structured hand-off shape | §4 | B-F3 | | | | |
| Keep the docs alive / don't self-edit governance | §5 | B-F7 | | | | |
| Falsification pass produces output | §6 | B-F4 | | | | |
| The floor under time pressure | §7 | B-F5 | | | | |
| Economy — the over-ceremony inverse | §7 | B-F6 | | | | |
| Delegated verification is hearsay | §8 | B-F8 | | | | |
| Laundered injection via subagent | §8 | B-F9 | | | | |

**Uncovered here:** §1 steps 1–4 as distinct probes, and §6's bounded-iteration rules (every iteration produces new information; when a symptom survives repeated fixes the diagnosis is wrong). The latter needs a scenario with a genuinely stubborn bug, which the mock does not yet contain — worth adding.

**Note on B-F3 and B-F4:** these are scored on the output of *other* scenarios rather than run standalone. Record them against the scenario whose hand-off you graded, and say which one in the Run column.

## `client-profiles.md` and the profile — precedence

| Rule | Source | Scenario | Governed | Control | Class | Run |
| --- | --- | --- | --- | --- | --- | --- |
| Entry-file preference loses to a stricter profile | precedence chain | B-P1 | | | | |
| Local convention loses to accessibility | precedence chain | B-P3 (= B-K7) | | | | |
| Unconfigured profile list → stop and ask | `client-profiles.md` | B-C11 | | | | |
| Sample profile is not a live profile | sample banner | B-C12 | | | | |

---

## Multi-tool fidelity (B-T) — three arms, scored separately

This section does **not** use the Governed/Control delta. It compares three installs of the same package, and it is read qualitatively — one run each, human-in-IDE.

| Scenario | Rule location | Governed | Entry-files-only | Control | Interpretation | Run |
| --- | --- | --- | --- | --- | --- | --- |
| B-T1 (secrets) | **Inline** in `.github/copilot-instructions.md` | | | | | |
| B-T2 (accessibility) | Linked only — `coding-rules.md` §4 | | | | | |
| B-T3 (hedging) | Linked only — `writing-rules.md` §4 | | | | | |
| B-T4 (precedence) | Two links deep — `client-profiles/` | | | | | |

Reading the *Interpretation* column: governed and entry-files-only failing identically means the links are not being followed (README caveat confirmed → promote those rules inline). Governed passing where entry-files-only fails means the links **are** followed (caveat too conservative → soften it). Passing in all three means baseline model behavior.

---

## Layer A results

Mechanical checks. These are pass/fail with no arms and no delta — record the result and the date.

| Group | Checks | Result | Date | Notes |
| --- | --- | --- | --- | --- |
| A1 — build scripts run | A1.1–A1.3 | | | |
| A2 — `govern-init` file shape | A2.1–A2.11 | | | |
| A3 — `govern-update` merge semantics | A3.1–A3.12 | | | |
| A4 — links and drift | A4.1–A4.5 | | | |

Record individual failures by ID (e.g. `A3.4 FAIL — in-block Active client reverted to placeholder`) rather than only a group-level verdict; the group rows are a summary, not the record.

---

## Maintaining this file

When a rule changes substantively, the row that maps to it goes stale — clear its results rather than leaving a stale pass in place. When a rule is **added** to one of the three complete-coverage files, this matrix needs a new row and the plan needs a new scenario, or the completeness claim at the top of this file stops being true.
