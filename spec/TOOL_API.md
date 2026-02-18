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
