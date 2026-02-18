#!/usr/bin/env bash
set -euo pipefail

mkdir -p spec

write_file () {
  local path="$1"
  cat > "$path"
  echo "Wrote $path"
}

write_file "spec/README.md" <<'EOF'
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
EOF

write_file "spec/PRD.md" <<'EOF'
# PRD: AgentOS v1

## Vision
AgentOS is a local-first platform for stateful autonomous AI agents:
- persistent identity + memory
- safe tool execution
- reproducible runs
- evidence-backed outputs

## Problem
Most agents fail because:
1) Statelessness: no durable memory/identity, no learning, no reproducibility
2) Weak execution: long tasks fail; no robust action loop
3) Missing infrastructure: no standard runtime, safety, audit, or lifecycle

## Solution
Combine:
- Memory OS (Athena-style): cold markdown + hot vector index + commits
- Executor (OpenClaw-style): tool-capable runtime for acting
- Supervisor (GodAgent): plans, critiques, enforces policy, dispatches execution, and commits results

## Target users
Primary: developers/power users building automations and agent workflows
Secondary: enterprises needing audit, policy, data ownership

## Non-goals (v1)
- training/hosting foundation models
- generic consumer chatbot
- cloud-only deployment
- marketplace/plugin store (later)

## MVP capabilities
- Persistent memory (read/write/search/commit)
- Execution adapter with tool allowlists and sandbox profiles
- Policy engine with approvals for sensitive actions
- Supervisor pipeline: retrieve -> plan -> critique -> authorize -> execute -> commit
- CLI and minimal API for tasks, runs, approvals
- Deterministic run artifacts + logs
- Docker Compose setup for local run

## Success metrics (v1)
- Golden flow passes 10/10 locally
- Run reproducibility: same input yields same artifacts shape (not identical model text)
- Clear auditability: "what happened and why" reconstructable from logs + evidence
- Safety: sensitive actions are blocked or require approval by default
EOF

write_file "spec/ARCHITECTURE.md" <<'EOF'
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
EOF

write_file "spec/ORCHESTRATION.md" <<'EOF'
# GodAgent Orchestration Design (v1)

## Objective
GodAgent is a deterministic controller. It does not "wing it".
It runs a pipeline and produces reproducible artifacts.

## Pipeline stages
1) Intake
- Input: {userId, message}
- Output: TaskSpec (structured intent, constraints, sensitivity)

2) Retrieve
- Query memory for:
  - profile + preferences
  - recent related commits
  - do/don’t rules
- Output: ContextBundle with citations/paths

3) Plan
- Produce PlanV1:
  - steps[] with tool, inputs, expected outputs
  - idempotency flag per step
  - risk label per step
  - evidence requirements per step
- Output: plan.json stored

4) Critique (pre-flight)
- Validate:
  - forbidden tools absent
  - sensitive actions marked requiresApproval
  - step order is coherent
  - evidence capture included for external claims
- Output: either approved plan or revised plan

5) Authorize
- For each step, Policy.check(action/tool/target)
- If requiresApproval -> create ticket and pause run
- Output: toolsAllowed + approvals list

6) Execute
- Dispatch PlanV1 + toolsAllowed + sandboxProfile to Executor
- Listen to events, apply retry rules for idempotent steps only
- If approval requested mid-run: pause + wait

7) Summarize + Commit
- Produce:
  - HumanSummary.md
  - MachineSummary.json (structured key facts)
  - Memory updates (preferences, decisions, task notes)
  - Commit manifest referencing artifacts + run logs

## Agent roles (future-ready)
- PlannerAgent: creates PlanV1
- CriticAgent: validates plan & risks
- ExecutorAgent: executes tools
- WriterAgent: final response + memory write format

In v1 these can be one model, but the code must preserve the role boundaries.

## Retry rules (v1)
- Retry only idempotent steps with bounded attempts (default 2)
- Never retry payment/login automatically
- On repeated failure: stop and return partial results + evidence
EOF

write_file "spec/TOOL_API.md" <<'EOF'
# Tool API Contracts (v1)

## Contract style
Tool calls are typed JSON messages.
Executor calls tools exposed by AgentOS (Memory/Policy), not internal DB/FS.

### Memory tools
- memory.search({ userId, query, scope[], k, filters? }) -> MemoryHit[]
- memory.read({ userId, path }) -> { content, version, contentHash }
- memory.write({ userId, path, mode, patch }) -> { version, contentHash }
- memory.commit({ userId, taskId, runId, summary, tags[], artifacts[] }) -> { commitId }

MemoryHit:
- path
- excerpt
- score
- docType
- tags

### Policy tools
- policy.check({ userId, action, target, context }) -> { allowed, requiresApproval, reason, requiredCaps[] }
- policy.requestApproval({ userId, action, payload, context }) -> { ticketId, status:"pending" }
- policy.resolveApproval({ ticketId, decision:"allow"|"deny" }) -> { status }

### Secrets broker (v1 minimal)
- secrets.getHandle({ userId, secretName }) -> { handleId }
- secrets.useHandle({ handleId, purpose }) -> { ok:true }  // executor uses handle indirectly; never receives raw secret

