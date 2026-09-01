# govern-init — install the governance package into a target repo

Scaffolds the governance package into a target project. This procedure **copies** the rules; it does not contain them. The rule text lives in the copied files, where it auto-loads every session and stays auditable in the client's repo.

**How this is run.** Follow it directly, start to finish. Either run `/govern-init` in Claude Code, or hand any other coding CLI — Codex CLI, the Copilot CLI — the path to this file and tell it to read the file and follow it exactly. Nothing here needs a tool or a tool-specific feature: every step is reading files, writing files, and asking the user questions.

## Source package

**The source package is the repository you are reading this file from.** Every file named below lives in its `ai-docs/` directory; read them from there.

**Do not reconstruct the rule files from memory** — a paraphrased safety rule is not the safety rule. If a source file named below cannot be read, stop and say so rather than writing an approximation of it.

### The client overlay — a second source, optional

Some teams keep client masters in a **private overlay repo**, so that one client appearing in several engagement repos is interviewed once rather than re-derived and drifting. Its shape is `clients/<client>/profile.md` and `clients/<client>/policy.md`, and **nothing else — never a rule file.** Two sources for a rule would mean two answers to "what does `core-rules.md` say," which is the drift this whole package exists to prevent.

Resolve it the way the launcher describes — a path the user gives you, `$AI_GOVERNANCE_CLIENTS_PATH`, or a prompt. **A missing overlay is not a stop**, unlike a missing source package: it is optional, and step 6 interviews instead.

**The overlay is a source you read *from*, never a location the installed repo points *at*.** Everything the engagement repo references must resolve for someone holding only that repo plus their normal client access — a cross-repo path resolves only on the machines that happen to have the overlay, and fails *silently* while the pointer still reads authoritative. So copy in; never link out.

## Procedure

### 1. Check before writing

- Confirm the target is the intended repo **root**. `AGENTS.md` and `CLAUDE.md` land there — they only auto-load from the root — and the companion files go in an `ai-governance/` directory beneath the root.
- If an `AGENTS.md` or `CLAUDE.md` already exists: **stop and show the user what's there.** Do not overwrite. Offer to merge the mandatory-rules block into the existing file instead, and let them decide.
- If the companion files or an `ai-governance/` directory already exist, report which ones and ask before replacing — they may carry local edits.

### 2. Copy the file set

The two entry files land at the repo root; the other nine items travel together into an **`ai-governance/`** directory you create at the root. `AGENTS.md` links into `./ai-governance/`, `CLAUDE.md` imports `AGENTS.md` plus `ai-governance/core-rules.md`, `ai-governance/agent-workflow.md`, and the `ai-governance/client-profiles.md` index, and the files inside `ai-governance/` link each other with relative `./` paths — separating them breaks the chain.

| From `ai-docs/` | To target repo |
| --- | --- |
| `AGENTS.template.md` | `AGENTS.md` *(repo root, renamed — the canonical entry)* |
| `CLAUDE.template.md` | `CLAUDE.md` *(repo root, renamed — thin: `@AGENTS.md` plus the two always-on rule imports and the client-profile index)* |
| `core-rules.md` | `ai-governance/core-rules.md` |
| `coding-rules.md` | `ai-governance/coding-rules.md` |
| `writing-rules.md` | `ai-governance/writing-rules.md` |
| `database-rules.md` | `ai-governance/database-rules.md` |
| `coding-patterns.md` | `ai-governance/coding-patterns.md` |
| `writing-patterns.md` | `ai-governance/writing-patterns.md` |
| `agent-workflow.md` | `ai-governance/agent-workflow.md` |
| `client-profiles.md` | `ai-governance/client-profiles.md` |
| `client-profiles/` | `ai-governance/client-profiles/` *(the directory — see the exclusion below)* |

Do not copy `human-docs/` — it is for people and stays in the governance repo. Do not copy `ai-docs/procedures/`, `ai-docs/skills/`, or `testing/` either: this procedure, its launchers, and the governance repo's own test plan are maintenance tooling for that repo, not part of the installed package.

