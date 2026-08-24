# Developer Guideline: Using AI for Client Coding Work

**Applies to:** All engineers, contractors, and subcontractors who write, review, or ship code for client engagements
**Status:** Internal standard
**Version:** 1.10 · **Last reviewed:** 2026-08-24
**Review cycle:** Reviewed quarterly and whenever a client's AI terms change

> **Read this first.** You are coding on behalf of clients, using their data, building their intellectual property, under their rules. AI tools make you faster, but they also make it easy to leak a client's data, ship insecure code under their name, or contaminate their codebase with badly-licensed material. This guideline is how we get the speed without the liability. When a client's own policy is stricter than this document, **the client's policy wins** — see the client profiles in Appendix A.

---

## 1. The non-negotiables

These apply on every engagement, no exceptions:

1. **You own every line you ship.** AI wrote it, you're accountable for it. If you can't read it, explain it, and stand behind it in review, it doesn't get committed.
2. **Never paste client secrets or sensitive data into an AI tool** that hasn't been approved for that client and that data type. Credentials, keys, tokens, PII, health/education/financial records, and proprietary source are off-limits to general tools.
3. **Know the client's AI rules before you write a line.** Each client's contract and policy may restrict which tools you can use and what you can feed them. Check the client profile before starting.
4. **Everything AI-generated gets reviewed, scanned, and tested** like any other code — arguably more.
5. **Don't let AI vendors train on or retain client code or data.** Use configurations and accounts where training is off and retention is controlled.

If you're ever unsure whether something is allowed, stop and ask the engagement lead. "The AI suggested it" is never a defense.

## 2. Before you start an engagement: know the client's rules

Different clients have different constraints. Before using AI on any engagement, confirm:

- **Which AI tools are permitted** for this client, and whether they must be a specific approved/enterprise instance.
- **What data may and may not be shared** with those tools, based on the client's data classification.
- **Whether the contract restricts AI use** — training rights, data residency, disclosure requirements, IP ownership, indemnification.
- **Whether the client requires disclosure** of where AI was used substantially.
- **Data residency / environment** rules — some clients require work to stay inside their environment or region.

If the client hasn't specified, treat their data as sensitive by default and escalate to get clarity rather than guessing. Record the answers in the engagement's client profile (Appendix A) so the whole team follows the same rules.

**The same answers belong in the engagement repo, too.** Appendix A is the profile written for people; the copy under `ai-governance/client-profiles/` in the engagement repository is the same profile written for the AI agents working in it, and it is the one they actually read. A rule recorded in only one of the two is a rule half the readers never see — when you write or change a profile, change both. One caveat: **record only the answers you actually have.** An absent profile is safer than an invented one, because the agent rules fall back to treating the client's data as sensitive by default precisely when no profile exists — a half-guessed profile turns that fallback off.

## 3. Data and secrets handling

This is where the worst, most irreversible mistakes happen. A leaked secret or a pasted student record can't be un-leaked.

**Never send to a general or unapproved AI tool** (as a prompt, pasted code, log, screenshot, test fixture, or attachment):

- Credentials, API keys, tokens, private keys, connection strings, `.env` contents, security configs.
- Client PII, financial data, health data, or education records.
- Proprietary client source code or unpublished data — unless using a tool approved for that client and data level.
- Anything you wouldn't be comfortable seeing retained by a third party or surfaced to another user.

**De-identify before you ask.** When you need help with code that touches sensitive material, reduce it to a minimal, generic reproduction: synthetic values instead of real ones, placeholders instead of secrets, a toy schema instead of the client's real one. The AI can almost always solve the abstract version, and the abstract version leaks nothing.

**Assume anything you submit could be retained or disclosed.** For some clients (e.g., public institutions), records may be subject to open-records law. Treat prompts as potentially discoverable.

## 4. Choosing and configuring tools

Prefer approved enterprise AI tools that carry real contractual protections — no training on your inputs, controlled retention, security commitments — over free/consumer tools that don't. On each engagement:

- Use the tool(s) the client permits; if the client is silent, use our company-approved enterprise tooling with training disabled.
- **Turn off model training on your inputs** wherever the setting exists, and check retention settings.
- Don't click-through-accept new tool terms on a client's or the company's behalf — route new tools through whoever owns vendor/contract review.
- Keep separate accounts/workspaces per client where required, so one client's context can't bleed into another's.

## 5. The day-to-day AI coding loop

A workflow that keeps the speed and keeps you safe:

