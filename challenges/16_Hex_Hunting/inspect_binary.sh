#!/bin/bash

# === Hex Flag Hunter ===

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
cd "$SCRIPT_DIR" || {
    echo "❌ Failed to change to script directory: $SCRIPT_DIR"
    exit 1
}

clear
echo "🔍 Hex Flag Hunter"
echo "============================"
echo
echo "🎯 Target binary: hex_flag.bin"
echo
echo "💡 Goal: Locate the real flag (format: CCRI-AAAA-1111)."
echo "    ⚠️ 5 candidate flags are embedded, but only ONE is correct!"
echo
echo "🔧 Behind the scenes:"
echo "   We'll scan the binary for any strings that *look like* flags using 'grep'."
echo "   Then we'll preview surrounding bytes in hex for context with 'xxd' and 'dd'."
echo

read -p "Press ENTER to begin scanning hex_flag.bin..." junk

# Add scanning animation
echo -ne "\n🔎 Scanning binary for flag-like patterns"
for i in {1..5}; do
    sleep 0.3
    echo -n "."
done
echo

BINARY_FILE="$SCRIPT_DIR/hex_flag.bin"
NOTES_FILE="$SCRIPT_DIR/notes.txt"

# Search for flag-like strings in the binary
flags=($(grep -aboE '([A-Z]{4}-[A-Z]{4}-[0-9]{4}|[A-Z]{4}-[0-9]{4}-[A-Z]{4})' "$BINARY_FILE" | awk -F: '{print $2}'))

if [[ ${#flags[@]} -eq 0 ]]; then
    echo -e "\n❌ No flag-like patterns found. Exiting..."
    read -p "Press ENTER to close..." junk
    exit 1
fi

echo
echo "✅ Found ${#flags[@]} candidate flag(s)."
echo

# Clear old notes file
> "$NOTES_FILE"

# Interactive loop for each candidate
for i in "${!flags[@]}"; do
    flag="${flags[$i]}"
    echo "--------------------------------------------"
    echo "[$((i+1))/${#flags[@]}] Candidate Flag: $flag"
    echo "--------------------------------------------"

    # Find the offset of the flag in the binary
    offset=$(grep -abo "$flag" "$BINARY_FILE" | head -n1 | cut -d: -f1)
    start=$((offset - 16))
    [ $start -lt 0 ] && start=0

    echo "📖 Hex context (around offset $offset):"
    echo "   Command used:"
    echo "   dd if=hex_flag.bin bs=1 skip=$start count=64 | xxd"
    sleep 1

    # Show hex dump around the flag
    dd if="$BINARY_FILE" bs=1 skip=$start count=64 2>/dev/null | xxd
    echo

    # Options for the user
    while true; do
        echo "Options:"
        echo "1) ✅ Mark this flag as POSSIBLE and save to notes.txt"
        echo "2) ➡️ Skip to next flag"
        echo "3) 🚪 Quit investigation"
        echo
        read -p "Choose an option (1-3): " choice

        case "$choice" in
            1)
                echo "$flag" >> "$NOTES_FILE"
                echo "✅ Saved '$flag' to notes.txt"
                sleep 0.5
                break
                ;;
            2)
                echo "➡️ Skipping to next candidate..."
                sleep 0.5
                break
                ;;
            3)
                echo "👋 Exiting investigation early."
                echo "📁 All saved candidate flags are in notes.txt"
                read -p "Press ENTER to close..." junk
                exit 0
                ;;
            *)
                echo "⚠️ Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
    echo
done

echo "🎉 Investigation complete!"
echo "📁 All saved candidate flags are in notes.txt"
echo "📝 Review and submit the correct flag to the scoreboard!"
read -p "Press ENTER to close..." junk
