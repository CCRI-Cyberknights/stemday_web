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

# === Change to server directory ===
cd "$SERVER_DIR" || {
    echo "❌ ERROR: Could not change to $SERVER_DIR. Exiting."
    exit 1
}

# === Check Python ===
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ ERROR: Python 3 is not installed or not in PATH."
    exit 1
fi

# === Start Flask server ===
echo "🌐 Launching Flask web server from: $SERVER_DIR/$SERVER_FILE"
nohup python3 "$SERVER_FILE" >/dev/null 2>&1 &

# Wait for server to initialize
sleep 2

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
