# Database Schema (Postgres + pgvector) (v1)

## Notes
- Cold store markdown is source of truth.
- DB is used for indexing/search + auditing + run tracking.

## Tables (logical)
- users
- memory_docs
- memory_chunks (pgvector embeddings)
- tasks
- runs
- run_events_index
- approvals
- memory_commits

## Indexing
- memory_docs(user_id, path) unique
- memory_chunks(doc_id)
- vector index on memory_chunks.embedding (ivfflat/hnsw depending on pgvector version)
