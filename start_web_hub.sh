#!/bin/bash
# start_web_hub.sh - Unified launcher for admin and student environments

set -e

echo "🚀 Starting the CCRI CTF Hub..."

# === Helper: Find Project Root ===
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.ccri_ctf_root" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "❌ ERROR: Could not find .ccri_ctf_root marker. Are you inside the CTF folder?" >&2
    exit 1
}

PROJECT_ROOT="$(find_project_root)"

# === Detect mode: Admin vs Student ===
if [[ -d "$PROJECT_ROOT/web_version_admin" ]]; then
    echo "🛠️  Admin/Dev mode detected (web_version_admin found)."
    SERVER_DIR="$PROJECT_ROOT/web_version_admin"
    SERVER_FILE="server.py"
else
    echo "🎓 Student mode detected (web_version_admin not found)."
    SERVER_DIR="$PROJECT_ROOT/web_version"
    SERVER_FILE="server.pyc"
fi

# === Validate server path ===
SERVER_PATH="$SERVER_DIR/$SERVER_FILE"
if [[ ! -f "$SERVER_PATH" ]]; then
    echo "❌ ERROR: Cannot find $SERVER_FILE in $SERVER_DIR"
    exit 1
fi

# === Check if Flask server already running on port 5000 ===
echo "🔍 Checking if web server is already running on port 5000..."
if command -v lsof >/dev/null 2>&1 && lsof -i:5000 >/dev/null 2>&1; then
    echo "🌐 Flask web server is already running. Skipping launch."
else
    echo "🌐 Launching Flask web server from: $SERVER_PATH"
    LOG_FILE="$PROJECT_ROOT/web_server.log"
    nohup python3 "$SERVER_PATH" > "$LOG_FILE" 2>&1 &
    sleep 2

    # Check if it successfully launched
    if ! curl -s http://localhost:5000 >/dev/null; then
        echo "❌ ERROR: Flask server failed to start. Check logs at: $LOG_FILE"
        exit 1
    fi
    echo "✅ Flask server started successfully."
fi

# === Launch browser ===
echo "🌐 Opening browser to http://localhost:5000 ..."
if command -v xdg-open >/dev/null 2>&1; then
    nohup xdg-open "http://localhost:5000" >/dev/null 2>&1 || \
    echo "⚠️ WARNING: Failed to launch browser. Open manually: http://localhost:5000"
elif command -v firefox >/dev/null 2>&1; then
    nohup firefox "http://localhost:5000" >/dev/null 2>&1 || \
    echo "⚠️ WARNING: Failed to launch Firefox. Open manually: http://localhost:5000"
else
    echo "⚠️ No browser launcher found. Please open http://localhost:5000 manually."
fi

echo
echo "✅ CCRI CTF Hub is ready!"
