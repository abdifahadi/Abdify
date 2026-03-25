(function abdify() {
    // --- ABDIFY v2.3 ZERO-DEPENDENCY ENGINE ---
    // No Spicetify/AbdiEngine required. 100% Standalone.

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
            --spice-accent: #8CC63E;
            --backdrop: rgba(0, 0, 0, 0.45);
        }

        /* Full Background Logic */
        .encore-dark-theme, .encore-layout-themes, 
        [class*="main-view-container"], [class*="Root__main-view"],
        [class*="Root__nav-bar"], [class*="Root__now-playing-bar"],
        .main-topBar-background, .main-topBar-overlay {
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
            transition: background-image 0.8s ease-in-out;
        }

        /* Search Bar & UI Tweak */
        [class*="searchBar"], .x-searchInput-searchInputInput {
            background-color: rgba(255,255,255,0.1) !important;
            border-radius: 500px !important;
            border: none !important;
        }
    `;

    injectCSS(CSS);

    // Dynamic Background Logic (Standalone DOM Observer)
    const updateBg = () => {
        const imgEl = document.querySelector('[data-testid="cover-art-image"], .main-nowPlayingWidget-coverExpanded img, .main-coverSlotCollapsed-container img');
        if (imgEl && imgEl.src) {
            const url = imgEl.src.replace("spotify:image:", "https://i.scdn.co/image/");
            document.documentElement.style.setProperty('--image_url', `url('${url}')`);
        } else {
            const defaultImg = "https://i.imgur.com/Wl2D0h0.png";
            document.documentElement.style.setProperty('--image_url', `url('${defaultImg}')`);
        }
    };

    // Branding Update Logic
    const brandUI = () => {
        const input = document.querySelector('[class*="searchBar"] input, .x-searchInput-searchInputInput');
        if (input && input.placeholder !== "Search in Abdify...") {
            input.placeholder = "Search in Abdify...";
        }
        
        // Update any other text elements if needed
    };

    // Main Observer Loop
    const observer = new MutationObserver(() => {
        brandUI();
        updateBg();
    });

    observer.observe(document.body, { childList: true, subtree: true, attributes: true });
    
    // Initial Run
    updateBg();
    brandUI();

    console.log("Abdify v2.3 (Zero-Dependency) started.");
})();
