#!/bin/bash

# Output file JSON
OUTPUT_FILE="articles.json"

# Cari semua file HTML (kecuali index.html) di mana saja dalam repo
ARTICLE_FILES=$(find . -type f -name "*.html" ! -name "index.html")

# Hitung jumlah artikel
ARTICLE_COUNT=$(echo "$ARTICLE_FILES" | wc -l)

if [ "$ARTICLE_COUNT" -eq 0 ]; then
    echo "⚠️ Tidak ada artikel ditemukan!"
    echo "[]" > "$OUTPUT_FILE"  # Buat file JSON kosong
    exit 0
fi

# Mulai JSON
echo "[" > "$OUTPUT_FILE"
first=true

# Loop semua file HTML
while IFS= read -r file; do
    filename=$(basename -- "$file")
    filepath=$(dirname -- "$file")
    relative_path=${filepath#./}  # Hapus './' di awal path

    # Ambil title dari tag <title>
    title=$(grep -oP '(?<=<title>).*?(?=</title>)' "$file" | head -1 | sed 's/"/\\"/g')

    # Ambil deskripsi dari meta tag <meta name="description">
    description=$(grep -oP '(?<=<meta name="description" content=").*?(?=")' "$file" | head -1 | sed 's/"/\\"/g')

    # Ambil gambar dari meta tag <meta property="og:image">
    image=$(grep -oP '(?<=<meta property="og:image" content=").*?(?=")' "$file" | head -1)

    # Jika title tidak ditemukan, gunakan nama file tanpa .html
    if [[ -z "$title" ]]; then
        title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    fi

    # Jika deskripsi tidak ditemukan, pakai fallback
    if [[ -z "$description" ]]; then
        description="Baca artikel terbaru: $title"
    fi

    # Jika gambar tidak ditemukan, pakai default (opsional)
    if [[ -z "$image" ]]; then
        image="https://inovasimasadepan.github.io/default-thumbnail.jpg"
    fi

    # Buat link yang benar sesuai lokasi file
    if [[ "$relative_path" == "" || "$relative_path" == "." ]]; then
        link="https://inovasimasadepan.github.io/$filename"
    else
        link="https://inovasimasadepan.github.io/$relative_path/$filename"
    fi

    echo "✅ Processing: $filename ($title)"  

    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi

    cat <<EOF >> "$OUTPUT_FILE"
    {
        "title": "$title",
        "description": "$description",
        "link": "$link",
        "image": "$image"
    }
EOF

done <<< "$ARTICLE_FILES"

echo "]" >> "$OUTPUT_FILE"

echo "✅ articles.json berhasil diperbarui dengan $ARTICLE_COUNT artikel!"
