#!/bin/bash
# stop_web_hub.sh - Stop the CCRI CTF Hub cleanly (project-root aware)

echo "🛑 Stopping CCRI CTF Hub..."

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
    SERVER_FILE_ADMIN="$PROJECT_ROOT/web_version_admin/server.py"
    SERVER_FILEC_ADMIN="$PROJECT_ROOT/web_version_admin/server.pyc"
else
    echo "🎓 Student mode detected (web_version_admin not found)."
    SERVER_FILE_STUDENT="$PROJECT_ROOT/web_version/server.pyc"
fi

# === Kill server.py or server.pyc processes ===
echo "🔍 Searching for running server processes..."
pkill -f "$SERVER_FILE_ADMIN" 2>/dev/null && echo "✅ Killed server.py (Admin)" || echo "⚠️ No server.py process running."
pkill -f "$SERVER_FILEC_ADMIN" 2>/dev/null && echo "✅ Killed server.pyc (Admin)" || echo "⚠️ No server.pyc process running (Admin)."
pkill -f "$SERVER_FILE_STUDENT" 2>/dev/null && echo "✅ Killed server.pyc (Student)" || echo "⚠️ No server.pyc process running (Student)."

# === Check prerequisites ===
if ! command -v lsof >/dev/null 2>&1; then
    echo "⚠️ WARNING: 'lsof' not found. Cannot check ports. Skipping port cleanup."
    exit 0
fi

# === Kill any Flask/Gunicorn processes on port 5000 ===
if lsof -i:5000 >/dev/null 2>&1; then
    echo "🔪 Killing processes on port 5000..."
    lsof -ti:5000 | xargs -r kill -9
    echo "✅ Port 5000 cleared."
else
    echo "⚠️ No processes found on port 5000."
fi

# === Kill all simulated services on ports 8000–8100 ===
ports_killed=0
for port in $(seq 8000 8100); do
    if lsof -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1; then
        lsof -tiTCP:$port -sTCP:LISTEN | xargs -r kill -9
        ports_killed=$((ports_killed + 1))
    fi
done

if [[ $ports_killed -gt 0 ]]; then
    echo "✅ Cleared $ports_killed simulated service(s) on ports 8000–8100."
else
    echo "⚠️ No simulated services running on ports 8000–8100."
fi

echo
echo "🎯 All cleanup complete."
