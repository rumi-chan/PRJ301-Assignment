<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Movie Management"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="movies"/>
        </jsp:include>
        <div class="min-w-0">
            <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                <div>
                    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                    <h1 class="mt-2 text-3xl font-black sm:text-4xl">Movie Management</h1>
                    <p class="mt-2 max-w-2xl text-zinc-500">Create, update, publish, and retire titles in the cinema catalog.</p>
                </div>
                <a href="<c:url value='/admin/movies?action=create'/>" class="rounded-xl bg-rose-600 px-5 py-3 text-center text-sm font-black text-white hover:bg-rose-500 transition shadow-lg shadow-rose-600/30">Add New Movie</a>
            </div>

            <c:if test="${not empty flashMessage}">
                <div class="mt-6 rounded-xl bg-emerald-500/10 border border-emerald-500/20 p-4 text-sm text-emerald-400 font-semibold">
                    <c:out value="${flashMessage}"/>
                </div>
            </c:if>

            <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025] shadow-xl">
                <div class="flex flex-col gap-3 border-b border-white/10 p-4 sm:flex-row items-center justify-between">
                    <form method="get" action="<c:url value='/admin/movies'/>" class="flex min-w-0 flex-1 gap-2 w-full sm:w-auto">
                        <input name="q" value="<c:out value='${q}'/>" placeholder="Search movies by title..." class="min-w-0 flex-1 rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 text-sm text-white outline-none focus:border-rose-500 transition">
                        <button type="submit" class="rounded-lg border border-white/10 px-4 py-2 text-sm font-bold text-white hover:bg-white/5 transition">Search</button>
                    </form>
                    <span class="text-xs font-semibold text-zinc-400"><c:out value="${totalCount}"/> records found</span>
                </div>

                <c:choose>
                    <c:when test="${not empty items}">
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[700px] text-left text-sm">
                                <thead class="bg-black/40 text-xs uppercase tracking-wider text-zinc-400">
                                    <tr>
                                        <th class="px-5 py-4 font-bold">Movie</th>
                                        <th class="px-5 py-4 font-bold">Director</th>
                                        <th class="px-5 py-4 font-bold">Duration / Rating</th>
                                        <th class="px-5 py-4 font-bold">Status</th>
                                        <th class="px-5 py-4 text-right font-bold">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-white/5">
                                    <c:forEach var="m" items="${items}">
                                        <tr class="hover:bg-white/[.025] transition">
                                            <td class="px-5 py-4">
                                                <div class="flex items-center gap-3">
                                                    <c:if test="${not empty m.posterUrl}">
                                                        <img src="<c:out value='${m.posterUrl}'/>" alt="" class="h-12 w-8 rounded object-cover shadow">
                                                    </c:if>
                                                    <div>
                                                        <div class="font-bold text-white"><c:out value="${m.title}"/></div>
                                                        <div class="text-xs text-zinc-500"><c:out value="${m.slug}"/></div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-5 py-4 text-zinc-300"><c:out value="${m.director}"/></td>
                                            <td class="px-5 py-4 text-zinc-300">
                                                <c:out value="${m.durationMinutes}"/> mins <span class="ml-1 rounded bg-white/10 px-1.5 py-0.5 text-[10px] font-bold text-zinc-300"><c:out value="${m.ageRating}"/></span>
                                            </td>
                                            <td class="px-5 py-4">
                                                <span class="rounded-full px-2.5 py-1 text-xs font-bold ${m.status == 'NOW_SHOWING' ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30' : m.status == 'COMING_SOON' ? 'bg-sky-500/20 text-sky-400 border border-sky-500/30' : 'bg-zinc-500/20 text-zinc-400 border border-zinc-500/30'}">
                                                    <c:out value="${m.status}"/>
                                                </span>
                                            </td>
                                            <td class="whitespace-nowrap px-5 py-4 text-right">
                                                <div class="flex items-center justify-end gap-3">
                                                    <a href="<c:url value='/admin/movies?action=edit&id=${m.id}'/>" class="font-bold text-sky-400 hover:text-sky-300 transition">Edit</a>
                                                    <form method="post" action="<c:url value='/admin/movies'/>" onsubmit="return confirm('Archive this movie?');" class="inline">
                                                        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                                                        <input type="hidden" name="_method" value="DELETE">
                                                        <input type="hidden" name="id" value="<c:out value='${m.id}'/>">
                                                        <button type="submit" class="font-bold text-rose-400 hover:text-rose-300 transition">Delete</button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="px-6 py-20 text-center">
                            <div class="text-4xl text-zinc-600">🎬</div>
                            <h2 class="mt-4 text-lg font-black text-white">No movies found</h2>
                            <p class="mt-2 text-sm text-zinc-500">Try adjusting your search query or add a new movie catalog entry.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
