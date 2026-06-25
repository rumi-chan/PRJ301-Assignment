<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Cinemas"/>
    <jsp:param name="active" value="cinemas"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
    <div class="grid items-end gap-8 lg:grid-cols-[1fr_420px]">
        <div>
            <p class="text-sm font-black uppercase tracking-[.3em] text-rose-500">Across Vietnam</p>
            <h1 class="mt-3 text-4xl font-black tracking-tight sm:text-6xl">Find your cinema.</h1>
            <p class="mt-4 max-w-2xl text-lg text-zinc-400">Search by city or region and discover showtimes at a screen near you.</p>
        </div>
        <form action="<c:url value='/cinemas'/>" method="get" class="glass-panel flex gap-3 rounded-2xl p-3">
            <select name="city" class="min-w-0 flex-1 rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 outline-none focus:border-rose-500">
                <option value="">Every city</option>
                <c:forEach var="city" items="${cities}">
                    <option value="<c:out value='${city}'/>" ${param.city == city || selectedCity == city ? 'selected' : ''}><c:out value="${city}"/></option>
                </c:forEach>
            </select>
            <button class="rounded-xl bg-rose-600 px-5 py-3 font-black hover:bg-rose-500">Search</button>
        </form>
    </div>

    <c:choose>
        <c:when test="${not empty cinemas}">
            <div class="mt-12 grid gap-5 md:grid-cols-2">
                <c:forEach var="cinema" items="${cinemas}">
                    <article class="group rounded-2xl border border-white/10 bg-white/[.025] p-6 transition hover:-translate-y-0.5 hover:border-rose-500/30 hover:bg-white/[.04]">
                        <div class="flex items-start justify-between gap-4">
                            <div class="grid h-12 w-12 shrink-0 place-items-center rounded-xl bg-rose-600/15 text-rose-400">
                                <svg viewBox="0 0 24 24" class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 21V7l8-4 8 4v14M8 10h2m4 0h2M8 14h2m4 0h2M9 21v-3h6v3"/></svg>
                            </div>
                            <c:if test="${not empty cinema.city}"><span class="rounded-full border border-white/10 px-3 py-1 text-xs font-bold text-zinc-400"><c:out value="${cinema.city}"/></span></c:if>
                        </div>
                        <h2 class="mt-5 text-xl font-black"><c:out value="${cinema.name}"/></h2>
                        <p class="mt-2 min-h-10 text-sm leading-5 text-zinc-500"><c:out value="${cinema.address}"/></p>
                        <div class="mt-5 flex flex-wrap gap-2">
                            <c:forEach var="format" items="${cinema.formats}"><span class="rounded bg-white/5 px-2 py-1 text-[11px] font-bold text-zinc-400"><c:out value="${format}"/></span></c:forEach>
                        </div>
                        <a href="<c:url value='/movies'/>" class="mt-6 inline-flex items-center gap-2 text-sm font-black text-rose-400 group-hover:text-rose-300">Choose a movie <span aria-hidden="true">→</span></a>
                    </article>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="glass-panel mt-12 rounded-3xl px-6 py-20 text-center">
                <div class="text-4xl">📍</div>
                <h2 class="mt-4 text-xl font-black">No cinemas found here yet</h2>
                <p class="mt-2 text-zinc-500">Try another city or browse every location.</p>
                <a href="<c:url value='/cinemas'/>" class="mt-5 inline-flex rounded-xl bg-rose-600 px-5 py-3 text-sm font-black">View all cinemas</a>
            </div>
        </c:otherwise>
    </c:choose>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
