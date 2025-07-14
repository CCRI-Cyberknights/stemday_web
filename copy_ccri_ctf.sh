#!/bin/bash

# === CCRI_CTF Selective Copy Script ===
# Copies CCRI_CTF folder to a student account Desktop
# Finds project root automatically and preserves ownership/permissions

# === Resolve project root ===
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
SRC="$PROJECT_ROOT/CCRI_CTF"

# === Prompt for student username ===
read -p "👤 Enter the student account username (e.g., 'ccri_stem'): " STUDENT_USER
if [ -z "$STUDENT_USER" ]; then
    echo "❌ No username entered. Aborting."
    exit 1
fi

DEST="/home/$STUDENT_USER/Desktop/CCRI_CTF"

# === Dry run flag ===
DRY_RUN=false

echo "🔄 CCRI_CTF Selective Copy Script (Overwrite Mode)"
echo "=================================================="
echo

read -p "Do a dry run first? (y/n): " yn
case $yn in
    [Yy]* ) DRY_RUN=true ;;
    * ) DRY_RUN=false ;;
esac

# === Check for existing destination ===
if [ -d "$DEST" ]; then
    echo "⚠️  Existing CCRI_CTF folder found at $DEST"
    read -p "Delete existing folder before copying? (y/n): " delete_yn
    case $delete_yn in
        [Yy]* )
            echo "🗑️  Deleting $DEST..."
            sudo rm -rf "$DEST"
            echo "✅ Old folder removed."
            ;;
        * )
            echo "🚫 Aborting: Folder already exists and not deleted."
            exit 1
            ;;
    esac
fi

# === Perform rsync ===
if $DRY_RUN; then
    echo "📝 Dry run: showing what would be copied..."
    rsync -avhn --progress \
        --include "challenges/***" \
        --include "web_version/***" \
        --include "Launch CCRI CTF Hub.desktop" \
        --exclude "*" \
        "$SRC/" "$DEST/"
    echo
    echo "✅ Dry run complete. No files were copied."
else
    echo "📂 Copying selected files from:"
    echo "   $SRC"
    echo "➡️  To:"
    echo "   $DEST"
    echo
    sudo rsync -avh --progress \
        --include "challenges/***" \
        --include "web_version/***" \
        --include "Launch CCRI CTF Hub.desktop" \
        --exclude "*" \
        "$SRC/" "$DEST/"

    # Set ownership
    echo "🔑 Setting ownership to $STUDENT_USER..."
    sudo chown -R "$STUDENT_USER":"$STUDENT_USER" "$DEST"

    # Set permissions
    echo "🔒 Adjusting permissions..."
    sudo chmod -R u+rwX,go-w "$DEST"

    echo
    echo "✅ Selective copy complete. Ownership and permissions fixed."
fi

echo
echo "🎯 Done! Switch to $STUDENT_USER to test:"
echo "    su - $STUDENT_USER"
echo "    cd ~/Desktop/CCRI_CTF"
