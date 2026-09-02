# Person 1 starts here

This folder is yours. Add `StudyBuddyAgent.bx` implementing the same
method shape as `src/integration/contracts/IStudyBuddyAgent.bx` (read that
file first - it's short).

Once `StudyBuddyAgent.bx` exists, flip `useMocks: false` for the agent in
`config/boxlang.json` (see `src/integration/StudyBuddyService.bx` for how
it's picked up) and the whole app switches from
`src/integration/mocks/MockStudyBuddyAgent.bx` to your real class with no
other code changes.

Useful docs while building:
- Agents: https://ai.ortusbooks.com/main-components/agents/getting-started
- Tools: https://ai.ortusbooks.com/main-components/tools
- RAG + agents: https://ai.ortusbooks.com/main-components/agents/rag

Questions about the contract shape → ping Person 4 (integration) before
changing it, since the quiz generator and the HTTP API both depend on it.
