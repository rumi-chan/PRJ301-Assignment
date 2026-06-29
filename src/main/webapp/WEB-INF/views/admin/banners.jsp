<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Banner Management"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="banners"/>
        </jsp:include>
        <div class="min-w-0">
            <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                <div>
                    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                    <h1 class="mt-2 text-3xl font-black sm:text-4xl">Homepage Banners</h1>
                    <p class="mt-2 max-w-2xl text-zinc-500">Manage promotional hero sliders and spotlight promotional cards.</p>
                </div>
                <a href="<c:url value='/admin/banners?action=create'/>" class="rounded-xl bg-rose-600 px-5 py-3 text-center text-sm font-black text-white hover:bg-rose-500 transition shadow-lg shadow-rose-600/30">Add New Banner</a>
            </div>

            <c:if test="${not empty flashMessage}">
                <div class="mt-6 rounded-xl bg-emerald-500/10 border border-emerald-500/20 p-4 text-sm text-emerald-400 font-semibold">
                    <c:out value="${flashMessage}"/>
                </div>
            </c:if>

            <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025] shadow-xl">
                <div class="flex items-center justify-between border-b border-white/10 p-4">
                    <span class="text-sm font-bold text-white">All Banners</span>
                    <span class="text-xs font-semibold text-zinc-400"><c:out value="${totalCount}"/> banners total</span>
                </div>

                <c:choose>
                    <c:when test="${not empty items}">
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[700px] text-left text-sm">
                                <thead class="bg-black/40 text-xs uppercase tracking-wider text-zinc-400">
                                    <tr>
                                        <th class="px-5 py-4 font-bold">Preview / Title</th>
                                        <th class="px-5 py-4 font-bold">Placement</th>
                                        <th class="px-5 py-4 font-bold">Order</th>
                                        <th class="px-5 py-4 font-bold">Status</th>
                                        <th class="px-5 py-4 text-right font-bold">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-white/5">
                                    <c:forEach var="b" items="${items}">
                                        <tr class="hover:bg-white/[.025] transition">
                                            <td class="px-5 py-4">
                                                <div class="flex items-center gap-3">
                                                    <c:if test="${not empty b.imageUrl}">
                                                        <img src="<c:out value='${b.imageUrl}'/>" alt="" class="h-10 w-20 rounded object-cover shadow border border-white/10">
                                                    </c:if>
                                                    <div>
                                                        <div class="font-bold text-white"><c:out value="${b.title}"/></div>
                                                        <div class="text-xs text-zinc-500 truncate max-w-[200px]"><c:out value="${b.subtitle}"/></div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-5 py-4">
                                                <span class="rounded bg-white/10 px-2 py-1 text-xs font-bold text-zinc-300">
                                                    <c:out value="${b.placement}"/>
                                                </span>
                                            </td>
                                            <td class="px-5 py-4 font-bold text-zinc-300">#<c:out value="${b.displayOrder}"/></td>
                                            <td class="px-5 py-4">
                                                <span class="rounded-full px-2.5 py-1 text-xs font-bold ${b.active ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30' : 'bg-rose-500/20 text-rose-400 border border-rose-500/30'}">
                                                    <c:out value="${b.active ? 'ACTIVE' : 'INACTIVE'}"/>
                                                </span>
                                            </td>
                                            <td class="whitespace-nowrap px-5 py-4 text-right">
                                                <div class="flex items-center justify-end gap-3">
                                                    <a href="<c:url value='/admin/banners?action=edit&id=${b.id}'/>" class="font-bold text-sky-400 hover:text-sky-300 transition">Edit</a>
                                                    <form method="post" action="<c:url value='/admin/banners'/>" onsubmit="return confirm('Delete this banner?');" class="inline">
                                                        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                                                        <input type="hidden" name="_method" value="DELETE">
                                                        <input type="hidden" name="id" value="<c:out value='${b.id}'/>">
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
                            <div class="text-4xl text-zinc-600">🖼️</div>
                            <h2 class="mt-4 text-lg font-black text-white">No promotional banners found</h2>
                            <p class="mt-2 text-sm text-zinc-500">Click 'Add New Banner' above to set up homepage slider cards.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
