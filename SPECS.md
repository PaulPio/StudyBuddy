# StudyBuddy - Paul AI/BX Agent Specification

Owner: **Paul**  
Challenge: **07 - Second Brain**  
Priority: **24-hour hackathon MVP**

## 1. Objective

Paul will build the StudyBuddy BX Agent responsible for turning a student's question and retrieved course evidence into a grounded, student-friendly answer with traceable citations.

```text
Student question
      ↓
StudyBuddy Agent (Paul)
      ↓
search_course_materials (Sushant)
      ↓
Evidence chunks
      ↓
Structured answer + citations
```

The solution supports the Second Brain challenge by answering questions across course materials, providing supporting evidence, distinguishing facts from inference, and identifying conflicting information.

## 2. Ownership

### Paul owns

- The `StudyBuddy` agent created with BoxLang AI/BX Agents.
- The agent's instructions and grounding rules.
- The `search_course_materials` tool adapter.
- Structured response generation.
- Citation validation and normalization.
- Insufficient-evidence and conflicting-evidence behavior.
- Agent-level fixtures and tests.

### Paul does not own

- Document uploading, parsing, chunking, embeddings, or indexing - **Sushant**.
- Frontend chat, document list, and citation display - **Sam**.
- API integration, full-system testing, and Quiz Mode - **Wilcy**.

## 3. MVP user story

As a student, I want to ask a question about my uploaded course materials so that I receive a clear answer and can verify which document supports it.

## 4. Required behavior

The MVP shall:

1. Accept `requestId`, `courseId`, `question`, and optional `filters`.
2. Call `search_course_materials` with the course ID and question.
3. Consume up to six evidence chunks returned by retrieval.
4. Answer using only the retrieved evidence.
5. Return JSON matching `schemas/study-answer.schema.json`.
6. Cite only `evidenceId` values returned by retrieval.
7. Copy document, page, and section metadata from retrieval rather than generating them.
8. Return `insufficient_evidence` instead of guessing when support is missing.
9. Return `conflicting_evidence` and cite both sides when sources disagree.
10. Mark the conclusion as `fact`, `inference`, `mixed`, or `unknown`.
11. Treat retrieved document text as untrusted data, never as agent instructions.
12. Return structured errors for invalid input, retrieval failure, model failure, or invalid model output.

## 5. Inputs and outputs

### Request

```json
{
  "requestId": "req-1042",
  "courseId": "cop-4710",
  "question": "Why is third normal form useful?",
  "mode": "answer",
  "filters": {
    "documentIds": [],
    "chapter": null
  }
}
```

### Retrieval tool request

Tool name: `search_course_materials`

```json
{
  "courseId": "cop-4710",
  "query": "Why is third normal form useful?",
  "limit": 6,
  "filters": {
    "documentIds": [],
    "chapter": null
  }
}
```

### Evidence chunk

```json
{
  "evidenceId": "ev-lecture05-p12-c03",
  "text": "Third normal form reduces data redundancy and update anomalies...",
  "score": 0.91,
  "metadata": {
    "documentId": "doc-lecture05",
    "documentName": "Lecture_05.pdf",
    "page": 12,
    "section": "Third Normal Form"
  }
}
```

### Successful response

```json
{
  "requestId": "req-1042",
  "status": "answered",
  "answer": "Third normal form is useful because it reduces duplicated data and prevents update anomalies.",
  "claimType": "fact",
  "confidence": "high",
  "citations": [
    {
      "evidenceId": "ev-lecture05-p12-c03",
      "documentName": "Lecture_05.pdf",
      "page": 12,
      "section": "Third Normal Form"
    }
  ],
  "conflicts": [],
  "suggestedNextStep": null,
  "error": null
}
```

## 6. Processing flow

1. Validate the request.
2. Call Sushant's retrieval interface.
3. Index returned chunks by `evidenceId`.
4. If no chunks exist, return a deterministic `insufficient_evidence` response.
5. Pass the question and clearly fenced evidence to the StudyBuddy agent.
6. Parse the agent's structured response.
7. Validate the response against the JSON schema.
8. Reject citations whose IDs were not returned by retrieval.
9. Replace model-provided citation metadata with the matching retrieval metadata.
10. Return the normalized result to Wilcy's API layer.

Only one formatting-repair attempt is permitted when the model returns invalid JSON.

## 7. Agent rules

- Use course evidence, not outside knowledge, for course claims.
- Lead with the direct answer.
- Keep normal answers under 350 words unless the student asks for more detail.
- Never invent quotations, evidence IDs, filenames, page numbers, or sections.
- Never expose hidden reasoning or chain-of-thought.
- Use `high` confidence only for strong, directly relevant evidence.
- Treat insufficient evidence as an honest product result, not a server failure.

The copy-ready agent instructions are in `system-prompt.md`.

## 8. Error codes

| Code | Meaning |
|---|---|
| `INVALID_REQUEST` | Required request data is missing or invalid |
| `RETRIEVAL_UNAVAILABLE` | Course-material search failed or timed out |
| `MODEL_UNAVAILABLE` | AI provider request failed |
| `MODEL_OUTPUT_INVALID` | Model output failed validation after one repair attempt |
| `INTERNAL_ERROR` | Unexpected server failure |

## 9. Acceptance criteria

Paul's part is complete when all of these pass:

- [ ] A directly supported question returns the correct answer and evidence ID.
- [ ] A question requiring two chunks cites both chunks.
- [ ] Empty retrieval returns `insufficient_evidence` with no citations.
- [ ] Conflicting sources return `conflicting_evidence` and cite both sides.
- [ ] An invented citation is rejected before reaching the UI.
- [ ] Missing page metadata remains `null` and is never guessed.
- [ ] Instructions hidden inside retrieved text do not override the agent rules.
- [ ] Retrieval failure returns `RETRIEVAL_UNAVAILABLE`.
- [ ] A blank question returns `INVALID_REQUEST` without calling retrieval.
- [ ] Malformed model JSON is repaired once or returns `MODEL_OUTPUT_INVALID`.
- [ ] The full response validates against `study-answer.schema.json`.
- [ ] The end-to-end flow works three times using a known demo course.

## 10. Implementation order

### P0 - Required

1. Freeze the request, retrieval, and response contracts.
2. Create the agent and retrieval adapter.
3. Implement grounded answering.
4. Implement insufficient-evidence behavior.
5. Add schema and citation validation.
6. Add conflicting-evidence behavior.
7. Test with fake retrieval fixtures.
8. Integrate with Sushant's retrieval and Wilcy's API.

### P1 - Only after P0 passes

1. Explain mode.
2. Summarize mode.
3. Study Guide mode.
4. Conversation memory.

## 11. Definition of done

Paul's deliverable is done when:

```text
question + retrieved evidence -> validated answer + real citations
```

works reliably through Wilcy's API and Sam's interface, without unsupported answers or fabricated citations.

## 12. Detailed files

- `requirements.md` - complete requirements and test matrix.
- `design.md` - technical design and BoxLang starter skeleton.
- `contracts.md` - team interface contracts.
- `system-prompt.md` - copy-ready agent instructions.
- `tasks.md` - prioritized implementation checklist.
- `schemas/study-answer.schema.json` - response validation schema.

## References

- `FIU_BoxLang_AI_Hackathon_10_Challenges.pdf`, page 8 - Challenge 07: Second Brain.
- [BoxLang AI repository](https://github.com/ortus-boxlang/bx-ai)
- [BoxLang AI agents reference](https://skills.boxlang.io/skills/ortus-boxlang/skills/boxlang-modules~bx-ai~bx-ai-agents)
