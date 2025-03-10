#!/bin/bash

# Output file JSON
OUTPUT_FILE="articles.json"

# Pastikan ada file HTML di root
ARTICLE_COUNT=$(ls -1 ./*.html 2>/dev/null | wc -l)
if [ "$ARTICLE_COUNT" -eq 0 ]; then
    echo "⚠️ Tidak ada artikel ditemukan di root!"
    echo "[]" > "$OUTPUT_FILE"  # Buat file JSON kosong
    exit 0
fi

# Mulai JSON
echo "[" > "$OUTPUT_FILE"
first=true

# Loop semua file HTML di root
for file in ./*.html; do
    [ -e "$file" ] || continue  

    filename=$(basename -- "$file")
    title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    description="Artikel dari $title!"
    link="https://inovasimasadepan.github.io/beritaterkini/$filename"

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
