#!/bin/bash
# Quick start script for Tinkoff Trading Bot

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Tinkoff Trading Bot - Quick Start${NC}"
echo "=================================="

# Check if venv exists
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment not found. Running setup...${NC}"
    python3 setup.py
    if [ $? -ne 0 ]; then
        echo -e "${RED}Setup failed!${NC}"
        exit 1
    fi
fi

# Check .env file
if [ ! -f ".env" ]; then
    echo -e "${RED}ERROR: .env file not found!${NC}"
    echo "Please create .env file from .env.example"
    exit 1
fi

# Check if TOKEN is set
if grep -q "TOKEN=your_token_here\|TOKEN=?" .env; then
    echo -e "${RED}ERROR: Please set your Tinkoff token in .env file!${NC}"
    echo "Get token: https://www.tinkoff.ru/invest/settings/"
    exit 1
fi

# Check instruments_config.json
if [ ! -f "instruments_config.json" ]; then
    echo -e "${YELLOW}WARNING: instruments_config.json not found!${NC}"
    echo "Creating default configuration..."
    cat > instruments_config.json << 'EOF'
{
  "instruments": [
    {
      "figi": "BBG004730N88",
      "strategy": {
        "name": "interval",
        "parameters": {
          "interval_size": 0.8,
          "days_back_to_consider": 7,
          "quantity_limit": 100,
          "check_interval": 60,
          "stop_loss_percent": 0.05
        }
      }
    }
  ]
}
EOF
fi

# Activate venv and run
echo -e "${GREEN}Starting bot...${NC}"
source venv/bin/activate
export GRPC_DNS_RESOLVER=native
export PYTHONPATH=./

# Check if ACCOUNT_ID is set
if grep -q "ACCOUNT_ID=?" .env; then
    echo -e "${YELLOW}ACCOUNT_ID not set. Getting accounts...${NC}"
    python3 tools/get_accounts.py
    echo ""
    echo -e "${YELLOW}Please update .env file with your account ID and run again.${NC}"
    exit 0
fi

# Run the bot
python3 app/main.py
