# AgentOS

This repository hosts the AgentOS implementation.

## Current status

Network access to the spec repository is blocked in this environment (`CONNECT tunnel failed, response 403`).
To avoid inventing architecture or contracts, this PR only creates a minimal Python monorepo scaffold and tooling.

## Local commands

- Run checks: `make test`
- Run formatting check: `make lint`
- Start docker compose stack: `docker compose up --build`
