(function abdify() {
    // --- ABDIFY THEME ENGINE (SUPER LIGHTWEIGHT) ---
    const injectCSS = (css) => {
        const style = document.createElement('style');
        style.id = 'abdify-core-styles';
        style.textContent = css;
        document.head.appendChild(style);
    };

    const ABDIFY_CORE_CSS = `
        :root {
            --spice-main: #0A0A0A;
            --spice-text: #FFFFFF;
            --spice-button: #8CC63E;
            --spice-accent: #8CC63E;
            --backdrop: rgba(0, 0, 0, 0.45);
        }

        /* Fully Transparent Abdify UI */
        .encore-dark-theme, .encore-layout-themes {
            --background-base: transparent !important;
        }

        .Root__top-container::before {
            content: "";
            background-image: var(--image_url);
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            position: fixed;
            inset: 0;
            filter: blur(var(--blur, 15px)) contrast(var(--cont, 50%)) saturate(var(--satu, 70%)) brightness(var(--bright, 120%));
            opacity: 0.55;
            z-index: -1;
            pointer-events: none;
        }

        /* Branding Overrides */
        .main-topBar-searchBar, .x-searchInput-searchInputInput {
            border-radius: 500px !important;
        }
    `;

    injectCSS(ABDIFY_CORE_CSS);

    if (typeof AbdiEngine === "undefined") {
        setTimeout(abdify, 100);
        return;
    }

    const { Platform, Player, PopupModal, Topbar } = AbdiEngine;

    function updateBackground(url) {
        const defaultBg = "https://i.imgur.com/Wl2D0h0.png";
        const finalUrl = url ? url.replace("spotify:image:", "https://i.scdn.co/image/") : defaultBg;
        document.documentElement.style.setProperty('--image_url', `url('${finalUrl}')`);
    }

    Player.addEventListener("songchange", (e) => {
        updateBackground(e.data.item.metadata.image_url);
    });

    // Initial Load
    updateBackground();

    // Search Placeholder Implementation (Abdify Branding)
    const applyPlaceholder = () => {
        const input = document.querySelector(".main-topBar-searchBar, .x-searchInput-searchInputInput");
        if (input) input.placeholder = "Search in Abdify...";
    };

    const observer = new MutationObserver(applyPlaceholder);
    observer.observe(document.body, { childList: true, subtree: true });
    applyPlaceholder();

    // Abdify Settings Button
    new Topbar.Button("Abdify Settings", "edit", () => {
        PopupModal.display({
            title: "Abdify Theme Settings",
            content: "<div><p>Welcome to Abdify by Abdifahadi.</p></div>"
        });
    });

    console.log("Abdify Engine Started Successfully.");
})();
