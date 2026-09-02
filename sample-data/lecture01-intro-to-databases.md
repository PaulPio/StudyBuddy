# Lecture 1 - Introduction to Databases

## What is a database?

A database is an organized collection of structured data, typically
stored and accessed electronically. Relational databases organize data
into tables made of rows and columns.

## Primary keys

A primary key uniquely identifies each row in a table. It cannot be
null and must be unique across all rows. Every table should have exactly
one primary key.

**Design guidance:** for student-facing tables (tables whose rows a
student might reference directly, like `students` or `courses`), prefer
a single-column surrogate key (e.g. an auto-incrementing `id`) over a
composite key. Composite primary keys are harder to reference from other
tables and are generally discouraged for these tables.

## Foreign keys

A foreign key is a column (or set of columns) in one table that refers
to the primary key of another table. Foreign keys enforce referential
integrity: you can't insert a row that references a primary key that
doesn't exist.

## Example

```sql
CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
```
