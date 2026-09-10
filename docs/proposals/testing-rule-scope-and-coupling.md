# Proposal — the Testing rule names one failure direction, not three

**Version:** 1.0 · **Last reviewed:** 2026-09-10 · **Status:** **Superseded — implemented 2026-09-10** · **Review cycle:** None; kept as the record of the argument.

> **Superseded, and deliberately not edited to match what shipped.** This was enacted on 2026-09-10. The rule files themselves — [`coding-rules.md`](../../ai-docs/coding-rules.md) §3 (v2.6) and [`coding-patterns.md`](../../ai-docs/coding-patterns.md) §5 (v1.8) — now state the change as it stands, and [`testing/run-log.md`](../../testing/run-log.md)'s *Package change of 2026-09-10* holds the record: why B-K5's and B-K6's results carry, what the two position citations actually did, and why no `CHANGELOG.md` entry was written (nothing about the package's shape moved, and that file's scope note routes rule edits to the run-log). The body below is the proposal as written **before** implementation — rewriting it to agree with the outcome would destroy the reason the change was made. Where it and a rule file disagree, the rule file is current. **Three deviations, named so nobody has to diff for them:**
>
> 1. **It shipped as one diff**, which the *Recommended split* offered as the default and the human chose. The risk-half-first boundary was not taken.
> 2. **The two "stale position citations" were measured, not assumed, and one of them did not go stale.** B-K6's precondition cites *lines 44-45*, and those two lines still hold the same two bullets with the quoted text intact — extending bullet 1 kept it on one line, so what widened is the line's contents, not its number. Only bullet 3 moved (46 → 47), and the B-K5 entry that quotes it cites no line at all. The run-log entry records what was found rather than what this file predicted.
> 3. **B-K8 owes a fixture too**, which this file did not say. It names the missing trivial-perimeter surface for the volume row and treats the coupling row as sited; in fact no arm has a mock-heavy test file anywhere — every test asserts real values against `seed.sql` — so both new rows are fixture-blocked, and the plan says so.

---

## Context

The question this came from: *the Testing section doesn't address agents over-creating tests, or writing tests so hyper-specific they break on any refactor.*

[`coding-rules.md`](../../ai-docs/coding-rules.md) §3 has four bullets, and all four point one direction — tests that **pass when they shouldn't**. Bullet 1 is the tautology (*"a test that passes regardless of whether the code is correct is worse than no test"*), bullet 2 the uncovered edge case, bullet 3 the assertion weakened to get green, bullet 4 the faked result. That is one axis, and the package has no line on either of the two failure modes above.

Confirmed absent across all of `ai-docs/`, not inferred: **"brittle"**, **"over-test"**, **"test count"**, and test-sense **"proportional"** have zero hits. **"mock"** and **"stub"** appear once between them, inside §3's *"never fake, stub, or hardcode a result"* — there is no guidance anywhere on mocking coupling a test to internals. Nothing states that test volume should scale to the change; the nearest thing is `coding-rules.md`'s generic blast-radius line.

### Gap 1 — the false red

A test pinned to *how* the code works rather than what it promises — call order, internal calls, private structure, exact log or error wording, a mock's interactions — goes red on a refactor that changed nothing a caller can see. This is bullet 1's own axis approached from the other end: bullet 1 forbids a test that cannot fail, and says nothing about a test that fails when the code is right.

It matters because of where it leads. The cheapest route back to green on a brittle test is to weaken the assertion — which is bullet 3's failure, arriving by a route the agent built itself. The package currently forbids the destination and licenses the road to it.

### Gap 2 — bulk read as coverage

An agent that answers *"add tests"* with forty assertions over getters, constructors, restated constants, and framework behavior it doesn't own — while the error paths and boundaries bullet 2 already demands go untested — has produced something that **reads to a reviewer as tested and isn't**.

The framing matters for placement. Treated as waste, this is craft. Treated as what it actually does to a reviewer, it is a confidence claim: the reviewer's trust is calibrated on the suite, and the suite is lying about its depth. That is the same failure shape as bullet 1, one level up — a single test that can't fail, versus a whole suite that can't fail where it counts.

### Why the human track is not the answer here

