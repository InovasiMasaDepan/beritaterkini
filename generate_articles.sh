name: Update Articles JSON

on:
  push:
    paths:
      - "**/*.html"
  schedule:
    - cron: '0 * * * *'
  workflow_dispatch:

jobs:
  update-json:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Beri izin eksekusi ke generate_articles.sh
        run: chmod +x generate_articles.sh

      - name: Jalankan generate_articles.sh
        run: |
          set -e
          ./generate_articles.sh || { echo "❌ Script gagal!"; exit 1; }

      - name: Debug - Periksa isi articles.json
        run: |
          echo "📂 Isi articles.json setelah generate:"
          cat articles.json || { echo "❌ articles.json tidak ditemukan!"; exit 1; }

      - name: Periksa perubahan pada articles.json
        run: |
          git status
          git diff --stat articles.json

      - name: Commit & Push Perubahan
        env:
          GH_TOKEN: ${{ secrets.GH_PAT }}
        run: |
          set -e
          git config --global user.name "github-actions"
          git config --global user.email "actions@github.com"

          git remote set-url origin https://x-access-token:${GH_TOKEN}@github.com/InovasiMasaDepan/beritaterkini.git

          git pull --rebase origin main || echo "⚠️ Tidak bisa pull, lanjut commit."

          git add articles.json

          if git diff --cached --quiet; then
            echo "✅ Tidak ada perubahan pada articles.json. Tidak perlu commit."
            exit 0
          fi

          git commit -m "🔄 Update articles.json otomatis"
          git push origin main
