<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="cb" uri="/WEB-INF/cinebook.tld" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Add snacks"/>
</jsp:include>
<section class="mx-auto max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
    <jsp:include page="/WEB-INF/views/shared/booking-progress.jsp"><jsp:param name="step" value="3"/></jsp:include>
    <div class="text-center">
        <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Movie night essentials</p>
        <h1 class="mt-2 text-3xl font-black sm:text-4xl">Add snacks to your order</h1>
        <p class="mt-3 text-zinc-500">Optional, but popcorn has a convincing argument.</p>
    </div>
    <form action="<c:url value='/booking/combos'/>" method="post" class="mt-10">
        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
        <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <c:forEach var="combo" items="${combos}">
                <article class="overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                    <div class="grid aspect-[16/9] place-items-center bg-gradient-to-br from-amber-950/50 via-zinc-900 to-rose-950/50">
                        <c:choose><c:when test="${not empty combo.imageUrl}"><img src="<c:out value='${combo.imageUrl}'/>" alt="" class="h-full w-full object-cover"></c:when><c:otherwise><span class="text-5xl">🍿</span></c:otherwise></c:choose>
                    </div>
                    <div class="p-5">
                        <input type="hidden" name="comboId" value="<c:out value='${combo.id}'/>">
                        <h2 class="text-lg font-black"><c:out value="${combo.name}"/></h2>
                        <p class="mt-2 min-h-10 text-sm leading-5 text-zinc-500"><c:out value="${combo.description}"/></p>
                        <div class="mt-5 flex items-center justify-between gap-4">
                            <strong class="text-amber-300"><c:out value="${cb:money(combo.price)}"/></strong>
                            <label class="flex items-center gap-2">
                                <span class="text-xs text-zinc-500">Qty</span>
                                <select name="quantity" class="rounded-lg border border-white/10 bg-zinc-900 px-3 py-2 text-sm outline-none focus:border-rose-500">
                                    <c:forEach begin="0" end="5" var="quantity"><option value="${quantity}">${quantity}</option></c:forEach>
                                </select>
                            </label>
                        </div>
                    </div>
                </article>
            </c:forEach>
            <c:if test="${empty combos}"><div class="glass-panel col-span-full rounded-3xl px-6 py-16 text-center"><div class="text-4xl">🥤</div><h2 class="mt-4 text-xl font-black">No combos available</h2><p class="mt-2 text-zinc-500">You can continue directly to checkout.</p></div></c:if>
        </div>
        <div class="mt-8 flex flex-col-reverse justify-between gap-3 sm:flex-row">
            <c:url var="backToSeats" value="/booking/seats"><c:param name="showtimeId" value="${showtime.id}"/></c:url>
            <a href="${backToSeats}" class="rounded-xl border border-white/10 px-6 py-3 text-center font-bold text-zinc-300 hover:bg-white/5">← Change seats</a>
            <button class="rounded-xl bg-rose-600 px-7 py-3 font-black text-white shadow-lg shadow-rose-950/40 hover:bg-rose-500">Review order →</button>
        </div>
    </form>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