**Copy the bytes, and write them consistently.** These files are UTF-8 without a byte-order mark; keep them that way — a BOM in a Markdown file that Codex or another CLI agent reads is a real defect, not a cosmetic one. Use one line-ending convention across the whole copied set, matching whatever the target repo already uses (its `.gitattributes` if it has one, otherwise its existing files). Getting this right at install is what lets `govern-update` later produce a small, reviewable diff instead of rewriting every line.

**Never copy `client-profiles/example-university.md`.** It is a fictional sample client that exists only to show a profile's shape; a real client's repo must never contain another client's profile, least of all an invented one. Read it from the governance repo when you need the shape (step 6) — don't land it in `ai-governance/client-profiles/`. If that directory has no real profile yet, it correctly arrives empty.

### 3. Strip the template banners

Both entry files ship with a "how to use" banner that must come off after copying:

- **`AGENTS.md`** — retitle `# AGENTS.md (template)` to `# AGENTS.md` and delete the banner block above the `Version:` line. It describes the template rather than the project, and its `../AGENTS.md` link does not resolve outside the governance repo. **Also delete the closing footnote** — the trailing `---` and the italic *"Fill in the italicized placeholders for this repository…"* paragraph after it. It is install instructions, not project guidance, and it points at "the note at the top" that you just removed. This is the file whose placeholders you fill (step 5).
- **`CLAUDE.md`** — retitle `# CLAUDE.md (template)` to `# CLAUDE.md`, delete everything from the `(template)` title down through the horizontal rule, and **keep everything beneath it verbatim**: the `@AGENTS.md` import, the `@ai-governance/core-rules.md`, `@ai-governance/agent-workflow.md`, and `@ai-governance/client-profiles.md` imports, their lead-ins, and the HTML comment. No placeholders here. **Do not trim the three imports as "not thin."** `AGENTS.md` *links* those files rather than importing them, so without these the always-on rules — and the pointer to the client profile that outranks them — load only if the agent chooses to open them, and measured behaviour says it often does not. They are routing, not rules: no rule text is duplicated, and a missing import fails silently, so nothing will tell you it was dropped. **The imported `client-profiles.md` is the index only.** The profile itself stays linked from it, so it is still read at a depth scaled to the task rather than charged to every trivial edit.

### 4. Strip the sample from the copied index

The copied `ai-governance/client-profiles.md` ships with a `## Sample profile` section pointing at `example-university.md`, and an `## Active client profiles` paragraph written for the governance repo — it says there is no live profile and refers to "the sample below." Neither is true in a client's repo, and the sample link would dangle now that the file isn't copied.

Delete the `## Sample profile` section outright. Rewrite the `## Active client profiles` body to match reality once you reach step 6 — the real client's entry, or an honest empty state:

```markdown
## Active client profiles

*(none yet)* — **this repo has no client profile.** Do not infer the client's rules from anything here; ask the engagement lead. Per `core-rules.md` §8, treat the client's data as sensitive by default until a profile exists.
```

Leave **every paragraph from "Add each client as `client-profiles/<client>.md`" onward** — the field list and scope test, and the paragraph on where the client's own policy lives and how two profiles compose. Both are generic guidance and still apply. There is more than one; keep them all.

### 5. Fill the placeholders

Interview the user for each italicized `*(placeholder)*` in the new `AGENTS.md` (the canonical entry — the thin `CLAUDE.md` carries none). Ask in one pass with concrete recommendations, not an open-ended survey:

- **Header:** active client. Set `Last reviewed` to today, absolute (e.g. `2026-07-14`). Leave `Version` at 1.0 — this is the target repo's first version.
- **Project overview:** 1–3 sentences — what the app is, who it's for, which engagement.
- **Tech stack:** languages, frameworks, package manager, database/infra, runtime versions, dev environment.
- **Common commands:** install, run, test-all, **single-test** (fast feedback), lint/format, build.
- **Verification contract:** the full gate, what a clean run looks like, how to exercise a change beyond tests.
- **Architecture & conventions:** structure, conventions, do-not-touch paths, testing approach.
- **Compliance:** regulatory regimes in play, records/privacy notes.
- **Escalation:** the engagement lead / client security contact.

