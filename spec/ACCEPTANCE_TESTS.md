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
