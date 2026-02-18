# Architecture: AgentOS v1

## High-level flow
User intent -> Supervisor -> (Memory + Policy) -> Executor -> Evidence -> Commit

## Components
1) Supervisor (GodAgent)
- creates TaskSpec and PlanV1
- retrieves memory context
- critiques plan for safety/completeness
- requests approvals if needed
- dispatches execution
- writes memory updates and commit manifest

2) Memory OS (Athena-style)
- cold store: markdown files (source of truth)
- hot store: vector index in Postgres pgvector (search acceleration)
- commit manifests: JSON metadata per checkpoint

3) Policy Engine
- capability tokens and action taxonomy
- checks each step before execution
- creates approval tickets for sensitive actions
- secrets broker: executor receives handles, never raw secrets

4) Executor Runtime (OpenClaw-style)
- runs tool steps (browser/http/fs/etc) in an isolated sandbox
- emits structured events for every step
- captures evidence artifacts

## Hard boundaries (must enforce)
- Executor MUST NOT access Postgres directly
- Executor MUST NOT read arbitrary filesystem paths
- All sensitive actions must go through Policy + approvals
- Secrets are never in model context; only handles via a tool
- Memory cold store is authoritative; DB can be rebuilt

## Storage layout
- ./memory/ (cold store)
- ./artifacts/ (evidence: screenshots/html/pdfs)
- ./runs/<runId>/events.jsonl
- Postgres (docs metadata, chunks embeddings, approvals, run indexes)

## Sandbox profiles (v1)
- safe-default:
  - no shell
  - read-only memory (except via memory.write tool)
  - no downloads
  - network allowed but optionally domain allowlist
- dev-mode:
  - limited shell inside container only (approval-gated)

## Observability requirements
- Every run produces:
  - plan.json
  - events.jsonl (structured)
  - commit manifest json
  - artifacts index
