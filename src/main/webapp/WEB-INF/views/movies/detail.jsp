<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="${movie.title}"/>
    <jsp:param name="active" value="movies"/>
</jsp:include>
<section class="relative overflow-hidden border-b border-white/10">
    <c:if test="${not empty movie.backdropUrl}">
        <img src="${movie.backdropUrl}" alt="" class="absolute inset-0 h-full w-full object-cover opacity-20">
        <div class="absolute inset-0 bg-gradient-to-t from-zinc-950 via-zinc-950/80 to-transparent"></div>
    </c:if>
    <div class="relative mx-auto max-w-7xl px-4 pt-12 sm:px-6 lg:px-8">
        <div class="grid gap-8 md:grid-cols-[280px_1fr]">
            <div class="overflow-hidden rounded-2xl bg-zinc-900 poster-shadow">
                <c:choose>
                    <c:when test="${not empty movie.posterUrl}"><img src="${movie.posterUrl}" alt="${movie.title} poster" class="aspect-[2/3] h-full w-full object-cover"></c:when>
                <c:otherwise><div class="grid aspect-[2/3] place-items-center bg-gradient-to-br from-zinc-800 to-rose-950 p-6 text-center text-xl font-black text-zinc-500"><c:out value="${movie.title}"/></div></c:otherwise>
            </c:choose>
        </div>
        <div class="self-end">
            <div class="flex flex-wrap gap-2">
                <c:if test="${not empty movie.status}"><span class="rounded-full bg-rose-600/15 px-3 py-1 text-xs font-black uppercase tracking-wider text-rose-300"><c:out value="${fn:replace(movie.status, '_', ' ')}"/></span></c:if>
                <c:forEach var="format" items="${movie.formats}"><span class="rounded-full border border-white/10 px-3 py-1 text-xs font-bold text-zinc-300"><c:out value="${format.label}"/></span></c:forEach>
                <c:if test="${not empty movie.ageRating}"><span class="rounded-full border border-white/10 px-3 py-1 text-xs font-bold text-zinc-300"><c:out value="${movie.ageRating}"/></span></c:if>
            </div>
            <h1 class="mt-4 text-4xl font-black leading-tight tracking-tight sm:text-6xl"><c:out value="${movie.title}"/></h1>
            <p class="mt-3 text-sm text-zinc-400">
                <c:if test="${not empty movie.releaseDate}"><c:out value="${movie.releaseDate}"/> · </c:if>
                <c:if test="${not empty movie.durationMinutes}"><c:out value="${movie.durationMinutes}"/> minutes · </c:if>
                <c:out value="${movie.genres}"/>
            </p>
            <p class="mt-6 max-w-3xl text-base leading-7 text-zinc-300 sm:text-lg"><c:out value="${movie.summary}"/></p>
            <div class="mt-8 flex flex-wrap gap-3">
                <c:choose>
                    <c:when test="${movie.status == 'COMING_SOON'}">
                        <span class="rounded-xl bg-white/10 px-6 py-3 font-black text-zinc-300">Coming soon</span>
                    </c:when>
                    <c:otherwise>
                        <c:url var="showtimesUrl" value="/booking/showtimes"><c:param name="movieId" value="${movie.id}"/></c:url>
                        <a href="${showtimesUrl}" class="rounded-xl bg-rose-600 px-6 py-3 font-black text-white shadow-lg shadow-rose-950/50 hover:bg-rose-500">Book tickets</a>
                    </c:otherwise>
                </c:choose>
                <c:if test="${not empty movie.trailerUrl}"><a href="#trailer" class="rounded-xl border border-white/15 px-6 py-3 font-black hover:bg-white/5">Watch trailer</a></c:if>
                <c:if test="${not empty viewer}">
                    <form action="<c:url value='/profile/watchlist'/>" method="post">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="hidden" name="movieId" value="${movie.id}">
                        <c:if test="${inWatchlist}">
                            <input type="hidden" name="_method" value="DELETE">
                        </c:if>
                        <button class="rounded-xl border border-white/15 px-6 py-3 font-black hover:bg-white/5">${inWatchlist ? '✓ In watchlist' : '+ Watchlist'}</button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</section>
<section class="mx-auto grid max-w-7xl gap-10 px-4 py-12 sm:px-6 lg:grid-cols-[1fr_320px] lg:px-8">
    <div>
        <h2 class="text-2xl font-black">About the movie</h2>
        <dl class="mt-6 divide-y divide-white/10 rounded-2xl border border-white/10 bg-white/[.025] px-5">
            <div class="grid gap-2 py-4 sm:grid-cols-[140px_1fr]"><dt class="text-sm text-zinc-500">Director</dt><dd class="font-semibold"><c:out value="${empty movie.director ? 'To be announced' : movie.director}"/></dd></div>
            <div class="grid gap-2 py-4 sm:grid-cols-[140px_1fr]"><dt class="text-sm text-zinc-500">Cast</dt><dd class="font-semibold"><c:out value="${empty movie.castNames ? movie.cast : movie.castNames}"/></dd></div>
            <div class="grid gap-2 py-4 sm:grid-cols-[140px_1fr]"><dt class="text-sm text-zinc-500">Language</dt><dd class="font-semibold"><c:out value="${empty movie.language ? 'Original language' : movie.language}"/></dd></div>
        </dl>
        <c:if test="${not empty movie.trailerUrl}">
            <div id="trailer" class="mt-10 scroll-mt-24">
                <h2 class="text-2xl font-black">Official trailer</h2>
                <div class="mt-5 aspect-video overflow-hidden rounded-2xl border border-white/10 bg-black">
                    <iframe src="${movie.trailerUrl}" title="${movie.title} trailer" class="h-full w-full" loading="lazy" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                </div>
            </div>
        </c:if>
    </div>
    <aside>
        <div class="glass-panel sticky top-24 rounded-2xl p-5">
            <p class="text-xs font-black uppercase tracking-[.2em] text-rose-400">Ready when you are</p>
            <h2 class="mt-2 text-xl font-black">Find your showtime</h2>
            <p class="mt-2 text-sm leading-6 text-zinc-500">Choose a cinema, date, and screening format. Your seats will be held for seven minutes.</p>
            <c:url var="asideShowtimesUrl" value="/booking/showtimes"><c:param name="movieId" value="${movie.id}"/></c:url>
            <a href="${asideShowtimesUrl}" class="mt-5 block rounded-xl bg-rose-600 px-5 py-3 text-center text-sm font-black hover:bg-rose-500">View showtimes</a>
        </div>
    </aside>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
