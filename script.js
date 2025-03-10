document.addEventListener("DOMContentLoaded", function () {
    const newsContainer = document.getElementById("news-container");

    // Cek URL JSON langsung di console
    const jsonURL = "articles.json?t=" + new Date().getTime();
    console.log("Fetching articles from:", jsonURL);

    fetch(jsonURL)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json();
        })
        .then(articles => {
            console.log("Articles loaded:", articles);
            newsContainer.innerHTML = ""; // Hapus teks "Memuat berita..."

            articles.forEach(article => {
                const articleElement = document.createElement("article");
                articleElement.innerHTML = `
                    <h3><a href="${article.link}">${article.title}</a></h3>
                    <p>${article.description}</p>
                `;
                newsContainer.appendChild(articleElement);
            });
        })
        .catch(error => {
            console.error("Error loading articles:", error);
            newsContainer.innerHTML = "<p>Gagal memuat berita. Silakan coba lagi.</p>";
        });
});
