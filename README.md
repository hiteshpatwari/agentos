# AgentOS

This repository hosts the AgentOS implementation.

## Status

This commit implements **PR1 only** from `spec/BUILD_PLAN.md`: monorepo scaffold + tooling.

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
