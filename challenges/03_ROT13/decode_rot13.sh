#!/bin/bash

# === ROT13 Decoder Helper ===

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

clear
echo "🔐 ROT13 Decoder Helper"
echo "==========================="
echo
echo "📄 File to analyze: cipher.txt"
echo "🎯 Goal: Decode this message and find the hidden CCRI flag."
echo
echo "💡 What is ROT13?"
echo "   ➡️ A simple Caesar cipher that shifts each letter 13 places in the alphabet."
echo "   ➡️ Encoding and decoding use the same operation because 13+13=26 (a full loop!)."
echo
read -p "Press ENTER to learn how the decoder works..."

# Explain the decoding process
clear
echo "🛠️ Behind the Scenes"
echo "---------------------------"
echo "We’ll use a Python helper to process each character:"
echo
echo "   For every letter in cipher.txt:"
echo "     ➡️ Rotate it forward by 13 places (A→N, N→A)."
echo
echo "💻 The Python decoder also animates this process so you can watch it work."
echo
read -p "Press ENTER to launch the animated decoder..."

# Run the Python decoder
python3 - <<EOF
import time
import os
import sys

# Path setup
project_root = "${PROJECT_ROOT}"
script_dir = "${SCRIPT_DIR}"
cipher_file = os.path.join(script_dir, "cipher.txt")
output_file = os.path.join(script_dir, "decoded_output.txt")

# Check if cipher.txt exists
if not os.path.isfile(cipher_file) or os.path.getsize(cipher_file) == 0:
    print("\\n❌ ERROR: cipher.txt is missing or empty.")
    sys.exit(1)

with open(cipher_file, "r") as f:
    encoded = f.read()

def rot13_char(c):
    if 'a' <= c <= 'z':
        return chr((ord(c) - ord('a') + 13) % 26 + ord('a'))
    elif 'A' <= c <= 'Z':
        return chr((ord(c) - ord('A') + 13) % 26 + ord('A'))
    else:
        return c

def animate_rot13(encoded_text):
    decoded_chars = list(encoded_text)
    for i in range(len(encoded_text)):
        c = encoded_text[i]
        if c.isalpha():
            for step in range(13):
                rotated = chr(((ord(c.lower()) - ord('a') + step) % 26 + ord('a')))
                if c.isupper():
                    rotated = rotated.upper()
                decoded_chars[i] = rotated
                os.system("clear")
                print("🔐 ROT13 Decoder Helper")
                print("===========================\\n")
                print("🌀 Decrypting:\\n")
                print("".join(decoded_chars))
                time.sleep(0.02)
            decoded_chars[i] = rot13_char(c)
    return "".join(decoded_chars)

final_message = animate_rot13(encoded)

# Save decoded output
with open(output_file, "w") as f_out:
    f_out.write(final_message)

# Display the result
print("\\n✅ Final Decoded Message:")
print("-----------------------------")
print(final_message)
print("-----------------------------")
print(f"📁 Saved to: {output_file}")
EOF

# Check for Python failure
if [[ $? -ne 0 ]]; then
    echo -e "\n⚠️ ROT13 decoding failed. Make sure cipher.txt exists and is valid."
    read -p "Press ENTER to close this terminal..."
    exit 1
fi

echo
echo "🧠 Look carefully: Only one string matches the CCRI flag format: CCRI-AAAA-1111"
echo "📋 Copy the correct flag and paste it into the scoreboard when ready."
echo
read -p "Press ENTER to close this terminal..."
exec $SHELL
