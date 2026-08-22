# AI Database Rules for Coding Agents

*Rules for working in a database project — a repository where the schema itself is the deliverable, whether a declarative schema project or a migration-based one — with §§1–5 below the whole scope. **Read [`core-rules.md`](./core-rules.md) first:** it holds the task-agnostic base that binds on every task; this file adds only the database-project rules on top of it. **Application code that queries a database** — the injection surface, input validation, the data-access layer — is [`coding-rules.md`](./coding-rules.md); this file governs the schema as the thing being shipped. Where a client profile (see [`client-profiles.md`](./client-profiles.md)) is stricter, it wins. Companions: [`coding-patterns.md`](./coding-patterns.md) (engineering craft) and [`agent-workflow.md`](./agent-workflow.md) (how to work).*

**Version:** 1.0 · **Last reviewed:** 2026-08-22 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — the schema checklist to run on every change

Run this **after** the `core-rules.md` TL;DR. Full detail in §§1–5.

1. **Deploy guards:** no data-loss or drop guard relaxed to make a deploy succeed.
2. **Data loss:** nothing dropped, renamed, narrowed, or rebuilt without preserving the data it holds.
3. **Preview:** the project builds, and the generated deploy script was read before it ran.
4. **Source of truth:** the project is authoritative; drift is reported, not absorbed or overwritten.
5. **Shipped data:** committed reference data is synthetic, and deployment scripts are re-runnable and secret-free.

Any "no" or "unsure": fix or flag it before presenting. Scale depth to the blast radius (`core-rules.md`) — a comment, or a new nullable column with a default, needs a quick pass; anything that drops, renames, narrows, rebuilds, or deploys gets the full check deliberately, stated in your hand-off.

---

## 1. Deploy guards are security settings

Applying a schema to an environment is an irreversible action, so `core-rules.md` §5's confirm-first gate, least privilege, and no-standing-production-credentials rules apply here unchanged. This section adds only what is specific to a schema deploy.

- **Never relax a data-loss guard to make a deploy succeed.** Publish and migration tools ship settings that refuse to apply a change that would drop an object or discard rows. Turning one off is not configuration — it deletes the check standing between a schema change and permanent data loss, the schema analog of `coding-rules.md` §3's rule against weakening a failing test. A blocked deploy is the finding: report what it refused and what that change would have destroyed.
- **Treat "shared" as wider than "production."** A team's development or integration database holds other people's work in progress, so a deploy that resets or overwrites it is destructive even though nothing there is live. Confirm before applying to any database you are not the sole user of.
- **Never widen permissions, disable a constraint, or drop a security object to get a script to run.** Grants, access policies, and audit objects defined in the project are part of the deliverable, not obstacles to it.

## 2. Rename is not drop-and-recreate

- **Preserve the rename record your tool keeps.** Renaming a column or table in the project source is ambiguous on its own: unless the tool is told it is a rename, it generates a drop and a create, and the deploy discards every row in the old object while reporting success. Where the tool records refactors in a log or a versioned migration, that record is source — commit it with the change, and never regenerate it by hand.
- **Call out every narrowing change explicitly.** Dropping a column, shortening or changing a type, tightening nullability, and adding a constraint or unique index all either fail or lose data against a populated target. Name them in your hand-off; don't let them ride along in a diff of otherwise additive changes.
- **A schema change that needs a data migration is not done without it.** When existing rows must be backfilled, transformed, or split to satisfy the new shape, that step is part of the change. Ship it alongside, or stop and say the change cannot be applied safely yet.

## 3. Read the generated script before you run it

§1 governs whether you are authorized to deploy; this governs whether you know what the deploy does. They fail separately — an authorized deploy of an unread script is still an unverified change.

- **Generate the deploy script and read it.** In a database project you author the desired state and the tool derives the change, so the derived script is what actually runs. Authoring the schema is not verifying it, the same way `writing-rules.md` §6 holds that an unrun example is an unverified claim. Build the project, produce the script or plan against a representative target, and read what it will do.
- **Report what it drops, alters, or rebuilds.** A generated script routinely rebuilds a whole table to change one column — copy out, drop, recreate, copy back. That is a downtime and locking claim, and on a large table it is the most important fact about the change. Surface it before the deploy, not after.
- **Preview against something representative.** A preview against an empty local database proves the project compiles, not that the change is safe. Where you cannot reach a populated target, say so explicitly rather than presenting the empty-database result as verification.

## 4. Drift and the source of truth

- **The project in version control is authoritative.** Where a deployed database differs from it, the difference is a finding to report, not a discrepancy to resolve on your own judgment — someone changed one of them for a reason you cannot see from here.
- **Never reconcile by editing the live database.** Applying a fix directly to a deployed database to make it match the project puts that change outside review, outside history, and outside every other environment.
- **Check what a schema import carries before you commit it.** Scripting an existing database into the project is a legitimate starting move, and it pulls in more than tables: real rows in reference and lookup tables, environment-specific objects, comments and extended properties quoting internal detail, and credentials embedded in external-data-source, linked-server, or scoped-credential definitions. `core-rules.md` §1 applies to every one of those before the import is committed.

## 5. Data and scripts that ship with the schema

Deployment scripts run on every deploy, against targets that already hold data. Idempotency is craft in `coding-patterns.md` §1; here it is a data-safety rule, because a script that assumes an empty database corrupts or fails against a populated one.

- **Make every deployment script re-runnable.** Guard inserts against rows that already exist, make object creation conditional, and never write a script whose second run does something different from its first. A script that only works once is a defect, not a convention.
- **Committed reference data is shipped data.** Lookup tables, seed rows, and fixtures checked into the project are copied into every environment it deploys to, so `core-rules.md` §1's synthetic-data rule applies to them directly: obviously-invented values, never real records lifted from a live database.
- **Deployment scripts are a common secret-leak path.** Connection strings, credentials for external sources, and service-account passwords end up in post-deployment scripts because that is where the wiring happens. They are committed code, and `core-rules.md` §1 forbids them there as anywhere else.

*(Application code that reads or writes a database — parameterized queries, input validation, the injection surface of dynamic SQL built inside a procedure or function — is [`coding-rules.md`](./coding-rules.md) §2. Performance craft — indexing for the access pattern, query shape, connection pooling, N+1 — is [`coding-patterns.md`](./coding-patterns.md) §3. Documentation of the schema — data dictionaries, runbooks, migration notes — is a written deliverable: [`writing-rules.md`](./writing-rules.md) §6 governs its risks, [`writing-patterns.md`](./writing-patterns.md) §4 its craft.)*

---

## Self-check before presenting a schema change

Re-run this file's **TL;DR** **and** the `core-rules.md` TL;DR — both gates apply, at the depth the blast radius warrants. For any change that drops, renames, narrows, or rebuilds an object, or that will be deployed to a shared environment, state in your hand-off which items you verified and what the generated script does, so the human reviewer sees the check rather than assuming it.
