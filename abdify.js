(function abdify() {
    // --- ABDIFY v2.2 CORE ENGINE ---
    const injectCSS = (css) => {
        const style = document.createElement('style');
        style.id = 'abdify-core-styles';
        style.textContent = css;
        document.head.appendChild(style);
    };

    const CSS = `
        :root {
            --spice-main: #0A0A0A;
            --spice-text: #FFFFFF;
            --spice-button: #8CC63E;
            --spice-accent: #8CC63E;
            --backdrop: rgba(0, 0, 0, 0.45);
        }

        /* Essential Transparency for Abdify */
        .encore-dark-theme, .encore-layout-themes, 
        [class*="main-view-container"], [class*="Root__main-view"],
        [class*="Root__nav-bar"], [class*="Root__now-playing-bar"] {
            background-color: transparent !important;
            background: transparent !important;
        }

        .Root__top-container::before {
            content: "";
            background-image: var(--image_url);
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            position: fixed;
            inset: 0;
            filter: blur(15px) contrast(50%) saturate(70%) brightness(120%);
            opacity: 0.55;
            z-index: -1;
            pointer-events: none;
            transition: background-image 0.6s ease-in-out;
        }

        /* Search & Navigation Tweaks */
        .main-topBar-searchBar, .x-searchInput-searchInputInput {
            background-color: rgba(255,255,255,0.1) !important;
            border-radius: 500px !important;
            border: none !important;
        }
    `;

    injectCSS(CSS);

    if (typeof AbdiEngine === "undefined") {
        setTimeout(abdify, 100);
        return;
    }

    const { Platform, Player, PopupModal, Topbar } = AbdiEngine;

    // Handle Background Transitions
    function updateBg(url) {
        const defaultImg = "https://i.imgur.com/Wl2D0h0.png";
        const finalUrl = url ? url.replace("spotify:image:", "https://i.scdn.co/image/") : defaultImg;
        document.documentElement.style.setProperty('--image_url', `url('${finalUrl}')`);
    }

    Player.addEventListener("songchange", (e) => {
        updateBg(e.data.item.metadata.image_url);
    });

    updateBg(); // Initial check

    // Branding Injection
    const brandUI = () => {
        const input = document.querySelector(".main-topBar-searchBar, .x-searchInput-searchInputInput");
        if (input) input.placeholder = "Search in Abdify...";
    };

    const obs = new MutationObserver(brandUI);
    obs.observe(document.body, { childList: true, subtree: true });
    brandUI();

    new Topbar.Button("Abdify Settings", "edit", () => {
        PopupModal.display({
            title: "Abdify Settings",
            content: "<div><h2 style='color:white'>Welcome to Abdify</h2><p>Running standalone without third-party tools.</p></div>"
        });
    });

    console.log("Abdify Standalone Engine Active.");
})();
