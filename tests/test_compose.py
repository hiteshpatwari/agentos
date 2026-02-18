from pathlib import Path


def test_compose_has_pgvector_service() -> None:
    compose = Path("docker-compose.yml").read_text(encoding="utf-8")

    assert "postgres:" in compose
    assert "pgvector/pgvector:pg16" in compose
    assert "pg_isready -U agentos -d agentos" in compose


def test_compose_has_runtime_volume_mounts() -> None:
    compose = Path("docker-compose.yml").read_text(encoding="utf-8")

    assert "./memory:/workspace/agentos/memory" in compose
    assert "./artifacts:/workspace/agentos/artifacts" in compose
    assert "./runs:/workspace/agentos/runs" in compose
    assert "pgdata:/var/lib/postgresql/data" in compose
