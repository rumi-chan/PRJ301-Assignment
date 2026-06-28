<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="Banner Management"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="banners"/></jsp:include>
        <div class="min-w-0">
            <c:choose>
                <c:when test="${mode == 'form'}">
                    <div class="flex items-center justify-between mb-6">
                        <div>
                            <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                            <h1 class="mt-2 text-3xl font-black sm:text-4xl"><c:out value="${formTitle}"/></h1>
                        </div>
                        <a href="<c:url value='/admin/banners'/>" class="rounded-xl border border-white/10 px-4 py-2 text-sm font-bold hover:bg-white/5">← Back to list</a>
                    </div>
                    <form action="<c:url value='/admin/banners'/>" method="post" class="space-y-6 rounded-2xl border border-white/10 bg-white/[.025] p-6">
                        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>"/>
                        <c:if test="${not empty banner}"><input type="hidden" name="id" value="${banner.id}"/></c:if>
                        <div class="grid gap-6 sm:grid-cols-2">
                            <div>
                                <label class="block text-sm font-semibold mb-2">Title *</label>
                                <input required name="title" value="<c:out value='${banner.title}'/>" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Subtitle</label>
                                <input name="subtitle" value="<c:out value='${banner.subtitle}'/>" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Image URL *</label>
                                <input required name="imageUrl" value="<c:out value='${banner.imageUrl}'/>" placeholder="https://..." class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Target Link URL</label>
                                <input name="targetUrl" value="<c:out value='${banner.targetUrl}'/>" placeholder="/movies/1 or https://..." class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Placement</label>
                                <select name="placement" class="w-full rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
                                    <option value="HOME_HERO" ${banner.placement == 'HOME_HERO' ? 'selected' : ''}>HOME_HERO</option>
                                    <option value="HOME_PROMO" ${banner.placement == 'HOME_PROMO' ? 'selected' : ''}>HOME_PROMO</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Display Order</label>
                                <input type="number" required name="displayOrder" value="${not empty banner ? banner.displayOrder : 1}" class="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Starts At</label>
                                <input type="datetime-local" name="startsAt" value="<c:out value='${banner.startsAt}'/>" class="w-full rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold mb-2">Ends At</label>
                                <input type="datetime-local" name="endsAt" value="<c:out value='${banner.endsAt}'/>" class="w-full rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-sm outline-none focus:border-rose-500">
                            </div>
                        </div>
                        <div class="flex items-center gap-3 pt-4">
                            <input type="checkbox" id="active" name="active" ${empty banner || banner.active ? 'checked' : ''} class="h-5 w-5 rounded border-white/10 bg-black/40 text-rose-600 focus:ring-rose-500">
                            <label for="active" class="text-sm font-semibold">Active (Show on front page)</label>
                        </div>
                        <div class="pt-4 border-t border-white/10 flex justify-end gap-3">
                            <a href="<c:url value='/admin/banners'/>" class="rounded-xl border border-white/10 px-6 py-3 text-sm font-bold hover:bg-white/5">Cancel</a>
                            <button type="submit" class="rounded-xl bg-rose-600 px-6 py-3 text-sm font-black text-white hover:bg-rose-500">Save Banner</button>
                        </div>
                    </form>
                </c:when>
                <c:otherwise>
                    <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                        <div>
                            <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                            <h1 class="mt-2 text-3xl font-black sm:text-4xl">Banner management</h1>
                            <p class="mt-2 max-w-2xl text-zinc-500">Manage promotional banners and hero slides displayed on the front page.</p>
                        </div>
                        <a href="?action=create" class="rounded-xl bg-rose-600 px-5 py-3 text-center text-sm font-black hover:bg-rose-500">Add new</a>
                    </div>
                    <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[680px] text-left text-sm">
                                <thead>
                                    <tr class="border-b border-white/10 bg-white/5 text-xs uppercase tracking-wider text-zinc-400">
                                        <th class="p-4">Image</th>
                                        <th class="p-4">Title</th>
                                        <th class="p-4">Placement</th>
                                        <th class="p-4">Order</th>
                                        <th class="p-4">Status</th>
                                        <th class="p-4 text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-white/5">
                                    <c:forEach var="item" items="${banners}">
                                        <tr class="hover:bg-white/[.02]">
                                            <td class="p-4"><img src="<c:out value='${item.imageUrl}'/>" class="h-12 w-20 object-cover rounded-lg border border-white/10" alt=""></td>
                                            <td class="p-4 font-semibold"><c:out value="${item.title}"/></td>
                                            <td class="p-4 text-zinc-400"><c:out value="${item.placement}"/></td>
                                            <td class="p-4"><c:out value="${item.displayOrder}"/></td>
                                            <td class="p-4">
                                                <span class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold ${item.active ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-zinc-500/10 text-zinc-400 border border-zinc-500/20'}">
                                                    ${item.active ? 'Active' : 'Inactive'}
                                                </span>
                                            </td>
                                            <td class="p-4 text-right space-x-2">
                                                <a href="?action=edit&id=${item.id}" class="rounded-lg border border-white/10 px-3 py-1.5 text-xs font-bold hover:bg-white/5">Edit</a>
                                                <form action="<c:url value='/admin/banners'/>" method="post" class="inline" onsubmit="return confirm('Delete this banner?');">
                                                    <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>"/>
                                                    <input type="hidden" name="_method" value="DELETE"/>
                                                    <input type="hidden" name="id" value="${item.id}"/>
                                                    <button type="submit" class="rounded-lg bg-rose-600/20 text-rose-400 border border-rose-500/30 px-3 py-1.5 text-xs font-bold hover:bg-rose-600/30">Delete</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty banners}">
                                        <tr><td colspan="6" class="p-8 text-center text-zinc-500">No banners found. Click "Add new" to create one.</td></tr>
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