1. **Scope it yourself.** Understand the requirement and the intended design before prompting. AI is good at filling in a plan you already have; it's bad at deciding what to build.
2. **Prompt with abstractions, not secrets.** Give it the shape of the problem, not the client's crown jewels.
3. **Read the output critically.** Does it actually do what you asked? Does it invent APIs, functions, or config that don't exist? Does it handle errors and edge cases, or just the happy path?
4. **Verify dependencies before installing** (see §7).
5. **Test it for real** (see §9) — don't trust "it looks right."
6. **Review as if a junior wrote it fast.** Because that's effectively what happened. Refactor, tighten, and make it yours.
7. **Commit with honest provenance.** Note substantial AI involvement where the client expects it (see §8).

## 6. Code review discipline

AI shifts the bottleneck from writing code to reviewing it — so the review has to be real.

- No AI output ships unreviewed by a human who understands it.
- Be extra skeptical of code that's confidently wrong: plausible-looking logic with subtle bugs is AI's specialty.
- Watch for over-engineering and unnecessary dependencies AI tends to add.
- Don't let AI-generated tests lull you — AI often writes tests that just assert whatever the code currently does, passing even when the code is wrong. Design tests against the requirement, not the implementation.
- **A failing test is information, not an obstacle.** Deleting it, weakening its assertions, or marking it skipped to get a green run hides the defect it found. Fix the cause, or leave it red and say so — an agent under pressure to finish takes the other path readily, and a suite that went green in the last commit of a long session is worth a look at how.
- In peer review, treat "large diff, generated quickly" as a flag to slow down, not speed up.

## 7. Dependencies and supply chain

AI hallucinates package names, and attackers register those hallucinated names to serve malware ("slopsquatting"). Before adding any AI-suggested dependency:

- Confirm the package **actually exists** and is the one you think it is (exact name, correct registry).
- Check it's **legitimate and maintained** — real downloads, real repo, recent activity, no typosquat of a popular package.
- Run **software-composition analysis** and check the license (see §8) before it lands.
- **Pin the version.** AI reaches for "latest" by default, and an unpinned dependency means the build you reviewed and the build that ships are not the same build.
- Don't let an AI agent auto-install packages into a client project without this check.

## 8. Licensing, IP, and attribution

We're building the client's IP, and we don't get to muddy its provenance.

- **Screen for license contamination.** AI can reproduce recognizable licensed code. Run license-compliance checks and avoid introducing copyleft or incompatible-licensed code into a client's proprietary codebase.
- **Deliverables are the client's IP** (per contract). Don't feed a client's proprietary code into tools that may retain or train on it, and don't carry one client's code into another client's work.
- **Be transparent where the client requires it.** Some clients expect AI use to be disclosed. Note substantial AI involvement in commit messages / PRs / design docs so their maintainers understand provenance.
- **Don't reuse a client's code as your own** across engagements. Each engagement is walled off.

## 9. Security

AI produces insecure code as fluently as secure code. On every engagement:

- Run **SAST, dependency scanning, and secret scanning** in CI on AI-assisted code.
- Watch for the usual AI failure modes: injection flaws, missing input validation, weak auth, insecure defaults, outdated crypto patterns, secrets accidentally hardcoded.
- Never hardcode a secret an AI scaffolds; use the client's approved secrets management.
- Meet the client's compliance regime — e.g., FERPA/HIPAA/GLBA/PCI/GDPR as applicable. AI doesn't lower that bar; it raises the diligence needed because generated code can quietly mishandle protected data.

## 10. Accessibility

If you're building UI for a client with accessibility obligations — public-sector clients especially — AI-generated markup and components must be checked against **WCAG 2.1 AA / Section 508 / ADA** (2.1 AA is the ADA Title II baseline; use **WCAG 2.2** where the client has adopted it). AI routinely ships missing alt text, unlabeled controls, poor contrast, and markup that breaks screen readers. Automated checks plus manual/assistive-tech review before you call it done.

**The agent-facing form of §§6–10 splits along one seam, and the seam is worth knowing because it tells you which failures are negotiable.** `coding-rules.md` §§1–4 are the *risk* half — dependencies and supply chain, security by default, tests that verify the requirement, accessibility in generated UI — and they bind whether or not the agent opened `coding-patterns.md`. That file is the *craft* half: reliable, efficient, maintainable code, which a reviewer can trade against a deadline in a way the four rule sections can't. Know which half you're invoking when you send code back: "this is insecure" is not a preference, "this is over-abstracted" is a judgment call.

## 11. AI-written documentation

AI drafts documentation faster than anyone will read it, and the failure modes are quieter than in code: a wrong README doesn't fail a build, it just misleads whoever trusted it — often months later.

