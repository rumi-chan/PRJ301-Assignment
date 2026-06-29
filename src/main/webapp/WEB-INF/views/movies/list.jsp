<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Movies"/>
    <jsp:param name="active" value="movies"/>
</jsp:include>

<c:set var="heroBannerCount" value="0"/>
<c:forEach var="b" items="${banners}">
    <c:if test="${b.placement == 'HOME_HERO'}"><c:set var="heroBannerCount" value="${heroBannerCount + 1}"/></c:if>
</c:forEach>

<c:if test="${heroBannerCount > 0}">
    <section class="relative border-b border-white/5" data-hero-carousel aria-label="Featured movies">
        <div class="relative min-h-[420px] max-h-[70vh] w-full overflow-hidden sm:min-h-[480px] lg:min-h-[520px]">
            <c:set var="heroSlideIndex" value="0"/>
            <c:forEach var="b" items="${banners}">
                <c:if test="${b.placement == 'HOME_HERO'}">
                    <article class="hero-slide absolute inset-0 ${heroSlideIndex == 0 ? 'is-active' : ''}" data-hero-slide aria-hidden="${heroSlideIndex == 0 ? 'false' : 'true'}">
                        <img src="<c:out value='${b.imageUrl}'/>" alt="" class="absolute inset-0 h-full w-full object-cover object-top scale-105" data-hero-backdrop loading="${heroSlideIndex == 0 ? 'eager' : 'lazy'}">
                        <div class="absolute inset-0 bg-gradient-to-r from-black via-black/75 to-black/20"></div>
                        <div class="absolute inset-0 bg-gradient-to-t from-zinc-950 via-transparent to-black/30"></div>
                        <div class="relative mx-auto flex h-full max-w-7xl flex-col justify-end px-4 pb-10 pt-24 sm:px-6 sm:pb-14 lg:px-8">
                            <span class="w-fit rounded-full bg-rose-600/90 px-3 py-1 text-[10px] font-black uppercase tracking-[.25em] text-white backdrop-blur-md">Now showing</span>
                            <h2 class="mt-4 max-w-3xl text-3xl font-black leading-tight tracking-tight text-white sm:text-5xl lg:text-6xl"><c:out value="${b.title}"/></h2>
                            <c:if test="${not empty b.subtitle}">
                                <p class="mt-4 max-w-2xl text-sm leading-relaxed text-zinc-300 sm:text-base line-clamp-3"><c:out value="${b.subtitle}"/></p>
                            </c:if>
                            <div class="mt-7 flex flex-wrap items-center gap-3">
                                <c:set var="heroRawTargetUrl" value="${not empty b.targetUrl and fn:startsWith(b.targetUrl, '/') and not fn:startsWith(b.targetUrl, '//') ? b.targetUrl : '/movies'}"/>
                                <c:url var="heroTargetUrl" value="${heroRawTargetUrl}"/>
                                <a href="<c:out value='${heroTargetUrl}'/>" class="inline-flex items-center gap-2 rounded-xl bg-rose-600 px-6 py-3 text-sm font-black text-white shadow-lg shadow-rose-950/40 transition hover:bg-rose-500">
                                    Book tickets
                                    <svg viewBox="0 0 24 24" class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2.5"><path d="m9 18 6-6-6-6"/></svg>
                                </a>
                            </div>
                        </div>
                    </article>
                    <c:set var="heroSlideIndex" value="${heroSlideIndex + 1}"/>
                </c:if>
            </c:forEach>
            <c:if test="${heroBannerCount > 1}">
                <div class="pointer-events-none absolute inset-x-0 bottom-0 z-10 mx-auto flex max-w-7xl items-center justify-between px-4 pb-6 sm:px-6 lg:px-8">
                    <div class="pointer-events-auto flex gap-2" role="tablist" aria-label="Featured movie slides">
                        <c:set var="heroDotIndex" value="0"/>
                        <c:forEach var="b" items="${banners}">
                            <c:if test="${b.placement == 'HOME_HERO'}">
                                <button type="button" data-hero-dot class="h-2 rounded-full transition-all ${heroDotIndex == 0 ? 'w-8 bg-rose-500' : 'w-2 bg-white/35 hover:bg-white/60'}" aria-label="Show slide ${heroDotIndex + 1}" aria-selected="${heroDotIndex == 0 ? 'true' : 'false'}"></button>
                                <c:set var="heroDotIndex" value="${heroDotIndex + 1}"/>
                            </c:if>
                        </c:forEach>
                    </div>
                    <div class="pointer-events-auto hidden gap-2 sm:flex">
                        <button type="button" data-hero-prev class="grid h-10 w-10 place-items-center rounded-full border border-white/15 bg-black/40 text-white backdrop-blur transition hover:bg-black/60" aria-label="Previous slide">
                            <svg viewBox="0 0 24 24" class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2"><path d="m15 18-6-6 6-6"/></svg>
                        </button>
                        <button type="button" data-hero-next class="grid h-10 w-10 place-items-center rounded-full border border-white/15 bg-black/40 text-white backdrop-blur transition hover:bg-black/60" aria-label="Next slide">
                            <svg viewBox="0 0 24 24" class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2"><path d="m9 18 6-6-6-6"/></svg>
                        </button>
                    </div>
                </div>
            </c:if>
        </div>
    </section>
