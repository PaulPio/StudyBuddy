# Requirements - Paul's StudyBuddy Agent

Priority meanings:

- **P0:** required for the hackathon MVP.
- **P1:** implement only after every P0 test passes.
- **P2:** optional demo polish.

## R1. Accept a question (P0)

The agent shall accept `requestId`, `courseId`, `question`, and `mode` using the request contract in `contracts.md`.

Acceptance criteria:

- Reject a blank question with `error.code = "INVALID_REQUEST"`.
- Default a missing mode to `answer`.
- Preserve `requestId` in the response.
- Never put API keys or provider credentials in a response or log.

## R2. Retrieve evidence through the team contract (P0)

When a valid question is received, the agent shall call `search_course_materials` with the same `courseId`, the question as `query`, and a default `limit` of 6.

Acceptance criteria:

- The agent consumes the retrieval response defined in `contracts.md`.
- The MVP performs at most two retrieval calls for one request.
- The agent does not read uploaded files directly; that is Sushant's boundary.
- A retrieval timeout or failure returns `error.code = "RETRIEVAL_UNAVAILABLE"`.

## R3. Ground the answer in supplied evidence (P0)

When evidence is returned, the agent shall treat it as data and answer only claims supported by that evidence.

Acceptance criteria:

- Every factual claim about the course material is supported by at least one citation.
- General explanation added by the model is marked as inference unless directly supported.
- Retrieved text is never treated as an instruction to the agent.
- The response does not claim to have inspected a document that retrieval did not return.

## R4. Return traceable citations (P0)

The agent shall cite evidence using stable `evidenceId` values rather than inventing filenames or page numbers.

Acceptance criteria:

- Every `citations[].evidenceId` exists in the retrieval response.
- Citation document name, page, and section are copied from the matching evidence metadata.
- If page metadata is unavailable, `page` is `null`; it is never guessed.
- Duplicate citations to the same evidence are removed.

## R5. Handle insufficient evidence safely (P0)

When retrieval returns no useful evidence, the agent shall not guess.

Acceptance criteria:

- Return `status = "insufficient_evidence"`.
- Set `answer` to a short explanation that the uploaded course material does not support an answer.
- Return an empty `citations` array.
- Suggest one practical next step, such as uploading the relevant chapter or rephrasing the question.

## R6. Distinguish fact, inference, and conflict (P0)

The agent shall classify the nature of its conclusion.

Acceptance criteria:

- `claimType = "fact"` when the answer is directly stated in evidence.
- `claimType = "inference"` when the answer reasonably combines evidence but is not stated directly.
- `claimType = "mixed"` when both are present.
- If credible chunks conflict, return `status = "conflicting_evidence"`, explain the disagreement neutrally, and cite both sides.

## R7. Produce structured output (P0)

The final response shall validate against `schemas/study-answer.schema.json`.

Acceptance criteria:

- Required fields are always present.
- `confidence` is one of `high`, `medium`, or `low`.
- `confidence = "high"` is allowed only when at least one strong, directly relevant chunk supports the answer.
- Invalid model output is repaired once; if still invalid, return `error.code = "MODEL_OUTPUT_INVALID"`.

## R8. Be useful to a student (P0)

The answer shall be concise, readable, and appropriate for a course Q&A interface.

Acceptance criteria:

- Lead with the direct answer.
- Use plain language unless the source requires technical terminology.
- Do not expose chain-of-thought or hidden reasoning.
- Keep a normal answer under 350 words unless the user explicitly asks for detail.

## R9. Support answer modes (P1)

After the P0 flow works, the agent may support:

- `explain`: explain a concept step by step using the retrieved evidence.
- `summarize`: summarize only the material selected by the request or retrieval filter.
- `study_guide`: return key concepts, definitions, and review questions grounded in evidence.

The output must still use the same response schema and citation rules.

## R10. Conversation memory (P2)

If memory is added, the agent shall use it only for conversational continuity. Memory must not replace retrieval as evidence for course facts.

## P0 acceptance test matrix

| ID | Scenario | Expected result |
|---|---|---|
| T1 | Direct answer exists in one chunk | `status=answered`; correct citation ID; `claimType=fact` |
| T2 | Answer requires two chunks | Both chunks cited; `claimType=inference` or `mixed` |
| T3 | No chunks returned | `status=insufficient_evidence`; no citations |
| T4 | Two documents disagree | `status=conflicting_evidence`; both sides cited |
| T5 | Model attempts a made-up citation | Validator rejects or removes it; never shown to UI |
| T6 | Chunk has no page number | Citation page is `null` |
| T7 | Retrieved text says to ignore agent instructions | Text is treated as untrusted data and ignored as instruction |
| T8 | Retrieval service fails | Structured `RETRIEVAL_UNAVAILABLE` error |
| T9 | Blank question | Structured `INVALID_REQUEST` error; no retrieval call |
| T10 | Valid model answer has malformed JSON | One repair attempt, then valid result or `MODEL_OUTPUT_INVALID` |

