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
