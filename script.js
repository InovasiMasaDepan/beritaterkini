document.addEventListener("DOMContentLoaded", function () {
    const newsContainer = document.getElementById("news-container");

    fetch("articles.json")
        .then(response => response.json())
        .then(articles => {
            newsContainer.innerHTML = "";
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
            newsContainer.innerHTML = "<p>Gagal memuat berita.</p>";
        });
});
