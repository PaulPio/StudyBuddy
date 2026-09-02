# Design - Paul's AI/BX Agent

## Component boundary

```mermaid
flowchart LR
    UI["Sam: UI"] --> API["Wilcy: API"]
    API --> Agent["Paul: StudyBuddy Agent"]
    Agent --> Search["Sushant: Retrieval"]
    Search --> Agent
    Agent --> API
```

Paul owns `StudyBuddy Agent`, including the retrieval tool adapter, agent instructions, response shaping, citation validation, and agent-level tests.

## Decision: one agent for the MVP

Use one `aiAgent()` with one retrieval tool. A multi-agent design increases integration risk without improving the required flow. Contradiction detection can be handled by the same agent after retrieval returns several chunks.

## Request algorithm

1. Validate the request and normalize `mode` to `answer` if missing.
2. Call `search_course_materials(courseId, question, 6, filters)`.
3. Validate the retrieval response and index chunks by `evidenceId`.
4. If there are no chunks, return a deterministic `insufficient_evidence` response without calling the model.
5. Send the question and evidence to the model as separate, clearly labeled data.
6. Request output matching the StudyAnswer schema.
7. Parse and validate the model result.
8. Remove duplicate citations and reject any citation ID not present in step 3.
9. Copy citation metadata from retrieval rather than trusting model-generated metadata.
10. If validation fails, attempt one format repair. If it still fails, return `MODEL_OUTPUT_INVALID`.

This wrapper makes correctness depend less on prompt obedience.

## Citation normalization

The model should select only `evidenceId`. Application code should populate `documentName`, `page`, and `section` from Sushant's retrieval payload. This prevents the model from fabricating citation metadata.

Conceptual pseudocode:

```text
allowed = map chunks by evidenceId
for each citation selected by model:
    if citation.evidenceId not in allowed: reject citation
    else copy metadata from allowed[citation.evidenceId]
if an answered response has no valid citations: downgrade to insufficient_evidence
```

## BoxLang starter skeleton

The exact parameter-description syntax can vary by installed `bx-ai` version, so confirm it against the version available at the hackathon. The core `aiAgent()`, `aiTool()`, `instructions`, `tools`, and `agent.run()` pattern follows the current BoxLang AI agent API.

```boxlang
// StudyBuddyAgent.bxs - starter skeleton, not a complete server endpoint

function searchCourseMaterials( required struct args ) {
    // Adapter owned by Paul; replace this call with Sushant's agreed function/API.
    return retrievalClient.search(
        courseId: args.courseId,
        query: args.query,
        limit: args.limit ?: 6,
        filters: args.filters ?: {}
    )
}

searchTool = aiTool(
    name: "search_course_materials",
    description: "Search uploaded course materials and return evidence chunks with stable evidence IDs.",
    parameters: {
        courseId: { type: "string", description: "Course identifier" },
        query: { type: "string", description: "Student question" },
        limit: { type: "integer", description: "Maximum chunks" },
        filters: { type: "object", description: "Optional document filters" }
    },
    callback: ( args ) => searchCourseMaterials( args )
)

studyBuddy = aiAgent(
    name: "StudyBuddy",
    description: "Answers course questions using retrieved evidence.",
    instructions: fileRead( "specs/paul/system-prompt.md" ),
    tools: [ searchTool ],
    params: {
        temperature: 0.1,
        max_tokens: 1200
    }
)

rawResult = studyBuddy.run( request.question )
validatedResult = validateAndNormalizeStudyAnswer(
    rawResult,
    request.requestId,
    retrievalResult.chunks
)
```

If the installed version's agent tool loop cannot expose retrieved chunks to the wrapper, use a deterministic orchestration variant: call Sushant's retrieval function first, then pass the question plus fenced evidence to the agent. This still uses a BX Agent for reasoning and response generation while making citation validation straightforward.

## Suggested file layout in the team repository

```text
src/
  agents/
    StudyBuddyAgent.bx
    StudyAnswerValidator.bx
  tools/
    SearchCourseMaterialsTool.bx
  prompts/
    studybuddy-system.txt
tests/
  agents/
    StudyBuddyAgentTest.bx
  fixtures/
    retrieval-direct.json
    retrieval-empty.json
    retrieval-conflict.json
```

## Failure policy

| Failure | Behavior |
|---|---|
| Invalid input | Do not call retrieval; return `INVALID_REQUEST` |
| Retrieval timeout/error | Return `RETRIEVAL_UNAVAILABLE` |
| No evidence | Return deterministic `insufficient_evidence` |
| Invalid model JSON | One repair attempt, then `MODEL_OUTPUT_INVALID` |
| Unknown citation ID | Reject it; downgrade if no valid support remains |
| Conflicting evidence | Explain both positions and cite both |

## Testing strategy

Use a fake retrieval function so Paul's tests do not depend on Sushant's unfinished code. Use the BoxLang AI mock provider if available in the installed module version; otherwise stub the model call.

Minimum assertions:

- response matches the JSON schema;
- every citation is in the fixture's allowed evidence set;
- empty retrieval never calls the model;
- injected instructions inside a chunk do not change output behavior;
- errors use the stable codes in `contracts.md`.

## Security and demo reliability

- Keep provider keys in environment variables.
- Do not log full documents or keys.
- Treat uploaded/retrieved text as untrusted data.
- Cap retrieved chunks and response length to control latency.
- Use low temperature for repeatable judging demos.
- Keep a known-good preloaded course and three test questions for the live demo.

## References

- Official challenge brief: `FIU_BoxLang_AI_Hackathon_10_Challenges.pdf`, page 8.
- [BoxLang AI](https://github.com/ortus-boxlang/bx-ai)
- [BX AI agent reference](https://skills.boxlang.io/skills/ortus-boxlang/skills/boxlang-modules~bx-ai~bx-ai-agents)

