<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activeAdminSection" value="${not empty adminSection ? adminSection : param.section}"/>
<aside class="rounded-2xl border border-white/10 bg-white/[.025] p-3 lg:sticky lg:top-24">
    <p class="px-3 py-2 text-[10px] font-black uppercase tracking-[.24em] text-zinc-600">Workspace</p>
    <nav class="grid grid-cols-2 gap-1 sm:grid-cols-3 lg:grid-cols-1" aria-label="Admin navigation">
        <c:forEach var="nav" items="${adminNavigation}">
            <a href="<c:url value='${nav.route}'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == nav.key ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5 hover:text-white'}"><c:out value="${nav.label}"/></a>
        </c:forEach>
        <c:if test="${empty adminNavigation}">
            <a href="<c:url value='/admin'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'dashboard' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Dashboard</a>
            <a href="<c:url value='/admin/analytics'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'analytics' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Analytics</a>
            <a href="<c:url value='/admin/movies'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'movies' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Movies</a>
            <a href="<c:url value='/admin/cinemas'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'cinemas' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Cinemas</a>
            <a href="<c:url value='/admin/showrooms'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'showrooms' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Showrooms</a>
            <a href="<c:url value='/admin/showtimes'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'showtimes' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Showtimes</a>
            <a href="<c:url value='/admin/combos'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'combos' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Combos</a>
            <a href="<c:url value='/admin/seat-layouts'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'seat-layouts' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Seat layouts</a>
            <a href="<c:url value='/admin/accounts'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'accounts' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Accounts</a>
            <a href="<c:url value='/admin/promotions'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'promotions' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Promotions</a>
            <a href="<c:url value='/admin/reviews'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'reviews' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Reviews</a>
            <a href="<c:url value='/admin/banners'/>" class="rounded-lg px-3 py-2.5 text-sm font-semibold ${activeAdminSection == 'banners' ? 'bg-rose-600 text-white' : 'text-zinc-400 hover:bg-white/5'}">Banners</a>
        </c:if>
    </nav>
</aside>
