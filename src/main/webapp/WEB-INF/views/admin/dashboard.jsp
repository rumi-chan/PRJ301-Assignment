<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="Admin dashboard"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="dashboard"/></jsp:include>
        <div class="min-w-0">
            <div><p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Control room</p><h1 class="mt-2 text-3xl font-black sm:text-4xl">Dashboard</h1><p class="mt-2 text-zinc-500">A quick pulse check across the CineBook platform.</p></div>
            <div class="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
                <c:forEach var="metric" items="${dashboardMetrics}">
                    <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5"><p class="text-xs font-bold uppercase tracking-wider text-zinc-500"><c:out value="${metric.label}"/></p><p class="mt-3 text-3xl font-black"><c:out value="${metric.value}"/></p><p class="mt-2 text-xs ${metric.positive ? 'text-emerald-400' : 'text-zinc-600'}"><c:out value="${metric.change}"/></p></article>
                </c:forEach>
                <c:if test="${empty dashboardMetrics}">
                    <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5"><p class="text-xs font-bold uppercase tracking-wider text-zinc-500">Revenue today</p><p class="mt-3 text-3xl font-black">—</p><p class="mt-2 text-xs text-zinc-600">Awaiting analytics data</p></article>
                    <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5"><p class="text-xs font-bold uppercase tracking-wider text-zinc-500">Bookings</p><p class="mt-3 text-3xl font-black">—</p><p class="mt-2 text-xs text-zinc-600">Awaiting booking data</p></article>
                    <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5"><p class="text-xs font-bold uppercase tracking-wider text-zinc-500">Active movies</p><p class="mt-3 text-3xl font-black">—</p><p class="mt-2 text-xs text-zinc-600">Awaiting catalog data</p></article>
                    <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5"><p class="text-xs font-bold uppercase tracking-wider text-zinc-500">Customers</p><p class="mt-3 text-3xl font-black">—</p><p class="mt-2 text-xs text-zinc-600">Awaiting account data</p></article>
                </c:if>
            </div>
            <div class="mt-6 grid gap-6 xl:grid-cols-[1fr_320px]">
                <article class="rounded-2xl border border-white/10 bg-white/[.025] p-6"><div class="flex items-center justify-between"><h2 class="font-black">Revenue overview</h2><a href="<c:url value='/admin/analytics'/>" class="text-xs font-bold text-rose-400">View analytics →</a></div><div class="mt-6 grid h-64 place-items-center rounded-xl border border-dashed border-white/10 bg-black/10 text-center text-sm text-zinc-600">Chart data will render here<br>when analytics are connected.</div></article>
                <article class="rounded-2xl border border-white/10 bg-white/[.025] p-6"><h2 class="font-black">Quick actions</h2><div class="mt-5 grid gap-3"><a href="<c:url value='/admin/movies?action=create'/>" class="rounded-xl bg-rose-600 px-4 py-3 text-sm font-black hover:bg-rose-500">Add a movie</a><a href="<c:url value='/admin/showtimes?action=create'/>" class="rounded-xl border border-white/10 px-4 py-3 text-sm font-black hover:bg-white/5">Schedule showtime</a><a href="<c:url value='/admin/promotions?action=create'/>" class="rounded-xl border border-white/10 px-4 py-3 text-sm font-black hover:bg-white/5">Create promotion</a><a href="<c:url value='/admin/reviews'/>" class="rounded-xl border border-white/10 px-4 py-3 text-sm font-black hover:bg-white/5">Moderate reviews</a></div></article>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
