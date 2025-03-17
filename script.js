document.addEventListener("DOMContentLoaded", function () {
    const newsContainer = document.getElementById("news-container");
    const jsonURL = "articles.json?t=" + new Date().getTime();

    console.log("Fetching articles from:", jsonURL);

    fetch(jsonURL)
        .then(response => {
            console.log("Response received:", response);
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return response.json();
        })
        .then(articles => {
            console.log("Articles loaded:", articles);
            newsContainer.innerHTML = ""; 

            articles.forEach(article => {
                const articleElement = document.createElement("article");

                // Pastikan link selalu memiliki "/beritaterkini/"
                let fixedLink = article.link.startsWith("/beritaterkini/") 
                    ? article.link 
                    : "/beritaterkini/" + article.link;

                articleElement.innerHTML = `
                    <h3><a href="${fixedLink}">${article.title}</a></h3>
                    <p>${article.description}</p>
                `;
                newsContainer.appendChild(articleElement);
            });
        })
        .catch(error => {
            console.error("Fetch error:", error);
            if (error.name === "AbortError") {
                newsContainer.innerHTML = "<p>Request dibatalkan.</p>";
            } else {
                newsContainer.innerHTML = "<p>Gagal memuat berita.</p>";
            }
        });
});