</c:if>

<c:set var="promoBannerCount" value="0"/>
<c:forEach var="b" items="${banners}">
    <c:if test="${b.placement == 'HOME_PROMO'}"><c:set var="promoBannerCount" value="${promoBannerCount + 1}"/></c:if>
</c:forEach>
<c:if test="${promoBannerCount > 0}">
    <section class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
        <div class="grid gap-4 sm:grid-cols-2">
            <c:forEach var="b" items="${banners}">
                <c:if test="${b.placement == 'HOME_PROMO'}">
                    <c:set var="promoRawTargetUrl" value="${not empty b.targetUrl and fn:startsWith(b.targetUrl, '/') and not fn:startsWith(b.targetUrl, '//') ? b.targetUrl : '/movies'}"/>
                    <c:url var="promoTargetUrl" value="${promoRawTargetUrl}"/>
                    <a href="<c:out value='${promoTargetUrl}'/>" class="group relative overflow-hidden rounded-2xl border border-white/10 bg-black/40 shadow-xl transition hover:border-rose-500/40 block">
                        <img src="<c:out value='${b.imageUrl}'/>" alt="<c:out value='${b.title}'/>" class="h-44 w-full object-cover object-top transition duration-500 group-hover:scale-105 sm:h-48" loading="lazy">
                        <div class="absolute inset-0 bg-gradient-to-t from-black via-black/50 to-transparent p-5 flex flex-col justify-end">
                            <span class="w-fit rounded-full bg-white/10 px-2.5 py-1 text-[10px] font-black uppercase tracking-wider text-zinc-200 backdrop-blur-md">Spotlight</span>
                            <h3 class="mt-2 text-lg font-black text-white group-hover:text-rose-400 transition"><c:out value="${b.title}"/></h3>
                            <c:if test="${not empty b.subtitle}">
                                <p class="mt-1 text-xs text-zinc-400 line-clamp-2"><c:out value="${b.subtitle}"/></p>
                            </c:if>
                        </div>
                    </a>
                </c:if>
            </c:forEach>
        </div>
    </section>
</c:if>

<section class="relative overflow-hidden border-b border-white/5">
    <div class="absolute inset-0 bg-gradient-to-r from-rose-950/35 via-transparent to-amber-950/20"></div>
    <div class="relative mx-auto max-w-7xl px-4 py-10 sm:px-6 sm:py-14 lg:px-8 ${heroBannerCount > 0 ? '' : 'sm:py-20'}">
        <c:if test="${heroBannerCount == 0}">
            <p class="text-sm font-black uppercase tracking-[.3em] text-rose-500">Now playing near you</p>
            <h1 class="mt-3 max-w-3xl text-4xl font-black tracking-tight sm:text-6xl">Big screen stories.<br><span class="text-zinc-500">Your favorite seat.</span></h1>
        </c:if>
        <c:if test="${heroBannerCount > 0}">
            <p class="text-sm font-black uppercase tracking-[.3em] text-rose-500">Find your showtime</p>
            <h1 class="mt-2 text-2xl font-black tracking-tight text-white sm:text-3xl">Search the catalog</h1>
        </c:if>
        <form action="<c:url value='/movies'/>" method="get" class="glass-panel mt-6 flex max-w-2xl flex-col gap-3 rounded-2xl p-3 sm:mt-8 sm:flex-row">
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
                <c:forEach var="movieItem" items="${movies}">
                    <c:set var="movie" value="${movieItem}" scope="request"/>
                    <jsp:include page="/WEB-INF/views/shared/movie-card.jsp"/>
                </c:forEach>
                <c:remove var="movie" scope="request"/>
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
