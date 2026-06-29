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

    document.querySelectorAll("[data-hero-carousel]").forEach((carousel) => {
        const slides = [...carousel.querySelectorAll("[data-hero-slide]")];
        const dots = [...carousel.querySelectorAll("[data-hero-dot]")];
        if (slides.length <= 1) return;

        let current = slides.findIndex((slide) => slide.classList.contains("is-active"));
        if (current < 0) current = 0;

        const setDotStyles = (index) => {
            dots.forEach((dot, dotIndex) => {
                const active = dotIndex === index;
                dot.classList.toggle("w-8", active);
                dot.classList.toggle("bg-rose-500", active);
                dot.classList.toggle("w-2", !active);
                dot.classList.toggle("bg-white/35", !active);
                dot.setAttribute("aria-selected", String(active));
            });
        };

        const show = (index) => {
            current = (index + slides.length) % slides.length;
            slides.forEach((slide, slideIndex) => {
                const active = slideIndex === current;
                slide.classList.toggle("is-active", active);
                slide.setAttribute("aria-hidden", String(!active));
            });
            setDotStyles(current);
        };

        carousel.querySelector("[data-hero-prev]")?.addEventListener("click", () => show(current - 1));
        carousel.querySelector("[data-hero-next]")?.addEventListener("click", () => show(current + 1));
        dots.forEach((dot, index) => dot.addEventListener("click", () => show(index)));

        let timer = window.setInterval(() => show(current + 1), 8000);
        carousel.addEventListener("mouseenter", () => window.clearInterval(timer));
        carousel.addEventListener("mouseleave", () => {
            timer = window.setInterval(() => show(current + 1), 8000);
        });
    });
})();
