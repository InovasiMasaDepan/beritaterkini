#!/bin/bash

# Direktori tempat artikel disimpan
ARTICLES_DIR="articles"
OUTPUT_FILE="articles.json"

# Awal JSON
echo "[" > $OUTPUT_FILE

# Loop semua file dalam folder articles
first=true
for file in "$ARTICLES_DIR"/*; do
    if [ -f "$file" ]; then
        # Ambil nama file sebagai judul (tanpa ekstensi)
        title=$(basename "$file" | sed 's/\.[^.]*$//')

        # Ambil 2 baris pertama sebagai deskripsi
        description=$(head -n 2 "$file" | tr '\n' ' ')

        # Buat URL gambar otomatis berdasarkan nama file
        image_url="https://inovasimassadepan.github.io/beritaterkini/images/${title}.jpg"

        # Tambahkan koma jika bukan data pertama
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> $OUTPUT_FILE
        fi

        # Tulis data JSON
        echo "  {" >> $OUTPUT_FILE
        echo "    \"judul\": \"$title\"," >> $OUTPUT_FILE
        echo "    \"gambar\": \"$image_url\"," >> $OUTPUT_FILE
        echo "    \"konten\": \"$description\"" >> $OUTPUT_FILE
        echo "  }" >> $OUTPUT_FILE
    fi
done

# Akhir JSON
echo "]" >> $OUTPUT_FILE

echo "✅ articles.json berhasil dibuat!"
