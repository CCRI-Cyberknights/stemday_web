#!/bin/bash

# === Subdomain Sweep ===

# Locate Project Root
find_project_root() {
    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    while [ "$DIR" != "/" ]; do
        if [ -f "$DIR/.ccri_ctf_root" ]; then
            echo "$DIR"
            return 0
        fi
        DIR="$(dirname "$DIR")"
    done
    echo "❌ ERROR: Could not find project root marker (.ccri_ctf_root)." >&2
    exit 1
}

PROJECT_ROOT="$(find_project_root)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear

echo "🌐 Subdomain Sweep"
echo "================================="
echo
echo "🎯 Mission Briefing:"
echo "You've discovered **five subdomains** hosted by the target organization."
echo "Each one has an HTML page that *might* hide a secret flag."
echo
echo "🧠 Flag format: CCRI-AAAA-1111"
echo "💡 In real CTFs, you'd use tools like curl, grep, or open the page in a browser to search for hidden data."
echo

# Subdomains (base names only)
domains=(alpha beta gamma delta omega)

# --- Pre-flight check ---
missing=0
for domain in "${domains[@]}"; do
    html_file="$SCRIPT_DIR/${domain}.liber8.local.html"
    if [[ ! -f "$html_file" ]]; then
        echo "❌ ERROR: Missing file '$(basename "$html_file")'"
        missing=1
    fi
done
if [[ "$missing" -eq 1 ]]; then
    echo
    read -p "⚠️ One or more HTML files are missing. Press ENTER to exit." junk
    exit 1
fi

while true; do
    echo
    echo "📂 Available subdomains:"
    for i in "${!domains[@]}"; do
        echo "$((i+1)). ${domains[$i]}.liber8.local"
    done
    echo "6. Auto-scan all subdomains for flag patterns"
    echo "7. Exit"
    echo

    read -p "Select an option (1-7): " choice

    if [[ "$choice" -ge 1 && "$choice" -le 5 ]]; then
        file="$SCRIPT_DIR/${domains[$((choice-1))]}.liber8.local.html"
        echo
        echo "🌐 Opening $(basename "$file") in your browser..."
        xdg-open "$file" >/dev/null 2>&1 &
        echo
        echo "💻 Tip: View the page AND its source (Ctrl+U) for hidden data."
        echo "        You can also try searching for 'CCRI-' manually in the browser."
        echo
        read -p "Press ENTER to return to the menu." junk
        clear

    elif [[ "$choice" -eq 6 ]]; then
        echo
        echo "🔎 Auto-scanning all subdomains for flags using:"
        echo "    grep -E 'CCRI-[A-Z]{4}-[0-9]{4}' *.html"
        grep -E 'CCRI-[A-Z]{4}-[0-9]{4}' "$SCRIPT_DIR"/*.html --color=always || echo "⚠️ No flags found in auto-scan."
        echo
        read -p "Press ENTER to return to the menu." junk
        clear

    elif [[ "$choice" -eq 7 ]]; then
        echo "👋 Exiting Subdomain Sweep. Stay sharp, agent!"
        break

    else
        echo "❌ Invalid choice. Please enter a number from 1 to 7."
        read -p "Press ENTER to continue." junk
        clear
    fi
done

# Clean exit for web hub
exec $SHELL
