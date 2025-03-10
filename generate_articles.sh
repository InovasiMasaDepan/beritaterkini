#!/bin/bash

ARTICLES_DIR="articles"
OUTPUT_FILE="articles.json"

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

    echo "    {" >> "$OUTPUT_FILE"
    echo "        \"title\": \"$title\"," >> "$OUTPUT_FILE"
    echo "        \"description\": \"$description\"," >> "$OUTPUT_FILE"
    echo "        \"link\": \"$link\"" >> "$OUTPUT_FILE"
    echo "    }" >> "$OUTPUT_FILE"
done

echo "]" >> "$OUTPUT_FILE"

echo "✅ articles.json berhasil diperbarui dengan $(ls -1 "$ARTICLES_DIR"/*.html 2>/dev/null | wc -l) artikel!"
