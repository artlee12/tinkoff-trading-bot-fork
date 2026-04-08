VENV := venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

# For macOS DNS resolver fix
export GRPC_DNS_RESOLVER := native

.PHONY: help setup install start backtest display_stats get_accounts clean

help:
	@echo "Tinkoff Trading Bot - Available commands:"
	@echo "  make setup        - Install dependencies and setup environment"
	@echo "  make start        - Run the trading bot"
	@echo "  make get_accounts - Get your Tinkoff account ID"
	@echo "  make backtest     - Run backtest on historical data"
	@echo "  make display_stats- Display trading statistics"
	@echo "  make clean        - Remove virtual environment and cache"

setup:
	@echo "Setting up environment..."
	python3 setup.py

install:
	$(PIP) install -r requirements.txt

start:
	PYTHONPATH=./ $(PYTHON) app/main.py

backtest:
	PYTHONPATH=./ $(PYTHON) -m pytest .

display_stats:
	PYTHONPATH=./ $(PYTHON) tools/display_stats.py

get_accounts:
	PYTHONPATH=./ $(PYTHON) tools/get_accounts.py

clean:
	rm -rf venv market_data_cache __pycache__ .pytest_cache
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
