# Writing Patterns for AI-Assisted Content

*A craft guide for content agents: how to produce written deliverables that are clear, useful, and maintainable. This is the companion to the safety/risk rules — [`core-rules.md`](./core-rules.md) (the task-agnostic base: secrets, data, correctness, licensing, provenance) and [`writing-rules.md`](./writing-rules.md) (content-specific: grounding, citations, confidentiality, voice fidelity, accessible documents); this file governs writing quality; [`agent-workflow.md`](./agent-workflow.md) governs how to work. It is the content-track sibling of [`coding-patterns.md`](./coding-patterns.md). Where these overlap or conflict, **accuracy and fidelity win over elegance and concision**, and a stricter client profile (see [`client-profiles.md`](./client-profiles.md)) wins over both.*

**Owner:** *(your company)* — Engineering · **Version:** 1.0 · **Last reviewed:** 2026-08-05 · **Review cycle:** Quarterly, or whenever a client's AI terms change.

---

## TL;DR — apply to every deliverable

1. **Name the reader and the job.** Who reads this, and what must they be able to do afterward.
2. **Front-load the answer.** The conclusion first, the reasoning after.
3. **Let the form match the content.** Comparison → table; ordered steps → numbered list; argument → prose.
4. **Cut what carries no information.** Preamble, restatement, throat-clearing, padding.
5. **Show what success looks like.** What to type without what to expect leaves the reader unable to tell it worked. *(Running the example at all is `writing-rules.md` §6 — a risk rule, and it binds regardless.)*
6. **State each fact in one owning place** and link to it from everywhere else.
7. **Edit the draft; don't regenerate it.** A rewrite discards the edits a human already made.

If a request can't satisfy these, flag the tension rather than quietly trading one away.

---

## 1. Know the reader and the job

- **Name the reader and the decision before the first sentence.** Say who this is for and what they must be able to do after reading it. "Everyone" means no one — a document written for a new user and an integrator at once serves neither. Where a deliverable genuinely has two audiences, section it explicitly rather than averaging them into something too shallow for one and too dense for the other. If you can't establish the reader, that's an assumption to state or a question to ask (`agent-workflow.md` §2), not a detail to skip.
- **Let the job set the length, not the topic.** A decision memo someone acts on in five minutes and a reference someone searches at 3 a.m. have different right lengths. Ask what the reader *does* with the document and write to that. Length is a consequence of the job, never a measure of effort.
- **Write to what the reader already knows.** Explain what is genuinely new to that audience and skip what they use daily. (Which *words* need defining is an accessibility obligation — `writing-rules.md` §5; this is about which *concepts* earn an explanation.)
- **Answer the question that was asked.** A deliverable that covers the adjacent topic thoroughly and the actual request in passing has failed, however polished it reads. Scope creep in content costs the reader's attention the way it costs review time in code (`core-rules.md` §2).

## 2. Structure that carries the argument

- **Lead with the answer.** Put the conclusion, recommendation, or result in the opening, then the support. Building up to a conclusion is the natural order for *writing* and the wrong order for *reading* — a reader who stops halfway should still have the point.

  ```text
  BAD:  "We evaluated three caching strategies. Redis offers... Memcached
         provides... In-process caching... Considering all of the above,
         we recommend Redis."
  GOOD: "Recommend Redis - the only one of the three that survives a restart,
         which the session store requires. Alternatives considered below."
  ```
- **Make headings state the claim, not the topic.** "Results" tells the reader nothing; "Redis is the only option that survives a restart" lets them skim the document and still get the argument. Heading *levels* and their order are an accessibility requirement (`writing-rules.md` §5); what the heading *says* is a craft one.
- **Match the form to the shape of the content.** A comparison across fixed dimensions is a table. A sequence whose order matters is a numbered list. Independent items are bullets. A claim needing a chain of reasoning is prose. Forcing one shape into another is where generated content bloats — a table flattened into paragraphs repeats every column name in every sentence.
- **One paragraph, one idea, announced in its first sentence.** A reader should be able to read only the opening sentence of each paragraph and still follow the argument.
- **State each fact in one owning place and link to it.** Duplicated content drifts, and the copy the reader happens to find is the stale one. Write it in the document or section that owns it and link from everywhere else — the content form of the single-source-of-truth rule in `coding-patterns.md` §4.

## 3. Precision and economy

- **Cut everything that carries no information.** No preamble restating the heading, no "in this section we will," no closing paragraph summarizing three sentences. Front-load and stop. Length is not thoroughness, and prose the reader learns to skip costs you the parts they should have read.

  ```text
  BAD:  "It's important to note that there are a number of different options
         available when it comes to configuring the timeout value."
  GOOD: "Set `timeout` in seconds. Default: 30."
  ```
