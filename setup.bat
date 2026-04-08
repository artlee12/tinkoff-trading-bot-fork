@echo off
echo ===========================================
echo Tinkoff Trading Bot - Windows Setup
echo ===========================================

REM Check Python
python --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found! Please install Python 3.9+
    exit /b 1
)

REM Create virtual environment
if not exist venv (
    echo [1/4] Creating virtual environment...
    python -m venv venv
) else (
    echo [1/4] Virtual environment already exists.
)

REM Upgrade pip
echo [2/4] Upgrading pip...
venv\Scripts\pip install --upgrade pip

REM Install dependencies
echo [3/4] Installing dependencies...
venv\Scripts\pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies!
    exit /b 1
)

REM Check .env file
echo [4/4] Checking configuration...
if not exist .env (
    echo Creating .env from example...
    if exist .env.example (
        copy .env.example .env
    ) else (
        echo TOKEN=your_token_here> .env
        echo ACCOUNT_ID=?>> .env
        echo SANDBOX=True>> .env
    )
    echo WARNING: Please edit .env file and add your Tinkoff token!
)

REM Check instruments_config.json
if not exist instruments_config.json (
    echo Creating default instruments_config.json...
    if exist instruments_config.json.example (
        copy instruments_config.json.example instruments_config.json
    )
)

echo ===========================================
echo Setup completed!
echo ===========================================
echo.
echo Next steps:
echo 1. Edit .env file and add your Tinkoff token
echo 2. Edit instruments_config.json to set your trading instruments
echo 3. Get account ID: make get_accounts
echo 4. Run the bot: make start
echo.
echo To activate venv manually: venv\Scripts\activate
echo.

pause