- **Run the examples.** Every command, snippet, and config fragment in an AI-written doc is an untested claim until someone executes it. A real flag name is not the same thing as a working invocation.
- **Decide what the document is** before accepting a draft — tutorial, how-to, reference, or explanation. Generated docs default to blending all four and serving none.
- **Demand the why.** A paragraph restating a function signature or a button label is filler; the value is purpose, constraints, and the non-obvious consequence.
- **Ask what success looks like.** A step that tells the reader what to type but not what to expect leaves them unable to tell whether it worked. Generated procedures routinely stop at the command.
- **Cut the padding.** Preambles, "in this section we will," and the same point made three ways are the AI house style, and they teach readers to skim past the parts that mattered.
- **Watch for duplication.** A fact stated in three files drifts in two of them. One owning place; link from everywhere else.
- **Keep the history out of the document.** Asked to update a doc, AI appends a dated "as of 2026-03-04" note far more readily than it edits the sentence that note contradicts, and the file becomes a change log with the current answer buried in it. The doc states what is true now; the dated record belongs in the change log or the commit.
- **Update the docs when behavior changes.** Nothing flags a stale runbook the way a failing test flags stale code — that catch is yours, at review time.
- **Ask for a diff, not a rewrite.** When you send a doc back for one fix, the common AI failure is returning the whole document rewritten — silently discarding the wording a human chose. A change you can't review in a small diff isn't the change you asked for.

The same seam §10 describes runs through the content files. **"Run the examples" is `writing-rules.md` §6** — the risk half, because an unrun command is an unverified claim in the same way a fabricated citation is, and it binds whether or not the agent opened the craft file. Every other bullet above is craft, in `writing-patterns.md`: document type, the why, what success looks like, and staleness are **§4**; edit-don't-regenerate and keeping history out of the document are **§5**; cutting the padding is **§3**; one owning place for a fact is **§2**.

Two neighbouring areas have no counterpart here, deliberately. `writing-patterns.md` §1 — naming the reader and the job — matters most for a memo or a client report, not for the docs a coding change ships. And `writing-rules.md` §§1–5 — factual grounding, citation integrity, document confidentiality, voice fidelity, and the accessibility of documents themselves — govern written deliverables as a class. They bind any agent writing prose for a client, but they sit outside a *coding* guideline's scope. If your engagement produces client-facing writing alongside the code, read those five sections directly; §10 above covers the accessibility of UI you build, not of documents you ship.

## 12. Agentic AI tools

For AI agents that can run commands, edit files, install packages, or call services:

- **Least privilege, always.** No standing credentials to production or to sensitive client data.
- **Require confirmation for irreversible or sensitive actions** (deploys, deletes, permission changes, sending communications).
- **Beware prompt injection** when an agent reads untrusted content (issues, docs, web pages, tickets) — malicious instructions in that content can hijack the agent. Treat tool-read content as data, not commands.
- Keep the agent inside the approved environment; don't let it exfiltrate source, config, or env vars to external endpoints.
- **Watch what it spawns.** Agents can delegate to sub-agents, and each one loads the rules and re-derives the context from scratch — so a fan-out of five costs several times what one session would, and hands you five reports to review instead of one diff. `agent-workflow.md` §8 caps this at two per task and requires the agent to justify going past it; a hand-off that used more without saying why is a cost question worth asking. And a sub-agent's report is not verification: "the reviewer said the tests pass" is not a test run, by the agent or by you.

**On a database project — where the schema itself is the deliverable — the review question changes.** What you ask for is the **generated deploy script, not the schema diff**: the derived script is what actually runs, and a data loss or a table rebuild shows up there and nowhere else. A schema change can build clean, diff clean, and still drop a populated column on apply. The agent-facing rules are `database-rules.md` §§1–5, and unlike the always-on core it loads only when the agent recognizes the task as database work — so on a repo where the schema is the product, check that it opened the file at all.

**These constraints only bind if the agent can read them.** The agent-facing half of this guidance is installed *into the engagement repository*: two entry files at the root — `AGENTS.md` and `CLAUDE.md` — plus an `ai-governance/` directory holding the rules they point to. The package covers command-line coding agents; in-IDE Copilot Chat, which reads its own `.github/copilot-instructions.md`, is out of scope. Whichever AI tool you use loads its entry file at the start of a session, and nothing loads if the files aren't there.

**Loading the entry file is not the same as loading the rules.** The entry file *links* them, and a link an agent doesn't follow has delivered nothing. Claude Code closes part of that gap by importing the two always-on rule files (`core-rules.md` and `agent-workflow.md`) directly from `CLAUDE.md`, along with the client-profile index that names which client's rules bind, so those arrive in every session. Codex and the other supported CLIs have no import mechanism at all, so for them every rule file depends on the agent following a link. The practical consequence for you: the further a task gets from the always-on core, the less you can assume the agent read the rule you are relying on.