## Executor events (EventV1)
Executor must stream events back to AgentOS (see SCHEMAS.md).
At minimum:
- RunStarted
- StepStarted
- Observation
- ArtifactCreated
- ApprovalRequested
- StepCompleted
- RunCompleted / RunFailed / RunPaused

Artifacts
- screenshots (png)
- html snapshots
- extracted text snippets
- downloaded files (only if approved)
EOF

write_file "spec/DB_SCHEMA.md" <<'EOF'
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
EOF

write_file "spec/SCHEMAS.md" <<'EOF'
# JSON Schemas (v1)

## PlanV1 (logical)
PlanV1 is saved as runs/<runId>/plan.json.

Fields:
- version: "v1"
- taskId, runId, userId
- createdAt
- objective: string
- contextRefs: [{ path, excerpt }]
- sandboxProfile: "safe-default" | "dev-mode"
- toolsRequested: string[]
- steps: StepV1[]

StepV1:
- stepId: string
- title: string
- goal: string
- tool: string
- action: string
- target: string?
- inputs: object
- expectedOutputs: string[]
- evidence: { required: boolean, types: string[] }
- idempotent: boolean
- risk: "low"|"medium"|"high"
- requiresApproval: boolean

## EventV1
All events are newline-delimited JSON objects in runs/<runId>/events.jsonl.

Common fields:
- schema: "event.v1"
- runId
- taskId
- ts (ISO8601)
- type (string)
- seq (monotonic per run)
- payload (object)

Required event types:
- RunStarted { sandboxProfile, toolsAllowed[] }
- StepStarted { stepId, tool, action, target? }
- Observation { stepId, data }
- ArtifactCreated { stepId, artifact: { type, path, sha256? } }
- ApprovalRequested { stepId?, action, ticketId, reason }
- StepCompleted { stepId, status:"ok"|"failed"|"skipped", summary?, error? }
- RunPaused { reason, ticketId? }
- RunCompleted { summary, commitId? }
- RunFailed { error, lastStepId? }
EOF

write_file "spec/BUILD_PLAN.md" <<'EOF'
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
EOF

write_file "spec/ACCEPTANCE_TESTS.md" <<'EOF'
# Acceptance Tests (v1)

## Golden Flow: "Web research + summarize + remember"
Expected files:
- runs/<runId>/plan.json
- runs/<runId>/events.jsonl
- memory/commits/<commitId>.json
- artifacts/<runId>/... at least one artifact

Safety:
- No shell
- No arbitrary filesystem reads
- No secrets returned to model

## Approval Flow: "Login attempt must pause"
- policy.check requires approval
- ApprovalRequested + RunPaused emitted
- run resumes only after approval
EOF

write_file "spec/RISKS_SECURITY.md" <<'EOF'
# Risks & Security Baseline (v1)

Controls:
- executor isolated (container/VM)
- least privilege tools + allowlists
- approvals for LOGIN, PAYMENT, DOWNLOAD, RUN_SHELL, SEND_EMAIL
- secrets via handles only
- structured events + evidence capture + commit manifests
EOF

write_file "spec/CODEX_INSTRUCTIONS.md" <<'EOF'
# Codex Implementation Instructions (AgentOS)

Read these files in order (mandatory):
- spec/README.md
- spec/PRD.md
- spec/ARCHITECTURE.md
- spec/ORCHESTRATION.md
- spec/TOOL_API.md
- spec/DB_SCHEMA.md
- spec/SCHEMAS.md
- spec/BUILD_PLAN.md
- spec/ACCEPTANCE_TESTS.md
- spec/RISKS_SECURITY.md

Hard rules:
- Safety-first defaults.
- Executor must not access DB directly.
- All sensitive actions go through Policy + approvals.
- Secrets never exposed to the model (handles only).
- Every run must produce deterministic artifacts:
  - runs/<runId>/plan.json
  - runs/<runId>/events.jsonl
  - memory/commits/<commitId>.json
  - artifacts/<runId>/...

Follow BUILD_PLAN.md strictly.
Work in small PR-sized steps.
Do not invent architecture or change contracts.
EOF

write_file "spec/DECISIONS.md" <<'EOF'
# Architecture Decision Log (ADR-lite)

Record decisions impacting architecture/contracts/safety.

Template:
- Date
- Decision
- Context
- Alternatives
- Consequences
- Spec files impacted
EOF

write_file "spec/FIRST_10_PRS.md" <<'EOF'
# First 10 PRs (AgentOS v1)

PR1: Scaffold repo structure + tooling
PR2: Define interfaces + Plan/Event types + event writer
PR3: Docker Compose (postgres+pgvector) + volumes
PR4: Memory FS read/write + hashing/versioning
PR5: DB migrations
PR6: Chunking + (stub) embeddings + rebuild index
PR7: memory.search (vector-only ok)
PR8: Policy + approvals + CLI approve + pause/resume
PR9: Executor adapter (mock) + event streaming
PR10: OpenClaw integration + supervisor pipeline + golden flow E2E
EOF

echo
echo "Done. Spec bundle created under ./spec"
echo "Next: git add spec bootstrap_spec.sh && git commit -m 'Add spec bundle'"
