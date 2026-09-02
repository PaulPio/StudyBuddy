# Tasks - Paul

Do the P0 items in order. Do not start P1 until the full team can complete `Upload -> Ask -> Retrieve -> Answer -> Citation`.

## P0 - Contract and scaffold (about 1 hour)

- [ ] Review `contracts.md` with Sushant and Wilcy.
- [ ] Freeze the tool name `search_course_materials` and evidence fields.
- [ ] Add the StudyAnswer JSON schema to the team repository.
- [ ] Create the agent, validator, tool adapter, and test fixture files from `design.md`.
- [ ] Configure the provider through an environment variable; do not commit a key.

Done when: a hard-coded question can call a placeholder agent and return a schema-shaped response.

## P0 - Retrieval adapter (about 1.5 hours)

- [ ] Implement the adapter for Sushant's search function or endpoint.
- [ ] Add request timeout and `RETRIEVAL_UNAVAILABLE` handling.
- [ ] Validate required chunk fields.
- [ ] Build a `Map<evidenceId, chunk>` for citation validation.
- [ ] Create fake direct, empty, conflicting, and injected-instruction retrieval fixtures.

Done when: Paul can switch between fake retrieval and Sushant's implementation without changing agent code.

## P0 - Agent behavior (about 2 hours)

- [ ] Load the instructions from `system-prompt.md`.
- [ ] Configure low temperature and a response-length cap.
- [ ] Ensure the model receives the question, mode, and retrieved evidence.
- [ ] Implement normal grounded answers.
- [ ] Implement deterministic empty-evidence behavior.
- [ ] Implement neutral conflicting-evidence behavior.

Done when: tests T1-T4 in `requirements.md` pass with fixtures.

## P0 - Validation and safeguards (about 1.5 hours)

- [ ] Validate output against `study-answer.schema.json`.
- [ ] Permit one repair attempt for malformed model output.
- [ ] Reject citation IDs absent from retrieval.
- [ ] Populate citation metadata from retrieval, not model text.
- [ ] Downgrade unsupported answers to `insufficient_evidence`.
- [ ] Ensure retrieved text is clearly fenced/labeled as untrusted data.

Done when: tests T5-T10 pass.

## P0 - Integration (about 2 hours, with Wilcy)

- [ ] Connect the agent function to Wilcy's API route.
- [ ] Confirm Sam can display `answer`, `confidence`, and `citations` without parsing prose.
- [ ] Test one real PDF question end to end.
- [ ] Test one no-answer question end to end.
- [ ] Test one contradiction question end to end.
- [ ] Add concise logs with `requestId`, duration, status, and evidence count.

Done when: the team can repeat the demo flow three times without changing data or code.

## P0 - Demo freeze

- [ ] Pick three known-good questions and record expected citations.
- [ ] Add a fallback message for temporary provider failure.
- [ ] Stop changing the response contract.
- [ ] Help Wilcy run the complete regression checklist.

## P1 - Only if every P0 item passes

- [ ] Add `explain` mode.
- [ ] Add `summarize` mode.
- [ ] Add `study_guide` mode.
- [ ] Improve contradiction wording and confidence calibration.
- [ ] Add short windowed conversation memory without using it as course evidence.

## Cut list if behind schedule

Cut in this order:

1. Conversation memory.
2. Study guide mode.
3. Summarize mode.
4. Explain mode.
5. Advanced contradiction presentation.

Never cut the grounded-answer path, evidence citations, insufficient-evidence behavior, or schema validation.

