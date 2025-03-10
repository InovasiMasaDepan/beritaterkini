#!/bin/bash

# Output file JSON
OUTPUT_FILE="articles.json"

# Pastikan ada file HTML di root (kecuali index.html)
ARTICLE_COUNT=$(ls -1 ./*.html 2>/dev/null | grep -v "/index.html$" | wc -l)
if [ "$ARTICLE_COUNT" -eq 0 ]; then
    echo "⚠️ Tidak ada artikel ditemukan di root!"
    echo "[]" > "$OUTPUT_FILE"  # Buat file JSON kosong
    exit 0
fi

# Mulai JSON
echo "[" > "$OUTPUT_FILE"
first=true

# Loop semua file HTML di root (kecuali index.html)
for file in ./*.html; do
    [[ "$file" == "./index.html" ]] && continue  # Pastikan index.html tidak diproses

    filename=$(basename -- "$file")
    
    # Ambil title dari <title> di dalam file HTML
    title=$(grep -oP '(?<=<title>).*?(?=</title>)' "$file" | head -1)

    # Jika title tidak ditemukan, gunakan nama file tanpa .html
    if [[ -z "$title" ]]; then
        title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    fi

    # Cek jika title adalah "Index", jangan masukkan ke JSON
    if [[ "$title" == "Index" ]]; then
        echo "❌ Skip index.html dari daftar artikel."
        continue
    fi

    description="Artikel dari $title!"
    link="https://inovasimasadepan.github.io/beritaterkini/$filename"

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
        "link": "$link"
    }
EOF
done

echo "]" >> "$OUTPUT_FILE"

echo "✅ articles.json berhasil diperbarui dengan $ARTICLE_COUNT artikel!"
