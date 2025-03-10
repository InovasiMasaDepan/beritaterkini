@@ -1,42 +1,40 @@
 #!/bin/bash
 
 # Direktori tempat artikel disimpan
 ARTICLES_DIR="articles"
 IMAGES_DIR="images"
 OUTPUT_FILE="articles.json"
 
 # Awal JSON
 # Mulai array JSON
 echo "[" > $OUTPUT_FILE
 
 # Loop semua file dalam folder articles
 # Loop setiap file .html di folder articles/
 first=true
 for file in "$ARTICLES_DIR"/*; do
     if [ -f "$file" ]; then
         # Ambil nama file sebagai judul (tanpa ekstensi)
         title=$(basename "$file" | sed 's/\.[^.]*$//')
 
         # Ambil 2 baris pertama sebagai deskripsi
         description=$(head -n 2 "$file" | tr '\n' ' ')
 
         # Buat URL gambar otomatis berdasarkan nama file
         image_url="https://inovasimassadepan.github.io/beritaterkini/images/${title}.jpg"
 
         # Tambahkan koma jika bukan data pertama
         if [ "$first" = true ]; then
             first=false
         else
             echo "," >> $OUTPUT_FILE
         fi
 
         # Tulis data JSON
         echo "  {" >> $OUTPUT_FILE
         echo "    \"judul\": \"$title\"," >> $OUTPUT_FILE
         echo "    \"gambar\": \"$image_url\"," >> $OUTPUT_FILE
         echo "    \"konten\": \"$description\"" >> $OUTPUT_FILE
         echo "  }" >> $OUTPUT_FILE
 for file in $ARTICLES_DIR/*.html; do
     [ -e "$file" ] || continue  # Lewati jika tidak ada file
 
     filename=$(basename -- "$file")
     title=$(echo "$filename" | sed 's/-/ /g' | sed 's/.html//g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
     description="Artikel dari $title!"
     image="https://inovasimasadepan.github.io/beritaterkini/$IMAGES_DIR/${filename%.html}.jpg"
     link="https://inovasimasadepan.github.io/beritaterkini/$ARTICLES_DIR/$filename"
 
     # Tambah koma kecuali untuk item pertama
     if [ "$first" = true ]; then
         first=false
     else
         echo "," >> $OUTPUT_FILE
     fi
 
     # Tambah item JSON
     echo "    {" >> $OUTPUT_FILE
     echo "        \"title\": \"$title\"," >> $OUTPUT_FILE
     echo "        \"description\": \"$description\"," >> $OUTPUT_FILE
     echo "        \"image\": \"$image\"," >> $OUTPUT_FILE
     echo "        \"link\": \"$link\"" >> $OUTPUT_FILE
     echo "    }" >> $OUTPUT_FILE
 done
 
 # Akhir JSON
 # Tutup array JSON
 echo "]" >> $OUTPUT_FILE
 
 echo "✅ articles.json berhasil dibuat!"
 echo "✅ articles.json berhasil diperbarui dengan $(ls $ARTICLES_DIR/*.html | wc -l) artikel!"
