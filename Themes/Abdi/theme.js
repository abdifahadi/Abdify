(function abdify_v37() {
    // 1. Force Search Placeholder
    function fixSearch() {
        const placeholder = "Follow - Abdi Fahadi";
        const selectors = [
            'input[data-testid="search-input"]',
            '.main-typeahead-searchBadge input',
            'input[placeholder*="want to play"]',
            '.Root__globalNav input'
        ];
        
        selectors.forEach(sel => {
            const el = document.querySelector(sel);
            if (el && el.placeholder !== placeholder) {
                el.placeholder = placeholder;
                el.setAttribute("placeholder", placeholder);
            }
        });
    }

    // 2. Aggressively Hide Extra Buttons
    function hideBadButtons() {
        // Hide the blank square button to the left of Home
        const historyButtons = document.querySelectorAll('.main-globalNav-historyButtonsContainer button');
        if (historyButtons.length > 2) {
            for (let i = 2; i < historyButtons.length; i++) {
                historyButtons[i].style.display = 'none';
            }
        }

        // Hide any button that has no icon or text
        document.querySelectorAll('button').forEach(btn => {
            if (btn.classList.contains('main-topBar-button') && !btn.querySelector('svg')) {
                btn.style.display = 'none';
            }
            if (btn.getAttribute('title') === 'Social' || btn.getAttribute('title') === 'Abdi Settings') {
                btn.style.display = 'none';
            }
        });
    }

    // Run loops
    setInterval(fixSearch, 500);
    setInterval(hideBadButtons, 500);
    
    console.log("Abdify V3.7: Stable Mode Activated");
})();
