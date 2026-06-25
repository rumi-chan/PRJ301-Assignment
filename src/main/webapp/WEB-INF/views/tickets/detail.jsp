<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="cb" uri="/WEB-INF/cinebook.tld" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Electronic ticket"/>
</jsp:include>
<style>
    @media print {
        header, footer, [data-print-hide] { display: none !important; }
        body { background: white !important; color: black !important; }
        .ticket-print { border: 1px solid #ddd !important; background: white !important; box-shadow: none !important; }
    }
</style>
<section class="mx-auto max-w-3xl px-4 py-12 sm:px-6 lg:px-8">
    <div data-print-hide class="mb-6 flex items-center justify-between">
        <a href="<c:url value='/profile/bookings'/>" class="text-sm font-bold text-zinc-400 hover:text-white">← Booking history</a>
        <button type="button" onclick="window.print()" class="rounded-lg border border-white/10 px-4 py-2 text-sm font-bold hover:bg-white/5">Print ticket</button>
    </div>
    <article class="ticket-print glass-panel overflow-hidden rounded-3xl">
        <div class="relative bg-gradient-to-br from-rose-700 via-rose-600 to-amber-500 p-7 sm:p-10">
            <div class="absolute -right-12 -top-12 h-44 w-44 rounded-full border-[28px] border-white/10"></div>
            <p class="relative text-xs font-black uppercase tracking-[.3em] text-white/70">CineBook electronic ticket</p>
            <h1 class="relative mt-4 max-w-xl text-3xl font-black leading-tight sm:text-5xl"><c:out value="${booking.movieTitle}"/></h1>
            <div class="relative mt-7 flex flex-wrap gap-2"><span class="rounded-full bg-black/20 px-3 py-1 text-xs font-bold"><c:out value="${booking.paymentStatus}"/></span><span class="rounded-full bg-black/20 px-3 py-1 text-xs font-bold"><c:out value="${booking.status}"/></span></div>
        </div>
        <div class="relative grid gap-8 p-7 sm:grid-cols-[1fr_180px] sm:p-10">
            <span class="absolute -left-4 -top-4 h-8 w-8 rounded-full bg-zinc-950"></span><span class="absolute -right-4 -top-4 h-8 w-8 rounded-full bg-zinc-950"></span>
            <div>
                <dl class="grid grid-cols-2 gap-x-6 gap-y-7">
                    <div><dt class="text-xs font-bold uppercase tracking-wider text-zinc-500">Date & time</dt><dd class="mt-1 font-black"><c:out value="${cb:dateTime(booking.showtimeAt)}"/></dd></div>
                    <div><dt class="text-xs font-bold uppercase tracking-wider text-zinc-500">Seats</dt><dd class="mt-1 font-black"><c:out value="${booking.seatLabels}"/></dd></div>
                    <div class="col-span-2"><dt class="text-xs font-bold uppercase tracking-wider text-zinc-500">Cinema</dt><dd class="mt-1 font-black"><c:out value="${booking.cinemaName}"/></dd><p class="mt-1 text-sm text-zinc-500"><c:out value="${booking.auditoriumName}"/></p></div>
                    <div><dt class="text-xs font-bold uppercase tracking-wider text-zinc-500">Guest</dt><dd class="mt-1 font-black"><c:out value="${sessionScope.currentUser.fullName}"/></dd></div>
                    <div><dt class="text-xs font-bold uppercase tracking-wider text-zinc-500">Total</dt><dd class="mt-1 font-black"><c:out value="${cb:money(booking.totalAmount)}"/></dd></div>
                </dl>
            </div>
            <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-white/15 bg-black/20 p-5 text-center">
                <div class="grid h-28 w-28 place-items-center rounded-xl bg-white p-3 text-zinc-900">
                    <span class="font-mono text-xs font-black leading-4">BOOKING<br>CODE<br>READY</span>
                </div>
                <p class="mt-4 font-mono text-sm font-black tracking-widest text-amber-300"><c:out value="${booking.bookingCode}"/></p>
            </div>
        </div>
        <div class="border-t border-dashed border-white/10 px-7 py-5 text-center text-xs text-zinc-500 sm:px-10">Present this ticket or booking code at the cinema entrance. Please arrive 15 minutes early.</div>
    </article>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
