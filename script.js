document.addEventListener("DOMContentLoaded", async function () {
    try {
        let response = await fetch("https://inovasimasadepan.github.io/beritaterkini/articles.json?t=" + new Date().getTime());
        if (!response.ok) throw new Error("Gagal memuat articles.json");

        let data = await response.json();
        let container = document.getElementById("news-container");
        container.innerHTML = "";

        if (!Array.isArray(data) || data.length === 0) {
            container.innerHTML = "<p style='color:red;'>⚠️ Tidak ada berita untuk ditampilkan.</p>";
            return;
        }

        // Gunakan Document Fragment untuk meningkatkan performa
        let fragment = document.createDocumentFragment();

        data.forEach(article => {
            if (!article.title || !article.link) return; // Skip jika data tidak lengkap

            let articleDiv = document.createElement("div");
            articleDiv.classList.add("news-item");

            let img = document.createElement("img");
            img.src = article.image || "https://inovasimasadepan.github.io/default-thumbnail.jpg"; // Default thumbnail
            img.alt = article.title;
            img.loading = "lazy";
            img.style.cssText = "width:100%; border-radius:8px;";

            let title = document.createElement("h3");
            title.textContent = article.title;

            let desc = document.createElement("p");
            desc.textContent = article.description || "Baca selengkapnya...";
            desc.style.color = "#666";

            let link = document.createElement("a");
            link.href = article.link;
            link.target = "_blank";
            link.textContent = "Baca selengkapnya";

            // Gabungkan elemen
            articleDiv.appendChild(img);
            articleDiv.appendChild(title);
            articleDiv.appendChild(desc);
            articleDiv.appendChild(link);

            fragment.appendChild(articleDiv);
        });

        container.appendChild(fragment);
    } catch (error) {
        console.error("❌ Error:", error);
        document.getElementById("news-container").innerHTML = "<p style='color:red;'>⚠️ Gagal memuat berita!</p>";
    }
});
