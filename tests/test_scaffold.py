from pathlib import Path


def test_scaffold_directories_exist() -> None:
    for directory in ("apps", "packages", "tests"):
        assert Path(directory).exists(), f"Missing scaffold directory: {directory}"
