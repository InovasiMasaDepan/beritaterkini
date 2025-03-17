#!/bin/bash

# Output file JSON
OUTPUT_FILE="beritaterkini/articles.json"

# Pastikan folder "beritaterkini" ada
if [[ ! -d "beritaterkini" ]]; then
    echo "⚠️ Folder 'beritaterkini' tidak ditemukan!"
    echo "[]" > "$OUTPUT_FILE"
    exit 0
fi

# Cari semua file HTML di dalam folder "beritaterkini" (kecuali index.html)
ARTICLE_FILES=$(find beritaterkini -type f -name "*.html" ! -name "index.html" 2>/dev/null)

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
total_articles=$(echo "$ARTICLE_FILES" | wc -l)

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

    # Escape karakter yang bisa merusak JSON
    title=$(echo "$title" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/ /g' | sed 's/\r//g' | sed 's/\n/ /g')
    description=$(echo "$description" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/ /g' | sed 's/\r//g' | sed 's/\n/ /g')

    # Link yang sesuai dengan struktur folder beritaterkini
    link="https://inovasimasadepan.github.io/beritaterkini/$relative_path"

    # Debugging: Tampilkan data yang diproses
    echo "📝 Artikel: $relative_path"
    echo "   ➜ Title: $title"
    echo "   ➜ Description: $description"
    echo "   ➜ Image: $image"
    echo "   ➜ Link: $link"

    # Tambahkan koma kecuali di elemen terakhir
    counter=$((counter+1))
    if [[ $counter -lt $total_articles ]]; then
        comma=","
    else
        comma=""
    fi

    # Tambahkan ke JSON
    echo "  {" >> "$OUTPUT_FILE"
    echo "    \"title\": \"$title\"," >> "$OUTPUT_FILE"
    echo "    \"description\": \"$description\"," >> "$OUTPUT_FILE"
    echo "    \"link\": \"$link\"," >> "$OUTPUT_FILE"
    echo "    \"image\": \"$image\"" >> "$OUTPUT_FILE"
    echo "  }$comma" >> "$OUTPUT_FILE"

done <<< "$ARTICLE_FILES"

echo "]" >> "$OUTPUT_FILE"

# Validasi JSON jika ada `jq`
if command -v jq &> /dev/null; then
    jq . "$OUTPUT_FILE" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ JSON tidak valid! Periksa kembali articles.json."
        exit 1
    else
        echo "✅ articles.json berhasil diperbarui dengan $total_articles artikel!"
    fi
else
    echo "⚠️ jq tidak terinstall, tidak bisa validasi JSON otomatis."
fi

# Commit dan push jika ada perubahan
if git diff --quiet "$OUTPUT_FILE"; then
    echo "✅ Tidak ada perubahan pada articles.json, tidak perlu commit."
    exit 0
fi

git add "$OUTPUT_FILE"
git commit -m "🔄 Update articles.json otomatis"
git push origin main