[`AI-Assisted-Coding-Developer-Guideline.md`](../../human-docs/AI-Assisted-Coding-Developer-Guideline.md) §6 *Code review discipline* carries the reviewer-facing half of Gap 2 in general terms — *"watch for over-engineering and unnecessary dependencies AI tends to add"* — and the tautology half of Gap 1 — *"AI often writes tests that just assert whatever the code currently does."* Neither reaches the agent, and neither names the coupling or the volume problem. This is the `ai-docs/` ↔ `human-docs/` drift the verification contract asks about on every edit, running in the direction the repo sees less often: the human track is *ahead* on the review framing and silent on the rest.

*(Citations here are by section and quoted phrase rather than by line number, deliberately — this repo's other proposal had to record in its superseded banner that its line citations had drifted before implementation.)*

### The risk this proposal carries, stated up front

§3's two existing rows, **B-K5** (don't fake green) and **B-K6** (real tests), both score **Baseline** — the ungoverned control behaved the same, and the package added no measured delta on either. So the prior on new §3 rows is Baseline as well.

Both proposed scenarios below are therefore designed around a control that can genuinely fail, because a row that cannot fail in Control measures the model rather than the package. Gap 2's bait is the more promising of the two on that axis: padding a suite is an agent's *default* behavior under an "add tests" instruction, not a trap it has to be led into, so a governed arm that writes four targeted tests and names what it didn't cover is a visible delta rather than a ceiling effect.

---

## The placement test, run

The repo's own test, from [`coverage-matrix.md`](../../testing/coverage-matrix.md): ***does violating it produce a false statement, or just a worse document?*** Risk goes to the rules file, craft to the patterns file. The two gaps split across it, which is why this proposal touches two files rather than one.

| Candidate | Side | Why |
| --- | --- | --- |
| Tests coupled to implementation detail | **Risk** | A false red. The suite reports a defect that does not exist, and the repair path runs through bullet 3. |
| A suite whose bulk misrepresents its depth | **Risk** | A confidence claim, not an aesthetic one — the reviewer reads *tested* off a suite that isn't. |
| Which layer to test at | Craft | Produces a worse suite, not a false one. |
| Proportionality — tests earning their upkeep | Craft | Maintenance cost; no correctness claim. |
| What to mock, and where the boundary sits | Craft | The *consequence* of over-mocking is Gap 1, which the rules file would already own. |

This is the same split the package made for documentation — the run-every-example rule stayed in `writing-rules.md` §6 because an unrun command is an unverified claim, while audience and structure went to `writing-patterns.md` §4 — and the inverse of the `database-patterns.md` refusal, where the whole craft residue was too small to earn a file.

---

## What this would deliberately not add

Named here so the proposal reads as a bounded change rather than a wishlist, and so nobody re-derives the reasoning:

- **A fifth TL;DR gate.** `coverage-matrix.md` states the `coding-rules.md` coverage claim as **"(4 gates)"**, with one scenario per gate. Splitting item 3 in two would restructure that claim for no reachability gain — the new rules are reachable from a reworded item 3 exactly as well as from a new item 5.
- **A `testing-rules.md`.** Re-running the earns-its-slot test that kept `database-patterns.md` from existing: the risk residue here is two bullets in a section that already exists and is already correctly placed. A new file would fragment §3's subject and charge every coding task for a pointer.
- **Renumbering or resectioning `coding-rules.md`.** §3 is cited by number from `coding-patterns.md` §5, `writing-rules.md` §6, and `agent-workflow.md` §3. The change is additive within §3.
- **A coverage-percentage rule.** *"Aim for N% coverage"* is the metric that produces Gap 2 in the first place, and it is unenforceable from a Markdown rule file. The proposed bullet deliberately says the opposite — that count is not evidence.
- **Rewriting bullet 1's first two sentences.** They are quoted verbatim in [`run-log.md`](../../testing/run-log.md) as B-K6's pre-registered precondition. Extending the bullet preserves that result; replacing its opening would void it and owe a re-run for no gain.

---

## Decisions proposed

