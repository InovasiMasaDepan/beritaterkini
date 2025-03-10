#!/bin/bash

ARTICLES_DIR="articles"
OUTPUT_FILE="articles.json"

# Pastikan folder articles ada
if [ ! -d "$ARTICLES_DIR" ]; then
    echo "❌ Folder $ARTICLES_DIR tidak ditemukan!"
    exit 1
fi

# Cek apakah ada file .html dalam folder
ARTICLE_COUNT=$(ls -1 "$ARTICLES_DIR"/*.html 2>/dev/null | wc -l)
if [ "$ARTICLE_COUNT" -eq 0 ]; then
    echo "⚠️ Tidak ada artikel ditemukan dalam $ARTICLES_DIR!"
    echo "[]" > "$OUTPUT_FILE"  # Buat file JSON kosong
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

    echo "✅ Processing: $filename"  

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

echo "✅ articles.json berhasil diperbarui dengan $ARTICLE_COUNT artikel!"
