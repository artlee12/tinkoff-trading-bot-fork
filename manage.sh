#!/bin/bash
# Management script for Tinkoff Trading Bot

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

show_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Tinkoff Trading Bot Manager          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Start Bot"
    echo -e "  ${GREEN}2.${NC} Get Account ID"
    echo -e "  ${GREEN}3.${NC} View Statistics"
    echo -e "  ${GREEN}4.${NC} Run Backtest"
    echo -e "  ${GREEN}5.${NC} Setup Environment"
    echo -e "  ${GREEN}6.${NC} Edit Configuration"
    echo ""
    echo -e "  ${YELLOW}7.${NC} View Logs (follow)"
    echo -e "  ${YELLOW}8.${NC} Stop Bot"
    echo -e "  ${RED}9.${NC} Clean Environment"
    echo ""
    echo -e "  ${RED}0.${NC} Exit"
    echo ""
}

check_venv() {
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}Virtual environment not found. Running setup...${NC}"
        python3 setup.py
    fi
}

start_bot() {
    check_venv
    echo -e "${GREEN}Starting bot...${NC}"
    source venv/bin/activate
    export GRPC_DNS_RESOLVER=native
    export PYTHONPATH=./
    python3 app/main.py
}

get_accounts() {
    check_venv
    echo -e "${YELLOW}Getting accounts...${NC}"
    source venv/bin/activate
    export GRPC_DNS_RESOLVER=native
    export PYTHONPATH=./
    python3 tools/get_accounts.py
    echo ""
    read -p "Press Enter to continue..."
}

view_stats() {
    check_venv
    echo -e "${YELLOW}Viewing statistics...${NC}"
    source venv/bin/activate
    export PYTHONPATH=./
    python3 tools/display_stats.py
    echo ""
    read -p "Press Enter to continue..."
}

run_backtest() {
    check_venv
    echo -e "${YELLOW}Running backtest...${NC}"
    source venv/bin/activate
    export PYTHONPATH=./
    python3 -m pytest .
    echo ""
    read -p "Press Enter to continue..."
}

setup_env() {
    echo -e "${YELLOW}Running setup...${NC}"
    python3 setup.py
    echo ""
    read -p "Press Enter to continue..."
}

edit_config() {
    echo -e "${YELLOW}Which file to edit?${NC}"
    echo "1. .env (tokens and settings)"
    echo "2. instruments_config.json (trading instruments)"
    read -p "Choice: " choice

    case $choice in
        1)
            if command -v nano &> /dev/null; then
                nano .env
            elif command -v vim &> /dev/null; then
                vim .env
            else
                echo "Please install nano or vim, or edit .env manually"
            fi
            ;;
        2)
            if command -v nano &> /dev/null; then
                nano instruments_config.json
            elif command -v vim &> /dev/null; then
                vim instruments_config.json
            else
                echo "Please install nano or vim, or edit instruments_config.json manually"
            fi
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

view_logs() {
    if [ -f "bot.log" ]; then
        tail -f bot.log
    else
        echo -e "${YELLOW}No log file found. Starting bot with logging...${NC}"
        check_venv
        source venv/bin/activate
        export GRPC_DNS_RESOLVER=native
        export PYTHONPATH=./
        python3 app/main.py 2>&1 | tee bot.log
    fi
}

stop_bot() {
    echo -e "${YELLOW}Stopping bot...${NC}"
    pkill -f "python.*app/main.py" 2>/dev/null
    echo -e "${GREEN}Bot stopped (if it was running)${NC}"
    sleep 2
}

clean_env() {
    echo -e "${RED}WARNING: This will remove virtual environment and cache files!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        echo "Cleaning..."
        rm -rf venv market_data_cache __pycache__ .pytest_cache bot.log
        find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null
        find . -type f -name "*.pyc" -delete
        echo -e "${GREEN}Cleaned!${NC}"
    else
        echo "Cancelled"
    fi
    sleep 2
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [0-9]: " choice

    case $choice in
        1) start_bot ;;
        2) get_accounts ;;
        3) view_stats ;;
        4) run_backtest ;;
        5) setup_env ;;
        6) edit_config ;;
        7) view_logs ;;
        8) stop_bot ;;
        9) clean_env ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 2 ;;
    esac
done
