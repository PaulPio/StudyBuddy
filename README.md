# StudyBuddy

An AI study agent for the "Second Brain" hackathon challenge, built with
[BoxLang AI (bx-ai)](https://ai.ortusbooks.com/). Upload course material,
ask questions and get cited answers, catch contradictions between
sources, and generate a graded quiz - all from the same material.

## Team split

| Person | Owns | Folder |
|---|---|---|
| 1 | BX Agent / AI | `src/agent/` |
| 2 | Documents / RAG | `src/rag/` |
| 3 | Frontend / UI | `src/frontend/` |
| 4 | Integration, Quiz Me, testing | `src/quiz/`, `src/integration/`, `tests/` |

Full architecture, the contracts between modules, and why mocks exist:
see **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**.
Demo flow for judging: see **[docs/DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md)**.

If your folder is empty, start with the `CONTRACT.md` inside it.

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

## API

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/health.bxm` | liveness check |
| GET | `/api/ask.bxm?question=...&courseId=...` | ask a question, get a cited answer |
| GET | `/api/quiz.bxm?topic=...&count=5` | generate a quiz |
| POST | `/api/quiz-submit.bxm` | grade a quiz (`{ sessionId, answers }`) |

## Status

- [x] Repo scaffolding, folder ownership, module contracts
- [x] Quiz Me (generate + grade), with tests
- [x] Integration layer + HTTP API, running against mocks
- [x] Demo sample data (with an intentional contradiction for the demo)
- [ ] Real `src/agent/StudyBuddyAgent.bx` (Person 1)
- [ ] Real `src/rag/DocumentStore.bx` (Person 2)
- [ ] Real `src/frontend/` (Person 3)
- [ ] `box testbox run` executed against a real BoxLang runtime (not yet
      verified in the environment this scaffold was written in - see the
      note at the bottom of `docs/ARCHITECTURE.md`)
