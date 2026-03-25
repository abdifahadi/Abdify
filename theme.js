(function abdi() {
    // --- ABDI THEME ENGINE (SUPER LIGHTWEIGHT) ---
    const injectCSS = (css) => {
        const style = document.createElement('style');
        style.id = 'abdi-core-styles';
        style.textContent = css;
        document.head.appendChild(style);
    };

    // Modern Selectors for Spotify 1.2.85+ (Global Nav)
    const CSS_VARS = `
        :root {
            --spice-main: #0A0A0A;
            --spice-sidebar: #0A0A0A;
            --spice-player: #0A0A0A;
            --spice-card: rgba(20, 20, 20, 0.6);
            --spice-text: #FFFFFF;
            --spice-subtext: #F0F0F0;
            --spice-button: #8CC63E;
            --spice-button-active: #8CC63E;
            --spice-accent: #8CC63E;
            --backdrop: rgba(0, 0, 0, 0.45);
            --blur: 15px;
        }

        /* Full Background & Transparency */
        .encore-dark-theme, .encore-layout-themes {
            --background-base: transparent !important;
            --background-highlight: var(--backdrop) !important;
            --background-elevated-base: var(--backdrop) !important;
        }

        /* The Magic Background Layer */
        .Root__top-container::before {
            content: "";
            background-image: var(--image_url);
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            position: fixed;
            inset: 0;
            filter: blur(var(--blur)) contrast(var(--cont, 50%)) saturate(var(--satu, 70%)) brightness(var(--bright, 120%));
            opacity: 0.55;
            z-index: -1;
            pointer-events: none;
            transition: background-image 0.5s ease;
        }

        /* Fix UI Elements to be Transparent */
        .Root__main-view, .Root__nav-bar, .Root__right-sidebar, .Root__now-playing-bar, 
        .main-topBar-background, .main-topBar-overlay {
            background-color: transparent !important;
            background: transparent !important;
            backdrop-filter: blur(10px);
        }

        /* Search Bar Styling */
        .main-topBar-searchBar, .x-searchInput-searchInputInput {
            background-color: rgba(255,255,255,0.1) !important;
            border-radius: 500px !important;
            color: white !important;
        }
    `;

    injectCSS(CSS_VARS);

    if (!Spicetify?.Platform || !Spicetify?.Player) {
        setTimeout(abdi, 100);
        return;
    }

    // Settings & State
    const defImage = "https://i.imgur.com/Wl2D0h0.png";
    let startImage = localStorage.getItem("abdi:startupBg") || defImage;

    function updateBackground(url) {
        const finalUrl = url ? url.replace("spotify:image:", "https://i.scdn.co/image/") : startImage;
        document.documentElement.style.setProperty('--image_url', `url('${finalUrl}')`);
    }

    // Hook into song changes
    Spicetify.Player.addEventListener("songchange", (e) => {
        const meta = e.data.item.metadata;
        if (localStorage.getItem("UseCustomBackground") !== "true") {
            updateBackground(meta.image_url);
        }
    });

    // Initial Load
    updateBackground();

    // Search Placeholder Implementation
    const applyPlaceholder = () => {
        const input = document.querySelector(".main-topBar-searchBar, .x-searchInput-searchInputInput");
        if (input) input.placeholder = "What do you want to play, Abdi?";
    };

    const observer = new MutationObserver(applyPlaceholder);
    observer.observe(document.body, { childList: true, subtree: true });
    applyPlaceholder();

    // Topbar Button
    const btn = new Spicetify.Topbar.Button("Abdi Settings", "edit", () => {
        Spicetify.PopupModal.display({
            title: "Abdi Theme Settings",
            content: "<div><p>Theme customized by Antigravity for Abdi.</p></div>"
        });
    });

    console.log("Abdify Core v2.0 Ready.");
})();
