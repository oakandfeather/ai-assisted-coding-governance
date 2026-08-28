# Example Client Profile — Example State University (ESU)

> ***SAMPLE.** Example State University is a fictional public university, included to show the expected shape of a profile. Replace with the real client's profile before use; delete this file once you have one.*

> *Working summary only. The authoritative source is the client's own AI policy — **"ESU Policy on AI in Application Development," v2.1 (2026-01-15), `policy.example.edu/ai-in-development`** — and where they differ, it governs. **Cite-only:** ESU does not permit its policy text in a vendor repository, so there is no `client-policies/example-university.md` here and the full text sits with the engagement lead; the alternative shape is a verbatim copy at that path (see [`client-profiles.md`](../client-profiles.md)). Tool procurement is out of scope for the agent, so this profile intentionally omits the approved-tool list that appears in the human guideline.*

- ESU classifies data as **Level I (Confidential)**, **Level II (Sensitive)**, **Level III (Public)**. Never accept, process, or emit Level I/II data through an unapproved tool.
- **Never handle in AI-generated code or examples using real values:** FERPA student records; HIPAA health data (especially at ESU Medical Center); PII (SSNs, IDs, financial data); GLBA/PCI/GDPR data; credentials and security configs; ESU proprietary source or unpublished research data. Use synthetic data instead.
- **Disclosure is expected** — note substantial AI involvement in commits/PRs/design docs (ESU Responsible AI principles).
- **Accessibility is mandatory** — WCAG 2.1 AA (ADA Title II baseline; use 2.2 where adopted) / Section 508 / ADA Title II for all front-end work.
- **Compliance regimes in play:** FERPA, HIPAA, GLBA, PCI-DSS, GDPR (as applicable), and the **state Open Records Act** (assume prompts/records may be disclosable).
- Escalate exceptions to the engagement lead / ESU IT Security rather than improvising.

*Reference: the client's own AI policy, pinned above by title and version, and the vendor "Developer Guideline: Using AI for Client Coding Work."*
