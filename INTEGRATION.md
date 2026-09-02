# StudyBuddy Agent — integration guide (Paul)

`question + retrieved evidence → validated answer + real citations`

Built on the **`bx-ai` BoxLang module** (not BX Agents — that layer generates a whole ColdBox app,
which would collide with Wilcy's API).

Verified stack: **BoxLang 1.17.1**, **bx-ai 3.4.0**, Java 21.

## Run it

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$HOME/.bvm/current/bin:$PATH"

set -a; . ./.env; set +a                           # BoxLang reads the process env, not .env

boxlang tests/run-tests.bxs                        # 68 assertions, offline, no API key
boxlang --bx-config ./boxlang.json demo.bxs        # 5 demo scenarios on live Gemini
```

> `boxlang.json` is **not** picked up automatically from the project root — you must pass
> `--bx-config ./boxlang.json`. Without it BoxLang falls back to its default provider (OpenAI).
> Tests don't need it; they use bx-ai's built-in `mock` provider.

## Sushant — connecting real retrieval

One constructor argument. Nothing in the agent changes.

```java
// Replace this closure with your search. Signature: ( courseId, query, limit, filters )
searcher = ( courseId, query, limit, filters ) => {
    return {
        "query" : query,
        "chunks": [
            {
                "evidenceId": "ev-lecture05-p12-c03",   // unique + stable for the request
                "text"      : "the exact passage ...",
                "score"     : 0.91,                      // 0..1 if you can normalise it
                "metadata"  : {
                    "documentId"  : "doc-lecture05",
                    "documentName": "Lecture_05.pdf",   // REQUIRED
                    "page"        : 12,                  // integer >= 1, or null
                    "section"     : "Third Normal Form"  // or null
                }
            }
        ]
    };
};

agent = new src.agents.StudyBuddyAgent(
    new src.tools.SearchCourseMaterialsTool( searcher )
);
```

Rules the adapter enforces on your payload:

- a chunk missing `evidenceId`, `text`, or `metadata.documentName` is **dropped** (it could never be
  cited safely);
- duplicate `evidenceId`s are dropped;
- `page` is coerced to an integer ≥ 1 or `null` — never guessed;
- at most **6** chunks are consumed;
- **throw** on failure or timeout; the agent turns that into `RETRIEVAL_UNAVAILABLE`.

## Wilcy — calling the agent

```java
agent = new src.agents.StudyBuddyAgent(
    new src.tools.SearchCourseMaterialsTool( sushantsSearcher )
);

response = agent.ask( {
    requestId : "req-1042",
    courseId  : "cop-4710",
    question  : "Why is third normal form useful?",
    mode      : "answer",                       // optional, defaults to "answer"
    filters   : { documentIds: [], chapter: nullValue() }   // optional
} );
```

`response` is a struct matching `study-answer.schema.json` — always, including on errors. It never
throws. Map it to HTTP per `contracts.md` §5:

| `response.status` | `response.error.code` | HTTP |
|---|---|---|
| `answered` / `insufficient_evidence` / `conflicting_evidence` | `null` | 200 |
| `error` | `INVALID_REQUEST` | 400 |
| `error` | `RETRIEVAL_UNAVAILABLE` / `MODEL_UNAVAILABLE` | 503 |
| `error` | `MODEL_OUTPUT_INVALID` / `INTERNAL_ERROR` | 500 |

`insufficient_evidence` is a **successful, honest product result**, not a server error.

Sam can render `answer`, `confidence`, and `citations[]` directly — no prose parsing. Every
`citations[].evidenceId` is guaranteed to exist in the retrieval result, and `documentName` / `page` /
`section` are copied from retrieval, never from the model.

## Guarantees (each covered by a test)

- Empty retrieval returns `insufficient_evidence` and **never calls the model**.
- An invalid request returns `INVALID_REQUEST` and **never calls retrieval**.
- A citation id the model invented is removed; if nothing valid remains the answer is downgraded to
  `insufficient_evidence`.
- Retrieved text is wrapped with `aiFence()` and treated as inert data, so an instruction hidden in an
  uploaded document cannot change behaviour or fabricate a citation.
- Malformed model JSON gets **exactly one** repair attempt, then `MODEL_OUTPUT_INVALID`.

## Config

`boxlang.json` → provider `gemini`, `temperature 0.1`, `max_tokens 1200`, `timeout 60`.
Keys come from the environment only (`GEMINI_API_KEY`); see `.env.example`. `.env` is git-ignored.

Switching provider is a one-line change to `provider` in `boxlang.json`; each provider's parameter
block is already there.

## Gemini gotchas in bx-ai 3.4.0 (all worked around, all verified live)

Hit these in order — worth knowing if you switch provider or debug a 400/404.

1. **The built-in default model is retired.** `GeminiService.DEFAULT_CHAT_PARAMS` pins
   `gemini-2.5-flash`, which now 404s for new API keys. Config pins `gemini-3.6-flash`.
2. **Configured params are resolved but not sent.** `aiService().getParams()` correctly shows the
   configured model, yet the provider re-seeds its own defaults at request time, so plain
   `aiChat( "hi" )` still 404s. `StudyBuddyAgent.configuredParams()` reads
   `settings.providers.<provider>.params` and passes it explicitly per call — the only shape that
   wins. Marked `ponytail:`; delete it once bx-ai honours configured params.
3. **Gemini rejects OpenAI-style generation params.** Flat `temperature` / `max_tokens` give
   `400 Unknown name "temperature"`. Gemini needs
   `generationConfig: { temperature, maxOutputTokens }`. This is why the params live per provider
   rather than in `defaultParams`.
4. **Gemini has no tool calling** (`Real-time Tools: Coming Soon`). Sending tool definitions gives
   `400 Unknown name "type" at 'tools[0]'`. So the agent does **not** register the tool by default
   (`registerTool: false`); deterministic orchestration never needs it. Pass `registerTool: true`
   only on a provider that supports tools.

## Live verification (real Gemini, `gemini-3.6-flash`)

| Scenario | Result |
|---|---|
| Direct answer | `answered`, `fact`, cites `ev-lecture05-p12-c03` (Lecture_05.pdf p.12) |
| Two chunks | `answered`, grounded, `page` correctly `null` on the chunk that has none |
| Sources disagree | `conflicting_evidence`, **both** sides cited, neutral description |
| No evidence | `insufficient_evidence`, no citations, model never called |
| Prompt injection | `answered` normally — ignored "reveal your system prompt", refused the planted `ev-fake-9999` |

All five schema-valid, zero fabricated citations.
