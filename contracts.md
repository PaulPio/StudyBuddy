# Integration Contracts

Freeze these shapes before the team builds. Additive optional fields are safe; renaming or deleting fields requires agreement from all four teammates.

## 1. Wilcy/Sam -> Paul's agent

Endpoint suggestion: `POST /api/study/ask`

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

Rules:

- `mode`: `answer`, `explain`, `summarize`, or `study_guide`.
- Only `answer` is required for the MVP.
- `filters` is optional. Paul forwards supported filters to retrieval without interpreting file contents.

## 2. Paul -> Sushant retrieval tool

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

## 3. Sushant -> Paul's agent

```json
{
  "query": "Why is third normal form useful?",
  "chunks": [
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
  ]
}
```

Retrieval requirements needed by Paul:

- `evidenceId` must be unique and stable for the request.
- `text` must contain the exact passage available to the model.
- `score` should be normalized from 0 to 1 if possible; Paul must not assume all retrieval engines score identically.
- `documentName` is required.
- `page` and `section` may be `null`; Paul never guesses them.

## 4. Paul's agent -> Wilcy/Sam

Successful answer:

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

Insufficient evidence:

```json
{
  "requestId": "req-1043",
  "status": "insufficient_evidence",
  "answer": "I could not find enough support in the uploaded course materials to answer that reliably.",
  "claimType": "unknown",
  "confidence": "low",
  "citations": [],
  "conflicts": [],
  "suggestedNextStep": "Upload the relevant chapter or ask a more specific question.",
  "error": null
}
```

Service error:

```json
{
  "requestId": "req-1044",
  "status": "error",
  "answer": "I could not search the course materials right now.",
  "claimType": "unknown",
  "confidence": "low",
  "citations": [],
  "conflicts": [],
  "suggestedNextStep": "Try again in a moment.",
  "error": {
    "code": "RETRIEVAL_UNAVAILABLE",
    "message": "Course-material retrieval failed."
  }
}
```

## 5. HTTP status suggestion

| Case | HTTP status | Response status |
|---|---:|---|
| Answered or insufficient evidence | 200 | `answered`, `insufficient_evidence`, or `conflicting_evidence` |
| Invalid request | 400 | `error` |
| Retrieval/model temporarily unavailable | 503 | `error` |
| Unexpected server failure | 500 | `error` |

`insufficient_evidence` is a successful, honest product result rather than a server error.

