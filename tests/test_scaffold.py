from pathlib import Path


def test_scaffold_directories_exist() -> None:
    expected_directories = (
        "apps/api/src/agentos_api",
        "apps/cli/src/agentos_cli",
        "packages/contracts/src/agentos_contracts",
        "packages/memory/src/agentos_memory",
        "packages/policy/src/agentos_policy",
        "packages/executor/src/agentos_executor",
        "packages/supervisor/src/agentos_supervisor",
        "tests",
        "memory",
        "artifacts",
        "runs",
    )

    for directory in expected_directories:
        assert Path(directory).exists(), f"Missing scaffold directory: {directory}"
