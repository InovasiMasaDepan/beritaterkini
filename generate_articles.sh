#!/bin/bash

set -e  # Stop jika ada error

# Output file JSON di root repo
OUTPUT_FILE="articles.json"

# Cari semua file HTML di dalam repo (kecuali index.html)
ARTICLE_FILES=$(find . -type f -name "*.html" ! -name "index.html" 2>/dev/null | sort)

# Debugging: Cek apakah ada file HTML yang ditemukan
echo "📂 Directory: $(pwd)"
echo "🔍 File ditemukan:"
echo "$ARTICLE_FILES"

# Jika tidak ada artikel, buat file JSON kosong
if [[ -z "$ARTICLE_FILES" ]]; then
    echo "⚠️ Tidak ada artikel ditemukan! Membuat JSON kosong."
    echo "[]" > "$OUTPUT_FILE"
    exit 0
fi

articles=()

# Looping setiap file artikel
while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue

    filename=$(basename "$filepath")
    relative_path=${filepath#./}

    # Ambil title dari tag <title>
    title=$(grep -oP '(?<=<title>).*?(?=</title>)' "$filepath" | head -1 | sed 's/"/\\"/g')

    # Ambil deskripsi dari meta tag <meta name="description">
    description=$(grep -oP '(?<=<meta name="description" content=").*?(?=")' "$filepath" | head -1 | sed 's/"/\\"/g')

    # Ambil gambar dari meta tag <meta property="og:image">
    image=$(grep -oP '(?<=<meta property="og:image" content=").*?(?=")' "$filepath" | head -1)

    # Jika title tidak ditemukan, gunakan nama file sebagai fallback
    [[ -z "$title" ]] && title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

    # Jika deskripsi tidak ditemukan, gunakan fallback
    [[ -z "$description" ]] && description="Baca artikel terbaru: $title"

    # Jika gambar tidak ditemukan, gunakan default
    [[ -z "$image" ]] && image="https://inovasimasadepan.github.io/default-thumbnail.jpg"

    # Escape karakter yang bisa merusak JSON
    escape_json() {
        echo "$1" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/\\/\\\\/g' | sed 's/"/\\"/g'
    }

    title=$(escape_json "$title")
    description=$(escape_json "$description")

    # Link sesuai dengan struktur GitHub Pages
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

# Simpan ke JSON
echo "[${articles[*]}]" | jq '.' > "$OUTPUT_FILE"

# Validasi JSON
if jq . "$OUTPUT_FILE" > /dev/null 2>&1; then
    echo "✅ articles.json berhasil diperbarui!"
else
    echo "❌ JSON tidak valid! Periksa kembali articles.json."
    exit 1
fi

# Konfigurasi Git untuk GitHub Actions
git config --global user.name "github-actions"
git config --global user.email "actions@github.com"

# Commit & Push jika ada perubahan
if git diff --quiet "$OUTPUT_FILE"; then
    echo "✅ Tidak ada perubahan, skip commit."
    exit 0
fi

git add "$OUTPUT_FILE"
git commit -m "🔄 Update articles.json otomatis via GitHub Actions"
git push
