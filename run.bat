@echo off
chcp 65001 >nul
REM Quick start script for Tinkoff Trading Bot

echo ===========================================
echo Tinkoff Trading Bot - Quick Start
echo ===========================================

REM Check if venv exists
if not exist venv (
    echo Virtual environment not found. Running setup...
    python setup.py
    if errorlevel 1 (
        echo Setup failed!
        exit /b 1
    )
)

REM Check .env file
if not exist .env (
    echo ERROR: .env file not found!
    echo Please create .env file from .env.example
    exit /b 1
)

REM Check if TOKEN is set
findstr /C:"TOKEN=your_token_here" .env >nul 2>&1
if errorlevel 0 (
    findstr /C:"TOKEN=?" .env >nul 2>&1
    if errorlevel 0 (
        echo ERROR: Please set your Tinkoff token in .env file!
        echo Get token: https://www.tinkoff.ru/invest/settings/
        exit /b 1
    )
)

REM Check instruments_config.json
if not exist instruments_config.json (
    echo WARNING: instruments_config.json not found!
    echo Creating default configuration...
    (
        echo {
        echo   "instruments": [
        echo     {
        echo       "figi": "BBG004730N88",
        echo       "strategy": {
        echo         "name": "interval",
        echo         "parameters": {
        echo           "interval_size": 0.8,
        echo           "days_back_to_consider": 7,
        echo           "quantity_limit": 100,
        echo           "check_interval": 60,
        echo           "stop_loss_percent": 0.05
        echo         }
        echo       }
        echo     }
        echo   ]
        echo }
    ) > instruments_config.json
)

echo Starting bot...
call venv\Scripts\activate
set GRPC_DNS_RESOLVER=native
set PYTHONPATH=.\

REM Check if ACCOUNT_ID is set
findstr /C:"ACCOUNT_ID=?" .env >nul 2>&1
if errorlevel 0 (
    echo ACCOUNT_ID not set. Getting accounts...
    python tools\get_accounts.py
    echo.
    echo Please update .env file with your account ID and run again.
    exit /b 0
)

REM Run the bot
python app\main.py
