(function abdi() {
    if (!Spicetify?.Platform || !Spicetify?.Platform?.History?.listen) {
        setTimeout(abdi, 100);
        return;
    }

    const defImage = "https://i.imgur.com/Wl2D0h0.png";
    let startImage = localStorage.getItem("abdi:startupBg") || defImage;
    const toggleInfo = [
        {
            id: "UseCustomBackground",
            name: "Custom background",
            defVal: false,
        },
        {
            id: "UseCustomColor",
            name: "Custom color",
            defVal: true,
        },
    ];
    const toggles = {
        UseCustomBackground: false,
        UseCustomColor: true,
    };

    // One-time color migration to new green default
    if (!localStorage.getItem("abdi:colorMigrated")) {
        localStorage.setItem("CustomColor", "#8CC63E");
        localStorage.setItem("UseCustomColor", "true");
        localStorage.setItem("abdi:colorMigrated", "true");
    }
    const sliders = [
        {
            id: "blur",
            name: "Blur",
            min: 0,
            max: 50,
            step: 1,
            defVal: 15,
            end: "px",
        },
        { id: "cont", name: "Contrast", min: 0, max: 200, step: 2, defVal: 50 },
        { id: "satu", name: "Saturation", min: 0, max: 200, step: 2, defVal: 70 },
        {
            id: "bright",
            name: "Brightness",
            min: 0,
            max: 200,
            step: 2,
            defVal: 120,
        },
    ];

    (function sidebar() {
        if (localStorage.getItem("abdi Sidebar Activated")) return;
        // Sidebar settings
        const parsedObject = JSON.parse(
            localStorage.getItem("spicetify-exp-features")
        );

        // Variable if client needs to reload
        let reload = false;

        // Array of features
        const features = [
            "enableYLXSidebar",
            "enableRightSidebar",
            "enableRightSidebarTransitionAnimations",
            "enableRightSidebarLyrics",
            "enableRightSidebarExtractedColors",
            "enablePanelSizeCoordination",
        ];

        for (const feature of features) {
            // Ignore if feature not present
            if (!parsedObject[feature]) continue;

            // Change value if disabled
            if (!parsedObject[feature].value) {
                parsedObject[feature].value = true;
                reload = true;
            }
        }

        localStorage.setItem(
            "spicetify-exp-features",
            JSON.stringify(parsedObject)
        );
        localStorage.setItem("abdi Sidebar Activated", true);
        if (reload) {
            window.location.reload();
            reload = false;
        }
    })();

    function loadSliders() {
        sliders.forEach((opt) => {
            const val = localStorage.getItem(`${opt.id}Amount`) || opt.defVal;
            document.documentElement.style.setProperty(
                `--${opt.id}`,
                `${val}${opt.end || "%"}`
            );
        });
    }

    function setAccentColor(color) {
        document.querySelector(":root").style.setProperty("--spice-button", color);
        document
            .querySelector(":root")
            .style.setProperty("--spice-button-active", color);
        document.querySelector(":root").style.setProperty("--spice-accent", color);
    }

    async function fetchFadeTime() {
        try {
            const response = await Spicetify.Platform.PlayerAPI._prefs.get({
                key: "audio.crossfade_v2",
            });

            // Default to 0.4s if crossfade is disabled
            if (!response.entries["audio.crossfade_v2"].bool) {
                document.documentElement.style.setProperty("--fade-time", "0.4s");
                return;
            }
            const fadeTimeResponse = await Spicetify.Platform.PlayerAPI._prefs.get({
                key: "audio.crossfade.time_v2",
            });
            const fadeTime =
                fadeTimeResponse.entries["audio.crossfade.time_v2"].number;

            // Use the CSS variable "--fade-time" for transition time
            document.documentElement.style.setProperty(
                "--fade-time",
                `${fadeTime / 1000}s`
            );
        } catch (error) {
            document.documentElement.style.setProperty("--fade-time", "0.4s");
        }
    }

    function getCurrentBackground(replace) {
        let url = Spicetify?.Player?.data?.item?.metadata?.image_url;
        if (toggles.UseCustomBackground || !url || !URL.canParse(url)) return startImage;
        if (replace)
            url = url.replace("spotify:image:", "https://i.scdn.co/image/");
        return url;
    }

    async function onSongChange() {
        fetchFadeTime();

        const album_uri = Spicetify?.Player?.data?.item?.metadata?.album_uri;
        if (album_uri !== undefined && !album_uri.includes("spotify:show")) {
            // Album
        } else if (Spicetify?.Player?.data?.item?.uri?.includes("spotify:episode")) {
            // Podcast
        } else if (Spicetify?.Player?.data?.item?.isLocal) {
            // Local file
        } else if (Spicetify?.Player?.data?.item?.provider === "ad") {
            // Ad
            return;
        } else {
            // When clicking a song from the homepage, songChange is fired with half empty metadata
            setTimeout(onSongChange, 200);
        }

        updateLyricsPageProperties();

        // Custom code added by lily
        if (!toggles.UseCustomColor) {
            // Get the accent color from the background image
            const img = new Image();
            // Allows CORS-enabled images
            img.crossOrigin = "Anonymous";

            img.onload = function () {
                const canvas = document.createElement("canvas");
                const ctx = canvas.getContext("2d");
                canvas.width = img.width;
                canvas.height = img.height;
                ctx.drawImage(img, 0, 0);

                const imageData = ctx.getImageData(
                    0,
                    0,
                    canvas.width,
                    canvas.height
                ).data;

                const rgbList = [];
                // Note that we are looping every 4 (red, green, blue and alpha)
                for (let i = 0; i < imageData.length; i += 4)
                    rgbList.push({
                        r: imageData[i],
                        g: imageData[i + 1],
                        b: imageData[i + 2],
                    });

                // Attempt with filters
                let hexColor = findColor(rgbList);

                // Retry without filters if no color is found
                if (!hexColor) hexColor = findColor(rgbList, true);

                setAccentColor(hexColor);
            };

            img.src = getCurrentBackground(true);
        } else {
            setAccentColor(localStorage.getItem("CustomColor") || "#8CC63E");
        }

        // Update background
        document.documentElement.style.setProperty(
            "--image_url",
            `url("${getCurrentBackground(false)}")`
        );
    }

    // Gets the most prominent color in a list of RGB values
    function findColor(rgbList, skipFilters = false) {
        const colorCount = {};
        let maxColor = "";
        let maxCount = 0;

        for (let i = 0; i < rgbList.length; i++) {
            if (
                !skipFilters &&
                (isTooDark(rgbList[i]) || isTooCloseToWhite(rgbList[i]))
            ) {
                continue;
            }

            const color = `${rgbList[i].r},${rgbList[i].g},${rgbList[i].b}`;
            colorCount[color] = (colorCount[color] || 0) + 1;

            if (colorCount[color] > maxCount) {
                maxColor = color;
                maxCount = colorCount[color];
            }
        }

        return maxColor ? rgbToHex(...maxColor.split(",").map(Number)) : null;
    }

    // Converts RGB to Hex
    function rgbToHex(r, g, b) {
        return "#" + [r, g, b].map((x) => x.toString(16).padStart(2, "0")).join("");
    }

    // Checks if a color is too dark
    function isTooDark(rgb) {
        const brightness = 0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b;
        // Adjust this value to control the "darkness" threshold
        const threshold = 100;
        return brightness < threshold;
    }

    // Checks if a color is too close to white
    function isTooCloseToWhite(rgb) {
        const threshold = 200;
        return rgb.r > threshold && rgb.g > threshold && rgb.b > threshold;
    }

    loadSliders();
    loadToggles();
    Spicetify.Player.addEventListener("songchange", onSongChange);
    if (window.navigator.userAgent.indexOf("Win") !== -1)
        document.body.classList.add("windows");
    galaxyFade();

    function scrollToTop() {
        const element = document.querySelector(".main-entityHeader-container");
        element.scrollIntoView({ behavior: "smooth", block: "start" });
    }

    document.addEventListener("click", (event) => {
        if (event.target.closest(".main-entityHeader-topbarTitle")) scrollToTop();
    });

    // Window Zoom Variable
    function updateZoomVariable() {
        let prevOuterWidth = window.outerWidth;
        let prevInnerWidth = window.innerWidth;
        let prevRatio = window.devicePixelRatio;

        function calculateAndApplyZoom() {
            const newOuterWidth = window.outerWidth;
            const newInnerWidth = window.innerWidth;
            const newRatio = window.devicePixelRatio;

            if (
                prevOuterWidth <= 160 ||
                prevRatio !== newRatio ||
                prevOuterWidth !== newOuterWidth ||
                prevInnerWidth !== newInnerWidth
            ) {
                const zoomFactor = newOuterWidth / newInnerWidth || 1;
                document.documentElement.style.setProperty("--zoom", zoomFactor);
                console.debug(
                    `[abdi] Zoom Updated: ${newOuterWidth} / ${newInnerWidth} = ${zoomFactor}`
                );

                // Update previous values
                prevOuterWidth = newOuterWidth;
                prevInnerWidth = newInnerWidth;
                prevRatio = newRatio;
            }
        }

        calculateAndApplyZoom();
        window.addEventListener("resize", calculateAndApplyZoom);
    }

    updateZoomVariable();

    function waitForElement(elements, func, timeout = 100) {
        const queries = elements.map((element) => document.querySelector(element));
        if (queries.every((a) => a)) {
            func(queries);
        } else if (timeout > 0) {
            setTimeout(waitForElement, 300, elements, func, timeout - 1);
        }
    }

    waitForElement(
        [".Root__globalNav"],
        (element) => {
            const isCenteredGlobalNav = Spicetify.Platform.version >= "1.2.46.462";
            let addedClass = "control-nav";
            if (element?.[0]?.classList.contains("Root__globalNav"))
                addedClass = isCenteredGlobalNav ? "global-nav-centered" : "global-nav";
            document.body.classList.add(addedClass);
        },
        10000
    );

    Spicetify.Platform.History.listen(updateLyricsPageProperties);

    waitForElement([".Root__lyrics-cinema"], ([lyricsCinema]) => {
        const lyricsCinemaObserver = new MutationObserver(
            updateLyricsPageProperties
        );
        const lyricsCinemaObserverConfig = {
            attributes: true,
            attributeFilter: ["class"],
        };
        lyricsCinemaObserver.observe(lyricsCinema, lyricsCinemaObserverConfig);
    });

    waitForElement([".main-view-container"], ([mainViewContainer]) => {
        const mainViewContainerResizeObserver = new ResizeObserver(
            updateLyricsPageProperties
        );
        mainViewContainerResizeObserver.observe(mainViewContainer);
    });

    // Fixes container shifting & active line clipping
    // Taken from Bloom | https://github.com/nimsandu/spicetify-bloom
    function updateLyricsPageProperties() {
        function setLyricsPageProperties() {
            function calculateLyricsMaxWidth(lyricsContentWrapper) {
                const lyricsContentContainer = lyricsContentWrapper.parentElement;
                const marginLeft = Number.parseInt(
                    window.getComputedStyle(lyricsContentWrapper).marginLeft,
                    10
                );
                const totalOffset = lyricsContentWrapper.offsetLeft + marginLeft;
                return Math.round(
                    0.95 * (lyricsContentContainer.clientWidth - totalOffset)
                );
            }

            waitForElement(
                [".lyrics-lyrics-contentWrapper"],
                ([lyricsContentWrapper]) => {
                    lyricsContentWrapper.style.maxWidth = "";
                    lyricsContentWrapper.style.width = "";

                    // 0, 1 - blank lines
                    const lyric = document.querySelector(
                        ".lyrics-lyricsContent-lyric"
                    )[2];
                    document.documentElement.style.setProperty(
                        "--lyrics-text-direction",
                        /[\u0591-\u07FF]/.test(lyric.innerText) ? "right" : "left"
                    );

                    document.documentElement.style.setProperty(
                        "--lyrics-active-max-width",
                        `${calculateLyricsMaxWidth(lyricsContentWrapper)}px`
                    );

                    // Lock lyrics wrapper width
                    const lyricsWrapperWidth =
                        lyricsContentWrapper.getBoundingClientRect().width;
                    lyricsContentWrapper.style.maxWidth = `${lyricsWrapperWidth}px`;
                    lyricsContentWrapper.style.width = `${lyricsWrapperWidth}px`;
                }
            );
        }

        function lyricsCallback(mutationsList, lyricsObserver) {
            for (const mutation of mutationsList)
                for (addedNode of mutation.addedNodes)
                    if (addedNode.classList?.contains("lyrics-lyricsContent-provider"))
                        setLyricsPageProperties();
            lyricsObserver.disconnect;
        }

        waitForElement(
            [".lyrics-lyricsContent-provider"],
            ([lyricsContentProvider]) => {
                setLyricsPageProperties();
                const lyricsObserver = new MutationObserver(lyricsCallback);
                lyricsObserver.observe(lyricsContentProvider.parentElement, {
                    childList: true,
                });
            }
        );
    }

    function setFadeDirection(scrollNode) {
        let fadeDirection = "full";
        if (scrollNode.scrollTop === 0) {
            fadeDirection = "bottom";
        } else if (
            scrollNode.scrollHeight -
            scrollNode.scrollTop -
            scrollNode.clientHeight ===
            0
        ) {
            fadeDirection = "top";
        }
        scrollNode.setAttribute("fade", fadeDirection);
    }

    // Add fade and dimness effects to mainview and the artist image on scroll
    // Taken from Galaxy | https://github.com/harbassan/spicetify-galaxy/
    function galaxyFade() {
        const setupFade = (selector, onScrollCallback) => {
            waitForElement([selector], ([scrollNode]) => {
                let ticking = false;

                scrollNode.addEventListener("scroll", () => {
                    if (!ticking) {
                        window.requestAnimationFrame(() => {
                            onScrollCallback(scrollNode);
                            ticking = false;
                        });
                        ticking = true;
                    }
                });

                // Initial trigger
                onScrollCallback(scrollNode);
            });
        };

        // Apply artist fade function
        const applyArtistFade = (scrollNode) => {
            const scrollValue = scrollNode.scrollTop;
            const fadeValue = Math.max(0, (-0.3 * scrollValue + 100) / 100);
            document.documentElement.style.setProperty("--artist-fade", fadeValue);
        };

        // Main view - apply artist fade + fade direction
        setupFade(
            ".Root__main-view [data-overlayscrollbars-viewport]",
            (scrollNode) => {
                applyArtistFade(scrollNode);
                setFadeDirection(scrollNode);
            }
        );

        // Nav bar - fade direction only
        setupFade(
            ".Root__nav-bar [data-overlayscrollbars-viewport]",
            (scrollNode) => {
                scrollNode.setAttribute("fade", "bottom");
                setFadeDirection(scrollNode);
            }
        );

        // Right sidebar - fade direction only
        setupFade(
            ".Root__right-sidebar [data-overlayscrollbars-viewport]",
            (scrollNode) => {
                scrollNode.setAttribute("fade", "bottom");
                setFadeDirection(scrollNode);
            }
        );
    }

    function loadToggles() {
        toggles.UseCustomBackground = JSON.parse(
            localStorage.getItem("UseCustomBackground")
        );
        toggles.UseCustomColor = JSON.parse(localStorage.getItem("UseCustomColor"));
        onSongChange();
    }

    // Input for custom background images (disabled until properly implemented)
    /* const bannerInput = document.createElement("input");
    bannerInput.type = "file";
    bannerInput.className = "banner-input";
    bannerInput.accept = [
      "image/jpeg",
      "image/apng",
      "image/avif",
      "image/gif",
      "image/png",
      "image/svg+xml",
      "image/webp",
    ].join(",");
  
    // When user selects a custom background image
    bannerInput.onchange = () => {
      if (!bannerInput.files.length) return;
  
      const file = bannerInput.files[0];
      const reader = new FileReader();
      reader.onload = (event) => {
        const result = event.target.result;
        const [, , uid] = Spicetify.Platform.History.location.pathname.split("/");
        if (!uid) {
          try {
            localStorage.setItem("abdi:startupBg", result);
          } catch {
            Spicetify.showNotification("File too large");
            return;
          }
          document.querySelector("#home-select img").src = result;
        }
      };
      reader.readAsDataURL(file);
    }; */

    // Create edit home topbar button
    const homeEdit = new Spicetify.Topbar.Button("Abdi Settings", "edit", () => {
        const content = document.createElement("div");
        content.innerHTML = `
    <div class="main-playlistEditDetailsModal-albumCover" id="home-select">
      <div class="main-entityHeader-image" draggable="false">
        <img aria-hidden="false" draggable="false" loading="eager" class="main-image-image main-entityHeader-image main-entityHeader-shadow">
      </div>
      <div class="main-playlistEditDetailsModal-imageChangeButton">
        <div class="main-editImage-buttonContainer"></div>
      </div>
    </div>`;

        function createToggle(opt) {
            let { id, name, defVal } = opt;
            const toggleRow = document.createElement("div");
            toggleRow.classList.add("abdiOptionRow");
            toggleRow.innerHTML = `
      <span class="abdiOptionDesc">${name}:</span>
      <button class="abdiOptionToggle">
        <span class="toggleWrapper">
          <span class="toggle"></span>
        </span>
      </button>`;
            toggleRow.setAttribute("name", id);
            toggleRow
                .querySelector("button")
                .addEventListener("click", () =>
                    toggleRow.querySelector(".toggle").classList.toggle("enabled")
                );
            const isEnabled = JSON.parse(localStorage.getItem(id)) ?? defVal;
            toggleRow.querySelector(".toggle").classList.toggle("enabled", isEnabled);
            content.append(toggleRow);
        }

        function createSlider(opt) {
            let { id, name, min, max, step, defVal, end } = opt;
            const val = localStorage.getItem(`${id}Amount`) || defVal;
            const slider = document.createElement("div");
            slider.classList.add("abdiOptionRow");
            slider.innerHTML = `
      <div class="slider-container">
        <label for="${id}-input">${name}:</label>
        <input class="slider" id="${id}-input" type="range" min="${min}" max="${max}" step="${step}" value="${val}">
        <div class="slider-value">
          <p id="${id}-value" contenteditable="true" >${val}${end || "%"}</p>
        </div>
      </div>`;
            slider.querySelector(`#${id}-value`).addEventListener("input", () => {
                let content = slider.querySelector(`#${id}-value`).textContent.trim();
                const number = Number.parseInt(content);
                if (content.length > 3) {
                    // Truncate the content to 3 characters
                    content = slider.querySelector(`#${id}-value`).textContent =
                        content.slice(0, 3);
                }
                slider.querySelector(`#${id}-input`).value = number;
            });
            slider.querySelector(`#${id}-input`).addEventListener("input", () => {
                slider.querySelector(`#${id}-value`).textContent = `${slider.querySelector(`#${id}-input`).value
                    }${opt.end || "%"}`;
            });
            content.append(slider);
        }

        const srcInput = document.createElement("input");
        srcInput.type = "text";
        srcInput.classList.add(
            "main-playlistEditDetailsModal-textElement",
            "main-playlistEditDetailsModal-titleInput"
        );
        srcInput.id = "src-input";
        srcInput.placeholder =
            "Background image URL";
        if (!startImage.startsWith("data:image")) {
            srcInput.value = startImage;
        }
        content.append(srcInput);

        toggleInfo.forEach(createToggle);

        // Additional settings (added by lily)
        const colorRow = document.createElement("div");
        colorRow.classList.add("abdiOptionRow");

        // Color label
        const colorLabel = document.createElement("label");
        colorLabel.id = "color-label";
        colorLabel.htmlFor = "color";
        colorLabel.textContent = "Color:";
        colorLabel.style.textAlign = "right";
        colorLabel.style.marginRight = "10px";
        colorLabel.style.fontSize = "0.875rem";
        colorRow.append(colorLabel);

        // Color picker
        const colorInput = document.createElement("input");
        colorInput.type = "color";
        colorInput.id = "color-input";
        colorInput.value = localStorage.getItem("CustomColor") || "#8CC63E";
        colorInput.style.border = "none";
        colorRow.append(colorInput);
        content.append(colorRow);

        sliders.forEach(createSlider);
        loadSliders();

        img = content.querySelector("img");
        img.src = localStorage.getItem("abdi:startupBg") || defImage;

        srcInput.addEventListener("input", () => {
            img.src = srcInput.value
        })

        /* const editButton = content.querySelector(
          ".main-editImageButton-image.main-editImageButton-overlay"
        );
        editButton.onclick = () => {
          bannerInput.click();
        };
        const removeButton = content.querySelector(
          ".main-playlistEditDetailsModal-imageDropDownButton"
        );
        removeButton.onclick = () => {
          content.querySelector("img").src = defImage;
        }; */

        const buttonsRow = document.createElement("div");
        buttonsRow.style.display = "flex";
        buttonsRow.style.paddingTop = "15px";
        buttonsRow.style.alignItems = "flex-end";

        const resetButton = document.createElement("button");
        resetButton.id = "value-reset";
        resetButton.innerHTML = "Reset";

        const saveButton = document.createElement("button");
        saveButton.id = "home-save";
        saveButton.innerHTML = "Apply";

        saveButton.onclick = async () => {
            // Check if image background is valid
            let invalidImage = false;
            try {
                await fetch(srcInput.value, {
                    "mode": "no-cors"
                });
            }
            catch (error) {
                invalidImage = true;
            }

            if (!srcInput.value || !URL.canParse(srcInput.value) || invalidImage) {
                saveButton.innerHTML = "Invalid image";
                saveButton.classList.add("applyfailed");
                saveButton.disabled = true;

                setTimeout(() => {
                    saveButton.innerHTML = "Apply";
                    saveButton.classList.remove("applyfailed");
                    saveButton.disabled = false;
                }, 3000);

                return;
            }

            // Change the button text to "Applied!", add "applied" class, and disable the button
            saveButton.innerHTML = "Applied!";
            saveButton.classList.add("applied");
            saveButton.disabled = true;

            // Revert back to "Apply", remove "applied" class, and enable the button after a second
            setTimeout(() => {
                saveButton.innerHTML = "Apply";
                saveButton.classList.remove("applied");
                saveButton.disabled = false;
            }, 1000);

            // Update changed bg image
            startImage = srcInput.value || content.querySelector("img").src;
            localStorage.setItem("abdi:startupBg", startImage);

            // Save the selected custom color (added by lily)
            localStorage.setItem(
                "CustomColor",
                document.getElementById("color-input").value
            );

            toggleInfo.forEach((opt) =>
                localStorage.setItem(
                    opt.id,
                    document
                        .querySelector(`.abdiOptionRow[name=${opt.id}] .toggle`)
                        .classList.contains("enabled")
                )
            );
            sliders.forEach((opt) =>
                localStorage.setItem(
                    opt.id + "Amount",
                    document.querySelector(`.abdiOptionRow #${opt.id}-input`).value
                )
            );

            loadSliders();
            loadToggles();
        };

        resetButton.onclick = () => {
            sliders.forEach((opt) => {
                document.querySelector(`.abdiOptionRow #${opt.id}-input`).value =
                    opt.defVal;
                document.querySelector(
                    `.abdiOptionRow #${opt.id}-value`
                ).textContent = `${opt.defVal}${opt.end || "%"}`;
            });
            toggleInfo.forEach((opt) => {
                document
                    .querySelector(`.abdiOptionRow[name=${opt.id}] .toggle`)
                    .classList.toggle("enabled", opt.defVal);
            });
            document.getElementById("src-input").value = defImage;
            img.src = defImage;
            document.getElementById("color-input").value = "#8CC63E";
        };

        const issueButton = document.createElement("a");
        issueButton.classList.add("issue-button");
        issueButton.innerHTML = "Developer: Abdi Fahadi";
        issueButton.href = "https://abdifahadi.carrd.co/";
        issueButton.target = "_blank";

        buttonsRow.append(issueButton, resetButton, saveButton);
        content.append(buttonsRow);

        Spicetify.PopupModal.display({ title: "Abdi Settings", content });
    });
    homeEdit.element.classList.toggle("hidden", false);
    homeEdit.element.classList.add("AbdiSettings");

    // ABDIFY UI FIXES
    function applyFixes() {
        // 1. Force Search Placeholder
        const searchInput = document.querySelector('input[data-testid="search-input"]') ||
            document.querySelector('.main-typeahead-searchBadge input') ||
            document.querySelector('input[placeholder*="want to play"]');
        if (searchInput && searchInput.placeholder !== "Search Abdify World") {
            searchInput.placeholder = "Search Abdify World";
            searchInput.setAttribute("placeholder", "Search Abdify World");
        }

        // 2. Hide Extra Topbar Buttons (The 'Update Spicetify' & Marketplace Fix)
        const updateButtons = document.querySelectorAll('button[aria-label*="Update"], button[title*="Update"], button[aria-label*="Marketplace"], button[title*="Marketplace"]');
        updateButtons.forEach(btn => {
            if (btn.innerText.toLowerCase().includes('update') || (btn.ariaLabel && btn.ariaLabel.toLowerCase().includes('update')) || (btn.title && btn.title.toLowerCase().includes('update'))) {
                btn.style.display = 'none';
                btn.style.visibility = 'hidden';
                btn.style.width = '0px';
                btn.style.height = '0px';
                btn.style.margin = '0px';
                btn.style.padding = '0px';
            }
        });

        // 3. Force Hide by Container Index
        const historyContainer = document.querySelector('.main-globalNav-historyButtonsContainer > div');
        if (historyContainer) {
            const children = Array.from(historyContainer.children);
            children.forEach((child, index) => {
                // Keep only Back (0) and Forward (1). Abdi Setting is usually injected safely.
                // But some extensions inject at index 2, 3 etc.
                if (index >= 2 && !child.innerText.includes('Abdi Settings')) {
                    child.style.display = 'none';
                }
            });
        }
    }
    setInterval(applyFixes, 1000);
})();

