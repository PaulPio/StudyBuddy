# Demo script (judging, ~2-3 minutes)

Goal: show upload → ask → cite, the contradiction-detection moment, and
Quiz Me - in that order, since that order builds from "it answers
questions" to "it actually understands the material."

1. **Set the scene (10s).** "StudyBuddy is a study agent for the Second
   Brain challenge. You give it your course material, it answers
   questions with citations, catches contradictions between sources, and
   quizzes you on it."

2. **Basic Q&A with citation (30s).**
   Ask: *"What is a primary key?"*
   Point out the answer names the exact lecture + page it came from -
   not a generic LLM answer.

3. **The contradiction moment (45s) - this is the highlight.**
   Ask: *"Do lecture 1 and lecture 2 agree about composite primary
   keys?"*
   StudyBuddy should surface that lecture 1 discourages composite
   primary keys for student-facing tables, while lecture 2's own
   `enrollments` example uses one without flagging it as an exception.
   This is the "it read the material, it didn't just summarize it"
   moment - see `sample-data/lecture02-normalization.md` for the planted
   contradiction.

4. **Quiz Me (45s).**
   Ask for a 3-question quiz on "normalization." Answer one on purpose
   wrong. Show the graded result: score, and for the wrong one, the
   explanation plus the exact source it came from.

5. **Close (10s).** "Everything you just saw - answer, contradiction
   check, and quiz - is backed by a citation back to the actual course
   material, not a guess."

## Fallback if the live AI call is slow/flaky during judging

`scripts/run_demo.bxs` runs the same flow against the mock
agent/document store (instant, deterministic) - useful as a backup if
Wi-Fi or the API is having a bad moment. Say so explicitly if you switch
to it rather than pretending it's the live model.

## Pre-flight checklist (do this before your judging slot, not during)

- [ ] `.env` has a working API key, `box testbox run` is green
- [ ] `boxlang-miniserver src/integration/webroot` is already running
- [ ] Frontend is pointed at that server's URL, not localhost:3000 by
      accident
- [ ] Run through steps 2-4 once, live, beforehand
- [ ] Know the fallback command (`boxlang scripts/run_demo.bxs`) by heart
