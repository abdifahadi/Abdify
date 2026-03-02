(function abdify_final() {
    console.log("Abdify Final Core V4.5 Loaded");

    function updateUI() {
        // 1. Force Search Placeholder
        const searchInput = document.querySelector('input[data-testid="search-input"]') || 
                          document.querySelector('.main-typeahead-searchBadge input') ||
                          document.querySelector('input[placeholder*="want to play"]');
        if (searchInput && searchInput.placeholder !== "Follow - Abdi Fahadi") {
            searchInput.placeholder = "Follow - Abdi Fahadi";
            searchInput.setAttribute("placeholder", "Follow - Abdi Fahadi");
        }

        // 2. Hide problematic buttons
        const buttons = document.querySelectorAll('button.main-topBar-button, .main-globalNav-historyButtonsContainer button');
        buttons.forEach(btn => {
            const label = btn.getAttribute("aria-label") || btn.getAttribute("title") || "";
            // Hide the extra button (usually blank or titled differently)
            if (label === "" || label === "Social" || label === "Abdi Settings" || (!btn.querySelector('svg') && !btn.innerText)) {
                btn.style.display = "none";
                btn.style.width = "0";
                btn.style.opacity = "0";
            }
        });
    }

    // Run aggressively
    setInterval(updateUI, 500);
})();
