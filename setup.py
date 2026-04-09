#!/usr/bin/env python3
"""
Setup script for Tinkoff Trading Bot.
Automatically configures the environment and dependencies.
"""
import os
import sys
import subprocess
import venv
from pathlib import Path

def find_python_3_12():
    """Find Python 3.12 executable."""
    possible_paths = [
        "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3",
        "/usr/local/bin/python3.12",
        "/usr/bin/python3.12",
        "/opt/homebrew/bin/python3.12",
    ]

    # First try command line
    for cmd in ["python3.12", "python3"]:
        try:
            result = subprocess.run(
                [cmd, "--version"],
                capture_output=True,
                text=True
            )
            if result.returncode == 0 and "3.12" in result.stdout:
                return cmd
        except:
            continue

    # Then try specific paths
    for path in possible_paths:
        if os.path.exists(path):
            try:
                result = subprocess.run(
                    [path, "--version"],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0 and "3.12" in result.stdout:
                    return path
            except:
                continue

    return None

def run_command(cmd, check=True):
    """Run shell command and return output."""
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"Error: {result.stderr}")
        return False
    if result.stdout:
        print(result.stdout)
    return True

def setup():
    """Main setup function."""
    print("=" * 60)
    print("Tinkoff Trading Bot - Setup")
    print("=" * 60)

    # Find Python 3.12 (required for tinkoff-investments)
    python_path = find_python_3_12()

    if python_path is None:
        print("\nERROR: Python 3.12 is required but not found!")
        print("Please install Python 3.12 from https://www.python.org/downloads/")
        print("Or install via:")
        print("  macOS: brew install python@3.12")
        print("  Ubuntu: sudo apt install python3.12")
        return False

    print(f"\n✓ Found Python 3.12: {python_path}")

    # Create virtual environment if not exists
    venv_path = Path("venv")
    if venv_path.exists():
        print("\n[1/4] Removing old virtual environment...")
        import shutil
        shutil.rmtree(venv_path)

    print("\n[1/4] Creating virtual environment with Python 3.12...")
    result = subprocess.run([python_path, "-m", "venv", "venv"], capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error creating venv: {result.stderr}")
        return False

    # Get Python path in venv
    if sys.platform == "win32":
        venv_python = venv_path / "Scripts" / "python.exe"
        venv_pip = venv_path / "Scripts" / "pip.exe"
    else:
        venv_python = venv_path / "bin" / "python"
        venv_pip = venv_path / "bin" / "pip"

    # Upgrade pip
    print("\n[2/4] Upgrading pip...")
    run_command(f"{venv_python} -m pip install --upgrade pip", check=False)

    # Install dependencies
    print("\n[3/4] Installing dependencies...")
    print("This may take a few minutes...")

    # First install core dependencies that work
    print("Installing core dependencies...")
    deps = [
        '"grpcio>=1.50"',
        '"protobuf>=4.0,<5.0"',
        '"pydantic>=1.9,<2.0"',
        '"pydantic[dotenv]>=1.9,<2.0"',
        '"python-dateutil>=2.8"',
        '"deprecation>=2.1"',
        '"numpy>=1.22"',
        '"pytest>=7.0"',
        '"pytest-mock>=3.7"',
        '"pytest-asyncio>=0.18"',
    ]

    for dep in deps:
        if not run_command(f"{venv_pip} install {dep}"):
            print(f"Warning: Failed to install {dep}")

    # Try to install tinkoff-investments from system packages if available
    print("\nInstalling tinkoff-investments...")
    result = subprocess.run(
        [str(venv_python), "-c", "import sys; sys.path.insert(0, '/Library/Frameworks/Python.framework/Versions/3.12/lib/python3.12/site-packages'); import tinkoff"],
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        print("Found tinkoff-investments in system packages")
        print("Creating .pth file to include system packages...")
        site_packages = list(venv_path.glob("lib/python*/site-packages"))[0]
        with open(site_packages / "system_packages.pth", "w") as f:
            f.write("/Library/Frameworks/Python.framework/Versions/3.12/lib/python3.12/site-packages\n")
    else:
        print("Warning: Could not install tinkoff-investments automatically")
        print("Please ensure Python 3.12 is installed with tinkoff-investments")

    # Check .env file
    print("\n[4/4] Checking configuration...")
    env_file = Path(".env")
    if not env_file.exists():
        print("Creating .env from example...")
        example = Path(".env.example")
        if example.exists():
            env_file.write_text(example.read_text())
        else:
            env_file.write_text("TOKEN=your_token_here\nACCOUNT_ID=?\nSANDBOX=True\n")
        print("⚠️  Please edit .env file and add your Tinkoff token!")
    else:
        print("✓ .env file exists")

    # Check instruments_config.json
    config_file = Path("instruments_config.json")
    if not config_file.exists():
        print("Creating default instruments_config.json...")
        example = Path("instruments_config.json.example")
        if example.exists():
            config_file.write_text(example.read_text())
        else:
            config_file.write_text('''{
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
}''')
        print("✓ Created instruments_config.json with default Sberbank settings")
    else:
        print("✓ instruments_config.json exists")

    # Verify installation
    print("\n" + "=" * 60)
    print("Verifying installation...")
    print("=" * 60)

    # Test with system packages path
    test_code = """
import sys
sys.path.insert(0, '/Library/Frameworks/Python.framework/Versions/3.12/lib/python3.12/site-packages')
try:
    from tinkoff.invest import AsyncClient
    print('✓ tinkoff-investments OK')
except ImportError as e:
    print(f'✗ Failed to import: {e}')
    sys.exit(1)
"""

    result = subprocess.run(
        [str(venv_python), "-c", test_code],
        capture_output=True,
        text=True
    )
    if result.returncode == 0:
        print(result.stdout.strip())
    else:
        print("✗ Failed to import tinkoff-investments")
        print(result.stderr)
        print("\nTrying alternative method...")
        # Copy site-packages from system Python 3.12
        import shutil
        system_site = "/Library/Frameworks/Python.framework/Versions/3.12/lib/python3.12/site-packages"
        venv_site = str(site_packages)

        for pkg in ["tinkoff", "tinkoff_invest", "grpc", "google"]:
            src = Path(system_site) / pkg
            dst = Path(venv_site) / pkg
            if src.exists() and not dst.exists():
                print(f"Linking {pkg}...")
                try:
                    if pkg == "grpc":
                        # Copy grpc directory
                        shutil.copytree(src, dst, ignore_dangling_symlinks=True)
                    else:
                        os.symlink(src, dst, target_is_directory=True)
                except Exception as e:
                    print(f"Warning: Could not link {pkg}: {e}")

    print("\n" + "=" * 60)
    print("Setup completed!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Edit .env file and add your Tinkoff token")
    print("   Get token: https://www.tinkoff.ru/invest/settings/")
    print("2. Get account ID: make get_accounts")
    print("3. Run the bot: make start")
    print("\nQuick commands:")
    if sys.platform == "win32":
        print("   venv\\Scripts\\activate")
        print("   make get_accounts")
        print("   make start")
    else:
        print("   source venv/bin/activate")
        print("   GRPC_DNS_RESOLVER=native make get_accounts")
        print("   GRPC_DNS_RESOLVER=native make start")
    print()

    return True

if __name__ == "__main__":
    success = setup()
    sys.exit(0 if success else 1)
