#!/bin/bash

# === Interactive Hidden File Explorer ===

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

ROOT_DIR="$SCRIPT_DIR/junk"
RESULTS_FILE="$SCRIPT_DIR/results.txt"
CURRENT_DIR="$ROOT_DIR"

clear
echo "🗂️  Interactive Hidden File Explorer"
echo "======================================"
echo
echo "📁 Mission Briefing:"
echo "---------------------------"
echo "🎯 You’ve gained access to a suspicious folder: $(basename "$ROOT_DIR")."
echo "🔍 Somewhere inside is a *hidden file* containing the **real flag**."
echo "⚠️ Beware: Some files contain fake flags. Only one matches this format: CCRI-AAAA-1111"
echo
echo "🛠️ You’ll use simulated Linux commands to explore:"
echo "   - 'ls -a' to list all files (even hidden ones)"
echo "   - 'cat' to view file contents"
echo "   - 'cd' to move between directories"
echo
echo "💡 Don’t worry! You don’t have to type commands — just choose from the menu."
echo

# Ensure root_dir exists
if [[ ! -d "$ROOT_DIR" ]]; then
    echo "❌ ERROR: Folder '$ROOT_DIR' not found!"
    read -p "Press ENTER to close this terminal..." junk
    exit 1
fi

# Start exploring
while true; do
    clear
    echo "🗂️  Hidden File Explorer"
    echo "--------------------------------------"
    echo "📁 Current directory: ${CURRENT_DIR#$SCRIPT_DIR/}"
    echo
    echo "Choose an action:"
    echo "1️⃣  Show all files (ls -a)"
    echo "2️⃣  Enter a subdirectory (cd)"
    echo "3️⃣  View a file (cat)"
    echo "4️⃣  Go up one level (cd ..)"
    echo "5️⃣  Exit explorer"
    echo
    read -p "Enter your choice (1-5): " choice

    case $choice in
        1)
            echo
            echo "📂 Running: ls -a \"$CURRENT_DIR\""
            echo "--------------------------------------"
            ls -a "$CURRENT_DIR" | sort
            echo "--------------------------------------"
            read -p "Press ENTER to continue..." ;;
        2)
            clear
            echo "📂 Subdirectories in '${CURRENT_DIR#$SCRIPT_DIR/}':"
            echo "--------------------------------------"
            subdirs=($(find "$CURRENT_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
            if [ ${#subdirs[@]} -eq 0 ]; then
                echo "⚠️  No subdirectories found here."
                read -p "Press ENTER to continue..."
            else
                for i in "${!subdirs[@]}"; do
                    printf "%2d) %s\n" "$((i+1))" "${subdirs[$i]}"
                done
                read -p "Enter the number of the directory to enter: " index
                if [[ "$index" =~ ^[0-9]+$ && $index -ge 1 && $index -le ${#subdirs[@]} ]]; then
                    subdir="${subdirs[$((index-1))]}"
                    CURRENT_DIR="$CURRENT_DIR/$subdir"
                    echo "📂 Changed directory to: ${CURRENT_DIR#$SCRIPT_DIR/}"
                    sleep 0.5
                else
                    echo "❌ Invalid selection."
                    read -p "Press ENTER to continue..."
                fi
            fi ;;
        3)
            clear
            echo "📄 Files in '${CURRENT_DIR#$SCRIPT_DIR/}':"
            echo "--------------------------------------"
            files=($(find "$CURRENT_DIR" -mindepth 1 -maxdepth 1 -type f -exec basename {} \; | sort))
            if [ ${#files[@]} -eq 0 ]; then
                echo "⚠️  No files found here."
                read -p "Press ENTER to continue..."
            else
                for i in "${!files[@]}"; do
                    printf "%2d) %s\n" "$((i+1))" "${files[$i]}"
                done
                read -p "Enter the number of the file to view: " index
                if [[ "$index" =~ ^[0-9]+$ && $index -ge 1 && $index -le ${#files[@]} ]]; then
                    file="${files[$((index-1))]}"
                    filepath="$CURRENT_DIR/$file"
                    clear
                    echo "📄 Running: cat \"${filepath#$SCRIPT_DIR/}\""
                    echo "--------------------------------------"
                    cat "$filepath"
                    echo "--------------------------------------"
                    echo
                    read -p "Would you like to save this output to $(basename "$RESULTS_FILE")? (y/n): " save_choice
                    if [[ "$save_choice" =~ ^[Yy]$ ]]; then
                        echo -e "\n----- ${filepath#$SCRIPT_DIR/} -----" >> "$RESULTS_FILE"
                        cat "$filepath" >> "$RESULTS_FILE"
                        echo "✅ Saved to $(basename "$RESULTS_FILE")"
                    fi
                else
                    echo "❌ Invalid selection."
                    read -p "Press ENTER to continue..."
                fi
            fi ;;
        4)
            if [[ "$CURRENT_DIR" != "$ROOT_DIR" ]]; then
                parent_dir="$(dirname "$CURRENT_DIR")"
                CURRENT_DIR="$parent_dir"
                echo "⬆️  Moved up to: ${CURRENT_DIR#$SCRIPT_DIR/}"
                sleep 0.5
            else
                echo "⚠️ Already at the top-level directory ($(basename "$ROOT_DIR"))."
                read -p "Press ENTER to continue..."
            fi ;;
        5)
            echo "👋 Exiting explorer. Good luck finding the *real* flag!"
            break ;;
        *)
            echo "❌ Invalid option. Please enter a number from 1 to 5."
            read -p "Press ENTER to continue..." ;;
    esac
done

# Clean exit for web hub
exec $SHELL
