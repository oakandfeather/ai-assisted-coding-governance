# Client AI Policy — shape and where the real one lives

**Version:** 2.1 · **Last reviewed:** 2026-09-01 · **Review cycle:** Whenever the client issues or revises its AI policy.

> **This file is a shape template, not a slot.** No client's policy is reproduced here. A client's own AI policy is **their material**, and this repository is the public governance package — client material never enters it. The real thing lives in the engagement repo, at `ai-governance/client-policies/<client>-policy.md`, put there by [`govern-init`](../ai-docs/procedures/govern-init.md) step 6. What this file gives you is the shape such a policy takes, so you can tell what a profile should have been checked against.

---

## Where the client's policy actually lives

- **In the engagement repo**, reproduced verbatim at `ai-governance/client-policies/<client>-policy.md`, beside the profile that summarizes it. That copy is the **upstream authority**: where it conflicts with anything in the governance package, it controls, and the profile is reconciled against it rather than the other way round.
- **Cited only, when the client will not permit its text in their repo.** Then there is no policy file, and the profile's authority note carries the title, the version or date, and the client's canonical URL, and says plainly that the full text sits with the engagement lead. A smaller claim, honestly labelled.
- **Never here.** This repo is copied into clients' repositories and is public; one client's policy landing in it would travel to every other client.
- **Optionally, as a master in a private client overlay** — a separate private repo holding `clients/<client>/profile.md` and `clients/<client>/policy.md` and nothing else, so a client appearing in several engagement repos is interviewed once rather than re-derived and drifting. `govern-init` reads *from* it and copies into the engagement repo; the engagement repo never points *at* it, because a cross-repo path resolves only on the machines that happen to have it. The overlay is optional, and a team with one repo per client needs none.

## Why the policy is reproduced into the engagement repo rather than linked

A client's policy is the thing we are actually bound by; the profiles are working summaries of it, written for a reader in a hurry (or for an agent). Keeping the full text alongside the summary means a reviewer can check a summary against its source without leaving the repo, and means the summary's drift from the source is visible rather than theoretical.

A link alone does not do that. A cross-repo path or an intranet URL resolves only on the machines that happen to have access, and it fails **silently** — the authority note still reads authoritative while pointing at nothing. So the rule is: anything the engagement repo references must resolve for someone holding only that repo plus their normal client access. Cite the client's canonical copy as well, but do not rely on the link alone, because policies move and versions matter — which is why the profile pins the version it was derived from.

## What a client AI policy typically covers

The shape below is what these policies tend to have, and what a profile should be checked against. Not every client will have all of it; the gaps are as informative as the content, because a silent client is one whose data you treat as sensitive by default — a field the policy does not address is marked *not addressed* in the profile, never filled in from general knowledge.

- **Data classification and handling** — the client's own data levels, and which levels may never reach an AI tool that isn't approved and contracted for them. This is usually the central rule.
- **Tool selection and procurement** — which AI tools are approved, what review a new tool must pass, and who may accept a vendor's terms.
- **Secure development** — review of generated code, secrets management, SAST / dependency / secret scanning, dependency vetting, constraints on agentic tools.
- **Intellectual property, licensing, and attribution** — who owns the work product, license-contamination screening, and whether AI involvement must be disclosed.
- **Accessibility** — the standard front-end work must meet, and who is accountable for it.
- **Privacy and legal compliance** — the regimes in play (e.g. FERPA, HIPAA, GLBA, PCI-DSS, GDPR), and any public-records exposure.
- **Prohibited uses** — the explicit never-do list.
- **Incident response** — who to notify, how fast, and through which path.
- **Governance and review** — who owns the policy and how often it is revisited.

**Not all of it reaches the profile.** Procurement paths, governance bodies, review cadences, and contract terms shape what the team may do and change nothing about what an agent does mid-task; they belong in the guideline, not in a profile. The profile takes the behavioral residue — see [`../ai-docs/procedures/govern-init.md`](../ai-docs/procedures/govern-init.md) step 6 for the cut-and-keep test.

## The worked example in this repo

The sample profiles here summarize a fictional client, **Example State University (ESU)**, a public university invented to show the expected shape of a profile — see [`../ai-docs/client-profiles/example-university.md`](../ai-docs/client-profiles/example-university.md) for the agent-facing version and Appendix A of [`AI-Assisted-Coding-Developer-Guideline.md`](./AI-Assisted-Coding-Developer-Guideline.md) for the human-facing one. ESU's policy has no text behind it, because ESU has no existence outside those two summaries; the sample therefore models the **cite-only** shape — a pinned title, version, and canonical URL, and no reproduced document. A real client's policy would sit in that client's engagement repo, not in this one.
