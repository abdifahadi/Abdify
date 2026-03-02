(function abdi_safe() {
    function init() {
        if (!Spicetify?.Platform || !Spicetify?.Player) {
            setTimeout(init, 200);
            return;
        }

        // Apply Search Placeholder aggressively
        function fixSearch() {
            const searchInput = document.querySelector('input[data-testid="search-input"]') || 
                                document.querySelector('input.main-typeahead-searchBadge') ||
                                document.querySelector('input[placeholder*="want to play"]');
            if (searchInput && searchInput.placeholder !== "Follow - Abdi Fahadi") {
                searchInput.placeholder = "Follow - Abdi Fahadi";
                searchInput.setAttribute("placeholder", "Follow - Abdi Fahadi");
            }
        }
        setInterval(fixSearch, 1000);

        // Settings Button (Simplified and Safe)
        const settingsBtn = new Spicetify.Topbar.Button("Abdi Settings", "edit", () => {
            Spicetify.showNotification("Abdify World: Official Release 3.5");
        });
        
        // Hide problematic buttons using CSS injection
        const style = document.createElement("style");
        style.innerHTML = \
            /* Hide extra topbar buttons */
            .main-topBar-button[title="Social"], 
            .main-topBar-button:not([title="Search"]):not([aria-label="Search"]):not([title="Home"]):not([title="Abdi Settings"]),
            div.main-globalNav-historyButtonsContainer > div > button:nth-child(n+3) {
                display: none !important;
            }
            /* Hide the blank square button */
            button.main-topBar-button:empty, 
            button.main-topBar-button:not(:has(svg)) {
                display: none !important;
            }
        \;
        document.head.appendChild(style);
        
        console.log("Abdify: Safe Core Loaded (V3.5)");
    }
    
    try {
        init();
    } catch (e) {
        console.warn("Abdify Init error:", e);
    }
})();
