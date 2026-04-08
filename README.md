### 🥇 The winner in [Tinkoff invest robot contest](https://github.com/Tinkoff/invest-robot-contest) 01.06.2022

# Tinkoff Trading Bot

This is a bot for trading on Tinkoff broker.
It uses [Tinkoff investments API](https://github.com/Tinkoff/investAPI)

App name is `qwertyo1`

## 🚀 Quick Start

### 1. Get Tinkoff Token
1. Go to [Tinkoff Invest settings](https://www.tinkoff.ru/invest/settings/)
2. Generate API token for your account
3. Copy the token (starts with `t.`)

### 2. Clone and Setup
```bash
# Clone the repository
git clone -b develop https://github.com/qwertyo1/tinkoff-trading-bot.git
cd tinkoff-trading-bot

# Run automated setup
python3 setup.py
```

Or manually:
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Configure
```bash
# Edit .env file with your token
nano .env  # or any text editor
```

`.env` file content:
```
TOKEN=t.your_token_here
ACCOUNT_ID=?
SANDBOX=True
```

### 4. Get Account ID
```bash
make get_accounts
```

Copy the account ID and update `.env`:
```
TOKEN=t.your_token_here
ACCOUNT_ID=your_account_id_here
SANDBOX=True
```

### 5. Configure Trading Instruments
Edit `instruments_config.json` to set which stocks to trade.

Example for Sberbank:
```json
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
```

### 6. Run the Bot
```bash
make start
```

## 📋 Available Commands

| Command | Description |
|---------|-------------|
| `make setup` | Install dependencies and setup environment |
| `make start` | Run the trading bot |
| `make get_accounts` | Get your Tinkoff account ID |
| `make backtest` | Run backtest on historical data |
| `make display_stats` | Display trading statistics |
| `make clean` | Remove virtual environment and cache |

## 🔧 Configuration

### .env file
- `TOKEN`: Your Tinkoff API token from [settings](https://www.tinkoff.ru/invest/settings/)
- `ACCOUNT_ID`: Your Tinkoff account ID (get with `make get_accounts`)
- `SANDBOX`: Set to `False` for real trading, `True` for sandbox (default: True)

### instruments_config.json
List of instruments to trade with their settings.

**Common FIGI codes:**
- SBER (Сбербанк): `BBG004730N88`
- GAZP (Газпром): `BBG004730RP0`
- LKOH (Лукойл): `BBG004731032`
- YNDX (Яндекс): `BBG006L8G4H1`
- TCSG (Тинькофф): `BBG00Q3K5F77`

**Interval strategy parameters:**
- `interval_size`: Percent of prices to include in interval (0.8 = 80%)
- `days_back_to_consider`: Days of history for interval calculation
- `check_interval`: Seconds between price checks
- `stop_loss_percent`: Stop loss trigger percent (0.05 = 5%)
- `quantity_limit`: Maximum shares to hold

## 📈 Strategies

### Interval Strategy
Main strategy logic: **buy low, sell high** within calculated price corridor.

1. Calculates price corridor using percentiles (e.g., 10th to 90th percentile)
2. **Buy** when price hits bottom of corridor
3. **Sell** when price hits top of corridor
4. **Stop-loss** sells all if price drops below purchase by stop_loss_percent

## 🧪 Sandbox Mode

The bot runs in **sandbox mode by default** - no real money is used.

To switch to real trading:
1. Set `SANDBOX=False` in `.env`
2. Make sure you understand the risks!

## 🧪 Backtest

Test strategy on historical data:

```bash
make backtest
```

Configure test parameters in `tests/strategies/interval/backtest/conftest.py`.

## 📊 Statistics

View executed trades:

```bash
make display_stats
```

## 🐛 Troubleshooting

### DNS Resolution Error (macOS)
If you see `DNS resolution failed` error, the fix is already applied in Makefile.

### ImportError: cannot import name 'MarketDataCache'
This is fixed in the latest version. Run `git pull` to get updates.

### ModuleNotFoundError
Make sure virtual environment is activated:
```bash
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This bot is for educational purposes. Trading involves risk. Past performance does not guarantee future results.
