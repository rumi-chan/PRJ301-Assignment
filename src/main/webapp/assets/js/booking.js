(() => {
    const root = document.querySelector("[data-seat-picker]");
    if (!root) return;

    const contextPath = root.dataset.contextPath || "";
    const showtimeId = root.dataset.showtimeId;
    const csrfToken = root.dataset.csrfToken || "";
    const apiUrl = `${contextPath}/api/seat-holds`;
    const form = root.closest("form") || document.querySelector("[data-seat-form]");
    const seats = [...root.querySelectorAll("[data-seat-id]")];
    const selected = new Set(
        (root.dataset.selectedSeatIds || "").split(",").map(String).filter(Boolean)
    );
    let holdToken = root.dataset.holdToken || "";
    let expiresAt = root.dataset.holdExpiresAt ? new Date(root.dataset.holdExpiresAt) : null;
    let requestVersion = 0;

    const money = new Intl.NumberFormat("vi-VN", {
        style: "currency",
        currency: "VND",
        maximumFractionDigits: 0
    });

    const tokenInputs = document.querySelectorAll("[data-hold-token]");
    const seatInputs = document.querySelectorAll("[data-selected-seat-ids]");
    const countNodes = document.querySelectorAll("[data-seat-count]");
    const totalNodes = document.querySelectorAll("[data-seat-total]");
    const countdownNodes = document.querySelectorAll("[data-hold-countdown]");
    const statusNode = document.querySelector("[data-hold-status]");
    const submitButton = form?.querySelector("[data-seat-submit]")
        || document.querySelector("[data-seat-submit]");

    const matchingPair = (seat) => {
        const pairId = seat.dataset.pairId;
        if (!pairId) return [seat];
        const partner = seats.find((candidate) => candidate.dataset.seatId === pairId);
        return partner ? [seat, partner] : [seat];
    };

    const sync = () => {
        seats.forEach((seat) => {
            const active = selected.has(seat.dataset.seatId);
            seat.classList.toggle("seat-selected", active);
            seat.setAttribute("aria-pressed", String(active));
        });
        const ids = [...selected];
        const countedPairs = new Set();
        const total = seats
            .filter((seat) => selected.has(seat.dataset.seatId))
            .reduce((sum, seat) => {
                if (seat.dataset.seatType === "COUPLE" && seat.dataset.pairId) {
                    const pairKey = [seat.dataset.seatId, seat.dataset.pairId].sort().join(":");
                    if (countedPairs.has(pairKey)) return sum;
                    countedPairs.add(pairKey);
                }
                return sum + Number(seat.dataset.seatPrice || 0);
            }, 0);
        seatInputs.forEach((input) => { input.value = ids.join(","); });
        countNodes.forEach((node) => { node.textContent = String(ids.length); });
        totalNodes.forEach((node) => { node.textContent = money.format(total); });
        tokenInputs.forEach((input) => { input.value = holdToken; });
        if (submitButton) submitButton.disabled = ids.length === 0 || !holdToken;
    };

    const setStatus = (message, tone = "muted") => {
        if (!statusNode) return;
        statusNode.textContent = message;
        statusNode.className = tone === "error"
            ? "mt-3 text-sm text-rose-300"
            : tone === "success"
                ? "mt-3 text-sm text-emerald-300"
                : "mt-3 text-sm text-zinc-400";
    };

    const reserve = async () => {
        const version = ++requestVersion;
        setStatus("Reserving your selection…");
        if (submitButton) submitButton.disabled = true;
        try {
            const response = await fetch(apiUrl, {
                method: "POST",
                credentials: "same-origin",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    ...(csrfToken ? { "X-CSRF-Token": csrfToken } : {})
                },
                body: JSON.stringify({
                    showtimeId: Number(showtimeId),
                    seatIds: [...selected].map((id) => Number(id)),
                    holdToken: holdToken || null
                })
            });
            const data = await response.json().catch(() => ({}));
            if (version !== requestVersion) return;
            if (!response.ok) {
                const message = data.error || data.message || (response.status === 409
                    ? "One of those seats was just taken. Please choose again."
                    : "We could not hold those seats. Please retry.");
                if (Array.isArray(data.unavailableSeatIds)) {
                    data.unavailableSeatIds.map(String).forEach((id) => selected.delete(id));
                }
                throw new Error(message);
            }
            holdToken = data.holdToken || data.token || holdToken;
            expiresAt = data.expiresAt ? new Date(data.expiresAt) : expiresAt;
            if (Array.isArray(data.seatIds)) {
                selected.clear();
                data.seatIds.map(String).forEach((id) => selected.add(id));
            }
            if (selected.size === 0) {
                holdToken = "";
                expiresAt = null;
            }
            setStatus(selected.size ? "Seats held. Complete your booking before the timer ends." : "Selection cleared.", "success");
        } catch (error) {
            setStatus(error.message, "error");
        } finally {
            sync();
        }
    };

    seats.forEach((seat) => {
        if (seat.disabled || seat.dataset.status === "SOLD" || seat.dataset.status === "HELD") return;
        seat.addEventListener("click", () => {
            const group = matchingPair(seat);
            const shouldSelect = group.some((item) => !selected.has(item.dataset.seatId));
            group.forEach((item) => {
                if (!item.disabled) {
                    if (shouldSelect) selected.add(item.dataset.seatId);
                    else selected.delete(item.dataset.seatId);
                }
            });
            sync();
            reserve();
        });
    });

    const tick = () => {
        if (!expiresAt || Number.isNaN(expiresAt.getTime())) {
            countdownNodes.forEach((node) => { node.textContent = "07:00"; });
            return;
        }
        const remaining = Math.max(0, Math.floor((expiresAt.getTime() - Date.now()) / 1000));
        const minutes = String(Math.floor(remaining / 60)).padStart(2, "0");
        const seconds = String(remaining % 60).padStart(2, "0");
        countdownNodes.forEach((node) => {
            node.textContent = `${minutes}:${seconds}`;
            node.classList.toggle("text-rose-300", remaining <= 60);
        });
        if (remaining === 0) {
            selected.clear();
            holdToken = "";
            sync();
            setStatus("Your seat hold expired. Select seats again to continue.", "error");
        }
    };

    sync();
    tick();
    window.setInterval(tick, 1000);
})();
