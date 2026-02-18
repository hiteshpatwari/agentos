from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any, Literal

SandboxProfile = Literal["safe-default", "dev-mode"]
RiskLevel = Literal["low", "medium", "high"]


@dataclass(slots=True)
class ContextRef:
    path: str
    excerpt: str


@dataclass(slots=True)
class EvidenceRequirement:
    required: bool
    types: list[str]


@dataclass(slots=True)
class StepV1:
    stepId: str
    title: str
    goal: str
    tool: str
    action: str
    target: str | None
    inputs: dict[str, Any]
    expectedOutputs: list[str]
    evidence: EvidenceRequirement
    idempotent: bool
    risk: RiskLevel
    requiresApproval: bool


@dataclass(slots=True)
class PlanV1:
    version: Literal["v1"]
    taskId: str
    runId: str
    userId: str
    createdAt: str
    objective: str
    contextRefs: list[ContextRef]
    sandboxProfile: SandboxProfile
    toolsRequested: list[str]
    steps: list[StepV1]

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
