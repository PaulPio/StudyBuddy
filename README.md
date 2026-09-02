# StudyBuddy - Paul AI/BX Agent Spec Pack

Owner: **Paul**  
Hackathon challenge: **07 - Second Brain**  
Time limit: **24 hours**  
Status: **Ready for implementation**

## Paul's mission

Build the StudyBuddy agent that receives a student's question, obtains relevant course evidence through Sushant's retrieval interface, and returns a useful answer with verifiable citations.

Paul owns this transformation:

```text
question + retrieved evidence -> grounded StudyBuddy response
```

Paul does **not** own document parsing/indexing (Sushant), the interface (Sam), or application-wide integration and Quiz Mode (Wilcy).

## Definition of done

Paul's part is done when the agent can:

1. Accept the request described in `contracts.md`.
2. Call `search_course_materials` and consume Sushant's evidence chunks.
3. Answer only from those chunks.
4. Return output valid against `schemas/study-answer.schema.json`.
5. Cite only evidence IDs actually returned by retrieval.
6. Say that the course material is insufficient when support is missing.
7. Pass the P0 acceptance tests in `requirements.md`.

## Files

- `requirements.md` - behavioral requirements and acceptance tests.
- `design.md` - architecture, algorithm, implementation skeleton, and safeguards.
- `contracts.md` - exact handoff payloads shared with Sushant, Sam, and Wilcy.
- `system-prompt.md` - copy-ready instructions for the StudyBuddy agent.
- `tasks.md` - Paul's prioritized hackathon checklist and timebox.
- `schemas/study-answer.schema.json` - machine-readable response contract.

## MVP rule

Finish normal question answering before adding modes. The team's critical path is:

```text
Upload -> Ask -> Retrieve -> Answer -> Citation
```

Contradiction detection, explanation modes, and study guides are useful only after that path works reliably.

## Source basis

- `FIU_BoxLang_AI_Hackathon_10_Challenges.pdf`, page 8: Second Brain requires multiple content types, evidence-backed answers, cross-source connections, contradiction detection, and separation of facts from inference.
- [BoxLang AI repository](https://github.com/ortus-boxlang/bx-ai)
- [BoxLang AI agent reference](https://skills.boxlang.io/skills/ortus-boxlang/skills/boxlang-modules~bx-ai~bx-ai-agents)

