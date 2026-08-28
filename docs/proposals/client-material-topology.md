# Proposal — client-material topology for `govern-init`

**Version:** 1.0 · **Last reviewed:** 2026-08-28 · **Status:** **Superseded — implemented 2026-08-28** · **Review cycle:** None; kept as the record of the argument.

> **Superseded, and deliberately not edited to match what shipped.** This was enacted on 2026-08-28. [`CHANGELOG.md`](../../CHANGELOG.md) now owns the record of the shape as it stands, and [`testing/run-log.md`](../../testing/run-log.md)'s *Package change of 2026-08-28* holds why no Layer B scenario is owed. The body below is the proposal as written **before** implementation — rewriting it to agree with the outcome would destroy the reason the change was made. Where it and the shipped package differ, the shipped package and `CHANGELOG.md` are current. **Three deliberate deviations, named so nobody has to diff for them:**
>
> 1. **A and B landed as two commits on one branch**, not as A shipped and reviewed before B was started. The seam in the *Recommended split* below is preserved in the commit boundary; the review gate between them was not taken.
> 2. **`human-docs/Example-Client-AI-Policy.md` was recast whole in A**, not one paragraph in A6 and the rest in B4. A half-recast file would have left four documents pointing away from a stub whose title and section headings still claimed to be the destination — a contradiction between shipped files, which is what A6 exists to prevent. B4 added only the overlay-master bullet.
> 3. **`govern-init.md` step 4 also went plural**, which this proposal did not name. It said *"leave the paragraph beginning 'Add each client as'"*, singular; after A1 there are two package-owned paragraphs there, and an installer following it literally could drop the second. Same defect class A3 catches on the update side.
>
> Line numbers cited below had drifted by a line or two before implementation, and are left as written.

---

## Context

`govern-init` resolves its source package to a local clone of this repo (`$AI_GOVERNANCE_PATH`), then step 6 tells the agent the client's AI policy is the upstream authority and to *"work from the document"* — without ever saying where that document comes from. The only location the package names for a client policy is `human-docs/Example-Client-AI-Policy.md`, **a single file inside this repo**, which is confirmed **public** on GitHub (`gh repo view` → `"visibility":"PUBLIC"`).

So a fresh clone gives you a repo that talks as though it holds your client's documents, has one slot for N clients, and can never legitimately hold any of them.

Three concrete defects:

1. **No inbound path.** Nothing tells the agent to ask for the policy — a path, a URL, or a paste. `ai-docs/client-profiles/example-university.md:5` says *"see `client-profiles.md` for where it lives"*; `client-profiles.md` never says. Dangling pointer.
2. **One shipped sentence, two opposite meanings.** `client-profiles.md:13` — *"Add each client as `client-profiles/<client>.md` and link it here"* — reads as "profiles accumulate here" in the source repo and "in this engagement repo" in the installed copy. Same text, two homes.
3. **Multi-client is undefined.** `client-profiles/` holds N files and the heading is plural, but `core-rules.md` §8 says *"the active client"* (singular), `AGENTS.md` carries one **Active client** value in two places, and nothing says which profile governs when two apply and disagree.

**Outcome:** client material never touches this public repo. Each engagement repo is self-contained; an optional private overlay repo holds the masters so one client across several repos doesn't get re-interviewed and drift.

## Decisions taken

| Question | Decision |
| --- | --- |
| Where client material accumulates | Engagement repo, **plus an optional private overlay repo** holding only `clients/<client>/{profile,policy}.md` — never rule files. `govern-init` prompts for both paths when the env vars are unset. |
| How the policy reaches the engagement repo | **Reproduced** into `ai-governance/client-policies/<client>.md`, with a cite-only fallback (title + version + canonical URL in the profile) when the client won't permit the text in their repo. |
| Multi-client | Supported by construction via directory shapes; composition rule = **the stricter of two profiles governs, per rule**. Single-client path looks exactly as it does today. |
| Write-back to the overlay | **Offer, don't assume** — `core-rules.md` §5 confirm-before-out-of-scope. |

**The load-bearing invariant this establishes:**

> The overlay is a source the installer reads **from**, never a location an installed repo points **at**. Anything the engagement repo references must resolve for someone holding only that repo plus their normal client access.

That is why the policy is copied in rather than linked: a cross-repo path resolves only on machines that happen to have the overlay, and fails *silently* — the authority note still reads authoritative. Which is the exact defect in (1) above.

---

