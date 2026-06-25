<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Payment result"/>
</jsp:include>
<section class="mx-auto flex min-h-[68vh] max-w-3xl items-center px-4 py-14 sm:px-6 lg:px-8">
    <div class="glass-panel w-full rounded-3xl p-7 text-center sm:p-12">
        <c:set var="resultStatus" value="${not empty paymentStatus ? paymentStatus : paymentResult.status}"/>
        <c:choose>
            <c:when test="${resultStatus == 'SUCCEEDED' || resultStatus == 'SUCCESS' || resultStatus == 'PAID'}">
                <div class="mx-auto grid h-20 w-20 place-items-center rounded-full bg-emerald-500/15 text-4xl text-emerald-400">✓</div>
                <p class="mt-6 text-sm font-black uppercase tracking-[.25em] text-emerald-400">Payment approved</p>
                <h1 class="mt-2 text-3xl font-black sm:text-5xl">Your seats are confirmed.</h1>
                <p class="mx-auto mt-4 max-w-lg text-zinc-400">Your electronic ticket is ready. Keep the booking code handy when you arrive.</p>
                <p class="mt-6 font-mono text-lg font-black tracking-[.18em] text-amber-300"><c:out value="${paymentResult.bookingCode}"/></p>
                <div class="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
                    <c:url var="ticketUrl" value="/tickets/${paymentResult.bookingCode}"/>
                    <a href="${ticketUrl}" class="rounded-xl bg-rose-600 px-6 py-3 font-black hover:bg-rose-500">Open ticket</a>
                    <a href="<c:url value='/profile/bookings'/>" class="rounded-xl border border-white/10 px-6 py-3 font-black hover:bg-white/5">Booking history</a>
                </div>
            </c:when>
            <c:when test="${resultStatus == 'CANCELLED' || resultStatus == 'CANCELED'}">
                <div class="mx-auto grid h-20 w-20 place-items-center rounded-full bg-zinc-500/15 text-4xl text-zinc-400">×</div>
                <p class="mt-6 text-sm font-black uppercase tracking-[.25em] text-zinc-500">Payment cancelled</p>
                <h1 class="mt-2 text-3xl font-black sm:text-5xl">No charge was made.</h1>
                <p class="mx-auto mt-4 max-w-lg text-zinc-400">The selected seats have been released. You can start a new booking whenever you are ready.</p>
                <a href="<c:url value='/movies'/>" class="mt-8 inline-flex rounded-xl bg-rose-600 px-6 py-3 font-black hover:bg-rose-500">Browse movies</a>
            </c:when>
            <c:otherwise>
                <div class="mx-auto grid h-20 w-20 place-items-center rounded-full bg-rose-500/15 text-4xl text-rose-400">!</div>
                <p class="mt-6 text-sm font-black uppercase tracking-[.25em] text-rose-400">Payment unsuccessful</p>
                <h1 class="mt-2 text-3xl font-black sm:text-5xl">That did not go through.</h1>
                <p class="mx-auto mt-4 max-w-lg text-zinc-400"><c:out value="${empty paymentMessage ? 'Your seats remain held if the timer has not expired. Try the payment again.' : paymentMessage}"/></p>
                <div class="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
                    <c:url var="retryUrl" value="/checkout"><c:param name="holdToken" value="${holdToken}"/></c:url>
                    <a href="${retryUrl}" class="rounded-xl bg-rose-600 px-6 py-3 font-black hover:bg-rose-500">Try again</a>
                    <a href="<c:url value='/movies'/>" class="rounded-xl border border-white/10 px-6 py-3 font-black hover:bg-white/5">Start over</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
