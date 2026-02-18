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
