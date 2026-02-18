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
