# Client AI Policy — *(reproduce the client's own policy here)*

**Owner:** *(your company)* — Engineering · **Version:** 1.0 · **Last reviewed:** 2026-07-14 · **Review cycle:** Whenever the client issues or revises its AI policy.

> **This file is a slot, not a policy.** When a client has its own policy governing AI use in application development, reproduce it here verbatim, under its own title and version. That copy is the **upstream authority**: where it conflicts with anything in this repository, it controls, and the client profiles that summarize it must be reconciled against it rather than the other way round.

---

## Why the client's policy is reproduced rather than linked

A client's policy is the thing we are actually bound by; the profiles in this repo are working summaries of it, written for a reader in a hurry (or for an agent). Keeping the full text alongside the summaries means a reviewer can check a summary against its source without leaving the repo, and means the summary's drift from the source is visible rather than theoretical. Link to the client's canonical copy as well — but do not rely on the link alone, because policies move and versions matter.

## What a client AI policy typically covers

The shape below is what these policies tend to have, and what a profile should be checked against. Not every client will have all of it; the gaps are as informative as the content, because a silent client is one whose data you treat as sensitive by default.

- **Data classification and handling** — the client's own data levels, and which levels may never reach an AI tool that isn't approved and contracted for them. This is usually the central rule.
- **Tool selection and procurement** — which AI tools are approved, what review a new tool must pass, and who may accept a vendor's terms.
- **Secure development** — review of generated code, secrets management, SAST / dependency / secret scanning, dependency vetting, constraints on agentic tools.
- **Intellectual property, licensing, and attribution** — who owns the work product, license-contamination screening, and whether AI involvement must be disclosed.
- **Accessibility** — the standard front-end work must meet, and who is accountable for it.
- **Privacy and legal compliance** — the regimes in play (e.g. FERPA, HIPAA, GLBA, PCI-DSS, GDPR), and any public-records exposure.
- **Prohibited uses** — the explicit never-do list.
- **Incident response** — who to notify, how fast, and through which path.
- **Governance and review** — who owns the policy and how often it is revisited.

## The worked example in this repo

The sample client profiles here summarize a fictional client, **Example State University (ESU)**, a public university invented to show the expected shape of a profile — see [`../ai-docs/client-profiles/example-university.md`](../ai-docs/client-profiles/example-university.md) for the agent-facing version and Appendix A of [`AI-Assisted-Coding-Developer-Guideline.md`](./AI-Assisted-Coding-Developer-Guideline.md) for the human-facing one. ESU has no policy document, because it has no existence outside those two summaries. A real client's would live in this file.
