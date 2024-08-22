# 3. Offline sync: change feed, tombstones and client ids

Date: 2024-08-20 · Status: accepted

## Context
The mobile app must work without a connection (recording a purchase in a shop with
no signal) and reconcile later. Options considered:

- **Full download each time** — simple but grows with history; wasteful on mobile data.
- **CRDTs / operation logs** — handle concurrent edits elegantly but are heavy for a
  single-user app where conflicting edits of the same transaction are rare.
- **Timestamp change feed** — server is the source of truth; clients pull what changed.

## Decision
A pull-based change feed with three pieces:

1. `GET /transactions?updated_since=` ordered by `(updated_at, id)` with an opaque
   cursor, backed by an index on `(user_id, updated_at, id)` — stable paging even when
   many rows share a timestamp.
2. A `deletions` table of tombstones written after a transaction is destroyed, read via
   `GET /deletions?since=`.
3. A client-generated UUID (`client_id`) on create, unique per user, making retried
   POSTs idempotent.

Conflicts resolve as last-write-wins at the server.

## Consequences
- Clients store one high-water mark and do bounded work per sync.
- Tombstones grow forever unless pruned; a periodic prune of tombstones older than the
  longest expected offline period (e.g. 90 days) is a small follow-up job.
- Last-write-wins can lose an edit made on two devices at once. Clients can opt into a
  check by sending `if_unmodified_since` on PATCH and handling `409 Conflict`.
