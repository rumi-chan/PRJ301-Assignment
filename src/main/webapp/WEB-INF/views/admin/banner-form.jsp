<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="${not empty banner ? 'Edit Banner' : 'Add Banner'}"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="banners"/>
        </jsp:include>
        <div class="min-w-0">
            <div class="flex items-center justify-between border-b border-white/10 pb-5">
                <div>
                    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                    <h1 class="mt-2 text-3xl font-black text-white sm:text-4xl">
                        <c:out value="${not empty banner ? 'Edit Banner' : 'Add New Banner'}"/>
                    </h1>
                </div>
                <a href="<c:url value='/admin/banners'/>" class="rounded-lg border border-white/10 px-4 py-2.5 text-sm font-bold text-zinc-300 hover:bg-white/5 transition">Back to List</a>
            </div>

            <c:if test="${not empty error}">
                <div class="mt-6 rounded-xl bg-rose-500/10 border border-rose-500/20 p-4 text-sm text-rose-400 font-semibold">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <form method="post" action="<c:url value='/admin/banners'/>" class="mt-8 space-y-6 rounded-2xl border border-white/10 bg-white/[.025] p-6 shadow-xl sm:p-8">
                <input type="hidden" name="_csrf" value="${csrfToken}">
                <c:if test="${not empty banner}">
                    <input type="hidden" name="id" value="${banner.id}">
                </c:if>

                <div class="grid gap-6 sm:grid-cols-2">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Title *</label>
                        <input type="text" name="title" value="${banner.title}" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Subtitle</label>
                        <input type="text" name="subtitle" value="${banner.subtitle}" placeholder="Optional promotional headline..." class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                </div>

                <div class="grid gap-6 sm:grid-cols-2">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Image URL *</label>
                        <input type="text" name="imageUrl" value="${banner.imageUrl}" required placeholder="https://..." class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Target URL (Link onClick)</label>
                        <input type="text" name="targetUrl" value="${banner.targetUrl}" placeholder="/movies/echoes-of-hoi-an" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                </div>

                <div class="grid gap-6 sm:grid-cols-2">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Placement Area *</label>
                        <select name="placement" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                            <option value="HOME_HERO" ${not empty banner && banner.placement == 'HOME_HERO' ? 'selected' : ''} class="bg-zinc-900">HOME_HERO (Top Hero Slider)</option>
                            <option value="HOME_PROMO" ${not empty banner && banner.placement == 'HOME_PROMO' ? 'selected' : ''} class="bg-zinc-900">HOME_PROMO (Spotlight Card)</option>
                            <option value="MOVIE_DETAIL" ${not empty banner && banner.placement == 'MOVIE_DETAIL' ? 'selected' : ''} class="bg-zinc-900">MOVIE_DETAIL (Sidebar Promo)</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Display Order *</label>
                        <input type="number" name="displayOrder" value="${not empty banner ? banner.displayOrder : 1}" required min="1" max="100" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                </div>

                <div class="grid gap-6 sm:grid-cols-2">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Starts At *</label>
                        <input type="datetime-local" name="startsAt" value="${not empty banner ? banner.startsAt.toString().substring(0, 16) : '2026-06-01T00:00'}" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Ends At *</label>
                        <input type="datetime-local" name="endsAt" value="${not empty banner ? banner.endsAt.toString().substring(0, 16) : '2027-01-01T23:59'}" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white outline-none focus:border-rose-500 transition">
                    </div>
                </div>

                <div class="pt-2">
                    <label class="flex items-center gap-3 cursor-pointer">
                        <input type="checkbox" name="active" value="true" ${empty banner || banner.active ? 'checked' : ''} class="h-5 w-5 rounded border-white/20 bg-black/40 text-rose-600 focus:ring-rose-500">
                        <span class="text-sm font-bold text-white">Active (Visible on Website)</span>
                    </label>
                </div>

                <div class="border-t border-white/10 pt-6 flex justify-end gap-4">
                    <a href="<c:url value='/admin/banners'/>" class="rounded-xl border border-white/10 px-6 py-3 text-sm font-bold text-zinc-300 hover:bg-white/5 transition">Cancel</a>
                    <button type="submit" class="rounded-xl bg-rose-600 px-8 py-3 text-sm font-black text-white hover:bg-rose-500 transition shadow-lg shadow-rose-600/30">Save Banner</button>
                </div>
            </form>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
