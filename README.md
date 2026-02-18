# AgentOS

This repository hosts the AgentOS implementation.

## Status

Implemented so far:
- PR1: monorepo scaffold + tooling
- PR2: shared contracts + Plan/Event types + Event writer
- PR3: Docker Compose dev stack (postgres+pgvector + runtime volume mounts)

## Monorepo layout

- `apps/api`: API service scaffold
- `apps/cli`: CLI scaffold
- `packages/contracts`: shared contracts/types scaffold
- `packages/memory`: memory subsystem scaffold
- `packages/policy`: policy subsystem scaffold
- `packages/executor`: executor adapter scaffold
- `packages/supervisor`: supervisor orchestration scaffold
- `tests`: repository-level tests
- `memory`, `artifacts`, `runs`: deterministic runtime storage roots
- `spec`: local spec bundle generated via `bootstrap_spec.sh`

## Local commands

- Run checks: `make test`
- Run tooling check: `make lint`
- Start docker compose stack: `docker compose up --build`
