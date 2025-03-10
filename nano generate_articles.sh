#!/bin/bash

set -e  # Hentikan script jika terjadi error

# Pastikan file articles.json ada
if [ ! -f articles.json ]; then
    echo "[]" > articles.json
fi

# Bersihkan isi articles.json lama
echo "[]" > temp.json

# Loop semua file HTML di repo
for file in *.html; do
    if [ -f "$file" ]; then
        title=$(grep -oP '(?<=<title>)(.*?)(?=</title>)' "$file" | head -1)
        desc=$(grep -oP '(?<=<meta name="description" content=")(.*?)(?=")' "$file" | head -1)
        link="$file"

        if [ -z "$title" ]; then title="No Title"; fi
        if [ -z "$desc" ]; then desc="No Description"; fi

        # Tambahkan ke JSON
        jq --arg title "$title" --arg link "$link" --arg desc "$desc" \
        '. + [{"title": $title, "link": $link, "description": $desc}]' temp.json > articles.json

        mv articles.json temp.json
    fi
done

mv temp.json articles.json  # Ganti file lama dengan yang baru

echo "✅ articles.json berhasil diperbarui!"