**Infer from the repo where you can** — read `package.json`, `pyproject.toml`, CI config, and existing test layout, and propose what you found rather than asking cold. But **never invent**. If you cannot determine something and the user cannot supply it, leave the placeholder italicized and tell them: an unfilled placeholder correctly signals "unconfigured — ask before assuming," which is the template's own instruction and is far better than a confident wrong command.

**Transcribe the commands; don't execute them — and mark what you didn't run.** Every line you put into **Common commands** and the **Verification contract** is a claim about this repo's behavior, and it is the claim every future agent here will trust instead of checking. Installing is not the moment to test that claim: this is somebody else's repo, its dependencies may not even be installed, and an install, seed, build, or migration script is a side effect an installer has no mandate to trigger uninvited (`ai-governance/core-rules.md` §5). So **source each command from the repo itself** — `package.json` scripts, the CI workflow, the `Makefile`, the contributor docs — and write it in **marked `unverified`**: a trailing `# unverified` comment inside the commands block, a trailing `— unverified` on a contract bullet. That marker is the second branch of `ai-governance/writing-rules.md` §6 — run it *or* label the unrun parts unverified — and **it belongs in the file, not only in your hand-off**: the next agent reads `AGENTS.md` and never sees your install transcript. A command you cannot source from the repo at all is the same outcome as one you cannot determine — leave that placeholder italicized.

**Then offer, once, to run them — and run nothing without a yes.** Name the exact commands and ask in a single batch (`ai-governance/agent-workflow.md` §7); **the default is no**, and a declined or unanswered offer is a normal install, not a failed one. Run only what the user approved and nothing outside that list, and raise anything that installs, seeds, migrates, deploys, or writes outside the working tree as its own question rather than folding it into the same yes. Drop the `unverified` marker only from the commands that actually ran, and record the invocation that worked rather than the one you meant to run.

### 6. Onboard the client profile

Fill the **Active client** line in the new `AGENTS.md` — one client, or a list of them — then author each client's profile. This is the step that makes the package specific to the engagement; without it the repo is scaffolded but unconfigured. **Everything below repeats per client**, derivation included: one policy per profile. Where two active profiles then disagree, the composition rule in `ai-governance/client-profiles.md` governs.

**Check the overlay first, if there is one.** If it holds `clients/<client>/`, read that client's `profile.md` and `policy.md` and copy them into the target as `ai-governance/client-profiles/<client>.md` and `ai-governance/client-policies/<client>.md`. Show the user what you found and confirm it is current before writing — an overlay master can be stale, and copying one unread is the same defect as summarizing a policy you never opened. Then skip to the linking and hand-off; the interview below is for what the overlay does not cover, or for a client it has never seen.

**First ask whether the client has its own AI policy — and where the document is.** If they do, it is the **upstream authority**: the profile summarizes it, and where the two differ the policy governs. Nothing in this package tells you where a client's policy lives, so ask for it explicitly — a path in the target repo, a path elsewhere on disk, a URL, or a paste into the conversation. Work from the document rather than from recollection of it, and reconcile the profile against the policy, never the reverse. If no policy is available, say so and interview for the rules directly, recording in the hand-off that the profile is interview-sourced.

**Reproduce the policy at `ai-governance/client-policies/<client>.md`.** Create that directory here; it is deliberately **not** in the step 2 copy table, because it holds the client's own material rather than the package's. Copy the text verbatim, under its own title and version. The copy is what makes the profile's authority note resolve for anyone holding only this repo — a path to a document on somebody else's machine fails *silently*, while the note still reads authoritative.

**Cite-only fallback.** When the client permits citation but not copying, write no policy file. The profile's authority note then carries the title, the version or date, and the client's canonical URL, and says plainly that the full text sits with the engagement lead. That is a smaller claim, honestly labelled — the same discipline as "never invent a client rule" below, without discarding what you legitimately know.

