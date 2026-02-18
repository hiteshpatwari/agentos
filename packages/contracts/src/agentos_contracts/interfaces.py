from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Protocol

from .plan import PlanV1


@dataclass(slots=True)
class MemoryHit:
    path: str
    excerpt: str
    score: float
    docType: str
    tags: list[str]


class MemoryContract(Protocol):
    def search(self, params: dict[str, Any]) -> list[MemoryHit]: ...

    def read(self, params: dict[str, Any]) -> dict[str, Any]: ...

    def write(self, params: dict[str, Any]) -> dict[str, Any]: ...

    def commit(self, params: dict[str, Any]) -> dict[str, Any]: ...


class PolicyContract(Protocol):
    def check(self, params: dict[str, Any]) -> dict[str, Any]: ...

    def request_approval(self, params: dict[str, Any]) -> dict[str, Any]: ...

    def resolve_approval(self, params: dict[str, Any]) -> dict[str, Any]: ...


class ExecutorContract(Protocol):
    def execute_plan(self, plan: PlanV1) -> None: ...


class SupervisorContract(Protocol):
    def run(self, task: dict[str, Any]) -> str: ...
