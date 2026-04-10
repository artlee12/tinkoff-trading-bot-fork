#!/usr/bin/env python3
"""
Display trading statistics and P&L (Profit & Loss)
"""
import sqlite3
from datetime import datetime
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "stats.db"


def get_orders():
    """Get all orders from database."""
    if not DB_PATH.exists():
        return []

    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT * FROM orders ORDER BY created_at")
            return cursor.fetchall()
        except sqlite3.OperationalError:
            return []


def format_currency(value, currency="RUB"):
    """Format currency value."""
    return f"{value:,.2f} {currency}"


def display_stats():
    """Display trading statistics."""
    orders = get_orders()

    if not orders:
        print("📊 No trades recorded yet.")
        print("\nRun the bot first with: make start")
        return

    print("=" * 80)
    print("📊 TRADING STATISTICS")
    print("=" * 80)
    print()

    # Header
    print(f"{'Order ID':<12} {'FIGI':<18} {'Type':<8} {'Qty':<6} {'Price':<15} {'Status':<12} {'Date'}")
    print("-" * 80)

    total_buys = 0
    total_sells = 0
    total_buy_value = 0
    total_sell_value = 0
    buy_count = 0
    sell_count = 0

    for order in orders:
        # order: (id, order_id, figi, direction, price, quantity, status, created_at)
        order_id = order[1][:10] if len(order) > 1 else "N/A"
        figi = order[2][:15] if len(order) > 2 else "N/A"
        direction = order[3] if len(order) > 3 else "N/A"
        price = order[4] if len(order) > 4 else 0
        quantity = order[5] if len(order) > 5 else 0
        status = order[6] if len(order) > 6 else "N/A"
        created_at = order[7] if len(order) > 7 else "N/A"

        # Parse direction
        if "BUY" in str(direction).upper():
            direction_short = "BUY"
            total_buys += quantity
            total_buy_value += price
            buy_count += 1
        elif "SELL" in str(direction).upper():
            direction_short = "SELL"
            total_sells += quantity
            total_sell_value += price
            sell_count += 1
        else:
            direction_short = str(direction)[:4]

        # Format status
        status_short = str(status).replace("EXECUTION_REPORT_STATUS_", "")[:10]

        print(f"{order_id:<12} {figi:<18} {direction_short:<8} {quantity:<6} {format_currency(price):<15} {status_short:<12} {created_at}")

    print("-" * 80)
    print()

    # Summary
    print("=" * 80)
    print("📈 SUMMARY")
    print("=" * 80)
    print(f"Total BUY orders:   {buy_count}")
    print(f"Total SELL orders:  {sell_count}")
    print(f"Total BUY value:    {format_currency(total_buy_value)}")
    print(f"Total SELL value:   {format_currency(total_sell_value)}")

    if total_sell_value > 0 or total_buy_value > 0:
        pnl = total_sell_value - total_buy_value
        pnl_percent = (pnl / total_buy_value * 100) if total_buy_value > 0 else 0

        print()
        if pnl > 0:
            print(f"💚 PROFIT: +{format_currency(pnl)} (+{pnl_percent:.2f}%)")
        elif pnl < 0:
            print(f"🔴 LOSS: {format_currency(pnl)} ({pnl_percent:.2f}%)")
        else:
            print(f"⚪ BREAK EVEN: {format_currency(pnl)}")

    print()
    print(f"Database: {DB_PATH}")
    print(f"Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")


if __name__ == "__main__":
    display_stats()
