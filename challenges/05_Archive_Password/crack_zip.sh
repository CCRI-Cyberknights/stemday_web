#!/bin/bash

# === ZIP Password Cracking Challenge ===

# === Locate Project Root ===
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
CIPHER_ZIP="$SCRIPT_DIR/secret.zip"
WORDLIST="$SCRIPT_DIR/wordlist.txt"
EXTRACTED_B64="$SCRIPT_DIR/message_encoded.txt"
OUTPUT_FILE="$SCRIPT_DIR/decoded_output.txt"

clear
echo "🔓 ZIP Password Cracking Challenge"
echo "======================================"
echo
echo "📁 Target archive: secret.zip"
echo "📜 Wordlist: wordlist.txt"
echo
echo "🎯 Goal: Crack the ZIP file’s password and decode the message inside."
echo
echo "💡 How this works:"
echo "   ➡️ We’ll test each password in wordlist.txt by running:"
echo
echo "      unzip -P [password] -t secret.zip"
echo
echo "   🛠 Breakdown:"
echo "      -P [password] → Supplies the password"
echo "      -t            → Tests if the ZIP is valid without extracting"
echo
read -p "Press ENTER to begin password testing..." junk

# Pre-flight checks
if [[ ! -f "$CIPHER_ZIP" ]]; then
    echo "❌ ERROR: secret.zip not found in this folder."
    read -p "Press ENTER to close this terminal..."
    exit 1
fi

if [[ ! -f "$WORDLIST" ]]; then
    echo "❌ ERROR: wordlist.txt not found in this folder."
    read -p "Press ENTER to close this terminal..."
    exit 1
fi

found=0
correct_pass=""

echo
echo "🔍 Starting password scan..."
sleep 0.5

# Try each password and display it
while read -r pw; do
    printf "\r[🔐] Trying password: %-20s" "$pw"
    sleep 0.05
    if unzip -P "$pw" -t "$CIPHER_ZIP" 2>/dev/null | grep -q "OK"; then
        echo -e "\n\n✅ Password found: \"$pw\""
        correct_pass="$pw"
        found=1
        break
    fi
done < "$WORDLIST"

if [[ "$found" -eq 0 ]]; then
    echo -e "\n❌ Password not found in wordlist.txt."
    echo "💡 Tip: You might need a bigger or different wordlist."
    read -p "Press ENTER to close this terminal..."
    exit 1
fi

# Confirm extraction
echo
read -p "Do you want to extract the ZIP archive now? [Y/n] " go
while [[ ! "$go" =~ ^[YyNn]?$ ]]; do
    read -p "Please enter Y or N: " go
done
[[ "$go" =~ ^[Nn]$ ]] && exit 0

echo
echo "📦 Extracting secret.zip..."
unzip -P "$correct_pass" "$CIPHER_ZIP" -d "$SCRIPT_DIR" >/dev/null 2>&1

if [[ ! -f "$EXTRACTED_B64" ]]; then
    echo "❌ Extraction failed."
    read -p "Press ENTER to close this terminal..."
    exit 1
fi

# Display base64 content
echo
echo "📄 Extracted Base64 Data:"
echo "-------------------------------"
cat "$EXTRACTED_B64"
echo "-------------------------------"

# Prompt for decoding
echo
read -p "Would you like to decode the Base64 message now? [Y/n] " decode
while [[ ! "$decode" =~ ^[YyNn]?$ ]]; do
    read -p "Please enter Y or N: " decode
done

if [[ "$decode" =~ ^[Nn]$ ]]; then
    echo "⚠️ Skipping Base64 decoding. You can run:"
    echo "    base64 --decode \"$EXTRACTED_B64\""
    echo "later if needed."
    read -p "Press ENTER to close this terminal..."
    exit 0
fi

# Decoding phase
echo
echo "🧪 Base64 Detected!"
echo "   Base64 encodes binary data as text for safe transmission."
echo
echo "🔓 Decoding Base64 using:"
echo "    base64 --decode \"$EXTRACTED_B64\""
read -p "Press ENTER to start decoding..." junk

# Decoding animation
echo
echo "🔽 Decoding..."
for i in {1..30}; do
    sleep 0.03
    printf "█"
done
echo -e "\n"

# Perform actual decoding
decoded=$(base64 --decode "$EXTRACTED_B64" 2>/dev/null)
status=$?

if [[ $status -ne 0 || -z "$decoded" ]]; then
    echo "❌ Decoding failed. The file may not be valid Base64."
    read -p "Press ENTER to close this terminal..."
    exit 1
fi

# Display decoded message
echo
echo "🧾 Decoded Message:"
echo "-------------------------------"
echo "$decoded"
echo "-------------------------------"
echo

# Save decoded output
echo "$decoded" > "$OUTPUT_FILE"
echo "💾 Decoded output saved as: decoded_output.txt"

echo
echo "🧠 Find the CCRI flag (format: CCRI-AAAA-1111) and submit it to the scoreboard."
read -p "Press ENTER to close this terminal..."
exec $SHELL
