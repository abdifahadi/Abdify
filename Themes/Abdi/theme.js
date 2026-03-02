(function abdify_v36() {
    const log = (msg) => console.log("[%cAbdify%c] " + msg, "color: #1ed760; font-weight: bold", "");
    
    function applyPlaceholder() {
        const input = document.querySelector('input[data-testid="search-input"]') || 
                    document.querySelector('.main-typeahead-searchBadge input') ||
                    document.querySelector('input[placeholder*="want to play"]');
        if (input) {
            input.placeholder = "Follow - Abdi Fahadi";
            input.setAttribute("placeholder", "Follow - Abdi Fahadi");
        }
    }

    function init() {
        if (!Spicetify?.Platform) {
            setTimeout(init, 300);
            return;
        }
        log("Safe Engine Initialized (V3.6)");
        setInterval(applyPlaceholder, 1000);
        
        // Remove problematic buttons via JS just in case CSS fails
        const removeBadButtons = () => {
            const buttons = document.querySelectorAll('button.main-topBar-button');
            buttons.forEach(btn => {
                const title = btn.getAttribute("title") || btn.getAttribute("aria-label") || "";
                if (title === "" || title === "Social" || title.includes("Abdi Settings")) {
                    btn.style.display = "none";
                }
            });
        };
        setInterval(removeBadButtons, 2000);
    }

    try { init(); } catch(e) { console.error("Abdify Error:", e); }
})();
