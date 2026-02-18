from __future__ import annotations

import json
from pathlib import Path

from agentos_contracts import ContextRef, EvidenceRequirement, EventV1, EventWriter, PlanV1, StepV1


def test_planv1_roundtrip_dict() -> None:
    plan = PlanV1(
        version="v1",
        taskId="task-1",
        runId="run-1",
        userId="user-1",
        createdAt="2026-01-01T00:00:00Z",
        objective="Complete the task",
        contextRefs=[ContextRef(path="memory/a.md", excerpt="context")],
        sandboxProfile="safe-default",
        toolsRequested=["memory.search", "policy.check"],
        steps=[
            StepV1(
                stepId="step-1",
                title="Retrieve context",
                goal="Fetch relevant memory",
                tool="memory",
                action="search",
                target=None,
                inputs={"query": "hello"},
                expectedOutputs=["MemoryHit[]"],
                evidence=EvidenceRequirement(required=False, types=[]),
                idempotent=True,
                risk="low",
                requiresApproval=False,
            )
        ],
    )

    data = plan.to_dict()
    assert data["version"] == "v1"
    assert data["steps"][0]["stepId"] == "step-1"


def test_event_writer_appends_jsonl(tmp_path: Path) -> None:
    writer = EventWriter(run_id="run-abc", base_dir=str(tmp_path))
    event = EventV1(
        schema="event.v1",
        runId="run-abc",
        taskId="task-abc",
        ts="2026-01-01T00:00:01Z",
        type="RunStarted",
        seq=1,
        payload={"sandboxProfile": "safe-default", "toolsAllowed": ["memory.search"]},
    )

    writer.append(event)

    events_path = tmp_path / "run-abc" / "events.jsonl"
    lines = events_path.read_text(encoding="utf-8").splitlines()
    assert len(lines) == 1
    parsed = json.loads(lines[0])
    assert parsed["schema"] == "event.v1"
    assert parsed["type"] == "RunStarted"
    assert parsed["seq"] == 1


def test_event_writer_enforces_monotonic_sequence(tmp_path: Path) -> None:
    writer = EventWriter(run_id="run-seq", base_dir=str(tmp_path))
    event = EventV1(
        schema="event.v1",
        runId="run-seq",
        taskId="task-seq",
        ts="2026-01-01T00:00:01Z",
        type="RunStarted",
        seq=2,
        payload={},
    )

    try:
        writer.append(event)
    except ValueError as exc:
        assert "event seq must be 1" in str(exc)
    else:
        raise AssertionError("Expected ValueError for non-monotonic sequence")
