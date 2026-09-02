# StudyBuddy — Architecture & Team Contracts

This document defines how the four pieces of StudyBuddy plug into each other,
so all four of us can build in parallel without breaking each other's code.
It also records the decisions Person 4 (integration/quiz/testing) made while
scaffolding the repo, since it started empty.

## Folder ownership

| Folder | Owner | Status |
|---|---|---|
| `src/agent/` | Person 1 (BX Agent / AI) | empty — see contract below |
| `src/rag/` | Person 2 (Documents / RAG) | empty — see contract below |
| `src/frontend/` | Person 3 (UI) | empty — see contract below |
| `src/quiz/` | Person 4 (me) | implemented |
| `src/integration/` | Person 4 (me) | implemented |
| `sample-data/` | Person 4 (me) | implemented — demo course material |
| `tests/` | Person 4 (me) | implemented |

**Rule of thumb:** only touch a folder you own. If you need a change in
someone else's folder, ping them (or open a PR comment) instead of editing
it directly — that's the whole point of branches.

## Why mocks exist

Since the repo was empty when I (Person 4) started, `src/agent/` and
`src/rag/` don't have real implementations yet. So the integration layer
(`src/integration/StudyBuddyService.bx`) is written against two small
contract classes, and ships with mock implementations
(`src/integration/mocks/`) that return realistic fake data.

This means:
- The whole pipeline (upload → ask → retrieve → answer → cite, and
  Quiz Me) already runs end-to-end today, against the mocks.
- Person 1 and Person 2 build their real classes to match the same method
  signatures. Once they exist, `StudyBuddyService` swaps the mock for the
  real thing via one config flag (`useMocks` in `config/boxlang.json`) —
  no integration code has to change.
- Nobody has to wait on anybody else to start.

## The two contracts

### `IDocumentStore` (Person 2 implements this in `src/rag/DocumentStore.bx`)

See `src/integration/contracts/IDocumentStore.bx` for the full method list.
Summary:

```
ingestFolder( path, options = {} ) -> {
    documentsIn: numeric,
    chunksOut: numeric,
    stored: numeric
}

search( query, limit = 5 ) -> array of {
    content: string,
    source: string,      // e.g. "sample-data/lecture02-normalization.md"
    fileName: string,     // e.g. "lecture02-normalization.md"
    page: numeric,        // 0/blank for non-paginated formats
    score: numeric         // similarity score, higher = more relevant
}
```

Implementation notes for Person 2 (from the BoxLang AI docs, `bx-ai`
module): `aiDocuments( path, { type: "directory", recursive: true } )
.toMemory( vectorMemory, { chunkSize: 1000, overlap: 200 } )` for ingest,
and `vectorMemory.search( query, limit: 5 )` for retrieval — that call
already returns `.content`, `.metadata.source`, `.metadata.fileName`,
`.metadata.page`, `.score`, so `DocumentStore.search()` can mostly be a
thin wrapper that reshapes that into the struct above.

### `IStudyBuddyAgent` (Person 1 implements this in `src/agent/StudyBuddyAgent.bx`)

See `src/integration/contracts/IStudyBuddyAgent.bx` for the full method
list. Summary:

```
ask( question, courseId = "", history = [] ) -> {
    answer: string,
    sources: array of { document: string, page: numeric },
    confidence: string   // "high" | "medium" | "low"
}
```

Implementation notes for Person 1: build this with `aiAgent()` from
`bx-ai`, wired to the vector memory Person 2 exposes (`agent =
aiAgent( name: "StudyBuddy", memory: vectorMemory,
instructions: "Only answer from the provided course materials. If the
materials don't cover it, say so instead of guessing. Always cite the
document and page you used." )`, then `agent.run( question )`). Please
keep the return shape above stable — that's what the integration layer
and the quiz generator both call.

## Quiz Me (Person 4's feature)

`src/quiz/` generates and grades multiple-choice quizzes from the same
course material, using structured output so the AI response comes back as
typed data instead of text to parse:

- `QuizGenerator.bx` — calls `aiChat()` with `returnFormat: [ new
  QuizQuestion() ]` against a set of retrieved chunks (via
  `IDocumentStore.search()`), and returns a `QuizSession`.
- `QuizGrader.bx` — grades a submitted answer set against a session and
  returns per-question feedback with the source citation, so a student
  can see *why* an answer was right or wrong.
- `QuizSession.bx` — a small value object holding the generated
  questions plus the course/topic they came from.

## Integration layer

- `src/integration/StudyBuddyService.bx` — the single entry point the
  frontend calls. Wraps the agent + document store + quiz modules behind
  three methods: `ask()`, `startQuiz()`, `submitQuiz()`. This is what
  Person 3's frontend should call — directly if it's also BoxLang, or
  through the HTTP API below if it's a separate JS app.
- `src/integration/webroot/` — a tiny JSON HTTP API
  (`boxlang-miniserver`) over `StudyBuddyService`, for a frontend that
  isn't BoxLang. Endpoints:
  - `GET  /api/ask.bxm?question=...&courseId=...`
  - `GET  /api/quiz.bxm?topic=...&count=5`
  - `POST /api/quiz-submit.bxm` (JSON body: `{ sessionId, answers }`)
  - `GET  /api/health.bxm` — used by the tests and by CI/demo scripts to
    check the server is actually up.
  - `GET  /` — serves `src/frontend/index.html` if Person 3 has built
    one yet, otherwise falls back to a plain status page so `npm run
    start`-equivalent (`boxlang-miniserver`) never 404s on the root.

## Contradiction-detection demo

`sample-data/lecture01-intro-to-databases.md` and
`lecture02-normalization.md` deliberately disagree about one fact (see the
`CONTRADICTION` markers inside those files). This is the “killer demo”
moment from the challenge brief: ask "Do the lecture and the syllabus
agree on X?" and the agent should surface the disagreement instead of
picking one side silently. That behavior lives in Person 1's agent
instructions, not in the integration layer — flagging it here so whoever
tunes the prompt remembers to test it.

## Running everything locally

```bash
box install                       # installs bx-ai + testbox
cp .env.example .env              # then fill in a real API key
boxlang-miniserver src/integration/webroot   # serves the API on :8080
box testbox run                   # runs tests/specs
boxlang scripts/run_demo.bxs      # scripted end-to-end demo for judging
```

> Note from Person 4: I wrote and researched this against the official
> BoxLang AI docs (ai.ortusbooks.com) and TestBox docs, but I don't have
> a BoxLang runtime in my sandbox to execute it, so treat this as a
> strong first draft, not verified-working code. First thing after
> merging: run `box testbox run` for real and fix whatever the runtime
> complains about.