## Recommended split — two pieces, at a real dependency boundary

**Piece A defines what an install contains and how the agent obtains the policy. Piece B adds a second source that supplies those same artifacts.** B depends on A having defined `client-policies/`; A stands alone and is worth shipping alone — someone with no overlay gets a completely fixed install flow, supplying the policy by path, URL, or paste.

I'd land A first and review it before starting B. **Say if you'd rather have it in one diff** — the pieces are separable, not independent, and one PR is defensible.

**There is a second seam inside A.** A1+A2+A3 are the fix to the reported defect and are shippable on their own; A4–A7 are correct and necessary but ride along. If you want the bug fixed and reviewed fast, take those three first and the rest as a follow-up — same accept-or-decline.

---

## Piece A — the engagement repo's shape

### A1. `ai-docs/client-profiles.md` — the pointer that resolves everything

Add **one new paragraph immediately after** the `Add each client as…` paragraph and **before** `## Sample profile`, stating:

- Where the client's own policy lives: `client-policies/<client>.md` beside the profiles, or — when it can't be reproduced — cited in the profile's authority note by title, version, and canonical URL.
- The composition rule: where two or more active profiles differ, **the stricter governs, rule by rule** (the package's existing universal tiebreak, applied to profiles). **Plus the clause that completes it:** where two profiles are not comparable on a rule — different disclosure trailer formats, different escalation contacts, different data-classification vocabularies, anything not on a common scale — there is no stricter option, and that is a `core-rules.md` §7 stop-and-ask. Without this, an agent meeting two incomparable rules either picks one arbitrarily or stalls, and "the stricter governs" is only half a rule.

Also clarify line 13's `Add each client as…` to say *this repo* means the repo the file is installed in, killing defect (2).

**Add the scope test to line 13's field list — what a profile leaves out.** Line 13 says what to cover and never says what to exclude, so the rule currently exists only as a passing clause in `govern-init.md:97` and a footnote in the ESU sample. It belongs here, because `govern-update` never touches profiles and humans edit them long after install. One clause: **a profile carries only what changes an agent's behavior on a task**; procurement, governance bodies, contract terms, and org structure belong in the human guideline, and anything restating `core-rules.md` belongs nowhere (one rule, one owning file).

Bump `Version` / `Last reviewed`.

> **Placement is mechanically constrained — three traps, all verified:**
> - `build.ps1` and `build-empty.ps1` call `Replace-Paragraph` anchored on the literal `*(none yet)*`, replacing **through the next blank line**. New text must be its own blank-line-separated paragraph or it gets swallowed.
> - Both scripts truncate this file at `## Sample profile` (`build-empty.ps1:139`). Anything after that heading never reaches `empty-build/`.
> - `govern-update.md:104` bounds the target-owned region as *everything between the `## Active client profiles` heading and the paragraph beginning "Add each client as"*. A paragraph placed **after** that anchor is package-owned and safe; one placed before silently becomes client content that update preserves forever.
>
> Reference `client-policies/<client>.md` as **inline code, not a Markdown link** — the directory doesn't exist in `ai-docs/`, and `check-links.ps1` would fail. Line 13 already uses inline code for `client-profiles/<client>.md`; follow that precedent.

### A2. `ai-docs/procedures/govern-init.md` — step 6 only

**Do not add a numbered step.** Root `AGENTS.md` records the step numbering as load-bearing, and `build-empty.ps1:118,125` cites "step 4" by number. Everything below folds into the existing step 6.

- **Inbound path (the core fix).** Before "work from the document," instruct the agent to *ask where the document is*: a path in the target repo, a path elsewhere on disk, a URL, or a paste. If none is available, say so and proceed by interview — recording that the profile is interview-sourced, which the hand-off already asks for.
- **Reproduce it.** Write the policy verbatim to `ai-governance/client-policies/<client>.md`. Create the directory here — it is **not** in the step 2 copy table, so the "nine `ai-governance/` items" counts in `AGENTS.md`, `README.md:128`, `govern-init.md:23`, and `Governance-Test-Plan.md:59` all stay correct. Verify that with a `\b(eight|nine|ten)\b` grep rather than trusting this note.
- **Cite-only fallback.** When the client permits citation but not copying: no policy file; the profile's authority note carries title, version/date, and the client's canonical URL, and says plainly that the full text lives with the engagement lead. Mirrors step 6's existing *"no profile is safer than an invented one"* discipline without discarding what you legitimately know.
- **Derive the profile from the policy — the step's real job, currently unstated.** Step 6 says the profile summarizes the policy, then says *"Interview for these,"* as though the interview were the source. Make the order explicit: **when a policy is in hand, extract the five fields from it first, then interview only for what it doesn't cover.** With the derivation rules below, because summarizing a governing document is precisely where an unsupported rule gets written down and then reads as authoritative:
  - **Cite what each field came from** — the policy section it was derived from — and **pin the version** in the authority note (title + version/date). When the client revises the policy, the profile's staleness becomes visible instead of theoretical. This is what makes the cite-only path safe as well.
  - **Silence is not permission.** A field the policy doesn't address is marked *not addressed by the policy* and asked about — never filled from general knowledge or from the ESU sample. `Example-Client-AI-Policy.md:15` already argues this: *"the gaps are as informative as the content, because a silent client is one whose data you treat as sensitive by default."* If the user can't supply it either, leave it unfilled and say `core-rules.md` §8 governs that field.
  - **A URL you cannot fetch is not a policy you have read.** Most client policies sit behind SharePoint or intranet SSO. If retrieval fails, that is the same outcome as no document: interview, and record the URL as an unverified upstream. Never summarize a document you did not open — `writing-rules.md` §§1–2 and step 6's existing *"never invent a client rule"* both bind here, and a derived profile that outruns its source suppresses §8's fail-safe exactly as an invented one does.
  - **The human confirms the derivation before it is written.** A profile derived from a document nobody reviewed is governance nobody approved. Step 6 is already an interview; this costs one exchange.
  - **Derive, don't transcribe — apply the scope test to every candidate line.** *Does this change what an agent does on a task?* If not, it goes to the human guideline, not the profile. A policy document is long and sectioned, and deriving "the five fields" from it invites wholesale copying; this is the guard. **Cut:** approved-tool lists and procurement paths, governance bodies and policy owners, review cadences, contract terms and signing authority, org and committee structure, the policy's rationale and background prose, and anything that merely restates `core-rules.md` (a profile repeating "don't hardcode secrets" because the client policy says so breaks the one-rule-one-owning-file discipline). **Keep:** data classification and what may never reach a tool, the hard never-with-AI list, disclosure format, compliance regimes, the accessibility standard, the escalation contact — the agent needs a name when it stops — and the *behavioral* residue of tool rules, such as "no vendor training on client code" and "don't accept AI tool terms on the client's behalf." **Length is the cheap signal:** a derived profile materially longer than `example-university.md` means transcription, not derivation.
  - **Fix the contradiction this exposes.** `govern-init.md:91` tells the interview to collect *"Permitted AI tools — and whether a specific approved/enterprise instance is required,"* while `example-university.md:5` states the profile *"intentionally omits the approved-tool list that appears in the human guideline"* because procurement is out of the agent's scope. The exemplar is right: an agent already running cannot act on which tool was approved. Amend the field list at `:91` to collect the behavioral residue rather than the tool roster, and keep the human guideline as the roster's owner.
  - **This is a scope cut, not a density pass** — it removes content that never bound, rather than compressing content that does. Keep the distinction visible in the commit message; this repo has twice rejected density passes on `ai-docs/`, and the reasoning there does not transfer here.
- **Multi-client.** Say the step repeats per client — derivation included, one policy per profile — and that `AGENTS.md`'s **Active client** may name more than one.

### A3. `ai-docs/procedures/govern-update.md` — keep client policies untouchable

- Tier E extends from `ai-governance/client-profiles/*.md` to **also** `ai-governance/client-policies/*.md`. The *"Tier E is absolute… do not read"* rule at line 46 applies unchanged and matters more here — this is the client's own document.
- Line 102: *"The paragraph beginning 'Add each client as…' is the package's"* → the paragraph**s** from that anchor onward. Bounding anchors at line 104 are unaffected.
- Step 7's **Untouched** bullet names both directories.

**The already-installed case — do not skip this; it is where the fix reintroduces its own bug.** Every repo installed before this change has no `client-policies/`, and nothing will ever create one: `govern-update.md:52` handles files "added upstream" only for things copied *from source*, and `client-policies/` never is (see A2). Such a repo comes out of `/govern-update` carrying the new `client-profiles.md` paragraph that points at `client-policies/<client>.md` — with no such directory. That is defect (1) recreated, in the very file whose job is resolving the override chain.

So `govern-update` must **notice and report** it: if the target has `ai-governance/client-profiles/*.md` but no `client-policies/`, the tier-D hand-off says so as open work — supply the policy, or convert the profile's authority note to the cite-only shape. It must not create the directory or fabricate a policy; reporting is the whole job. Silence is the one unacceptable outcome.

### A4. `ai-docs/AGENTS.template.md:11,27` — accept a list

Reword the prose around **Active client** to allow one or more clients, pointing at `client-profiles.md` for the composition rule.

> **Keep the placeholder tokens byte-identical**: `*(date)*`, `*(client name)*`, `*(fill in)*`. `build.ps1:116–118` matches them literally via `Replace-Placeholder`, and `Assert-NoPlaceholders` (`build.ps1:92`) throws on any `*(…)*` survivor. Change the surrounding sentence, not the tokens.

### A5. `ai-docs/client-profiles/example-university.md`

Line 5's *"see `client-profiles.md` for where it lives"* resolves once A1 lands. Tighten the authority note into the shape `govern-init` now requires — title, version/date, canonical link — since this file is the exemplar step 6 tells the agent to copy the *shape* of. Keep it fictional (`example.edu`, `555-01xx`); ESU still has no policy document, so model the **cite-only** shape here.

### A6. Re-point the "slot" claims

`README.md:158`, root `AGENTS.md:148` and `:154`, and `human-docs/AI-Assisted-Coding-Developer-Guideline.md:188` all say the client's policy gets reproduced into `human-docs/Example-Client-AI-Policy.md`. Re-point them at the engagement repo's `ai-governance/client-policies/`.

**Include the stub's opening paragraph in this piece, not in B.** `Example-Client-AI-Policy.md:5` currently reads *"This file is a slot, not a policy… reproduce it here verbatim."* If A ships alone and that paragraph stays, four files point away from the stub while the stub still claims to be the destination — a direct contradiction between shipped files, which is worse than the defect being fixed. Recast that one paragraph here (slot → shape template, and where the real thing lives); B4 does the rest of the file.

### A7. Testing track

- `testing/Governance-Test-Plan.md` — Layer A gains a check that `ai-governance/client-policies/` is reported untouched by `govern-update`, and a check that a target with profiles but no `client-policies/` is *reported as open work* (the A3 case above). **Keep this out of A2.2.** That row reads *"All nine `ai-governance/` items present — the seven rule files, `client-profiles.md`, and `client-profiles/`"* and describes the copied-from-source set, which is unchanged; adding `client-policies/` there would contradict the counts A2 deliberately preserves. New rows, not an amended A2.2 — and re-read A2.2's wording after editing to confirm the two don't disagree inside one file.
- **No new Layer B scenario is owed.** The composition rule lands in `client-profiles.md`, which is not in `coverage-matrix.md`'s complete-coverage set (that set is the TL;DR checklists of `core-rules.md`, `coding-rules.md`, `writing-rules.md`, `database-rules.md`). Putting it in `core-rules.md` §8 instead *would* owe one — that is the reason for this placement, and the plan should say so in `run-log.md` so nobody "restores" it later.

---

## Piece B — the optional private overlay

### B1. `ai-docs/skills/govern-init/SKILL.md` — second rung on the ladder

The launcher's source-resolution ladder gains the overlay, kept parallel to the existing one:

1. A path the user gives you.
2. `$AI_GOVERNANCE_CLIENTS_PATH` if set.
3. **Prompt for it**, and offer to persist it (`[Environment]::SetEnvironmentVariable(...,'User')` on Windows, shell profile on macOS/Linux — the same two forms `README.md:62,85` already document for `$AI_GOVERNANCE_PATH`).

Unlike the package path, **a missing overlay is not a stop** — it is optional, and `govern-init` proceeds by interview. Say that explicitly; the existing ladder's "stop and say so" posture must not leak onto this one. `govern-update` needs no overlay at all (it never touches client files) — leave that launcher alone and note why.

### B2. `ai-docs/procedures/govern-init.md` — read the overlay in step 6

The **Source package** section gains a short second subsection: the overlay, what it holds (`clients/<client>/profile.md`, `clients/<client>/policy.md`), and what it explicitly does not (any rule file — two sources for a rule means two answers to "what does `core-rules.md` say," which is the drift the whole package exists to prevent).

Step 6, in order: check the overlay for the named client → copy its profile and policy in if present → otherwise interview and author → **then offer** to save the result back to the overlay as the master. Never write to the overlay without a yes; today's *"don't write into the governance repo from here"* becomes *"the overlay is a different repo and a different review — ask."*

### B3. `README.md`

Path A setup gains the optional second clone and env var; Path B's paste-instruction mentions it; Path C notes the overlay is irrelevant when copying by hand. Keep the "optional" framing prominent — a solo engagement with one repo per client should not feel obliged to set it up.

### B4. `human-docs/` recast

- **`Example-Client-AI-Policy.md`** — recast from *"reproduce the client's policy here"* to a **shape template**: what such a policy covers (§13's list is already exactly that and survives unchanged), plus where the real thing lives — overlay master, engagement-repo copy. **Recommend recasting, not renaming**: a rename costs five touch points (`README.md:158`, `AGENTS.md:148`/`:154`, guideline `:188`, `CHANGELOG.md`) plus `check-links.ps1`, and the content change carries the whole substance.
- **`AI-Assisted-Coding-Developer-Guideline.md` Appendix A** (`:167–194`) — from *"maintain one profile per active client"* here, to: this is the shape and the worked ESU example; live profiles live in the overlay and in each engagement repo.
- **`AI-Coding-Onboarding-One-Pager.md`** — bump to match the guideline. Per root `AGENTS.md`, the one-pager's version tracks the guideline's and **nothing detects a skew**.

### B5. Root `AGENTS.md` + `CHANGELOG.md`

Root `AGENTS.md` gains a short section on the two sources and the read-from-never-point-at invariant; the human-docs mapping is updated. `CHANGELOG.md` records the shape change — a second, optional, private source, and the rule that client material never enters this public repo — with the reasoning, per the *"a working document states current state; its dated record lives in the matching log"* convention.

---

## Verification

Run from the repo root, in this order:

```powershell
.\scripts\build.ps1          # must complete and print its file count
.\scripts\build-empty.ps1    # must complete and print its file count
.\scripts\check-links.ps1    # must exit 0
```

A script that throws is a stop signal, not something to work around — it means a template's structure no longer matches its anchors. The A1 paragraph placement is the likely trigger; fix the script alongside the edit if so.

Then, because `ai-docs/` was materially edited, **re-run Layer A**:

```powershell
cd testing\harness
.\check-identity.ps1; .\check-fixtures.ps1; .\check-layer-a.ps1; .\check-layer-a-extra.ps1
```

Each must exit 0. The A3 group is stateful and needs the source aged first — see `testing/harness/README.md`.

Manual checks the scripts cannot make:

- **Grep `\b(eight|nine|ten)\b` across `*.md` and `scripts/*.ps1`** and confirm every count still describes the copied-from-source set. `client-policies/` must not have crept into the step 2 copy table.
- **Inspect `empty-build/ai-governance/client-profiles.md`** — the A1 paragraph must be present, the `*(none yet)*` empty state intact and not merged into it, and nothing lost to the `## Sample profile` truncation.
- **Derivation dry run:** write a short fictional policy that deliberately covers only three of the five profile fields, is silent on the other two, and is padded with procurement, governance-body, and review-cadence sections. Run `govern-init` against it. The derived profile must cite its sections, pin the version, mark the two silent fields as *not addressed* rather than filling them, **omit every padded section**, come out no longer than `example-university.md`, and be shown for confirmation before it is written. Repeat with an unreachable URL and confirm the run falls back to interview instead of summarizing a document it never opened — that is the failure mode most likely to look like success.
- **End-to-end dry run:** `govern-init` against a throwaway repo outside this one, once with no overlay (interview path, cite-only fallback) and once with a scratch overlay holding a fictional client. Confirm `client-policies/` lands, the counts hold, and the write-back offer asks rather than acts. Do **not** scaffold this inside the repo — `govern-init` would create the `ai-governance/` directory this repo forbids.
- **The already-installed case (A3):** take a mock arm installed *before* this change — one with a profile and no `client-policies/` — and run `govern-update` against it. The hand-off must name the missing directory as open work, and the run must not create it or invent a policy. This is the check that catches the reintroduced dangling pointer; skipping it is skipping the reason A3 exists.
- **Drift check** `ai-docs/` ↔ `human-docs/`; each rule still stated in exactly one owning file.
- **`Version` / `Last reviewed`** bumped on every governed document touched, dates absolute; one-pager version equal to the guideline's.
- Layer B is deliberately **not** in this contract. A7 argues no new scenario is owed; record that reasoning in `testing/run-log.md` so it is not silently reversed.
