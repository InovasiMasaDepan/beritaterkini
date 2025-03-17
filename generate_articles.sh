#!/bin/bash

# Output file JSON
OUTPUT_FILE="beritaterkini/articles.json"

# Cari semua file HTML di dalam folder "beritaterkini" (kecuali index.html)
ARTICLE_FILES=$(find beritaterkini -type f -name "*.html" ! -name "index.html")

# Debugging: Tampilkan lokasi dan file yang ditemukan
echo "📂 Current directory: $(pwd)"
echo "🔍 Files ditemukan:"
echo "$ARTICLE_FILES"

# Jika tidak ada artikel, buat file JSON kosong
if [[ -z "$ARTICLE_FILES" ]]; then
    echo "⚠️ Tidak ada artikel ditemukan!"
    echo "[]" > "$OUTPUT_FILE"
    exit 0
fi

# Mulai JSON
echo "[" > "$OUTPUT_FILE"
counter=0

# Loop semua file HTML
while IFS= read -r filepath; do
    filename=$(basename "$filepath")
    relative_path=${filepath#beritaterkini/}

    # Ambil title dari tag <title>
    title=$(grep -oP '(?<=<title>).*?(?=</title>)' "$filepath" | head -1 | sed 's/"/\\"/g')

    # Ambil deskripsi dari meta tag <meta name="description">
    description=$(grep -oP '(?<=<meta name="description" content=").*?(?=")' "$filepath" | head -1 | sed 's/"/\\"/g')

    # Ambil gambar dari meta tag <meta property="og:image">
    image=$(grep -oP '(?<=<meta property="og:image" content=").*?(?=")' "$filepath" | head -1)

    # Jika title tidak ditemukan, gunakan nama file tanpa .html
    if [[ -z "$title" ]]; then
        title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    fi

    # Jika deskripsi tidak ditemukan, pakai fallback
    if [[ -z "$description" ]]; then
        description="Baca artikel terbaru: $title"
    fi

    # Jika gambar tidak ditemukan, pakai default
    if [[ -z "$image" ]]; then
        image="https://inovasimasadepan.github.io/default-thumbnail.jpg"
    fi

    # Perbaikan: Pastikan JSON string valid
    title=$(echo "$title" | jq -Rsa .)
    description=$(echo "$description" | jq -Rsa .)

    # Buat link
    link="https://inovasimasadepan.github.io/beritaterkini/$relative_path"

    # Debugging: Tampilkan data yang diproses
    echo "📝 Artikel: $relative_path"
    echo "   ➜ Title: $title"
    echo "   ➜ Description: $description"
    echo "   ➜ Image: $image"
    echo "   ➜ Link: $link"

    # Tambahkan koma kecuali di elemen terakhir
    counter=$((counter+1))
    if [[ $counter -eq $ARTICLE_COUNT ]]; then
        comma=""
    else
        comma=","
    fi

    cat <<EOF >> "$OUTPUT_FILE"
    {
        "title": $title,
        "description": $description,
        "link": "$link",
        "image": "$image"
    }$comma
EOF

done <<< "$ARTICLE_FILES"

echo "]" >> "$OUTPUT_FILE"

# Validasi JSON jika ada `jq`
if command -v jq &> /dev/null; then
    jq . "$OUTPUT_FILE" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ JSON tidak valid! Periksa kembali articles.json."
        exit 1
    else
        echo "✅ articles.json berhasil diperbarui dengan $ARTICLE_COUNT artikel!"
    fi
else
    echo "⚠️ jq tidak terinstall, tidak bisa validasi JSON otomatis."
fi

# Commit dan push jika ada perubahan
git add "$OUTPUT_FILE"
git commit -m "Update articles.json otomatis"
git push origin main
