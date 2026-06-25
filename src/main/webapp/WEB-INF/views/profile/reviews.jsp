<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="My reviews"/>
</jsp:include>
<section class="mx-auto max-w-5xl px-4 py-12 sm:px-6 lg:px-8">
    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Profile module</p>
    <h1 class="mt-2 text-4xl font-black">Ratings & reviews</h1>
    <div class="mt-8 rounded-3xl border border-white/10 bg-white/[.025] px-6 py-16 text-center">
        <div class="text-4xl">★</div>
        <h2 class="mt-4 text-xl font-black">Review workflow scaffold</h2>
        <p class="mx-auto mt-2 max-w-xl text-zinc-500">The screen and route are ready for UC23. Connect watched bookings to rating, spoiler, and review persistence here.</p>
        <a href="<c:url value='/profile/bookings'/>" class="mt-6 inline-flex rounded-xl bg-rose-600 px-5 py-3 text-sm font-black hover:bg-rose-500">View watched bookings</a>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
