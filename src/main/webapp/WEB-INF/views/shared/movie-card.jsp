<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="group">
    <a href="<c:url value='/movies/${movie.id}'/>" class="block overflow-hidden rounded-2xl bg-zinc-900 poster-shadow">
        <div class="relative aspect-[2/3] overflow-hidden">
            <c:if test="${not empty movie.posterUrl}">
                <img data-poster src="${movie.posterUrl}" alt="${movie.title} poster" class="h-full w-full object-cover transition duration-500 group-hover:scale-105">
            </c:if>
            <div class="${not empty movie.posterUrl ? 'hidden' : ''} grid h-full w-full place-items-center bg-gradient-to-br from-zinc-800 via-zinc-900 to-rose-950 p-6 text-center">
                <span class="text-2xl font-black text-zinc-500"><c:out value="${movie.title}"/></span>
            </div>
            <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black via-black/55 to-transparent p-4 pt-16">
                <div class="flex flex-wrap gap-2">
                    <c:if test="${not empty movie.formats}"><span class="rounded bg-white/15 px-2 py-1 text-[10px] font-black uppercase tracking-wider backdrop-blur"><c:out value="${movie.formats[0].label}"/></span></c:if>
                    <c:if test="${not empty movie.ageRating}"><span class="rounded bg-rose-600 px-2 py-1 text-[10px] font-black"><c:out value="${movie.ageRating}"/></span></c:if>
                </div>
            </div>
        </div>
    </a>
    <div class="px-1 pt-4">
        <a href="<c:url value='/movies/${movie.id}'/>" class="line-clamp-1 text-base font-bold text-white group-hover:text-rose-400"><c:out value="${movie.title}"/></a>
        <p class="mt-1 line-clamp-1 text-sm text-zinc-500">
            <c:choose>
                <c:when test="${not empty movie.genreNames}"><c:out value="${movie.genreNames}"/></c:when>
                <c:when test="${not empty movie.genres}"><c:out value="${movie.genres}"/></c:when>
                <c:otherwise>Movie</c:otherwise>
            </c:choose>
            <c:if test="${not empty movie.durationMinutes}"> · <c:out value="${movie.durationMinutes}"/> min</c:if>
        </p>
    </div>
</div>
