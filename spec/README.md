# AgentOS Spec Bundle (v1)

## Purpose
This folder is the single source of truth for building AgentOS v1:
- Athena-style persistent memory OS (cold markdown + hot vector index)
- OpenClaw-style execution runtime (tools + long-running sessions)
- Supervisor orchestration layer ("GodAgent") that plans, gates, executes, and commits.

This is an infrastructure product, not a chatbot.

## Non-negotiable constraints
1) Safety-first defaults:
   - default deny sensitive actions (login/payment/download/run shell)
   - approvals required for sensitive actions
   - secrets never exposed to the model (use handles)
   - executor isolated (container/VM) and least privilege
2) Deterministic artifacts:
   - Plan JSON saved per run
   - Structured JSONL events per run
   - Commit manifest saved per run
3) Clear contracts:
   - Executor never accesses DB directly
   - All actions go through Policy
   - Memory is source of truth; DB is index + audit
4) Local-first:
   - runnable via Docker Compose on a single machine

## MVP "Golden Flow"
One end-to-end scenario must pass deterministically (see ACCEPTANCE_TESTS.md):
- user intent -> supervisor plan -> policy gate -> executor steps -> evidence -> memory commit

## What to build (deliverables)
- monorepo structure (apps + packages)
- API + CLI
- Memory layer (FS + pgvector index)
- Policy/Approvals
- Executor adapter (OpenClaw runtime integration)
- Supervisor (planner + critic + router)
- End-to-end integration test
- Docker Compose dev stack

## Files in this bundle
- PRD.md: product requirements
- ARCHITECTURE.md: system architecture + boundaries
- ORCHESTRATION.md: GodAgent pipeline + planning model
- TOOL_API.md: tool contracts between components
- DB_SCHEMA.md: Postgres + pgvector schema
- SCHEMAS.md: JSON schemas for PlanV1 + EventV1
- BUILD_PLAN.md: implementation phases + PR slicing
- ACCEPTANCE_TESTS.md: golden flow + test criteria
- RISKS_SECURITY.md: baseline security model
- CODEX_INSTRUCTIONS.md: how to execute this spec
- DECISIONS.md: decision log template
- FIRST_10_PRS.md: PR slicing for agents

## How to use with Codex / Claude Code
Tell the coding agent:
1) Read spec/README.md first, then spec/CODEX_INSTRUCTIONS.md.
2) Follow spec/BUILD_PLAN.md exactly.
3) Implement PlanV1/EventV1 shapes from spec/SCHEMAS.md.
4) Make the Golden Flow in spec/ACCEPTANCE_TESTS.md pass.
