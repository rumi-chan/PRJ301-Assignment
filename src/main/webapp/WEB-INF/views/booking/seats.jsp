<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="cb" uri="/WEB-INF/cinebook.tld" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Choose seats"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <jsp:include page="/WEB-INF/views/shared/booking-progress.jsp"><jsp:param name="step" value="2"/></jsp:include>
    <div class="grid gap-8 lg:grid-cols-[1fr_320px]">
        <form action="<c:url value='/booking/combos'/>" method="get" data-seat-form>
            <input type="hidden" name="showtimeId" value="<c:out value='${showtime.id}'/>">
            <input type="hidden" name="seatIds" data-selected-seat-ids value="<c:out value='${selectedSeatIdsCsv}'/>">
            <input type="hidden" name="holdToken" data-hold-token value="<c:out value='${not empty hold.token ? hold.token : holdToken}'/>">
            <div class="rounded-3xl border border-white/10 bg-black/20 p-4 sm:p-8">
                <div class="mb-8 text-center">
                    <p class="text-sm font-bold text-rose-400">Select your seats</p>
                    <h1 class="mt-1 text-2xl font-black sm:text-3xl"><c:out value="${movie.title}"/></h1>
                    <p class="mt-2 text-sm text-zinc-500"><c:out value="${showtime.cinemaName}"/> · <c:out value="${showtime.auditoriumName}"/> · <c:out value="${cb:dateTime(showtime.startsAt)}"/></p>
                </div>
                <div class="mx-auto max-w-2xl">
                    <div class="cinema-screen"></div>
                    <p class="mt-4 text-center text-[10px] font-bold uppercase tracking-[.4em] text-zinc-600">Screen</p>
                </div>
                <div data-seat-picker
                     data-context-path="${pageContext.request.contextPath}"
                     data-showtime-id="<c:out value='${showtime.id}'/>"
                     data-csrf-token="<c:out value='${csrfToken}'/>"
                     data-hold-token="<c:out value='${not empty hold.token ? hold.token : holdToken}'/>"
                     data-hold-expires-at="<c:out value='${not empty hold.expiresAt ? hold.expiresAt : holdExpiresAt}'/>"
                     data-selected-seat-ids="<c:out value='${selectedSeatIdsCsv}'/>"
                     class="mx-auto mt-12 flex max-w-3xl flex-wrap justify-center gap-2 sm:gap-3">
                    <c:forEach var="seat" items="${seats}">
                        <c:set var="isUnavailable" value="${seat.status == 'SOLD' || seat.status == 'HELD' || seat.availability == 'SOLD' || seat.availability == 'HELD'}"/>
                        <button type="button"
                                data-seat-id="<c:out value='${seat.id}'/>"
                                data-seat-type="<c:out value='${seat.type}'/>"
                                data-seat-price="<c:out value='${seat.price}'/>"
                                data-pair-id="<c:out value='${seat.pairId}'/>"
                                data-status="<c:out value='${not empty seat.status ? seat.status : seat.availability}'/>"
                                aria-label="Seat <c:out value='${seat.label}'/> — <c:out value='${seat.type}'/>"
                                aria-pressed="false"
                                ${isUnavailable ? 'disabled' : ''}
                                class="seat ${seat.type == 'VIP' ? 'seat-vip' : seat.type == 'COUPLE' ? 'seat-couple' : 'seat-standard'} ${isUnavailable ? 'seat-sold' : ''}">
                            <c:out value="${empty seat.label ? seat.seatNumber : seat.label}"/>
                        </button>
                    </c:forEach>
                    <c:if test="${empty seats}"><p class="w-full py-16 text-center text-zinc-500">The seat map is not available for this screening.</p></c:if>
                </div>
                <div class="mt-10 flex flex-wrap justify-center gap-x-6 gap-y-3 text-xs text-zinc-500">
                    <span class="flex items-center gap-2"><i class="h-3 w-3 rounded bg-zinc-600"></i> Standard</span>
                    <span class="flex items-center gap-2"><i class="h-3 w-3 rounded bg-amber-400"></i> VIP</span>
                    <span class="flex items-center gap-2"><i class="h-3 w-5 rounded bg-fuchsia-400"></i> Couple</span>
                    <span class="flex items-center gap-2"><i class="h-3 w-3 rounded bg-rose-600"></i> Selected</span>
                    <span class="flex items-center gap-2"><i class="h-3 w-3 rounded bg-zinc-800 ring-1 ring-zinc-700"></i> Sold / held</span>
                </div>
            </div>
        </form>
        <aside>
            <div class="glass-panel sticky top-24 rounded-2xl p-5">
                <div class="flex items-center justify-between border-b border-white/10 pb-4">
                    <span class="text-sm font-semibold text-zinc-400">Seat hold</span>
                    <span data-hold-countdown class="font-mono text-lg font-black text-amber-300">07:00</span>
                </div>
                <div class="space-y-3 py-5">
                    <div class="flex justify-between text-sm"><span class="text-zinc-500">Selected seats</span><strong data-seat-count>0</strong></div>
                    <div class="flex justify-between text-sm"><span class="text-zinc-500">Ticket subtotal</span><strong data-seat-total>₫0</strong></div>
                </div>
                <p data-hold-status class="mb-4 text-sm text-zinc-500">Choose one or more available seats.</p>
                <button type="button" onclick="document.querySelector('[data-seat-form]').requestSubmit()" data-seat-submit disabled class="w-full rounded-xl bg-rose-600 px-5 py-3 font-black text-white hover:bg-rose-500 disabled:cursor-not-allowed disabled:bg-zinc-800 disabled:text-zinc-600">Continue to combos</button>
                <p class="mt-3 text-center text-xs leading-5 text-zinc-600">Couple seats are selected as a pair. Seats are confirmed only after payment.</p>
            </div>
        </aside>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"><jsp:param name="bookingScripts" value="true"/></jsp:include>
