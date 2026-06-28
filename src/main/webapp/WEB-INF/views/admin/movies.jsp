<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="Movie Management"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="movies"/></jsp:include>
        <div class="min-w-0">
            <c:choose>
                <c:when test="${mode == 'form'}">
                    <div class="flex items-center justify-between mb-6">
                        <div>
                            <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                            <h1 class="mt-2 text-3xl font-black sm:text-4xl"><c:out value="${formTitle}"/></h1>
                        </div>
                        <a href="<c:url value='/admin/movies'/>" class="rounded-xl border border-white/10 px-4 py-2 text-sm font-bold hover:bg-white/5">← Back to catalog</a>
                    </div>
                    <form action="<c:url value='/admin/movies'/>" method="post" class="space-y-6 rounded-2xl border border-white/10 bg-white/[.025] p-6">
                        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>"/>
                        <c:if test="${not empty movie}"><input type="hidden" name="id" value="${movie.id}"/></c:if>
                        <div class="grid gap-6 sm:grid-cols-2">
                            <div>
                                <label class="block text-sm font-semibold mb-2">Movie Title *</label>
                                <input required name="title" value="<c:out value='${movie.title}'/>" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">URL Slug (Leave blank to auto-generate)</label>
                                <input name="slug" value="<c:out value='${movie.slug}'/>" placeholder="e.g. dune-part-two" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Director *</label>
                                <input required name="director" value="<c:out value='${movie.director}'/>" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Cast (Actors)</label>
                                <input name="cast" value="<c:out value='${movie.cast}'/>" placeholder="Timothée Chalamet, Zendaya..." class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Duration (minutes) *</label>
                                <input type="number" required min="1" max="600" name="durationMinutes" value="${not empty movie ? movie.durationMinutes : 120}" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Age Rating *</label>
                                <input required name="ageRating" value="${not empty movie ? movie.ageRating : 'T18'}" placeholder="PG-13, T18, P..." class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Release Date *</label>
                                <input type="date" required name="releaseDate" value="<c:out value='${movie.releaseDate}'/>" class="w-full rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Status *</label>
                                <select name="status" class="w-full rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
                                    <c:forEach var="st" items="${allStatuses}">
                                        <option value="${st.name()}" ${movie.status == st ? 'selected' : ''}>${st.name()}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="sm:col-span-2">
                                <label class="block text-sm font-semibold mb-2">Synopsis *</label>
                                <textarea required rows="4" name="synopsis" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500"><c:out value='${movie.synopsis}'/></textarea>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Poster URL *</label>
                                <input required name="posterUrl" value="<c:out value='${movie.posterUrl}'/>" placeholder="https://..." class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Backdrop URL</label>
                                <input name="backdropUrl" value="<c:out value='${movie.backdropUrl}'/>" placeholder="https://..." class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div class="sm:col-span-2">
                                <label class="block text-sm font-semibold mb-2">Trailer URL (YouTube / MP4)</label>
                                <input name="trailerUrl" value="<c:out value='${movie.trailerUrl}'/>" placeholder="https://youtube.com/..." class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                        </div>

                        <div class="border-t border-white/10 pt-4">
                            <label class="block text-sm font-semibold mb-3">Genres</label>
                            <div class="flex flex-wrap gap-4">
                                <c:forEach var="g" items="${allGenres}">
                                    <label class="inline-flex items-center gap-2 text-sm">
                                        <input type="checkbox" name="genres" value="${g}" ${not empty movie && movie.genres.contains(g) ? 'checked' : ''} class="h-4 w-4 rounded border-white/10 bg-black/40 text-rose-600 focus:ring-rose-500">
                                        <c:out value="${g}"/>
                                    </label>
                                </c:forEach>
                            </div>
                        </div>

                        <div class="border-t border-white/10 pt-4">
                            <label class="block text-sm font-semibold mb-3">Formats</label>
                            <div class="flex flex-wrap gap-4">
                                <c:forEach var="f" items="${allFormats}">
                                    <label class="inline-flex items-center gap-2 text-sm">
                                        <input type="checkbox" name="formats" value="${f.label}" ${not empty movie && movie.formats.contains(f) ? 'checked' : ''} class="h-4 w-4 rounded border-white/10 bg-black/40 text-rose-600 focus:ring-rose-500">
                                        <c:out value="${f.label}"/>
                                    </label>
                                </c:forEach>
                            </div>
                        </div>

                        <div class="pt-4 border-t border-white/10 flex justify-end gap-3">
                            <a href="<c:url value='/admin/movies'/>" class="rounded-xl border border-white/10 px-6 py-3 text-sm font-bold hover:bg-white/5">Cancel</a>
                            <button type="submit" class="rounded-xl bg-rose-600 px-6 py-3 text-sm font-black text-white hover:bg-rose-500">Save Movie</button>
                        </div>
                    </form>
                </c:when>
                <c:otherwise>
                    <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                        <div>
                            <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                            <h1 class="mt-2 text-3xl font-black sm:text-4xl">Movie management</h1>
                            <p class="mt-2 max-w-2xl text-zinc-500">Create, update, publish, and retire titles in the cinema catalog.</p>
                        </div>
                        <a href="?action=create" class="rounded-xl bg-rose-600 px-5 py-3 text-center text-sm font-black hover:bg-rose-500">Add new title</a>
                    </div>
                    <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[680px] text-left text-sm">
                                <thead>
                                    <tr class="border-b border-white/10 bg-white/5 text-xs uppercase tracking-wider text-zinc-400">
                                        <th class="p-4">Poster</th>
                                        <th class="p-4">Title / Info</th>
                                        <th class="p-4">Director</th>
                                        <th class="p-4">Genres</th>
                                        <th class="p-4">Status</th>
                                        <th class="p-4 text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-white/5">
                                    <c:forEach var="item" items="${movies}">
                                        <tr class="hover:bg-white/[.02]">
                                            <td class="p-4"><img src="<c:out value='${item.posterUrl}'/>" class="h-16 w-12 object-cover rounded shadow border border-white/10" alt=""></td>
                                            <td class="p-4">
                                                <div class="font-bold text-base"><c:out value="${item.title}"/></div>
                                                <div class="text-xs text-zinc-400 mt-1">${item.durationMinutes} mins · <span class="border border-white/10 px-1.5 py-0.5 rounded">${item.ageRating}</span></div>
                                            </td>
                                            <td class="p-4 text-zinc-300"><c:out value="${item.director}"/></td>
                                            <td class="p-4 text-xs text-zinc-400 max-w-xs truncate"><c:forEach var="g" items="${item.genres}" varStatus="s"><c:out value="${g}"/>${!s.last ? ', ' : ''}</c:forEach></td>
                                            <td class="p-4">
                                                <span class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold ${item.status.name() == 'NOW_SHOWING' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : (item.status.name() == 'COMING_SOON' ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20' : 'bg-zinc-500/10 text-zinc-400 border border-zinc-500/20')}">
                                                    ${item.status.name()}
                                                </span>
                                            </td>
                                            <td class="p-4 text-right space-x-2">
                                                <a href="?action=edit&id=${item.id}" class="rounded-lg border border-white/10 px-3 py-1.5 text-xs font-bold hover:bg-white/5">Edit</a>
                                                <form action="<c:url value='/admin/movies'/>" method="post" class="inline" onsubmit="return confirm('Retire this movie?');">
                                                    <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>"/>
                                                    <input type="hidden" name="_method" value="DELETE"/>
                                                    <input type="hidden" name="id" value="${item.id}"/>
                                                    <button type="submit" class="rounded-lg bg-rose-600/20 text-rose-400 border border-rose-500/30 px-3 py-1.5 text-xs font-bold hover:bg-rose-600/30">Delete</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty movies}">
                                        <tr><td colspan="6" class="p-8 text-center text-zinc-500">No movies found. Click "Add new title" to create one.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
