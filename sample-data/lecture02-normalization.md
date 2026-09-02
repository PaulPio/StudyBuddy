# Lecture 2 - Normalization

## Why normalize?

Normalization organizes columns and tables to reduce data redundancy and
avoid update/insert/delete anomalies.

## First Normal Form (1NF)

Every column holds a single, atomic value - no repeating groups or
comma-separated lists in one cell.

## Second Normal Form (2NF)

The table is in 1NF, and every non-key column depends on the *whole*
primary key, not just part of it. This only matters when the primary key
has more than one column.

## Third Normal Form (3NF)

The table is in 2NF, and every non-key column depends on the key, the
whole key, and nothing but the key - i.e. no transitive dependencies
(a non-key column depending on another non-key column).

## Worked example: enrollments

Consider an `enrollments` table that records which students are enrolled
in which courses, and their grade:

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id  INTEGER,
    grade      CHAR(2),
    PRIMARY KEY (student_id, course_id)
);
```

Here `(student_id, course_id)` together form the primary key - a
composite primary key - because neither column alone uniquely identifies
a row, but the pair does. `grade` depends on the whole pair (a student's
grade is specific to one course), so this table is already in 2NF.

<!--
CONTRADICTION EXAMPLE (intentional, for the demo):
Lecture 1 says composite primary keys are "generally discouraged" for
student-facing tables. This lecture's own worked example uses a composite
primary key (student_id, course_id) for `enrollments` - a student-facing
table - without calling out that it's an exception to Lecture 1's
guidance. A good StudyBuddy answer should notice and flag this instead of
picking one lecture's framing silently. See docs/ARCHITECTURE.md.
-->
