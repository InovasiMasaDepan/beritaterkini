#!/bin/bash

set -e  # Stop jika ada error

# Output file JSON di root repo
OUTPUT_FILE="articles.json"

# Cari semua file HTML di dalam repo (kecuali index.html)
ARTICLE_FILES=$(find . -type f -name "*.html" ! -name "index.html" 2>/dev/null | sort)

# Jika tidak ada artikel, buat file JSON kosong
if [[ -z "$ARTICLE_FILES" ]]; then
    echo "[]" > "$OUTPUT_FILE"
else
    articles=()
    while IFS= read -r filepath; do
        filename=$(basename "$filepath")
        relative_path=${filepath#./}

        title=$(grep -oP '(?<=<title>).*?(?=</title>)' "$filepath" | head -1 | sed 's/"/\\"/g')
        description=$(grep -oP '(?<=<meta name="description" content=").*?(?=")' "$filepath" | head -1 | sed 's/"/\\"/g')
        image=$(grep -oP '(?<=<meta property="og:image" content=").*?(?=")' "$filepath" | head -1)

        [[ -z "$title" ]] && title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        [[ -z "$description" ]] && description="Baca artikel terbaru: $title"
        [[ -z "$image" ]] && image="https://inovasimasadepan.github.io/default-thumbnail.jpg"

        title=$(echo "$title" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        description=$(echo "$description" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

        link="https://inovasimasadepan.github.io/$relative_path"

        articles+=("{\"title\": \"$title\", \"description\": \"$description\", \"link\": \"$link\", \"image\": \"$image\"}")
    done <<< "$ARTICLE_FILES"

    echo "[" > "$OUTPUT_FILE"
    for i in "${!articles[@]}"; do
        [[ $i -gt 0 ]] && echo "," >> "$OUTPUT_FILE"
        echo "${articles[$i]}" >> "$OUTPUT_FILE"
    done
    echo "]" >> "$OUTPUT_FILE"
fi

# Validasi JSON
jq . "$OUTPUT_FILE" > /dev/null 2>&1 || { echo "❌ JSON tidak valid!"; exit 1; }

# Commit & Push otomatis
git config --global user.name "github-actions"
git config --global user.email "actions@github.com"

if git diff --quiet "$OUTPUT_FILE"; then
    echo "✅ Tidak ada perubahan, skip commit."
    exit 0
fi

git add "$OUTPUT_FILE"
git commit -m "🔄 Update articles.json otomatis via GitHub Actions"
git push
