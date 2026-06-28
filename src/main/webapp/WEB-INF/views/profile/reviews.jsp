<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="My reviews"/>
</jsp:include>
<section class="mx-auto max-w-5xl px-4 py-12 sm:px-6 lg:px-8">
    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Profile module</p>
    <h1 class="mt-2 text-4xl font-black text-white">Ratings & Reviews</h1>
    <p class="mt-2 text-zinc-400">Review your movie ratings and share feedback with other moviegoers.</p>

    <div class="mt-8">
        <c:choose>
            <c:when test="${not empty reviews}">
                <div class="space-y-4">
                    <c:forEach var="rev" items="${reviews}">
                        <article class="rounded-2xl border border-white/10 bg-white/[.025] p-6 transition hover:border-white/20">
                            <div class="flex flex-col justify-between gap-2 sm:flex-row sm:items-center">
                                <div>
                                    <a href="<c:url value='/movies/${rev.movieId}'/>" class="text-lg font-black text-white hover:text-rose-400">
                                        <c:out value="${rev.movieTitle}"/>
                                    </a>
                                    <div class="mt-1 flex items-center gap-2 text-xs text-zinc-400">
                                        <span class="text-amber-400 font-bold">
                                            <c:forEach begin="1" end="${rev.rating}">★</c:forEach><c:forEach begin="${rev.rating + 1}" end="5"><span class="text-zinc-600">★</span></c:forEach>
                                        </span>
                                        <span>•</span>
                                        <c:out value="${rev.createdAtDisplay}"/>
                                    </div>
                                </div>
                                <div>
                                    <span class="inline-flex rounded-full px-3 py-1 text-xs font-bold ${rev.status == 'VISIBLE' ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' : 'bg-rose-500/20 text-rose-300 border border-rose-500/30'}">
                                        <c:out value="${rev.status}"/>
                                    </span>
                                </div>
                            </div>
                            <c:if test="${not empty rev.title}">
                                <h3 class="mt-4 font-bold text-zinc-200"><c:out value="${rev.title}"/></h3>
                            </c:if>
                            <p class="mt-2 text-sm text-zinc-300 leading-relaxed"><c:out value="${rev.content}"/></p>
                            <c:if test="${rev.containsSpoiler}">
                                <div class="mt-3 inline-block rounded bg-amber-500/20 px-2 py-0.5 text-xs font-semibold text-amber-300 border border-amber-500/30">Contains Spoiler</div>
                            </c:if>
                            <c:if test="${not empty rev.moderationNote}">
                                <div class="mt-3 rounded-lg bg-rose-500/10 p-3 text-xs text-rose-300 border border-rose-500/20">
                                    <strong>Moderator Note:</strong> <c:out value="${rev.moderationNote}"/>
                                </div>
                            </c:if>
                        </article>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="rounded-3xl border border-white/10 bg-white/[.025] px-6 py-16 text-center">
                    <div class="text-4xl text-zinc-600">★</div>
                    <h2 class="mt-4 text-xl font-black text-white">No reviews yet</h2>
                    <p class="mx-auto mt-2 max-w-xl text-zinc-500">You haven't submitted any reviews or movie ratings yet. Watch a movie and let us know your thoughts!</p>
                    <a href="<c:url value='/movies/'/>" class="mt-6 inline-flex rounded-xl bg-rose-600 px-6 py-3 text-sm font-black text-white hover:bg-rose-500 transition">Browse Movies</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
