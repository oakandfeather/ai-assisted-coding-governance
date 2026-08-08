# Coding Patterns for AI-Assisted Development

*Craft guide for code: reliable, efficient, maintainable. Companion to the safety/risk rules — [`core-rules.md`](./core-rules.md) (the task-agnostic base) and [`coding-rules.md`](./coding-rules.md) (the code rules); [`agent-workflow.md`](./agent-workflow.md) governs how to work. Sibling [`writing-patterns.md`](./writing-patterns.md) owns documentation *of* code — READMEs, runbooks, API references; this file owns the comments and docstrings inside a source file. On conflict, **safety and correctness win over efficiency and elegance**, and a stricter client profile (see [`client-profiles.md`](./client-profiles.md)) wins over both.*

**Version:** 1.4 · **Last reviewed:** 2026-08-07 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — apply on every change

1. **Smallest correct change.** Solve the stated problem; don't rebuild what works.
2. **Match the codebase.** Its conventions beat your preferences.
3. **Fail loudly, early, and specifically.** No silent failures, no swallowed errors.
4. **Validate at the boundary, trust the interior.** Check untrusted input once, at the edge.
5. **Correct, then clear, then fast** — and only fast with a measurement in hand.
6. **Leave it testable:** pure logic, injected dependencies, deterministic behavior.
7. **Clean up what you allocate:** connections, files, locks, timers.

Can't satisfy one? Flag the tension rather than quietly trading it away.

---

## 1. Reliability and correctness

- **Fail fast and explicitly.** Stop at the earliest invalid state with a specific error; a crash at the cause beats corrupt data three layers later.
- **Never swallow errors.** No catch-and-ignore, no `except: pass`, no discarded promise rejection. Handle, propagate, or log-and-rethrow.

  ```text
  BAD:  try { save(order) } catch (e) { /* ignore */ }   // failure vanishes
  GOOD: try { save(order) } catch (e) { throw new OrderSaveError(order.id, e) }
  ```
- **Handle every case:** error paths, empty inputs, boundaries (0, 1, n, max), and every enum/union variant. Prefer exhaustive `switch`/pattern matches that break loudly over a silent default.
- **Make errors actionable.** Say what failed and what state caused it — enough to diagnose without a debugger. (No secrets or regulated data in messages or logs — `core-rules.md` §1, `coding-rules.md` §2.)
- **Design for idempotency and retries** where an operation may run more than once (network calls, queue consumers, migrations): assume at-least-once delivery, guard side effects.
- **No partial writes.** Group must-succeed-together operations into a transaction or an all-or-nothing unit; never leave data half-updated on failure.
- **Concurrency:** prefer immutable data and message-passing over shared mutable state. Where sharing is unavoidable, make synchronization explicit and put timeouts on every blocking I/O and lock acquisition.

## 2. Simplicity and maintainability

- **YAGNI.** Build what the requirement needs, not what it might need; flag speculative extension points instead of adding them.
- **Prefer the boring, explicit solution.** Clever code is a liability the next maintainer pays for.
- **Don't abstract on the first occurrence.** Duplication is cheaper than the wrong abstraction; extract once the pattern is real (roughly the third repeat), not in anticipation.
- **One responsibility per unit.** An `and` in a function's true name means it should split.
- **Name for intent, not mechanism.** `retryableFetch` over `doFetch2`.
- **Keep functions shallow and short.** Cut nesting with early returns and guard clauses; deep indentation hides logic.
- **Comment the *why*, not the *what*.** Code shows what it does; comments carry intent, trade-offs, and non-obvious constraints. Match the surrounding comment density.

## 3. Efficiency and performance

- **Correct first, fast second.** Never trade correctness or clarity for speed the requirement doesn't demand.
- **Measure before optimizing.** Profile; don't guess at hot paths. Optimizing unmeasured code buys complexity for no proven gain.
- **Get algorithmic complexity right anyway.** Not premature — an O(n²) loop or an N+1 query is a design defect, not a micro-optimization. Watch for repeated work and per-iteration I/O inside loops.

  ```text
  BAD:  for user in users: orders = db.query(Order, user.id)   # N+1: one query per user
  GOOD: orders_by_user = db.query(Order, [u.id for u in users])  # one batched query
  ```
- **Right data structure for the access pattern.** Set/map for membership and lookup, not linear scans of a list; pick by how the data is queried.
- **Batch and stream at scale.** Batch remote calls and DB round-trips; stream or paginate large datasets instead of loading everything into memory.
- **Cache deliberately, not reflexively.** A cache buys invalidation and staleness bugs — add one only against a measured cost, and state its lifetime and invalidation.
- **Release resources promptly.** Close connections, files, and handles; free large buffers; use the language's scoped-cleanup construct (`with`, `defer`, `try-with-resources`, RAII) so cleanup survives the error path.

## 4. Interfaces and data

- **Narrow, honest contracts.** Expose the minimum surface; accept the least you need and return a precise type.
- **Validate untrusted input at the boundary; trust it inside.** Parse and check external input once at the edge, then pass well-typed, known-valid data inward — don't re-parse the same raw payload at every layer.
- **Make invalid states unrepresentable.** Use the type system and enums so bad combinations can't be constructed; prefer that to runtime guards where the language allows.
- **Immutability by default.** Favor immutable values and pure transformations; localize mutation. Shared mutable state breeds the hardest bugs.
- **Single source of truth.** Derive rather than duplicate; don't store what you can compute, and don't let two fields drift out of sync.
- **Be explicit about nullability and absence.** Distinguish "missing," "empty," and "zero"; don't overload one sentinel to mean several things.

  ```text
  BAD:  getDiscount() returns 0 for "no discount", "not yet loaded", AND "lookup failed"
  GOOD: getDiscount() returns Discount | None, raises LookupError on failure
  ```

## 5. Testability and change discipline

- **Write code that's easy to test.** Separate pure logic from I/O; inject dependencies (clock, network, filesystem, randomness) instead of reaching for globals. (What makes a *good* test: `coding-rules.md` §3 — test the requirement, not the implementation.)
- **Determinism.** No hidden dependence on wall-clock time, ambient locale, map iteration order, or unseeded randomness in logic that must be reproducible.
- **Separate refactors from behavior changes.** Don't bundle reformatting, renaming, and logic into one indivisible diff — it hides the real change from review. Keep diffs small and scoped.
- **Follow the existing structure.** Put new code where its neighbors live; reuse the project's existing helpers, error types, and patterns before introducing your own.
- **Update the types and docs that travel with the code** — signatures, docstrings, adjacent comments — so they don't rot against the change.

---

## Self-check before presenting code

Re-run the TL;DR above. Where a requirement forced a trade-off against one of those gates, name it in your hand-off. Then run the safety self-checks in `core-rules.md` and `coding-rules.md` — all gates apply.
