.PHONY: test lint

test:
	pytest

lint:
	python -m compileall apps packages tests
