<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Watchlist"/>
    <jsp:param name="active" value="watchlist"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
    <div><p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Saved for later</p><h1 class="mt-2 text-4xl font-black tracking-tight">My watchlist</h1><p class="mt-3 text-zinc-500">The stories you do not want to miss.</p></div>
    <c:choose>
        <c:when test="${not empty movies}">
            <div class="mt-10 grid grid-cols-2 gap-x-4 gap-y-10 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
                <c:forEach var="movieItem" items="${movies}">
                    <div>
                        <c:set var="movie" value="${movieItem}" scope="request"/>
                        <jsp:include page="/WEB-INF/views/shared/movie-card.jsp"/>
                        <form action="<c:url value='/profile/watchlist'/>" method="post" class="mt-3">
                            <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>"><input type="hidden" name="movieId" value="<c:out value='${movieItem.id}'/>"><input type="hidden" name="_method" value="DELETE">
                            <button data-confirm="Remove this movie from your watchlist?" class="w-full rounded-lg border border-white/10 px-3 py-2 text-xs font-bold text-zinc-500 hover:border-rose-500/30 hover:text-rose-400">Remove</button>
                        </form>
                    </div>
                </c:forEach>
                <c:remove var="movie" scope="request"/>
            </div>
        </c:when>
        <c:otherwise>
            <div class="glass-panel mt-10 rounded-3xl px-6 py-20 text-center"><div class="text-5xl">♡</div><h2 class="mt-5 text-xl font-black">Your watchlist is waiting</h2><p class="mt-2 text-zinc-500">Save interesting movies and find them quickly later.</p><a href="<c:url value='/movies'/>" class="mt-6 inline-flex rounded-xl bg-rose-600 px-5 py-3 text-sm font-black">Find a movie</a></div>
        </c:otherwise>
    </c:choose>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
