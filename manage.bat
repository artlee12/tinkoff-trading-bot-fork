@echo off
chcp 65001 >nul
REM Management script for Tinkoff Trading Bot

:menu
cls
echo ═══════════════════════════════════════════
echo      Tinkoff Trading Bot Manager
echo ═══════════════════════════════════════════
echo.
echo   [1] Start Bot
echo   [2] Get Account ID
echo   [3] View Statistics
echo   [4] Run Backtest
echo   [5] Setup Environment
echo   [6] Edit Configuration
echo.
echo   [7] View Logs
echo   [8] Stop Bot
echo   [9] Clean Environment
echo.
echo   [0] Exit
echo.

set /p choice="Enter your choice [0-9]: "

if "%choice%"=="1" goto start_bot
if "%choice%"=="2" goto get_accounts
if "%choice%"=="3" goto view_stats
if "%choice%"=="4" goto run_backtest
if "%choice%"=="5" goto setup_env
if "%choice%"=="6" goto edit_config
if "%choice%"=="7" goto view_logs
if "%choice%"=="8" goto stop_bot
if "%choice%"=="9" goto clean_env
if "%choice%"=="0" goto exit
goto invalid

:start_bot
call :check_venv
echo Starting bot...
call venv\Scripts\activate
set GRPC_DNS_RESOLVER=native
set PYTHONPATH=.\
python app\main.py
pause
goto menu

:get_accounts
call :check_venv
echo Getting accounts...
call venv\Scripts\activate
set GRPC_DNS_RESOLVER=native
set PYTHONPATH=.\
python tools\get_accounts.py
pause
goto menu

:view_stats
call :check_venv
echo Viewing statistics...
call venv\Scripts\activate
set PYTHONPATH=.\
python tools\display_stats.py
pause
goto menu

:run_backtest
call :check_venv
echo Running backtest...
call venv\Scripts\activate
set PYTHONPATH=.\
python -m pytest .
pause
goto menu

:setup_env
echo Running setup...
python setup.py
pause
goto menu

:edit_config
echo Which file to edit?
echo 1. .env (tokens and settings)
echo 2. instruments_config.json (trading instruments)
set /p config_choice="Choice: "
if "%config_choice%"=="1" notepad .env
if "%config_choice%"=="2" notepad instruments_config.json
goto menu

:view_logs
echo Viewing logs...
if exist bot.log (
    type bot.log | more
) else (
    echo No log file found.
)
pause
goto menu

:stop_bot
echo Stopping bot...
taskkill /F /IM python.exe 2>nul
echo Bot stopped (if it was running)
timeout /t 2 >nul
goto menu

:clean_env
echo WARNING: This will remove virtual environment and cache files!
set /p confirm="Are you sure? (yes/no): "
if /I "%confirm%"=="yes" (
    echo Cleaning...
    rmdir /S /Q venv 2>nul
    rmdir /S /Q market_data_cache 2>nul
    rmdir /S /Q __pycache__ 2>nul
    rmdir /S /Q .pytest_cache 2>nul
    del /Q bot.log 2>nul
    for /r %%i in (*.pyc) do del /Q "%%i" 2>nul
    echo Cleaned!
    timeout /t 2 >nul
)
goto menu

:invalid
echo Invalid option!
timeout /t 2 >nul
goto menu

:exit
echo Goodbye!
exit /b 0

:check_venv
if not exist venv (
    echo Virtual environment not found. Running setup...
    python setup.py
)
goto :eof
