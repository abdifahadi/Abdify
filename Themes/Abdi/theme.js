(function abdify_master_fix() {
    const DEBUG = true;
    const log = (msg) => DEBUG && console.log("[%cAbdify%c] " + msg, "color: #1ed760; font-weight: bold", "");

    function applyFixes() {
        // 1. Force Search Placeholder
        const searchInput = document.querySelector('input[data-testid="search-input"]') || 
                          document.querySelector('.main-typeahead-searchBadge input') ||
                          document.querySelector('input[placeholder*="want to play"]');
        
        if (searchInput) {
            const targetText = "Follow - Abdi Fahadi";
            if (searchInput.placeholder !== targetText) {
                searchInput.placeholder = targetText;
                searchInput.setAttribute("placeholder", targetText);
            }
        }

        // 2. Hide Extra Topbar Buttons (The Square Button Fix)
        // This targets buttons that are NOT Home and NOT Search in the global nav
        const historyContainer = document.querySelector('.main-globalNav-historyButtonsContainer > div');
        if (historyContainer) {
            const children = Array.from(historyContainer.children);
            children.forEach((child, index) => {
                // Keep only the first 2 buttons (Back/Forward usually)
                if (index >= 2) {
                    child.style.display = 'none';
                    child.style.visibility = 'hidden';
                    child.style.width = '0';
                }
            });
        }

        // Hide any generic topbar buttons that look like "Social" or blank squares
        document.querySelectorAll('button.main-topBar-button').forEach(btn => {
            const label = btn.getAttribute("aria-label") || btn.getAttribute("title") || "";
            if (label === "" || label === "Social" || label === "Abdi Settings" || (!btn.querySelector('svg') && !btn.innerText)) {
                btn.style.setProperty('display', 'none', 'important');
            }
        });
    }

    // Use MutationObserver for instant response to UI changes
    const observer = new MutationObserver(() => {
        applyFixes();
    });

    function start() {
        if (!document.body) {
            setTimeout(start, 100);
            return;
        }
        
        applyFixes();
        observer.observe(document.body, { childList: true, subtree: true });
        log("Ultra-Aggressive Fix Core V5.0 Loaded");
    }

    try { start(); } catch (e) { console.error("Abdify Master Error:", e); }
})();
