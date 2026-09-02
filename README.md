# StudyBuddy

An AI study agent for the "Second Brain" hackathon challenge (FIU BoxLang
AI Hackathon), built with [BoxLang AI (bx-ai)](https://ai.ortusbooks.com/).
Upload course material, ask questions and get cited answers, catch
contradictions between sources, and generate a graded quiz - all from the
same material.

## Team split

| Person | Owns | Folder / docs |
|---|---|---|
| Paul | BX Agent / AI | `contracts.md`, `design.md`, `requirements.md`, `system-prompt.md`, `tasks.md`, `study-answer.schema.json` (spec pack, root) |
| Sushant | Documents / RAG (retrieval) | `src/rag/` |
| Sam | Frontend / UI | `src/frontend/` |
| Wilcy | Integration, Quiz Me, testing | `src/quiz/`, `src/integration/`, `tests/` |

Paul's mission: build the StudyBuddy agent that receives a student's
question, obtains relevant course evidence through Sushant's retrieval
interface, and returns a useful answer with verifiable citations. His
full spec pack (API contract, JSON schema, requirements, acceptance
tests, and a BoxLang starter skeleton) lives in the root-level `.md`
files listed above - **start there** for anything agent-related.

Wilcy's integration layer and module contracts (how `src/agent/`,
`src/rag/`, and `src/frontend/` plug together, and why mocks exist) are
in **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**.
Demo flow for judging: **[docs/DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md)**.

If your folder is empty, start with the `CONTRACT.md` inside it.

> **Known open item:** two API contracts currently exist side by side -
> Paul's (`contracts.md` / `study-answer.schema.json`, richer: request
> IDs, status/claimType, evidence-id citations, structured errors) and
> Wilcy's first draft in `docs/ARCHITECTURE.md` (simpler:
> `{answer, sources, confidence}`). The plan is to align the integration
> layer to Paul's contract, since it's the one Sushant/Sam should build
> against - see the open pull request for details before building
> against either one.

## Quickstart

```bash
box install                                   # installs bx-ai + testbox
cp .env.example .env                          # then add a real API key
boxlang-miniserver src/integration/webroot    # API on http://localhost:8080
box testbox run                               # run the test suite
boxlang scripts/run_demo.bxs                  # scripted end-to-end demo
```

The app runs against mock AI/document-store data out of the box (see
`docs/ARCHITECTURE.md`), so every piece is demoable before every piece is
finished.

## API (Wilcy's draft - see the open item above)

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/health.bxm` | liveness check |
| GET | `/api/ask.bxm?question=...&courseId=...` | ask a question, get a cited answer |
| GET | `/api/quiz.bxm?topic=...&count=5` | generate a quiz |
| POST | `/api/quiz-submit.bxm` | grade a quiz (`{ sessionId, answers }`) |

## Status

- [x] Repo scaffolding, folder ownership, module contracts (Wilcy)
- [x] Paul's agent spec pack: contract, schema, requirements, design (Paul)
- [x] Quiz Me (generate + grade), with tests (Wilcy)
- [x] Integration layer + HTTP API, running against mocks (Wilcy)
- [x] Demo sample data (with an intentional contradiction for the demo) (Wilcy)
- [ ] Reconcile Wilcy's API contract with Paul's `contracts.md` / schema
- [ ] Real `src/agent/StudyBuddyAgent.bx` (Paul)
- [ ] Real `src/rag/DocumentStore.bx` (Sushant)
- [ ] Real `src/frontend/` (Sam)
- [ ] `box testbox run` executed against a real BoxLang runtime (not yet
      verified in the sandbox this scaffold was written in - see the
      note at the bottom of `docs/ARCHITECTURE.md`)
