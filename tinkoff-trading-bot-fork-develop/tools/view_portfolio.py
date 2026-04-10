#!/usr/bin/env python3
"""
View current portfolio status and positions
"""
import asyncio
import os
import sys
from pathlib import Path

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.client import client
from app.settings import settings
from app.utils.quotation import quotation_to_float


async def view_portfolio():
    """Display current portfolio."""
    await client.ainit()

    print("=" * 80)
    print("💼 PORTFOLIO OVERVIEW")
    print("=" * 80)
    print()

    # Get account info
    try:
        accounts = await client.get_accounts()
        print(f"Account ID: {settings.account_id or accounts.accounts[0].id}")
        print(f"Sandbox: {settings.sandbox}")
        print()
    except Exception as e:
        print(f"❌ Error getting account: {e}")
        return

    # Get portfolio
    try:
        portfolio = await client.get_portfolio(account_id=settings.account_id)
    except Exception as e:
        print(f"❌ Error getting portfolio: {e}")
        return

    if not portfolio.positions:
        print("📭 Portfolio is empty")
        print("No positions currently held")
        return

    # Display positions
    print(f"{'Instrument':<25} {'Quantity':<10} {'Price':<15} {'Value':<15}")
    print("-" * 80)

    total_value = 0

    for position in portfolio.positions:
        figi = position.figi
        quantity = int(quotation_to_float(position.quantity))
        price = quotation_to_float(position.current_price)
        value = quantity * price
        total_value += value

        # Try to get instrument name
        try:
            instrument = await client.get_instrument(
                id_type=1,  # INSTRUMENT_ID_TYPE_FIGI
                id=figi
            )
            name = instrument.instrument.name[:23] if instrument.instrument else figi[:23]
        except:
            name = figi[:23]

        print(f"{name:<25} {quantity:<10} {price:>14,.2f}₽ {value:>14,.2f}₽")

    print("-" * 80)
    print(f"{'TOTAL:':<25} {'':<10} {'':<15} {total_value:>14,.2f}₽")
    print()

    # Show expected profit/loss
    print("💡 Note: Expected profit/loss is tracked in stats.db")
    print("   Run: python tools/display_stats.py")


if __name__ == "__main__":
    asyncio.run(view_portfolio())
