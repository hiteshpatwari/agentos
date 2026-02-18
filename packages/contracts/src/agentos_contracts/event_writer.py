from __future__ import annotations

import json
from pathlib import Path

from .events import EventV1


class EventWriter:
    """Appends EventV1 records as deterministic JSONL for a run."""

    def __init__(self, run_id: str, base_dir: str = "runs") -> None:
        self.run_id = run_id
        self._next_seq = 1
        self.run_dir = Path(base_dir) / run_id
        self.run_dir.mkdir(parents=True, exist_ok=True)
        self.path = self.run_dir / "events.jsonl"

    def append(self, event: EventV1) -> EventV1:
        if event.seq != self._next_seq:
            raise ValueError(
                f"event seq must be {self._next_seq} for run {self.run_id}, got {event.seq}"
            )
        with self.path.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(event.to_dict(), sort_keys=True) + "\n")
        self._next_seq += 1
        return event
