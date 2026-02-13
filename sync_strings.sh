#!/bin/bash

# Define paths
BACKUP_STRINGS="/media/saad/Code9s/Dimitry_iOS/ketal_ios/ketal/Sources/Generated/Strings.swift"
LOCAL_STRINGS="/media/saad/Code9s/Dimitry_iOS/ketal_ios/ketal/Resources/Localizations/en.lproj/Localizable.strings"
LOCAL_STRINGSDICT="/media/saad/Code9s/Dimitry_iOS/ketal_ios/ketal/Resources/Localizations/en.lproj/Localizable.stringsdict"
PUB_STRINGS="/media/saad/Code9s/Dimitry_iOS/ketal_pub/ketal/Resources/Localizations/en.lproj/Localizable.strings"
MISSING_KEYS_FILE="missing_keys.txt"

echo "Extracting keys from Strings.swift..."
grep 'L10n.tr("Localizable", "' "$BACKUP_STRINGS" | sed -E 's/.*"Localizable", "([^"]+)".*/\1/' | sort -u > needed_keys.txt

echo "Extracting keys from Localizable.strings..."
grep -E '^\s*"' "$LOCAL_STRINGS" | sed -E 's/^\s*"([^"]+)".*/\1/' | sort -u > existing_keys.txt

echo "Extracting keys from Localizable.stringsdict..."
# Simple extraction of keys from plist (lines like <key>some_key</key>)
# We filter out standard plist keys like NSStringLocalizedFormatKey, etc.
grep -E "^\s*<key>.*</key>" "$LOCAL_STRINGSDICT" | sed -E 's/^\s*<key>(.*)<\/key>/\1/' | grep -vE "^(NSStringLocalizedFormatKey|NSStringFormatSpecTypeKey|NSStringFormatValueTypeKey|COUNT|one|other|zero|two|few|many)$" | sort -u >> existing_keys.txt

# Re-sort existing keys
sort -u existing_keys.txt -o existing_keys.txt

echo "Calculating missing keys..."
comm -23 needed_keys.txt existing_keys.txt > "$MISSING_KEYS_FILE"

MISSING_COUNT=$(wc -l < "$MISSING_KEYS_FILE")
echo "Found $MISSING_COUNT missing keys (excluding those in stringsdict)."

# Append missing keys
while read -r key; do
    # 1. Try exact match in PUB_STRINGS
    escaped_key=$(echo "$key" | sed 's/[]\/$*.^|[]/\\&/g')
    entry=$(grep -E "^\s*\"$escaped_key\"" "$PUB_STRINGS")
    
    if [ -n "$entry" ]; then
        echo "$entry" >> "$LOCAL_STRINGS"
        echo "Added (exact): $key"
        continue
    fi
    
    # 2. Try replacing underscores with dots
    dot_key=$(echo "$key" | sed 's/_/./g')
    escaped_dot_key=$(echo "$dot_key" | sed 's/[]\/$*.^|[]/\\&/g')
    entry=$(grep -E "^\s*\"$escaped_dot_key\"" "$PUB_STRINGS")
    
    if [ -n "$entry" ]; then
        value=$(echo "$entry" | sed -E 's/^\s*"[^"]+"(\s*=\s*".*";)/\1/')
        echo "\"$key\"$value" >> "$LOCAL_STRINGS"
        echo "Added (mapped): $key (from $dot_key)"
        continue
    fi
    
    # 3. Generate default value
    # value = Title Case of key, removing underscores
    # e.g. common_private -> Common Private
    # We use python for easy capitalization if available, or just sed
    
    # Simple sed replacement for underscores
    generated_value=$(echo "$key" | sed 's/_/ /g' | sed 's/\b\(.\)/\u\1/g')
    
    echo "\"$key\" = \"$generated_value\";" >> "$LOCAL_STRINGS"
    echo "Added (generated): $key = \"$generated_value\""
    
done < "$MISSING_KEYS_FILE"

# Clean up
rm needed_keys.txt existing_keys.txt "$MISSING_KEYS_FILE"
