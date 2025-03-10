#!/bin/bash

ARTICLES_DIR="articles"
OUTPUT_FILE="articles.json"

# Cek apakah folder articles ada dan berisi file HTML
if [ ! -d "$ARTICLES_DIR" ] || [ -z "$(ls -A "$ARTICLES_DIR"/*.html 2>/dev/null)" ]; then
    echo "[]" > "$OUTPUT_FILE"
    echo "⚠️ Tidak ada artikel ditemukan. articles.json dibuat kosong."
    exit 0
fi

echo "[" > "$OUTPUT_FILE"
first=true

for file in "$ARTICLES_DIR"/*.html; do
    [ -e "$file" ] || continue  

    filename=$(basename -- "$file")
    title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    description="Artikel dari $title!"
    link="https://inovasimasadepan.github.io/beritaterkini/$ARTICLES_DIR/$filename"

    echo "Processing: $filename"  

    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi

    cat <<EOF >> "$OUTPUT_FILE"
    {
        "title": "$title",
        "description": "$description",
        "link": "$link"
    }
EOF

done

echo "]" >> "$OUTPUT_FILE"

# Pastikan JSON valid dengan jq (jika tersedia)
if command -v jq &> /dev/null; then
    jq '.' "$OUTPUT_FILE" > temp.json && mv temp.json "$OUTPUT_FILE"
fi

echo "✅ articles.json berhasil diperbarui dengan $(ls -1 "$ARTICLES_DIR"/*.html 2>/dev/null | wc -l) artikel!"