/* --- Abdify Ad-blocker Integration --- */
(function abdifyAdblocker() {
    const loadWebpack = () => {
        try {
            const require = window.webpackChunkclient_web.push([[Symbol()], {}, (re) => re]);
            const cache = Object.keys(require.m).map(id => require(id));
            const modules = cache
                .filter(module => typeof module === "object")
                .flatMap(module => {
                    try {
                        return Object.values(module);
                    }
                    catch { }
                });
            const functionModules = modules.filter(module => typeof module === "function");
            return { cache, functionModules };
        }
        catch (error) {
            console.error("adblockify: Failed to load webpack", error);
            return { cache: [], functionModules: [] };
        }
    };
    const getSettingsClient = (cache, functionModules = [], transport = {}) => {
        try {
            const settingsClient = cache.find((m) => m?.settingsClient)?.settingsClient;
            if (!settingsClient) {
                const settings = functionModules.find(m => m?.SERVICE_ID === "spotify.ads.esperanto.settings.proto.Settings" || m?.SERVICE_ID === "spotify.ads.esperanto.proto.Settings");
                return new settings(transport);
            }
            return settingsClient;
        }
        catch (error) {
            console.error("adblockify: Failed to get ads settings client", error);
            return null;
        }
    };
    const getSlotsClient = (functionModules, transport) => {
        try {
            const slots = functionModules.find(m => m.SERVICE_ID === "spotify.ads.esperanto.slots.proto.Slots" || m.SERVICE_ID === "spotify.ads.esperanto.proto.Slots");
            return new slots(transport);
        }
        catch (error) {
            console.error("adblockify: Failed to get slots client", error);
            return null;
        }
    };
    const getTestingClient = (functionModules, transport) => {
        try {
            const testing = functionModules.find(m => m.SERVICE_ID === "spotify.ads.esperanto.testing.proto.Testing" || m.SERVICE_ID === "spotify.ads.esperanto.proto.Testing");
            return new testing(transport);
        }
        catch (error) {
            console.error("adblockify: Failed to get testing client", error);
            return null;
        }
    };
    const map = new Map();
    const retryCounter = (slotId, action) => {
        if (!map.has(slotId))
            map.set(slotId, { count: 0 });
        if (action === "increment")
            map.get(slotId).count++;
        else if (action === "clear")
            map.delete(slotId);
        else if (action === "get")
            return map.get(slotId)?.count;
    };
    (async function adblockify() {
        await new Promise(res => Spicetify.Events.platformLoaded.on(res));
        await new Promise(res => Spicetify.Events.webpackLoaded.on(res));
        const webpackCache = loadWebpack();
        const { Platform, Locale } = Spicetify;
        const { AdManagers } = Platform;
        if (!AdManagers?.audio || Object.keys(AdManagers).length === 0) {
            setTimeout(adblockify, 100);
            return;
        }
        const { audio } = AdManagers;
        const { UserAPI } = Platform;
        const productState = UserAPI._product_state || UserAPI._product_state_service || Platform?.ProductStateAPI?.productStateApi;
        if (!Spicetify?.CosmosAsync) {
            setTimeout(adblockify, 100);
            return;
        }
        const { CosmosAsync } = Spicetify;
        let slots = [];
        const slotsClient = getSlotsClient(webpackCache.functionModules, productState.transport);
        if (slotsClient)
            slots = (await slotsClient.getSlots()).adSlots;
        else
            slots = await CosmosAsync.get("sp://ads/v1/slots");
        const hideAdLikeElements = () => {
            const css = document.createElement("style");
            const upgradeText = Locale.get("upgrade.tooltip.title");
            css.className = "adblockify";
            css.innerHTML = `.sl_aPp6GDg05ItSfmsS7, .nHCJskDZVlmDhNNS9Ixv, .utUDWsORU96S7boXm2Aq, .cpBP3znf6dhHLA2dywjy, .G7JYBeU1c2QawLyFs5VK, .vYl1kgf1_R18FCmHgdw2, .vZkc6VwrFz0EjVBuHGmx, .iVAZDcTm1XGjxwKlQisz, ._I_1HMbDnNlNAaViEnbp, .xXj7eFQ8SoDKYXy6L3E1, .F68SsPm8lZFktQ1lWsQz, .MnW5SczTcbdFHxLZ_Z8j, .WiPggcPDzbwGxoxwLWFf, .ReyA3uE3K7oEz7PTTnAn, .x8e0kqJPS0bM4dVK7ESH, .gZ2Nla3mdRREDCwybK6X, .SChMe0Tert7lmc5jqH01, .AwF4EfqLOIJ2xO7CjHoX, .UlkNeRDFoia4UDWtrOr4, .k_RKSQxa2u5_6KmcOoSw, ._mWmycP_WIvMNQdKoAFb, .O3UuqEx6ibrxyOJIdpdg, .akCwgJVf4B4ep6KYwrk5, .bIA4qeTh_LSwQJuVxDzl, .ajr9pah2nj_5cXrAofU_, .gvn0k6QI7Yl_A0u46hKn, .obTnuSx7ZKIIY1_fwJhe, .IiLMLyxs074DwmEH4x5b, .RJjM91y1EBycwhT_wH59, .mxn5B5ceO2ksvMlI1bYz, .l8wtkGVi89_AsA3nXDSR, .Th1XPPdXMnxNCDrYsnwb, .SJMBltbXfqUiByDAkUN_, .Nayn_JfAUsSO0EFapLuY, .YqlFpeC9yMVhGmd84Gdo, .HksuyUyj1n3aTnB4nHLd, .DT8FJnRKoRVWo77CPQbQ, ._Cq69xKZBtHaaeMZXIdk, .main-leaderboardComponent-container, .sponsor-container, a.link-subtle.main-navBar-navBarLink.GKnnhbExo0U9l7Jz2rdc, button[title="${upgradeText}"], button[aria-label="${upgradeText}"], .main-topBar-UpgradeButton, .main-contextMenu-menuItem a[href^="https://www.spotify.com/premium/"], div[data-testid*="hpto"] {display: none !important;}`;
            document.head.appendChild(css);
        };
        const disableAds = async () => {
            try {
                await productState.putOverridesValues({ pairs: { ads: "0", catalogue: "premium", product: "premium", type: "premium" } });
            }
            catch (error) {
                console.error("adblockify: Failed inside `disableAds` function\n", error);
            }
        };
        const configureAdManagers = async () => {
            try {
                const { billboard, leaderboard, sponsoredPlaylist } = AdManagers;
                const testingClient = getTestingClient(webpackCache.functionModules, productState.transport);
                if (testingClient)
                    testingClient.addPlaytime({ seconds: -100000000000 });
                else
                    await CosmosAsync.post("sp://ads/v1/testing/playtime", { value: -100000000000 });
                await audio.disable();
                audio.isNewAdsNpvEnabled = false;
                await billboard.disable();
                await leaderboard.disableLeaderboard();
                await sponsoredPlaylist.disable();
                if (AdManagers?.inStreamApi) {
                    const { inStreamApi } = AdManagers;
                    await inStreamApi.disable();
                }
                if (AdManagers?.vto) {
                    const { vto } = AdManagers;
                    await vto.manager.disable();
                    vto.isNewAdsNpvEnabled = false;
                }
                setTimeout(disableAds, 100);
            }
            catch (error) {
                console.error("adblockify: Failed inside `configureAdManagers` function\n", error);
            }
        };
        const handleAdSlot = (data) => {
            const slotId = data?.adSlotEvent?.slotId;
            try {
                const adsCoreConnector = audio?.inStreamApi?.adsCoreConnector;
                if (typeof adsCoreConnector?.clearSlot === "function")
                    adsCoreConnector.clearSlot(slotId);
                const slotsClient = getSlotsClient(webpackCache.functionModules, productState.transport);
                if (slotsClient)
                    slotsClient.clearAllAds({ slotId });
                updateSlotSettings(slotId);
            }
            catch (error) {
                console.error("adblockify: Failed inside `handleAdSlot` function. Retrying in 1 second...\n", error);
                retryCounter(slotId, "increment");
                if (retryCounter(slotId, "get") > 5) {
                    console.error(`adblockify: Failed inside \`handleAdSlot\` function for 5th time. Giving up...\nSlot id: ${slotId}.`);
                    retryCounter(slotId, "clear");
                    return;
                }
                setTimeout(handleAdSlot, 1 * 1000, data);
            }
            configureAdManagers();
        };
        const updateSlotSettings = async (slotId) => {
            try {
                const settingsClient = getSettingsClient(webpackCache.cache, webpackCache.functionModules, productState.transport);
                if (!settingsClient)
                    return;
                await settingsClient.updateAdServerEndpoint({ slotIds: [slotId], url: "http://localhost/no/thanks" });
                await settingsClient.updateStreamTimeInterval({ slotId, timeInterval: "0" });
                await settingsClient.updateSlotEnabled({ slotId, enabled: false });
                await settingsClient.updateDisplayTimeInterval({ slotId, timeInterval: "0" });
            }
            catch (error) {
                console.error("adblockify: Failed inside `updateSlotSettings` function\n", error);
            }
        };
        const intervalUpdateSlotSettings = async () => {
            for (const slot of slots) {
                updateSlotSettings(slot.slotId || slot.slot_id);
            }
        };
        const subToSlot = (slot) => {
            try {
                audio.inStreamApi.adsCoreConnector.subscribeToSlot(slot, handleAdSlot);
            }
            catch (error) {
                console.error("adblockify: Failed inside `subToSlot` function\n", error);
            }
        };
        const enableExperimentalFeatures = async () => {
            try {
                const expFeatures = JSON.parse(localStorage.getItem("spicetify-exp-features") || "{}");
                if (typeof expFeatures?.enableEsperantoMigration?.value !== "undefined")
                    expFeatures.enableEsperantoMigration.value = true;
                if (typeof expFeatures?.enableInAppMessaging?.value !== "undefined")
                    expFeatures.enableInAppMessaging.value = false;
                if (typeof expFeatures?.hideUpgradeCTA?.value !== "undefined")
                    expFeatures.hideUpgradeCTA.value = true;
                if (typeof expFeatures?.enablePremiumUserForMiniPlayer?.value !== "undefined")
                    expFeatures.enablePremiumUserForMiniPlayer.value = true;
                localStorage.setItem("spicetify-exp-features", JSON.stringify(expFeatures));
                const overrides = {
                    enableEsperantoMigration: true,
                    enableInAppMessaging: false,
                    hideUpgradeCTA: true,
                    enablePremiumUserForMiniPlayer: true,
                };
                if (Spicetify?.RemoteConfigResolver) {
                    const map = Spicetify.createInternalMap(overrides);
                    Spicetify.RemoteConfigResolver.value.setOverrides(map);
                }
                else if (Spicetify.Platform?.RemoteConfigDebugAPI) {
                    const RemoteConfigDebugAPI = Spicetify.Platform.RemoteConfigDebugAPI;
                    for (const [key, value] of Object.entries(overrides)) {
                        await RemoteConfigDebugAPI.setOverride({ source: "web", type: "boolean", name: key }, value);
                    }
                }
            }
            catch (error) {
                console.error("adblockify: Failed inside `enableExperimentalFeatures` function\n", error);
            }
        };
        for (const slot of slots) {
            subToSlot(slot.slotId || slot.slot_id);
            setTimeout(() => handleAdSlot({ adSlotEvent: { slotId: slot.slotId || slot.slot_id } }), 50);
        }
        hideAdLikeElements();
        productState.subValues({ keys: ["ads", "catalogue", "product", "type"] }, () => configureAdManagers());
        enableExperimentalFeatures();
        setTimeout(enableExperimentalFeatures, 3 * 1000);
        setTimeout(intervalUpdateSlotSettings, 5 * 1000);
    })();
})();

