#!/bin/bash
# start_web_hub.sh - Launch the CTF student hub (robust version)

set -e

echo "🚀 Starting the CCRI CTF Student Hub..."
cd "$(dirname "$0")" || {
    echo "❌ ERROR: Could not change to script directory. Exiting."
    exit 1
}

# === Check prerequisites ===
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ ERROR: Python 3 is not installed or not in PATH. Please install it first."
    exit 1
fi

if ! command -v lsof >/dev/null 2>&1; then
    echo "❌ ERROR: 'lsof' command is required but not found. Please install it (e.g., apt install lsof)."
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "⚠️ WARNING: 'curl' not found. Startup checks may be less reliable."
fi

# === Check if Flask server is already running on port 5000 ===
echo "🔍 Checking if Flask server is already running on port 5000..."
if lsof -i:5000 >/dev/null 2>&1; then
    echo "🌐 Flask web server is already running on port 5000."
    flask_running=true
else
    echo "🌐 Starting Flask web server on port 5000..."
    flask_running=false

    # Attempt to start the server
    if [ -f "server.pyc" ]; then
        nohup python3 server.pyc >/dev/null 2>&1 &
    elif [ -f "server.py" ]; then
        nohup python3 server.py >/dev/null 2>&1 &
    else
        echo "❌ ERROR: server.py not found in $(pwd). Cannot start web hub."
        exit 1
    fi

    sleep 2  # Give it a moment to spin up
fi

# === Check if any ports 8000–8100 are already in use ===
echo "🔍 Checking simulated service ports (8000–8100)..."
ports_in_use=0
for port in $(seq 8000 8100); do
    if lsof -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1; then
        ports_in_use=$((ports_in_use + 1))
    fi
done

if [[ $ports_in_use -gt 0 ]]; then
    echo "🛰️ Detected $ports_in_use simulated services already running on ports 8000–8100."
else
    if [ "$flask_running" = true ]; then
        echo "⚠️ Flask is running but no simulated services detected on ports 8000–8100."
        echo "   (These are normally started automatically by server.py.)"
    else
        echo "🛰️ Simulated services on ports 8000–8100 will be launched shortly."
    fi
fi

# === Wait for Flask server to respond ===
echo "⏳ Waiting for web server to respond at http://localhost:5000 ..."
for i in {1..10}; do
    if curl -s http://localhost:5000 >/dev/null 2>&1; then
        echo "🌐 Web server is up and responding!"
        break
    else
        echo "⏳ Attempt $i/10: Web server not ready yet..."
        sleep 1
    fi

    if [[ $i -eq 10 ]]; then
        echo "❌ ERROR: Web server did not start within expected time."
        echo "💡 You may need to check 'server.py' for errors or run it manually with:"
        echo "    python3 server.py"
        exit 1
    fi
done

# === Launch browser to the hub ===
echo "🌐 Opening browser to http://localhost:5000..."
export DISPLAY=:0  # Ensure graphical display is set

if command -v xdg-open >/dev/null 2>&1; then
    if ! nohup xdg-open http://localhost:5000 >/dev/null 2>&1; then
        echo "⚠️ WARNING: Failed to launch browser with xdg-open. Open manually: http://localhost:5000"
    fi
elif command -v firefox >/dev/null 2>&1; then
    if ! nohup firefox http://localhost:5000 >/dev/null 2>&1; then
        echo "⚠️ WARNING: Failed to launch Firefox. Open manually: http://localhost:5000"
    fi
else
    echo "⚠️ WARNING: No browser launcher found (xdg-open or Firefox)."
    echo "💡 Please open http://localhost:5000 manually in your browser."
fi

echo
echo "✅ CCRI CTF Student Hub is ready to use!"
echo "📡 Simulated ports (8000–8100) are managed by the hub."

# === Keep script alive briefly to avoid launcher killing child processes ===
sleep 3
