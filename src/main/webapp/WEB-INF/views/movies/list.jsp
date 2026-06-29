<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Movies"/>
    <jsp:param name="active" value="movies"/>
</jsp:include>

<c:if test="${not empty banners}">
    <section class="relative mx-auto max-w-7xl px-4 pt-8 sm:px-6 lg:px-8">
        <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            <c:forEach var="b" items="${banners}">
                <a href="<c:out value='${not empty b.targetUrl ? b.targetUrl : "#"}'/>" class="group relative overflow-hidden rounded-3xl border border-white/10 bg-black/40 shadow-2xl transition hover:scale-[1.02] hover:border-rose-500/50 block">
                    <img src="<c:out value='${b.imageUrl}'/>" alt="<c:out value='${b.title}'/>" class="h-56 w-full object-cover transition duration-500 group-hover:scale-105 opacity-80">
                    <div class="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent p-6 flex flex-col justify-end">
                        <span class="w-fit rounded-full bg-rose-600/80 px-3 py-1 text-[10px] font-black uppercase tracking-wider text-white backdrop-blur-md">Featured Promo</span>
                        <h3 class="mt-2 text-xl font-black text-white group-hover:text-rose-400 transition"><c:out value="${b.title}"/></h3>
                        <c:if test="${not empty b.subtitle}">
                            <p class="mt-1 text-xs text-zinc-300 line-clamp-2"><c:out value="${b.subtitle}"/></p>
                        </c:if>
                    </div>
                </a>
            </c:forEach>
        </div>
    </section>
</c:if>

<section class="relative overflow-hidden border-b border-white/5">
    <div class="absolute inset-0 bg-gradient-to-r from-rose-950/35 via-transparent to-amber-950/20"></div>
    <div class="relative mx-auto max-w-7xl px-4 py-14 sm:px-6 sm:py-20 lg:px-8">
        <p class="text-sm font-black uppercase tracking-[.3em] text-rose-500">Now playing near you</p>
        <h1 class="mt-3 max-w-3xl text-4xl font-black tracking-tight sm:text-6xl">Big screen stories.<br><span class="text-zinc-500">Your favorite seat.</span></h1>
        <form action="<c:url value='/movies'/>" method="get" class="glass-panel mt-9 flex max-w-2xl flex-col gap-3 rounded-2xl p-3 sm:flex-row">
            <label class="relative flex-1">
                <span class="sr-only">Search movies</span>
                <svg viewBox="0 0 24 24" class="absolute left-3 top-3.5 h-5 w-5 text-zinc-500" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/></svg>
                <input name="q" value="<c:out value='${not empty filters.query ? filters.query : param.q}'/>" placeholder="Search by movie title…" class="w-full rounded-xl border border-white/10 bg-black/25 py-3 pl-11 pr-4 outline-none focus:border-rose-500">
            </label>
            <button class="rounded-xl bg-rose-600 px-6 py-3 font-black hover:bg-rose-500">Find a movie</button>
        </form>
    </div>
</section>

<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <form action="<c:url value='/movies'/>" method="get" class="mb-10 grid gap-3 rounded-2xl border border-white/10 bg-white/[.025] p-4 sm:grid-cols-4">
        <input type="hidden" name="q" value="<c:out value='${not empty filters.query ? filters.query : param.q}'/>">
        <select name="status" class="rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
            <option value="">All releases</option>
            <option value="NOW_SHOWING" ${param.status == 'NOW_SHOWING' || filters.status == 'NOW_SHOWING' ? 'selected' : ''}>Now showing</option>
            <option value="COMING_SOON" ${param.status == 'COMING_SOON' || filters.status == 'COMING_SOON' ? 'selected' : ''}>Coming soon</option>
        </select>
        <select name="genre" class="rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
            <option value="">All genres</option>
            <c:forEach var="genre" items="${genres}">
                <option value="<c:out value='${genre}'/>" ${param.genre == genre ? 'selected' : ''}><c:out value="${genre}"/></option>
            </c:forEach>
        </select>
        <select name="format" class="rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
            <option value="">All formats</option>
            <c:forEach var="format" items="${empty formats ? ['2D','3D','IMAX'] : formats}">
                <option value="<c:out value='${format}'/>" ${param.format == format || filters.format == format ? 'selected' : ''}><c:out value="${format}"/></option>
            </c:forEach>
        </select>
        <button class="rounded-xl border border-white/10 px-4 py-3 text-sm font-bold hover:border-rose-500/50 hover:bg-rose-500/10">Apply filters</button>
    </form>

    <div class="mb-7 flex items-end justify-between gap-4">
        <div>
            <p class="text-sm font-semibold text-rose-400"><c:out value="${empty resultLabel ? 'Cinema catalog' : resultLabel}"/></p>
            <h2 class="mt-1 text-2xl font-black sm:text-3xl"><c:out value="${empty pageTitle ? 'Movies to watch' : pageTitle}"/></h2>
        </div>
        <c:if test="${not empty totalCount}"><p class="text-sm text-zinc-500"><c:out value="${totalCount}"/> results</p></c:if>
    </div>
    <c:choose>
        <c:when test="${not empty movies}">
            <div class="grid grid-cols-2 gap-x-4 gap-y-9 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
                <c:forEach var="m" items="${movies}">
                    <c:set var="movie" value="${m}" scope="request"/>
                    <jsp:include page="/WEB-INF/views/shared/movie-card.jsp"/>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="glass-panel rounded-3xl px-6 py-20 text-center">
                <div class="mx-auto grid h-16 w-16 place-items-center rounded-full bg-white/5 text-3xl">🎬</div>
                <h3 class="mt-5 text-xl font-bold">No movies found</h3>
                <p class="mt-2 text-zinc-500">Try a broader search or clear a filter.</p>
                <a href="<c:url value='/movies'/>" class="mt-6 inline-flex rounded-xl bg-rose-600 px-5 py-3 text-sm font-bold hover:bg-rose-500">Browse all movies</a>
            </div>
        </c:otherwise>
    </c:choose>
    <c:if test="${not empty totalPages && totalPages > 1}">
        <nav class="mt-12 flex justify-center gap-2" aria-label="Pagination">
            <c:forEach begin="1" end="${totalPages}" var="pageNumber">
                <c:url var="pageUrl" value="/movies">
                    <c:param name="page" value="${pageNumber}"/>
                    <c:param name="q" value="${param.q}"/>
                    <c:param name="status" value="${param.status}"/>
                    <c:param name="genre" value="${param.genre}"/>
                    <c:param name="format" value="${param.format}"/>
                </c:url>
                <a href="${pageUrl}" class="grid h-10 w-10 place-items-center rounded-lg text-sm font-bold ${pageNumber == currentPage ? 'bg-rose-600 text-white' : 'border border-white/10 text-zinc-400 hover:bg-white/5'}">${pageNumber}</a>
            </c:forEach>
        </nav>
    </c:if>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
