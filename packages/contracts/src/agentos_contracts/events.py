from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any, Literal

EventSchema = Literal["event.v1"]


@dataclass(slots=True)
class EventV1:
    schema: EventSchema
    runId: str
    taskId: str
    ts: str
    type: str
    seq: int
    payload: dict[str, Any]

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