- **Be concrete.** Name the thing, give the number, show the case. "Significantly faster" is unusable; "40% fewer round trips" is a claim the reader can check — and checkability is the point (`writing-rules.md` §1).
- **Prefer the plain verb to the noun phrase built from it.** "Use" over "utilize," "decide" over "make a determination," "we tested" over "testing was performed." Name the actor wherever responsibility matters — passive voice that hides who does what is a defect in a runbook, not a style preference.
- **Don't let emphasis substitute for evidence.** Bold, superlatives, and intensifiers — "critical," "seamless," "robust," "incredibly" — add heat, not information, and a reader who sees them everywhere stops seeing them anywhere. Reserve emphasis for the few places a reader must not miss. (Adding a *claim* the source never made is a different and more serious problem — `writing-rules.md` §4.)
- **Keep parallel things parallel.** List items in one grammatical shape, headings at one level in one form, each term used one way throughout. Switching mid-document makes the reader stop to work out what the change signifies.

## 4. Documentation of software

Applies when the deliverable documents software — a README, API reference, runbook, release note, help-center article, or in-repo guide. Everything above applies; this section adds what software documentation specifically owes its reader. *(For comments and docstrings that travel inside a source file, see [`coding-patterns.md`](./coding-patterns.md) §2.)*

**One rule for documentation is not in this file: run every example before you ship it.** That one is [`writing-rules.md`](./writing-rules.md) §6, because an unrun command is an unverified claim rather than a rough edge — a risk rule, not a craft one. It binds whether or not you opened this file. Everything below assumes it.

- **Pick the document type and hold it.** Four shapes, each with a different job: **tutorial** (learning by doing), **how-to** (one specific goal), **reference** (exhaustive lookup), **explanation** (why it works this way). Blending all four in one document is the default failure of generated documentation — too long to look something up in, too shallow to learn from. §1's audience question decides which one you're writing.
- **Show what success looks like.** A step that says what to type but not what to expect leaves the reader unable to tell whether it worked. Give the meaningful part of the output, the resulting state, or the error that means they got it wrong.
- **Explain the why, not just the what.** Restating a signature, a flag name, or a UI label adds nothing the reader couldn't already see. Document purpose, constraints, non-obvious consequences, and the reason behind a surprising choice — the documentation form of the comment rule in `coding-patterns.md` §2.
- **Cover what the document type owes.** A README owes what this is, who it's for, how to install it, how to run it, how to run its tests, and where to go next. A how-to owes prerequisites up front and ordered steps. A reference owes completeness and skimmability — every parameter, its default, and its error cases, in one consistent shape. An explanation owes the trade-offs and the alternatives rejected.
- **Keep documentation true when behavior changes.** A README, runbook, or help article doesn't travel with the source file the way a docstring does, so nothing will flag it when the code moves underneath it. When you change behavior, find the documentation describing it and update it in the same change; when you find documentation already stale, fix it or flag it rather than writing around it.

## 5. Revision and change discipline

- **Edit the draft; don't regenerate it.** When revising a document that already exists — especially one a human has edited — change the parts the request names and leave the rest untouched. Regenerating from scratch silently discards accepted edits, resets wording someone chose deliberately, and produces a diff nobody can review.

  ```text
  BAD:  asked to fix one stale command; returns a rewritten README
  GOOD: asked to fix one stale command; returns a one-line diff
  ```
- **Don't reformat and rewrite in the same pass.** Rewrapping lines, reordering sections, or converting bullets to prose alongside a substantive edit buries the real change — the content form of `coding-patterns.md` §5's separate-refactors-from-behavior-changes rule. If the formatting genuinely needs fixing, make it its own change.
- **Match the document's existing conventions.** Terminology, heading style, list punctuation, code-fence language tags, citation form, date format — follow what the document and its siblings already do rather than importing your own. (The client's *voice* and register are `writing-rules.md` §4's; this is the mechanical layer beneath it.)
- **Never ship an unfilled placeholder as finished text.** An unfilled `*(TBD)*` is a useful signal that something is unconfigured — but only when it's visible and called out. Fill it, delete it, or name it in your hand-off; a placeholder buried mid-document reads as content.
- **Leave the document navigable after you edit it.** Update the table of contents, section numbers, and cross-references your edit invalidated. An internal link that no longer resolves, or a "see §4" now pointing at renumbered content, is a defect you introduced.

---

## Self-check before presenting content

Re-run the TL;DR at the top: the reader and job are named, the answer is up front, the form fits the content, nothing padded survives, every step shows what success looks like, each fact has one owning place, and an existing draft was edited rather than regenerated. Where a requirement forced a trade-off against one of these, name it in your hand-off so the reviewer sees the choice. Then run the safety self-checks in `core-rules.md` and `writing-rules.md` — all gates apply, including §6's run-every-example rule, and accuracy wins over polish.
