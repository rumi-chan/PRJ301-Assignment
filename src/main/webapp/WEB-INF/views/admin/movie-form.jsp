<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="${not empty movie ? 'Edit Movie' : 'Add Movie'}"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="movies"/>
        </jsp:include>
        <div class="min-w-0">
            <div class="flex items-center justify-between border-b border-white/10 pb-5">
                <div>
                    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                    <h1 class="mt-2 text-3xl font-black text-white sm:text-4xl">
                        <c:out value="${not empty movie ? 'Edit Movie' : 'Add New Movie'}"/>
                    </h1>
                </div>
                <a href="<c:url value='/admin/movies'/>" class="rounded-lg border border-white/10 px-4 py-2.5 text-sm font-bold text-zinc-300 hover:bg-white/5 transition">Back to List</a>
            </div>

            <c:if test="${not empty error}">
                <div class="mt-6 rounded-xl bg-rose-500/10 border border-rose-500/20 p-4 text-sm text-rose-400 font-semibold">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <form method="post" action="<c:url value='/admin/movies'/>" class="mt-8 space-y-6 rounded-2xl border border-white/10 bg-white/[.025] p-6 shadow-xl sm:p-8">
                <input type="hidden" name="_csrf" value="${csrfToken}">
                <c:if test="${not empty movie}">
                    <input type="hidden" name="id" value="${movie.id}">
                </c:if>

                <div class="grid gap-6 sm:grid-cols-2">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Movie Title *</label>
                        <input type="text" name="title" value="${movie.title}" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">URL Slug *</label>
                        <input type="text" name="slug" value="${movie.slug}" required placeholder="e.g. echoes-of-hoi-an" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                </div>

                <div class="grid gap-6 sm:grid-cols-3">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Director *</label>
                        <input type="text" name="director" value="${movie.director}" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Duration (Minutes) *</label>
                        <input type="number" name="durationMinutes" value="${not empty movie ? movie.durationMinutes : 120}" required min="1" max="600" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Age Rating *</label>
                        <input type="text" name="ageRating" value="${not empty movie ? movie.ageRating : 'T13'}" required placeholder="e.g. P, T13, T16, T18" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                </div>

                <div class="grid gap-6 sm:grid-cols-2">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Release Date *</label>
                        <input type="date" name="releaseDate" value="${not empty movie ? movie.releaseDate : ''}" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Status *</label>
                        <select name="status" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                            <c:forEach var="st" items="${allStatuses}">
                                <option value="${st}" ${not empty movie && movie.status == st ? 'selected' : ''} class="bg-zinc-900 text-white"><c:out value="${st}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Cast Members</label>
                    <input type="text" name="cast" value="${movie.cast}" placeholder="Comma separated actors..." class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                </div>

                <div>
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Synopsis *</label>
                    <textarea name="synopsis" rows="4" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition"><c:out value="${movie.synopsis}"/></textarea>
                </div>

                <div class="grid gap-6 sm:grid-cols-3">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Poster URL</label>
                        <input type="text" name="posterUrl" value="${movie.posterUrl}" placeholder="https://..." class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Backdrop URL</label>
                        <input type="text" name="backdropUrl" value="${movie.backdropUrl}" placeholder="https://..." class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Trailer Youtube URL</label>
                        <input type="text" name="trailerUrl" value="${movie.trailerUrl}" placeholder="https://..." class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                </div>

                <div class="border-t border-white/10 pt-6">
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400 mb-3">Genres</label>
                    <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
                        <c:forEach var="g" items="${allGenres}">
                            <label class="flex items-center gap-2 text-sm text-zinc-300 cursor-pointer">
                                <input type="checkbox" name="genreIds" value="${g.id}" class="rounded border-white/20 bg-black/40 text-rose-600 focus:ring-rose-500">
                                <span><c:out value="${g.name}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <div class="border-t border-white/10 pt-6">
                    <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400 mb-3">Available Formats</label>
                    <div class="flex flex-wrap gap-6">
                        <c:forEach var="fmt" items="${allFormats}">
                            <label class="flex items-center gap-2 text-sm text-zinc-300 cursor-pointer">
                                <input type="checkbox" name="formats" value="${fmt}" class="rounded border-white/20 bg-black/40 text-rose-600 focus:ring-rose-500">
                                <span class="font-bold"><c:out value="${fmt.label}"/></span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <div class="border-t border-white/10 pt-6 flex justify-end gap-4">
                    <a href="<c:url value='/admin/movies'/>" class="rounded-xl border border-white/10 px-6 py-3 text-sm font-bold text-zinc-300 hover:bg-white/5 transition">Cancel</a>
                    <button type="submit" class="rounded-xl bg-rose-600 px-8 py-3 text-sm font-black text-white hover:bg-rose-500 transition shadow-lg shadow-rose-600/30">Save Movie</button>
                </div>
            </form>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
