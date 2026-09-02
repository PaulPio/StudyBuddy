# Person 2 starts here

This folder is yours. Add `DocumentStore.bx` implementing the same method
shape as `src/integration/contracts/IDocumentStore.bx` (read that file
first - it's short).

Once `DocumentStore.bx` exists, flip `useMocks: false` for the store in
`config/boxlang.json` (see `src/integration/StudyBuddyService.bx` for how
it's picked up) and the whole app switches from
`src/integration/mocks/MockDocumentStore.bx` to your real class with no
other code changes.

`sample-data/` already has a small demo course (3 files, one deliberate
contradiction between lecture 1 and lecture 2) you can ingest immediately
to test against, instead of waiting for real course material.

Useful docs while building:
- Document loaders: https://ai.ortusbooks.com/rag/document-loaders
- RAG overview: https://ai.ortusbooks.com/rag/rag
- Vector memory: https://ai.ortusbooks.com/main-components/memory/vector-memory

Questions about the contract shape → ping Person 4 (integration) before
changing it, since the quiz generator and the HTTP API both depend on it.
