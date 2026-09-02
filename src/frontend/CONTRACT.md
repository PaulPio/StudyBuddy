# Person 3 starts here

This folder is yours. The backend is already reachable over plain HTTP/JSON
so you can build in whatever the team prefers (plain HTML/JS is fastest for
a 24h hackathon) without waiting on BoxLang specifics.

Run the API locally with:

```bash
boxlang-miniserver src/integration/webroot
```

Endpoints (see `docs/ARCHITECTURE.md` for full request/response shapes):

- `GET  /api/ask.bxm?question=...&courseId=...`
- `GET  /api/quiz.bxm?topic=...&count=5`
- `POST /api/quiz-submit.bxm`  (JSON body: `{ sessionId, answers }`)
- `GET  /api/health.bxm`

Right now these all run against mock data (see
`src/integration/mocks/`), so you can build and demo the UI today without
waiting for the AI agent or the document store to be finished - the
responses just won't be "real" until Person 1 and Person 2 plug in.

If you drop an `index.html` in this folder, `boxlang-miniserver` will
serve it at `/` automatically.

Questions about a response shape → ping Person 4 (integration) before
changing it.