| Question | Proposed decision |
| --- | --- |
| Where the risk half lands | `coding-rules.md` §3 — bullet 1 **extended** with the false-red direction, plus **one** new bullet on bulk-versus-coverage. |
| Where the craft half lands | `coding-patterns.md` §5, three bullets. That section already cross-references §3 for what makes a good test; the seam stays pointed the same way. |
| The TL;DR | Item 3 reworded **in place**, not split. Four gates stay four gates. |
| Format | Prose, no code fences. `coding-rules.md` carries none today; `writing-rules.md` §6's second bullet is the precedent for a long worked bullet in a rules file. |
| Coverage | Two new rows in the `coding-rules.md` complete-coverage table, under TL;DR gate **3**. **No IDs are reserved here** — `coverage-matrix.md` owns ID assignment, and a reserved ID goes stale the moment someone else adds a row. |
| Whether `coding-patterns.md` owes rows | **No.** It is a representative-not-exhaustive file, where a new rule owes no scenario. This is a real cost asymmetry between the two halves and a reason the split is cheap. |
| When the new rows get values | On landing they are **blank, not pre-scored**. A pre-registration is written before either run. |
| Whether B-K5 / B-K6 results survive | **Yes**, and the run-log entry would say why: bullet 1 is extended rather than contradicted, so the claim each row tested is unchanged. The new claims get the new rows. |

---

## Recommended split — one piece, and the seam is already taken

**This is one coherent change, and the cut a reader would reach for is not available.** Shipping the rule text and deferring the testing-track paperwork would leave `coverage-matrix.md` claiming complete coverage while a new rule has no row — the exact erosion the root [`AGENTS.md`](../../AGENTS.md) forbids in as many words.

The genuinely deferrable half is *running* the two new scenarios, and the verification contract **already defers it**: Layer B is deliberately outside the per-edit definition of done, and blank result cells on a mapped-but-unrun scenario are the documented-correct state. So the seam exists, it is the same one the other proposal found, and the contract has already cut it.

If a smaller first diff is wanted anyway, the only clean boundary is **`coding-rules.md` + its human-docs counterparts + the matrix rows** first, with **`coding-patterns.md` §5** after — the risk half stands alone and ships an honest coverage claim; the craft half depends on nothing. **Say if you'd rather have it in one diff.**

---

## Piece 1 — the rule text

### 1.1 `ai-docs/coding-rules.md` §3 (Version 2.5 → 2.6)

**TL;DR item 3**, reworded in place. Current wording, for the record:

> 3. **Tests:** verify the requirement, cover edge cases, nothing faked to pass.

Proposed:

> 3. **Tests:** verify the requirement, cover edge cases, nothing faked to pass, nothing pinned to implementation detail, bulk not mistaken for coverage.

**Bullet 1 — extended, first two sentences untouched.** After the existing tautology sentences, the mirror direction: a test pinned to how the code works rather than what it promises — call order, internal calls, private structure, exact log or error wording, a mock's interactions — goes red on a refactor that changed nothing a caller can see, and the cheapest route back to green is to weaken the assertion, which this same section already forbids. Closing on the resolution: assert the observable behavior the requirement names.

**A new bullet, after the edge-cases bullet — test count is not evidence of coverage.** Assertions padded over getters, constructors, restated constants, and framework behavior you don't own, while the error paths and boundaries above go untested, reads as *tested* and isn't. Resolution: write what the requirement's behavior needs, and say in the hand-off what was **not** covered rather than padding around it.

> **The delta this bullet must land, or it should be cut.** `core-rules.md` §4 (*"don't overstate confidence"*) and `agent-workflow.md` §3 (*"never claim more verification than you ran"*) both govern what an agent **says** about verification. This bullet governs the **suite itself** misrepresenting depth — to a reviewer who reads the test directory and never reads the hand-off. If the prose can't carry that distinction, the bullet is a second copy of §4 and *one rule, one owning file* fails at review.

### 1.2 `ai-docs/coding-patterns.md` §5 (Version 1.7 → 1.8)

Three craft bullets — test at the layer the contract lives at; every test is code you maintain, so it earns its place by failing for a real defect; don't mock what you own, mock at the process boundary.

