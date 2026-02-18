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
