<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="Review Moderation"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="reviews"/></jsp:include>
        <div class="min-w-0">
            <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                <div>
                    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                    <h1 class="mt-2 text-3xl font-black sm:text-4xl text-white">Review Moderation</h1>
                    <p class="mt-2 max-w-2xl text-zinc-500">Inspect, hide, or remove reviews containing spoilers or inappropriate content.</p>
                </div>
            </div>

            <c:if test="${not empty flashMessage}">
                <div class="mt-6 rounded-2xl border border-emerald-500/20 bg-emerald-500/10 p-4 text-sm font-bold text-emerald-300">
                    <c:out value="${flashMessage}"/>
                </div>
            </c:if>

            <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                <div class="flex flex-col gap-3 border-b border-white/10 p-4 sm:flex-row">
                    <form method="get" action="<c:url value='/admin/reviews'/>" class="flex min-w-0 flex-1 gap-2">
                        <input name="q" value="<c:out value='${param.q}'/>" placeholder="Search by author, movie or keyword…" class="min-w-0 flex-1 rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 text-sm text-white outline-none focus:border-rose-500">
                        <button type="submit" class="rounded-lg border border-white/10 px-4 py-2 text-sm font-bold hover:bg-white/5 text-white">Search</button>
                    </form>
                    <span class="self-center text-xs text-zinc-600"><c:out value="${empty totalCount ? 0 : totalCount}"/> records</span>
                </div>
                <c:choose>
                    <c:when test="${not empty reviews}">
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[850px] text-left text-sm">
                                <thead class="bg-black/20 text-xs uppercase tracking-wider text-zinc-500">
                                    <tr>
                                        <th class="px-5 py-4 font-bold">Author & Movie</th>
                                        <th class="px-5 py-4 font-bold">Rating & Content</th>
                                        <th class="px-5 py-4 font-bold">Status</th>
                                        <th class="px-5 py-4 text-right font-bold">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-white/5">
                                    <c:forEach var="rev" items="${reviews}">
                                        <tr class="hover:bg-white/[.025]">
                                            <td class="px-5 py-4 align-top w-1/4">
                                                <div class="font-bold text-white"><c:out value="${rev.userName}"/></div>
                                                <div class="text-xs text-rose-400 font-semibold"><c:out value="${rev.movieTitle}"/></div>
                                                <div class="text-[11px] text-zinc-500 mt-1">
                                                    <c:out value="${rev.createdAtDisplay}"/>
                                                </div>
                                            </td>
                                            <td class="px-5 py-4 align-top w-1/2 text-zinc-300">
                                                <div class="text-amber-400 text-xs font-bold mb-1">
                                                    <c:forEach begin="1" end="${rev.rating}">★</c:forEach> (<c:out value="${rev.rating}"/>/5)
                                                    <c:if test="${rev.containsSpoiler}">
                                                        <span class="ml-2 rounded bg-amber-500/20 px-1.5 py-0.5 text-[10px] text-amber-300 border border-amber-500/30">Spoiler</span>
                                                    </c:if>
                                                </div>
                                                <c:if test="${not empty rev.title}">
                                                    <div class="font-bold text-white text-xs mb-1"><c:out value="${rev.title}"/></div>
                                                </c:if>
                                                <div class="text-xs text-zinc-300 line-clamp-3"><c:out value="${rev.content}"/></div>
                                                <c:if test="${not empty rev.moderationNote}">
                                                    <div class="mt-1 text-[11px] text-zinc-500 italic">Note: <c:out value="${rev.moderationNote}"/></div>
                                                </c:if>
                                            </td>
                                            <td class="px-5 py-4 align-top">
                                                <span class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-bold ${rev.status == 'VISIBLE' ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' : (rev.status == 'HIDDEN' ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30' : 'bg-rose-500/20 text-rose-300 border border-rose-500/30')}">
                                                    <c:out value="${rev.status}"/>
                                                </span>
                                            </td>
                                            <td class="px-5 py-4 align-top text-right whitespace-nowrap">
                                                <form action="<c:url value='/admin/reviews'/>" method="post" class="inline-flex flex-col gap-1 items-end">
                                                    <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                                                    <input type="hidden" name="reviewId" value="<c:out value='${rev.id}'/>">
                                                    <c:choose>
                                                        <c:when test="${rev.status == 'VISIBLE'}">
                                                            <input type="hidden" name="status" value="HIDDEN">
                                                            <input type="hidden" name="note" value="Hidden by administrator due to policy violation.">
                                                            <button type="submit" class="rounded border border-amber-500/30 bg-amber-500/10 px-2.5 py-1 text-xs font-bold text-amber-300 hover:bg-amber-500/20">Hide Review</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <input type="hidden" name="status" value="VISIBLE">
                                                            <input type="hidden" name="note" value="">
                                                            <button type="submit" class="rounded border border-emerald-500/30 bg-emerald-500/10 px-2.5 py-1 text-xs font-bold text-emerald-300 hover:bg-emerald-500/20">Approve / Restore</button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:if test="${rev.status != 'DELETED'}">
                                                        <button type="submit" onclick="this.form.status.value='DELETED'; this.form.note.value='Deleted by admin';" class="rounded border border-rose-500/30 bg-rose-500/10 px-2.5 py-1 text-xs font-bold text-rose-300 hover:bg-rose-500/20 mt-1">Delete</button>
                                                    </c:if>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="px-6 py-20 text-center"><div class="text-4xl text-zinc-600">★</div><h2 class="mt-4 text-lg font-black text-white">No reviews found</h2><p class="mt-2 text-sm text-zinc-600">There are currently no reviews to moderate.</p></div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>