**Derive the profile from the policy, then interview for the rest.** With a policy in hand, extract the fields below **from it first**, and interview only for what it does not cover. Summarizing a governing document is precisely where an unsupported rule gets written down and thereafter reads as authoritative, so:

- **Cite what each field came from** — the policy section it was derived from — and **pin the version** in the authority note (title plus version or date). When the client revises the policy, the profile's staleness becomes visible instead of theoretical. This is also what makes the cite-only path safe.
- **Silence is not permission.** A field the policy does not address is marked *not addressed by the policy* and asked about — never filled in from general knowledge, and never from the sample profile. If the user cannot supply it either, leave it unfilled and say that `core-rules.md` §8 governs that field.
- **A URL you cannot fetch is not a policy you have read.** Most client policies sit behind SSO. If retrieval fails, that is the same outcome as no document at all: interview, and record the URL as an unverified upstream. Never summarize a document you did not open — `ai-governance/writing-rules.md` §§1–2 bind here, and a derived profile that outruns its source suppresses §8's fail-safe exactly as an invented one does.
- **The human confirms the derivation before you write it.** A profile derived from a document nobody reviewed is governance nobody approved. This step is already an interview; the confirmation costs one exchange.

**Interview for these** (the field list `ai-governance/client-profiles.md` already names):

- **Tool rules — the behavioral residue only.** What the client's tool rules require of an agent *already running*: whether an approved or enterprise instance is required for their data, whether vendor training on client code or data is prohibited, and that you may not accept an AI tool's terms on the client's behalf. The approved-tool roster and the procurement path stay in the human guideline — an agent already running cannot act on which tool was approved.
- **Data rules** — the client's data classification, and what may never reach an AI tool.
- **Disclosure** — whether AI involvement must be noted in commits/PRs/design docs, and in what format.
- **Compliance regimes** — e.g. FERPA, HIPAA, GLBA, PCI-DSS, GDPR; plus any public-records exposure.
- **Escalation** — the engagement lead and the client's security contact for suspected exposure.

**Author `ai-governance/client-profiles/<client>.md`** following the shape of `example-university.md` in the governance repo: title, a short authority note naming the upstream policy, tight imperative bullets, a closing reference line. Read that file for its **shape** — do not copy its content, which belongs to a fictional client. Then link the profile from the copied `ai-governance/client-profiles.md` under `## Active client profiles`.

**Derive, don't transcribe — apply the scope test to every candidate line: does this change what an agent does on a task?** A policy document is long and sectioned, and deriving five fields from it invites wholesale copying. **Cut:** approved-tool rosters and procurement paths, governance bodies and policy owners, review cadences, contract terms and signing authority, org and committee structure, the policy's rationale and background prose, and anything that merely restates `core-rules.md` — a profile repeating "don't hardcode secrets" because the client's policy says so breaks the one-rule-one-owning-file discipline. **Keep:** the data classification and what may never reach a tool, the hard never-with-AI list, the disclosure format, the compliance regimes, the accessibility standard, the escalation contact — an agent that stops needs a name — and the behavioral residue of the tool rules. **Length is the cheap signal — measured against that sample's six body bullets, not its file length**, since its SAMPLE banner never travels to a client repo and its authority note is fixed overhead the derived profile carries too. A derived profile materially longer than those six bullets means transcription, not derivation.

**Before writing the file, read the draft back a line at a time and cut it to the scope test in the copied `ai-governance/client-profiles.md`** — for each line, name the moment in a task where it changes what an agent does, and cut the line rather than soften it when you cannot. Do it while it is still a draft: once written, every line reads as a rule the client set, and no later agent has the policy open to tell one apart from the other. **Say in the hand-off what you cut**, if you dropped something the user or the policy supplied — the human may want it in the human guideline, which is where most of it belongs.

