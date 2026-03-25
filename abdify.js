(function abdify() {
    // --- ABDIFY v2.3 [TRUE ZERO-DEPENDENCY] ---
    // No Spicetify / No External Engine Needed.
    
    console.log("Abdify v2.3 [Zero-Engine] Initializing...");

    const injectCSS = (css) => {
        const style = document.createElement('style');
        style.id = 'abdify-core-styles';
        style.textContent = css;
        document.head.appendChild(style);
    };

    const TRULY_STANDALONE_CSS = `
        :root {
            --spice-main: #0A0A0A;
            --spice-text: #FFFFFF;
            --spice-accent: #8CC63E;
            --backdrop: rgba(0, 0, 0, 0.45);
        }

        /* Forces Transparency on EVERY layer */
        .encore-dark-theme, .encore-layout-themes, 
        .Root__top-container, .Root__main-view, .Root__nav-bar, .Root__now-playing-bar,
        .main-topBar-background, .main-topBar-overlay,
        [class*="main-view-container"], [class*="under-main-view"], 
        .main-view-container__scroll-node, [class*="Root__content-wrapper"] {
            background-color: transparent !important;
            background: transparent !important;
        }

        /* The Animated Background */
        .Root__top-container::before {
            content: "";
            background-image: var(--image_url);
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            position: fixed;
            inset: 0;
            filter: blur(20px) contrast(50%) saturate(80%) brightness(130%);
            opacity: 0.6;
            z-index: -1;
            pointer-events: none;
            transition: background-image 1s ease-in-out;
        }

        /* Global UI Improvements */
        .main-topBar-searchBar, .x-searchInput-searchInputInput {
            background-color: rgba(255,255,255,0.1) !important;
            border-radius: 500px !important;
            border: none !important;
            padding-left: 15px !important;
        }
    `;

    // Inject Styles Immediately
    injectCSS(TRULY_STANDALONE_CSS);

    // Dynamic Logic (Stand-Alone)
    function updateLayout() {
        // Search Bar Placeholder
        const input = document.querySelector(".main-topBar-searchBar, .x-searchInput-searchInputInput");
        if (input && input.placeholder !== "Search in Abdify...") {
            input.placeholder = "Search in Abdify...";
        }

        // Image Detection (Stand-Alone)
        const img = document.querySelector('[data-testid="cover-art-image"], .main-nowPlayingWidget-coverExpanded img, .main-coverSlotCollapsed-container img');
        if (img && img.src) {
            const url = img.src.replace("spotify:image:", "https://i.scdn.co/image/");
            if (document.documentElement.style.getPropertyValue('--image_url') !== \`url('\${url}')\`) {
                document.documentElement.style.setProperty('--image_url', \`url('\${url}')\`);
            }
        } else if (!document.documentElement.style.getPropertyValue('--image_url')) {
            const def = "https://i.imgur.com/Wl2D0h0.png";
            document.documentElement.style.setProperty('--image_url', \`url('\${def}')\`);
        }
    }

    // High Performance Loop
    const obs = new MutationObserver(updateLayout);
    obs.observe(document.body, { childList: true, subtree: true, attributes: true });
    
    updateLayout();
    console.log("Abdify v2.3 [Zero-Engine] Running.");
})();
