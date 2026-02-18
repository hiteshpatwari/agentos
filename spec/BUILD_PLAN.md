# Build Plan (v1)

## Phase 0: Foundations
1) Monorepo scaffold + tooling
2) Common contracts (Memory/Policy/Executor/Supervisor), EventV1 writer, PlanV1 types
3) Docker Compose dev stack (postgres+pgvector, volume mounts)

## Phase 1: Memory OS
4) Cold store filesystem markdown read/write + hashing/versioning
5) DB schema + migrations
6) Chunking + embeddings pipeline (can stub embeddings)
7) memory.search (vector-only ok first)

## Phase 2: Policy + Approvals
8) policy.check default-deny sensitive actions
9) approvals store + CLI approve; pause/resume run

## Phase 3: Executor Adapter
10) executor adapter mocked then integrate OpenClaw
11) tool allowlist mapping + sandbox profiles

## Phase 4: Supervisor
12) intake/retrieve/plan minimal
13) critique/authorize/execute/commit end-to-end

## Phase 5: Golden Flow E2E
14) implement acceptance tests and docs; ensure deterministic artifacts
