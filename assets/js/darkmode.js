"use strict";

(function () {
    "use strict";

    // Patch version
    const darkModePatchVersion = '0.1.2';

    // Define theme colors
    const darkModeColors = {
        background: '#111',
        headers: '#0beb7b',
        text: '#a8b2b7',
        links: '#00b7ff',
        preDiv: '#111',
        preBackground: '#18181a',
        preBorders: '#474a4c',
        preText: '#9eb2bb',
        preTextSpanBlue: '#a2a2f3'
    }

    // Show version on load
    console.log(`Dark mode patch loaded.\n\nVersion: ${darkModePatchVersion}`);

    // Create the media query.
    const darkModeQuery = window.matchMedia("(prefers-color-scheme: dark)");

    // Icons from Feather library
    const lightModeIcon = 'PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmRjNDQiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0iZmVhdGhlciBmZWF0aGVyLXN1biI+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iNSI+PC9jaXJjbGU+PGxpbmUgeDE9IjEyIiB5MT0iMSIgeDI9IjEyIiB5Mj0iMyI+PC9saW5lPjxsaW5lIHgxPSIxMiIgeTE9IjIxIiB4Mj0iMTIiIHkyPSIyMyI+PC9saW5lPjxsaW5lIHgxPSI0LjIyIiB5MT0iNC4yMiIgeDI9IjUuNjQiIHkyPSI1LjY0Ij48L2xpbmU+PGxpbmUgeDE9IjE4LjM2IiB5MT0iMTguMzYiIHgyPSIxOS43OCIgeTI9IjE5Ljc4Ij48L2xpbmU+PGxpbmUgeDE9IjEiIHkxPSIxMiIgeDI9IjMiIHkyPSIxMiI+PC9saW5lPjxsaW5lIHgxPSIyMSIgeTE9IjEyIiB4Mj0iMjMiIHkyPSIxMiI+PC9saW5lPjxsaW5lIHgxPSI0LjIyIiB5MT0iMTkuNzgiIHgyPSI1LjY0IiB5Mj0iMTguMzYiPjwvbGluZT48bGluZSB4MT0iMTguMzYiIHkxPSI1LjY0IiB4Mj0iMTkuNzgiIHkyPSI0LjIyIj48L2xpbmU+PC9zdmc+';
    const darkModeIcon = 'PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0iZmVhdGhlciBmZWF0aGVyLW1vb24iPjxwYXRoIGQ9Ik0yMSAxMi43OUE5IDkgMCAxIDEgMTEuMjEgMyA3IDcgMCAwIDAgMjEgMTIuNzl6Ij48L3BhdGg+PC9zdmc+';

    // Create theme selector
    const darkModeSelector = document.createElement('div');
    darkModeSelector.id = 'theme-selector';
    darkModeSelector.style.float = 'right';

    // Target 'header' DOM element
    const header = document.getElementsByTagName('header')[0];
    const headerH1 = document.getElementsByClassName('project-name')[0];

    // Inject theme selector before header 'h1' DOM element
    header.insertBefore(darkModeSelector, headerH1);

    // Apply dark theme
    function applyTheme() {
        const body = document.querySelector('body');
        const headerTags = document.querySelectorAll('h2, h3');
        const links = document.querySelectorAll('a');
        const highlightedDiv = document.querySelectorAll('div.highlight');
        const highlightedPre = document.querySelectorAll('pre.highlight');
        const highlightedCode = document.querySelectorAll('pre.highlight code');
        const highlightedCodeFix = document.querySelectorAll('pre.highlight code span.nt');

        body.style.backgroundColor = darkModeColors.background;
        body.style.color = darkModeColors.text;
        headerTags.forEach(element => {
            if (element.parentElement.nodeName !== 'HEADER') {
                element.style.color = darkModeColors.headers;
            }
        });
        links.forEach(element => {
            element.style.color = darkModeColors.links;
        });
        highlightedDiv.forEach(element => {
            element.style.backgroundColor = darkModeColors.preDiv;
        });
        highlightedPre.forEach(element => {
            element.style.backgroundColor = darkModeColors.preBackground;
            element.style.borderColor = darkModeColors.preBorders;
        });
        highlightedCode.forEach(element => {
            element.style.color = darkModeColors.preText;
        });
        highlightedCodeFix.forEach(element => {
            element.style.color = darkModeColors.preTextSpanBlue;
        });
    }

    // Remove dark theme
    function removeTheme() {
        const body = document.querySelector('body');
        const headerTags = document.querySelectorAll('h2, h3');
        const links = document.querySelectorAll('a');
        const highlightedDiv = document.querySelectorAll('div.highlight');
        const highlightedPre = document.querySelectorAll('pre.highlight');
        const highlightedCode = document.querySelectorAll('pre.highlight code');
        const highlightedCodeFix = document.querySelectorAll('pre.highlight code span.nt');

        body.style.backgroundColor = '';
        body.style.color = '';
        headerTags.forEach(element => {
            if (element.parentElement.nodeName !== 'HEADER') {
                element.style.color = '';
            }
        });
        links.forEach(element => {
            element.style.color = '';
        });
        highlightedDiv.forEach(element => {
            element.style.backgroundColor = '';
        });
        highlightedPre.forEach(element => {
            element.style.backgroundColor = '';
            element.style.borderColor = '';
        });
        highlightedCode.forEach(element => {
            element.style.color = '';
        });
        highlightedCodeFix.forEach(element => {
            element.style.color = '';
        });
    }

    // Store selected theme
    function storeThemeChange(query) {
        sessionStorage.setItem('dark-mode', query);
    }

    // Theme change handler
    function handleThemeChange(query) {
        // Reset 'darkModeSelector' content
        darkModeSelector.innerHTML = '';

        // Create child element selector
        const imgSelector = document.createElement('img');
        imgSelector.id = 'icon-selector';
        imgSelector.style.cursor = 'pointer';
        imgSelector.style.width = '18px';
        imgSelector.style.height = '18px';
        imgSelector.style.marginTop = '3px';

        // Assign 'imgSelector' click handler
        imgSelector.onclick = () => {
            // Apply the 'toggle' effect by always inversing the mached value
            handleThemeChange({ matches: !query.matches });
        }

        // Load dark theme
        if (query.matches && query.matches === true) {
            console.log('Applying dark theme.');
            imgSelector.src = `data:image/svg+xml;base64,${lightModeIcon}`;
            imgSelector.title = 'Toggle light mode';
            darkModeSelector.appendChild(imgSelector);
            applyTheme();
        }
        // Load light theme (means unload dark theme css file)
        else {
            console.log('Removing dark theme.');
            imgSelector.src = `data:image/svg+xml;base64,${darkModeIcon}`;
            imgSelector.title = 'Toggle dark mode';
            darkModeSelector.appendChild(imgSelector);
            removeTheme();
        }

        // Store theme change
        storeThemeChange(JSON.stringify({ matches: query.matches }));
    }

    // Initial theme load
    handleThemeChange(JSON.parse(sessionStorage.getItem('dark-mode')) || darkModeQuery);

    // Monitor query changes
    darkModeQuery.addEventListener('change', handleThemeChange);

    // Remove listener on unload
    window.onunload = () => {
        darkModeQuery.removeEventListener('change');
    }
})();