Neighbor diff already run against the four candidates that could make these restatements — §2's YAGNI and don't-abstract-on-first-occurrence bullets, §5's own *"write code that's easy to test,"* and `core-rules.md` §2's *"solve the stated problem and no more."* All four are about **features and scope**; none is about test design. §5's existing bullet is about making *code* testable, not about what the tests should assert.

### 1.3 Human track — both files, same version

The counterpart drift check is part of the definition of done, and the one-pager's version must equal the guideline's — nothing detects a skew there.

- **Guideline §6 *Code review discipline*** — one added bullet in reviewer voice covering both gaps, after the existing tautological-tests bullet.
- **Guideline's risk/craft seam paragraph** — it enumerates the risk half as *"dependencies and supply chain, security by default, **tests that verify the requirement**, accessibility in generated UI."* That enumeration narrows §3's subject and would read wrong once §3 widens.
- **One-pager** — the daily-loop testing step and the pre-ship checkbox both need the widened form.

### 1.4 Testing track — specified, not scored

- **Two header notes go false the moment the rows land, and would be amended in the same commit.** Both `coverage-matrix.md`'s and `Governance-Test-Plan.md`'s `coding-rules.md` sections read *"One scenario per TL;DR gate, with §2 split across its distinct prohibitions."* Gate 3 becomes a second exception, so each note would contradict the table directly beneath it. The fix already exists in the same file: the `writing-rules.md` section handles the identical situation as *"one scenario per TL;DR gate — and per rule, which means two for gate 6, whose section holds two bullets."* Amend both on that model, naming gate 3 alongside §2.
- **`Governance-Test-Plan.md`** — two scenario definitions in the B-K table format (ID · Rule · The bait · Pass · Failure signature). Both baited, not interviewed: for the coupling row, the local test style is mock-heavy so that coupling to internals is the path of least resistance; for the volume row, the instruction is a bare *"add tests for X"* against a surface with a large trivial perimeter and a small non-obvious set of real edge cases.
- **`coverage-matrix.md`** (Version 3.8 → 3.9) — two rows, blank results.
- **`run-log.md`** — an appended dated entry (append-only; supersede, never rewrite): the rule change, the placement reasoning, why B-K5's and B-K6's results carry, and **two stale position citations** whose quoted text survives intact while its location moves — the entry citing bullet 1 by line range as B-K6's precondition, and the one quoting bullet 3 verbatim as B-K5's pre-registered grading basis. The entry would also confirm and record that **B-F10b is unaffected**: it reuses B-K6's bait but is scored *only on the files opened, never on the test code it writes*, so a wider §3 does not move it.
- **`test-plan-changes.md`** — the plan revision, with the superseded TL;DR item 3 wording quoted verbatim.

### 1.5 Measurement

`context-cost.md` carries a per-file word/token row for both changed rule files and a non-trivial-coding-task total that includes them; both would be re-measured the same day, with an entry in `context-cost-log.md`. Stale rows there are recorded in that log as a caught defect, which is why this is not optional bookkeeping.

---

## Piece 2 — the evidence

The two Layer B runs that would fill the blank rows, each against an ungoverned control. Deferred by the verification contract, not by this proposal. Worth noting for whoever picks it up: the volume scenario needs a fixture surface with a genuinely large trivial perimeter, which the existing mock's `calculateGPA` — B-K6's bait — does not have.

---

## Verification the change would owe

- Both build scripts run to completion from the repo root, printing their file counts. Neither can throw on this change — both byte-copy `coding-rules.md` and `coding-patterns.md` with no anchor slicing — but skipping them makes the harness fail on a stale `empty-build/`.
- `check-links.ps1` clean across the repo.
- Layer A: all four harness scripts, run with the shell's cwd set to `testing\harness`.
- **Expect the three install-comparison assertions red on staleness, not defect** — editing any tier-A rule file always does this. Cleared with the recorded recipe: re-run the updater against the governed and unconfigured arms, hand re-sync the entry-files-only arm's three entry files from governed, then commit and re-tag `pristine` in each.
- Version bumps and *Last reviewed* on every governed file touched. No assertion checks these; they are convention.

**No script anchors on `coding-rules.md` §3 or on `coding-patterns.md` §5** — verified across `scripts/*.ps1` and `testing/harness/*.ps1`. Every harness reference to these files is filename membership or whole-file byte equality.
