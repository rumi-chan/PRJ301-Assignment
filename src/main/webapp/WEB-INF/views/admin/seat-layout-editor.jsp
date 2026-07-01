<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Seat Layouts"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>

<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="showrooms"/>
        </jsp:include>

        <div class="min-w-0">
            <div class="flex flex-col mb-6">
                <a href="${pageContext.request.contextPath}/admin/seat-layouts" class="text-sm font-bold text-sky-400 hover:text-sky-300 mb-2">← Back to Seat Layouts</a>
                <div class="flex justify-between items-center">
                    <h1 class="text-3xl font-black">Seat Layout <c:if test="${not empty auditorium}">- <c:out value="${auditorium.name}"/></c:if></h1>
                    <div class="flex gap-2">
                    <form action="${pageContext.request.contextPath}/admin/showrooms" method="POST" style="margin:0;">
                        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                        <input type="hidden" name="action" value="generateSeats">
                        <input type="hidden" name="auditoriumId" value="${param.auditoriumId}">
                        <button type="submit" class="rounded-xl border border-white/10 px-4 py-2 text-sm font-bold hover:bg-white/5" onclick="return confirm('Mọi cấu hình hiện tại sẽ bị xóa. Bạn có chắc muốn tạo lại layout mặc định?');">
                            Reset to Default
                        </button>
                    </form>
                    <button id="saveLayoutBtn" class="rounded-xl bg-rose-600 px-6 py-2 text-sm font-black hover:bg-rose-500 transition-colors">
                        Save Layout
                    </button>
                </div>
            </div>

            <div class="rounded-2xl border border-white/10 bg-white/[.025] p-6 text-center mt-6">
                <p class="mb-4 text-zinc-400">💡 <strong>Tip:</strong> Click on any seat to cycle through its type: <span class="text-zinc-200">Standard &rarr; VIP &rarr; Couple &rarr; Empty (Hidden)</span>.</p>
                <div class="mb-8 p-4 bg-zinc-800 rounded mx-auto max-w-3xl text-sm font-bold tracking-widest text-zinc-400">SCREEN</div>

                <div class="grid justify-center gap-2 mx-auto max-w-3xl" style="grid-template-columns: repeat(10, minmax(0, 45px));">
                    <c:choose>
                        <c:when test="${not empty seats}">
                            <c:forEach var="seat" items="${seats}">
                                <c:set var="seatClass" value="${seat.status == 'UNAVAILABLE' ? 'empty' : fn:toLowerCase(seat.type)}" />
                                <div data-seat-id="${seat.id}" data-row-label="<c:out value='${seat.rowLabel}'/>" data-seat-number="<c:out value='${seat.seatNumber}'/>" data-type="${seatClass}"
                                     class="seat-element seat-${seatClass} flex h-11 w-11 items-center justify-center rounded border border-white/10 font-bold text-xs cursor-pointer hover:scale-110 transition-all select-none">
                                    <c:out value="${seat.label}"/>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-span-10 text-center py-10 text-zinc-500">
                                Chưa có dữ liệu ghế cho phòng chiếu này. Hãy click "Reset to Default".
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="mt-8 flex justify-center gap-6">
                    <div class="flex items-center gap-2 text-sm"><div class="w-4 h-4 rounded bg-[#3f3f46]"></div> Standard</div>
                    <div class="flex items-center gap-2 text-sm"><div class="w-4 h-4 rounded bg-[#f59e0b]"></div> VIP</div>
                    <div class="flex items-center gap-2 text-sm"><div class="w-4 h-4 rounded bg-[#e11d48]"></div> Couple</div>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
    .seat-standard { background-color: #3f3f46; color: #d4d4d8; }
    .seat-vip      { background-color: #f59e0b; color: #000; }
    .seat-couple   { background-color: #e11d48; color: #fff; }
    .seat-empty    { background-color: transparent; border: 1px dashed #3f3f46; color: transparent; }
    .seat-empty:hover { color: #52525b; }
</style>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const seatTypes = ['standard', 'vip', 'couple', 'empty'];
    const seatElements = document.querySelectorAll('.seat-element');
    let hasChanges = false;
    let updates = {};

    seatElements.forEach(seat => {
        seat.addEventListener('click', function() {
            const currentType = this.getAttribute('data-type');
            let nextTypeIndex = (seatTypes.indexOf(currentType) + 1) % seatTypes.length;
            const nextType = seatTypes[nextTypeIndex];

            this.classList.remove('seat-' + currentType);
            this.classList.add('seat-' + nextType);
            this.setAttribute('data-type', nextType);

            updates[this.getAttribute('data-seat-id')] = nextType;
            hasChanges = true;
        });
    });

    document.getElementById('saveLayoutBtn').addEventListener('click', function() {
        if (!hasChanges) {
            alert('No changes to save.');
            return;
        }
        if (!coupleChangesAreValid()) {
            alert('Couple seats must be saved as adjacent pairs.');
            return;
        }

        const originalText = this.innerText;
        this.innerText = 'Saving...';
        this.disabled = true;

        fetch('${pageContext.request.contextPath}/admin/showrooms?action=saveSeatLayout', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': '<c:out value="${csrfToken}"/>'
            },
            body: JSON.stringify(updates)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Seat layout saved successfully!');
                hasChanges = false;
                updates = {};
            } else {
                alert('Error saving layout: ' + data.error);
            }
        })
        .catch(err => {
            alert('Network error while saving.');
            console.error(err);
        })
        .finally(() => {
            this.innerText = originalText;
            this.disabled = false;
        });
    });

    function coupleChangesAreValid() {
        const changedCouples = Array.from(seatElements)
            .filter(seat => updates[seat.getAttribute('data-seat-id')] === 'couple')
            .sort((left, right) => {
                const rowCompare = left.getAttribute('data-row-label').localeCompare(right.getAttribute('data-row-label'));
                if (rowCompare !== 0) {
                    return rowCompare;
                }
                return Number(left.getAttribute('data-seat-number')) - Number(right.getAttribute('data-seat-number'));
            });
        if (changedCouples.length % 2 !== 0) {
            return false;
        }
        for (let index = 0; index < changedCouples.length; index += 2) {
            const first = changedCouples[index];
            const second = changedCouples[index + 1];
            const sameRow = first.getAttribute('data-row-label') === second.getAttribute('data-row-label');
            const adjacent = Number(second.getAttribute('data-seat-number')) === Number(first.getAttribute('data-seat-number')) + 1;
            if (!sameRow || !adjacent) {
                return false;
            }
        }
        return true;
    }
});
</script>

<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
