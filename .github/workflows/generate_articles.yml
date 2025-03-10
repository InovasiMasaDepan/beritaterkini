#!/bin/bash

# Pastikan script berhenti jika ada error
set -e

# Hapus file lama dan mulai dengan array kosong
echo "[" > articles.json
first=true

# Loop semua file HTML, kecuali index.html
for file in *.html; do
    if [[ "$file" != "index.html" ]]; then
        title=$(grep -oP '(?<=<title>).*?(?=</title>)' "$file")

        # Tambahkan koma hanya jika bukan item pertama
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> articles.json
        fi
        
        echo "  { \"title\": \"$title\", \"description\": \"Artikel dari $title\", \"link\": \"$file\" }" >> articles.json
    fi
done

# Tutup array JSON
echo "]" >> articles.json

echo "✅ articles.json berhasil diperbarui!"
