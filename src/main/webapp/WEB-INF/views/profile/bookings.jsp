<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="cb" uri="/WEB-INF/cinebook.tld" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="My bookings"/>
    <jsp:param name="active" value="bookings"/>
</jsp:include>
<section class="mx-auto max-w-6xl px-4 py-12 sm:px-6 lg:px-8">
    <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
        <div><p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Your movie nights</p><h1 class="mt-2 text-4xl font-black tracking-tight">Booking history</h1><p class="mt-3 text-zinc-500">Tickets, statuses, and all the details in one place.</p></div>
        <a href="<c:url value='/movies'/>" class="rounded-xl bg-rose-600 px-5 py-3 text-center text-sm font-black hover:bg-rose-500">Book another movie</a>
    </div>
    <div class="mt-10 flex flex-wrap gap-2">
        <c:forEach var="filterStatus" items="${['ALL','PAID','CANCELLED','USED']}">
            <c:url var="statusUrl" value="/profile/bookings"><c:if test="${filterStatus != 'ALL'}"><c:param name="status" value="${filterStatus}"/></c:if></c:url>
            <a href="${statusUrl}" class="rounded-full px-4 py-2 text-xs font-black ${(empty param.status && filterStatus == 'ALL') || param.status == filterStatus ? 'bg-white text-zinc-950' : 'border border-white/10 text-zinc-400 hover:bg-white/5'}"><c:out value="${filterStatus}"/></a>
        </c:forEach>
    </div>
    <c:choose>
        <c:when test="${not empty bookings}">
            <div class="mt-8 space-y-5">
                <c:forEach var="booking" items="${bookings}">
                    <article class="overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                        <div class="grid gap-5 p-5 sm:grid-cols-[88px_1fr_auto] sm:p-6">
                            <c:choose><c:when test="${not empty booking.moviePosterUrl}"><img src="<c:out value='${booking.moviePosterUrl}'/>" alt="" class="hidden h-32 w-20 rounded-lg object-cover sm:block"></c:when><c:otherwise><div class="hidden h-28 w-20 place-items-center rounded-lg bg-zinc-800 text-2xl sm:grid">🎬</div></c:otherwise></c:choose>
                            <div>
                                <div class="flex flex-wrap items-center gap-3">
                                    <h2 class="text-xl font-black"><c:out value="${booking.movieTitle}"/></h2>
                                    <span class="rounded-full px-2.5 py-1 text-[10px] font-black ${booking.status == 'PAID' ? 'bg-emerald-500/15 text-emerald-300' : booking.status == 'USED' ? 'bg-sky-500/15 text-sky-300' : 'bg-zinc-500/15 text-zinc-400'}"><c:out value="${booking.status}"/></span>
                                </div>
                                <p class="mt-3 text-sm text-zinc-400"><c:out value="${booking.cinemaName}"/> · <c:out value="${booking.auditoriumName}"/></p>
                                <p class="mt-1 text-sm text-zinc-500"><c:out value="${cb:dateTime(booking.showtimeAt)}"/> · Seats <c:out value="${booking.seatLabels}"/></p>
                                <p class="mt-4 font-mono text-xs font-bold tracking-wider text-amber-300"><c:out value="${booking.bookingCode}"/></p>
                            </div>
                            <div class="flex flex-row items-end justify-between gap-4 border-t border-white/10 pt-4 text-right sm:flex-col sm:border-l sm:border-t-0 sm:pl-6 sm:pt-0">
                                <div><p class="text-xs text-zinc-600">Total paid</p><p class="mt-1 font-black"><c:out value="${cb:money(booking.totalAmount)}"/></p></div>
                                <c:if test="${booking.status == 'PAID' || booking.status == 'USED'}"><a href="<c:url value='/tickets/${booking.bookingCode}'/>" class="rounded-lg border border-white/10 px-4 py-2 text-xs font-black hover:bg-white/5">View ticket</a></c:if>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="glass-panel mt-10 rounded-3xl px-6 py-20 text-center"><div class="text-5xl">🎟️</div><h2 class="mt-5 text-xl font-black">No bookings here yet</h2><p class="mt-2 text-zinc-500">Your future movie nights will appear here.</p><a href="<c:url value='/movies'/>" class="mt-6 inline-flex rounded-xl bg-rose-600 px-5 py-3 text-sm font-black">Explore movies</a></div>
        </c:otherwise>
    </c:choose>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
