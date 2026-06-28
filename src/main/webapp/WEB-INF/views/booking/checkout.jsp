<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="cb" uri="/WEB-INF/cinebook.tld" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Checkout"/>
</jsp:include>
<section class="mx-auto max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
    <jsp:include page="/WEB-INF/views/shared/booking-progress.jsp"><jsp:param name="step" value="4"/></jsp:include>
    <div class="mb-8 flex flex-col justify-between gap-3 sm:flex-row sm:items-end">
        <div><p class="text-sm font-bold text-rose-400">One last look</p><h1 class="mt-1 text-3xl font-black sm:text-4xl">Review and pay</h1></div>
        <p class="rounded-lg border border-amber-400/15 bg-amber-400/5 px-4 py-2 text-sm text-amber-200">Hold expires in <strong data-hold-countdown><c:out value="${empty holdRemaining ? '07:00' : holdRemaining}"/></strong><c:if test="${not empty hold.expiresAt}"><span class="sr-only"> at <c:out value="${cb:dateTime(hold.expiresAt)}"/></span></c:if></p>
    </div>
    <div class="grid gap-8 lg:grid-cols-[1fr_380px]">
        <div class="space-y-5">
            <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5 sm:p-6">
                <div class="flex gap-5">
                    <c:if test="${not empty movie.posterUrl}"><img src="<c:out value='${movie.posterUrl}'/>" alt="" class="hidden h-32 w-24 rounded-xl object-cover sm:block"></c:if>
                    <div><p class="text-xs font-black uppercase tracking-[.2em] text-rose-400">Your screening</p><h2 class="mt-2 text-2xl font-black"><c:out value="${movie.title}"/></h2><p class="mt-3 text-sm text-zinc-400"><c:out value="${showtime.cinemaName}"/> · <c:out value="${showtime.auditoriumName}"/></p><p class="mt-1 text-sm text-zinc-400"><c:out value="${cb:dateTime(showtime.startsAt)}"/> · <c:out value="${showtime.format.label}"/></p></div>
                </div>
            </article>
            <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5 sm:p-6">
                <h2 class="font-black">Tickets</h2>
                <div class="mt-4 space-y-3">
                    <c:forEach var="seat" items="${hold.seats}"><div class="flex justify-between text-sm"><span class="text-zinc-400">Seat <strong class="text-white"><c:out value="${seat.label}"/></strong> · <c:out value="${seat.type}"/></span><span><c:out value="${cb:money(seat.price)}"/></span></div></c:forEach>
                </div>
            </article>
            <c:if test="${not empty draft.combos}">
                <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5 sm:p-6">
                    <h2 class="font-black">Food & drinks</h2>
                    <div class="mt-4 space-y-3"><c:forEach var="item" items="${draft.combos}"><div class="flex justify-between text-sm"><span class="text-zinc-400"><c:out value="${item.quantity}"/> × <c:out value="${item.name}"/></span><span><c:out value="${cb:money(item.total)}"/></span></div></c:forEach></div>
                </article>
            </c:if>
            <form action="<c:url value='/checkout'/>" method="post" class="rounded-2xl border border-white/10 bg-white/[.025] p-5 sm:p-6">
                <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                <label for="promotionCode" class="text-sm font-black">Promotion code</label>
                <div class="mt-3 flex gap-3"><input id="promotionCode" name="promotionCode" value="<c:out value='${promotionCode}'/>" placeholder="Enter code" class="min-w-0 flex-1 rounded-xl border border-white/10 bg-black/25 px-4 py-3 uppercase outline-none focus:border-rose-500"><button class="rounded-xl border border-white/15 px-5 py-3 text-sm font-black hover:bg-white/5">Apply</button></div>
                <c:if test="${not empty promotionMessage}"><p class="mt-2 text-xs ${promotionValid ? 'text-emerald-400' : 'text-rose-400'}"><c:out value="${promotionMessage}"/></p></c:if>
            </form>
        </div>
        <aside>
            <form action="<c:url value='/payments/simulate'/>" method="post" class="glass-panel sticky top-24 rounded-2xl p-6">
                <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                <input type="hidden" name="holdToken" value="<c:out value='${hold.token}'/>">
                <input type="hidden" name="promotionCode" value="<c:out value='${promotionCode}'/>">
                <h2 class="text-xl font-black">Order total</h2>
                <div class="mt-5 space-y-3 border-b border-white/10 pb-5 text-sm">
                    <div class="flex justify-between"><span class="text-zinc-500">Tickets</span><span><c:out value="${cb:money(pricing.ticketSubtotal)}"/></span></div>
                    <div class="flex justify-between"><span class="text-zinc-500">Food & drinks</span><span><c:out value="${cb:money(pricing.comboSubtotal)}"/></span></div>
                    <c:if test="${pricing.discountAmount > 0}"><div class="flex justify-between text-emerald-400"><span>Promotion</span><span>− <c:out value="${cb:money(pricing.discountAmount)}"/></span></div></c:if>
                    <div class="flex justify-between"><span class="text-zinc-500">Tax (8%)</span><span><c:out value="${cb:money(pricing.taxAmount)}"/></span></div>
                    <div class="flex justify-between"><span class="text-zinc-500">Service fee</span><span><c:out value="${cb:money(pricing.serviceFee)}"/></span></div>
                </div>
                <div class="flex items-end justify-between py-5"><span class="font-bold">Total</span><strong class="text-2xl text-amber-300"><c:out value="${cb:money(pricing.total)}"/></strong></div>
                <label for="paymentOutcome" class="mb-2 block text-xs font-bold uppercase tracking-wider text-zinc-500">Demo payment outcome</label>
                <select id="paymentOutcome" name="outcome" class="w-full rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
                    <option value="success">Approve payment</option><option value="failure">Simulate failure</option><option value="cancel">Cancel payment</option>
                </select>
                <button class="mt-4 w-full rounded-xl bg-rose-600 px-5 py-3.5 font-black shadow-lg shadow-rose-950/50 hover:bg-rose-500">Pay securely</button>
                <p class="mt-3 text-center text-[11px] leading-5 text-zinc-600">Demo only. No card details or real funds are processed.</p>
            </form>
        </aside>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
