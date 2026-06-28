(() => {
    const menuButton = document.querySelector("[data-mobile-menu-button]");
    const menu = document.querySelector("[data-mobile-menu]");
    if (menuButton && menu) {
        menuButton.addEventListener("click", () => {
            const isOpen = menuButton.getAttribute("aria-expanded") === "true";
            menuButton.setAttribute("aria-expanded", String(!isOpen));
            menu.classList.toggle("hidden", isOpen);
        });
    }

    document.querySelectorAll("[data-dismiss]").forEach((button) => {
        button.addEventListener("click", () => button.closest("[role='alert']")?.remove());
    });

    window.setTimeout(() => {
        document.querySelectorAll("[data-auto-dismiss]").forEach((alert) => {
            alert.classList.add("opacity-0", "-translate-y-2");
            window.setTimeout(() => alert.remove(), 300);
        });
    }, 5000);

    document.querySelectorAll("[data-confirm]").forEach((element) => {
        element.addEventListener("click", (event) => {
            if (!window.confirm(element.dataset.confirm)) event.preventDefault();
        });
    });

    document.querySelectorAll("[data-poster]").forEach((image) => {
        image.addEventListener("error", () => {
            image.classList.add("hidden");
            image.nextElementSibling?.classList.remove("hidden");
        }, { once: true });
    });
})();