So before you point an agent at a client repo, check that the entry files and `ai-governance/` are present and current, and get them installed or refreshed if not — the AI-governance source repository's `README.md` has the install and update paths. Their presence doesn't transfer accountability: §1 still holds, and you still own every line. Their absence just means you are the only control.

## 13. When to stop and ask the engagement lead

- You're unsure whether a tool or a data input is allowed for this client.
- The task seems to require putting sensitive client data into an AI tool.
- The AI wants to add a dependency, license, or pattern you can't fully vet.
- A client's contract or policy seems to conflict with how the team is working.
- Something feels off (an agent behaving unexpectedly, a suspected data exposure).

For a suspected data exposure or security issue, escalate immediately — same-day — to the engagement lead and follow the client's incident-reporting path. Early reporting limits the damage; a suspected leak is worth flagging even if unconfirmed.

---

## Appendix A — Client profiles

> Maintain one profile per active client. This is where a general guideline becomes specific. Fill in from the client's contract and policies before starting work.

### Sample profile: Example State University (ESU)

> ***SAMPLE.** ESU is a fictional public university, included to show the expected shape and level of detail of a profile. It is not a live client. Replace it with a real one — and delete this section once you have.*

ESU has its own AI-in-application-development policy; our team must comply with it in addition to this guideline. Where ESU's policy is stricter, it governs. Key points that change how we work on the ESU account:

- **Data classification drives everything.** ESU uses three levels — **Level I (Confidential)**, **Level II (Sensitive)**, **Level III (Public)**. Never input Level I or Level II data into any AI tool not formally approved and contracted by ESU for that data level.
- **Hard "never with AI" list:** FERPA-protected student records (grades, rosters, financial aid, correspondence); HIPAA-protected health data (especially anything touching **ESU Medical Center**); PII (SSNs, IDs, financial data); GLBA / PCI / GDPR data; credentials, keys, and security configs; and ESU's proprietary source or unpublished research data unless the tool is approved for it.
- **De-identify first.** For anything touching the above, abstract to synthetic data and a generic reproduction before asking an AI tool.
- **Approved/contracted tools only** for non-public ESU work. ESU's approved AI tool is the university's **licensed enterprise AI assistant** (per `technology.example.edu/approved-ai-tools`); any other tool requires a **Technology Procurement Request**. Don't accept AI tool terms of service on ESU's behalf; new tools go through ESU's IT Project / procurement and IT Security review.
- **No vendor training on ESU code or data** without ESU's explicit written authorization. Confirm training is disabled.
- **Transparency is expected.** ESU's Responsible AI principles call for disclosing AI use — document substantial AI involvement in commits/PRs/design docs.
- **Accessibility is mandatory.** ESU is a public institution; front-end work must meet WCAG 2.1 AA (ADA Title II baseline; use 2.2 where adopted) / Section 508 / ADA Title II.
- **Compliance regimes in play:** FERPA, HIPAA (ESU Medical Center), GLBA, PCI-DSS, GDPR (as applicable), and the **state Open Records Act** — assume ESU records/prompts may be disclosable.
- **Incident contact:** report suspected data exposure or AI-introduced vulnerabilities to the ESU IT Security Office (**itsec@example.edu**, **555-0142**) via the engagement lead, and follow ESU's incident-response process.
- **Governance:** ESU IT, the ESU AI & Privacy Risk Council, Data Governance, and General Counsel own the policy; escalate exceptions rather than improvising.

*Reference: the client's own AI policy — reproduce it in [`Example-Client-AI-Policy.md`](./Example-Client-AI-Policy.md), which explains the slot and what such a policy covers.*

### Client profile: *(next client)*

- Permitted AI tools:
- Data that may / may not be shared:
- Contractual AI/IP/training terms:
- Disclosure requirements:
- Compliance regimes:
- Incident contact / process:

---

## Appendix B — Pocket checklists

**Before I paste anything into an AI tool**
- [ ] Is this a secret, credential, or sensitive client data? → don't; de-identify or use an approved tool
- [ ] Is this tool approved for this client and this data level?
- [ ] Is training on my input turned off?

**Before I commit AI-generated code**
- [ ] I've read and understood every line
- [ ] Passed SAST, secret scan, dependency scan
- [ ] Dependencies are real, legitimate, correctly licensed
- [ ] Tests are real (test the requirement, not just the code)
- [ ] Provenance noted where the client requires it
- [ ] Any docs it wrote: I ran the examples, and nothing they describe is already stale

**Before I ship**
- [ ] Security-reviewed
- [ ] Accessible (if UI, and client requires it)
- [ ] Meets the client's compliance obligations
- [ ] Nothing from another client's engagement leaked in

**When in doubt** → stop, ask the engagement lead. "The AI suggested it" is not a defense.