**Offer to save the result back to the overlay — don't assume.** When you have authored a profile (and reproduced a policy) for a client the overlay does not yet hold, ask whether to write them there as the master. The overlay is a different repository and a different review, and writing to it unasked is exactly the out-of-scope action `ai-governance/core-rules.md` §5 requires you to confirm first. No overlay, or no answer: the engagement repo's copies stand on their own, and the offer goes in the hand-off as open work.

**Never invent a client rule.** This fallback is the opposite of step 5's. There, an unfilled placeholder is the safe outcome — it signals "unconfigured, ask." Here the safe outcome is **no profile file at all**, because `core-rules.md` §8 only fails safe when the profile is *absent*: it then treats the client's data as sensitive by default. A guessed or half-authored profile looks authoritative, suppresses that fail-safe, and is worse than nothing. So if the client's rules cannot be established and the user cannot supply them: write no profile, leave the empty state from step 4 in place, and tell the user plainly that `core-rules.md` §8's sensitive-by-default governs until someone raises it with the engagement lead.

### 7. Signpost the humans (opt-in)

The copied `AGENTS.md` already carries a short "For the humans on this project" note, but a developer joining the repo looks at `README.md` first. Offer — **don't assume** — to add a matching pointer where humans actually land.

- **Ask first.** This edits a project-owned file. If the user declines, skip it; the `AGENTS.md` note already covers the durable baseline.
- Append a clearly-marked block to the repo's `README.md`, or to `CONTRIBUTING.md` if that's where the project keeps contributor guidance. **Never overwrite existing content** — apply the same discipline as step 1: if the target file already has an AI/governance section, stop and show the user rather than duplicating. If neither file exists, offer to create a short `README.md` section.
- Ask the user for the organization name, and include the AI-governance source-repo link if the user can supply one; otherwise keep it generic ("ask your engagement lead"). Do **not** introduce a `*(placeholder)*` here — fill it now or word it generically. Shape:

  ```markdown
  ## AI-assisted development

  This repository follows <org>'s AI-assisted coding governance. The rules AI
  agents follow live in `./ai-governance/` — start at `AGENTS.md`. Developer
  onboarding and the full guideline live in the AI-governance source repository.
  ```

## Hand off

Report:

- Files copied, placeholders filled, and placeholders **left unfilled** — call these out explicitly, they are open work.
- **The commands, in three states.** Which ones you wrote in marked `unverified`, which stayed italicized placeholders because nothing in the repo sourced them, and whether the offer to run them was **accepted, declined, or unanswered**. Anything still marked `unverified`, and any offer left unanswered, is open work — say so plainly rather than letting a filled-looking file imply otherwise.
- **Whether a human-facing README/CONTRIBUTING pointer was added** (step 7), or declined.
- **Whether a client profile was authored, and from what source** — the client's own policy document, an interview, or not at all. Name the policy by title and version if there was one, and say which fields it did not address. If no profile was authored, say that `core-rules.md` §8's sensitive-by-default applies until one exists. **Name what you cut from the draft as out of scope**, so the human can move it to the human guideline if that is where it belongs.
- **Whether an overlay was used, and whether anything was written back to it.** Say which client artifacts came from the overlay and which you authored here, and whether the write-back offer was accepted, declined, or never made because there is no overlay. A write-back that was offered and not answered is open work, not a completed step.
- **Whether the policy itself landed in the repo** — reproduced at `ai-governance/client-policies/<client>.md`, cited only (title, version, canonical URL in the profile's authority note), or absent because there is no policy. A cite-only install is a smaller claim than a reproduced one; say which the reviewer is looking at.
- **The two-track follow-up.** This package is the agent-facing half. A new client profile also needs its human-facing counterpart in the governance repo's `human-docs/AI-Assisted-Coding-Developer-Guideline.md` (Appendix A). Report this as open work — don't write into the governance repo from here; that's a different repo and a different review. **The client's policy does not go there:** its home is this engagement repo's `ai-governance/client-policies/`, and the governance repo is a package, not a place client material accumulates.

Tell the user to review and commit the result: this is governance the client's reviewers should see in a PR.
