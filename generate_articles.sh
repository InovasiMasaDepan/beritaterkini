#!/bin/bash

ARTICLES_DIR="articles"
IMAGES_DIR="images"
OUTPUT_FILE="articles.json"

# Cek apakah folder articles/ ada
if [ ! -d "$ARTICLES_DIR" ]; then
    echo "❌ ERROR: Folder '$ARTICLES_DIR' tidak ditemukan!"
    exit 1
fi

# Mulai array JSON
echo "[" > "$OUTPUT_FILE"

# Loop setiap file .html di folder articles/
first=true
count=0

for file in "$ARTICLES_DIR"/*.html; do
    [ -e "$file" ] || continue  # Lewati jika tidak ada file
    
    count=$((count + 1))
    filename=$(basename -- "$file")
    title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    description="Artikel dari $title!"
    image="https://inovasimasadepan.github.io/beritaterkini/$IMAGES_DIR/${filename%.html}.jpg"
    link="https://inovasimasadepan.github.io/beritaterkini/$ARTICLES_DIR/$filename"

    # Tambahkan log agar terlihat di terminal
    echo "✅ Memproses artikel: $title"

    # Tambah koma kecuali untuk item pertama
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi

    # Tambah item JSON
    cat <<EOF >> "$OUTPUT_FILE"
    {
        "title": "$title",
        "description": "$description",
        "image": "$image",
        "link": "$link"
    }
EOF
done

# Tutup array JSON
echo "]" >> "$OUTPUT_FILE"

# Jika tidak ada artikel ditemukan
if [ "$count" -eq 0 ]; then
    echo "[]" > "$OUTPUT_FILE"
    echo "⚠️ Tidak ada artikel ditemukan di folder '$ARTICLES_DIR'!"
else
    echo "🎉 articles.json berhasil diperbarui dengan $count artikel!"
fi
