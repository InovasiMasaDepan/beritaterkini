document.addEventListener("DOMContentLoaded", async function () {
    try {
        let response = await fetch("https://inovasimasadepan.github.io/beritaterkini/articles.json?t=" + new Date().getTime());
        if (!response.ok) throw new Error("Gagal memuat articles.json");

        let data = await response.json();
        let container = document.getElementById("news-container");
        container.innerHTML = "";

        if (data.length === 0) {
            container.innerHTML = "<p style='color:red;'>⚠️ Tidak ada berita untuk ditampilkan.</p>";
            return;
        }

        data.forEach(article => {
            let articleHTML = `
                <div class="news-item">
                    <img src="${article.image}" alt="${article.title}" loading="lazy" style="width:100%; border-radius:8px;">
                    <h3>${article.title}</h3>
                    <p style="color: #666;">${article.description}</p>
                    <a href="${article.link}" target="_blank">Baca selengkapnya</a>
                </div>
            `;
            container.innerHTML += articleHTML;
        });
    } catch (error) {
        console.error("❌ Error:", error);
        document.getElementById("news-container").innerHTML = "<p style='color:red;'>⚠️ Gagal memuat berita!</p>";
    }
});
