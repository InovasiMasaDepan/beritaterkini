#!/bin/bash

set -e  # Stop jika ada error

# Output file JSON di root repo
OUTPUT_FILE="articles.json"

# Cari semua file HTML di dalam repo (kecuali index.html)
ARTICLE_FILES=$(find . -type f -name "*.html" ! -name "index.html" 2>/dev/null | sort)

# Debugging: Pastikan ada file yang ditemukan
echo "📂 Current directory: $(pwd)"
echo "🔍 Files ditemukan:"
echo "$ARTICLE_FILES"

# Jika tidak ada artikel, buat file JSON kosong
if [[ -z "$ARTICLE_FILES" ]]; then
    echo "⚠️ Tidak ada artikel ditemukan! Membuat JSON kosong."
    echo "[]" > "$OUTPUT_FILE"
    exit 0
fi

# Array JSON
articles=()

while IFS= read -r filepath; do
    if [[ -z "$filepath" ]]; then
        continue
    fi

    filename=$(basename "$filepath")
    relative_path=${filepath#./}  # Buang "./" di depan path

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
    escape_json() {
        echo "$1" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/\\/\\\\/g' | sed 's/"/\\"/g'
    }

    title=$(escape_json "$title")
    description=$(escape_json "$description")

    # Link yang sesuai dengan struktur folder di GitHub Pages
    link="https://inovasimasadepan.github.io/$relative_path"

    # Debugging: Tampilkan data yang diproses
    echo "📝 Artikel: $relative_path"
    echo "   ➜ Title: $title"
    echo "   ➜ Description: $description"
    echo "   ➜ Image: $image"
    echo "   ➜ Link: $link"

    # Tambahkan data ke array JSON
    articles+=("{\"title\": \"$title\", \"description\": \"$description\", \"link\": \"$link\", \"image\": \"$image\"}")

done <<< "$ARTICLE_FILES"

# Gabungkan array menjadi JSON valid
echo "[${articles[*]}]" | jq '.' > "$OUTPUT_FILE"

# Debugging: Pastikan file JSON benar-benar dibuat
if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "❌ Gagal membuat articles.json!"
    exit 1
fi

# Validasi JSON
if jq . "$OUTPUT_FILE" > /dev/null 2>&1; then
    total_articles=$(echo "$ARTICLE_FILES" | wc -l)
    echo "✅ articles.json berhasil diperbarui dengan $total_articles artikel!"
else
    echo "❌ JSON tidak valid! Periksa kembali articles.json."
    exit 1
fi

# Pastikan Git dikonfigurasi agar bisa commit
git config --global user.name "netkiller" 
git config --global user.email "muhamad.faqih190402@gmail.com"

# Commit dan push jika ada perubahan
if git diff --quiet "$OUTPUT_FILE"; then
    echo "✅ Tidak ada perubahan pada articles.json, tidak perlu commit."
    exit 0
fi

git add "$OUTPUT_FILE"
git commit -m "🔄 Update articles.json otomatis"
git push origin main
