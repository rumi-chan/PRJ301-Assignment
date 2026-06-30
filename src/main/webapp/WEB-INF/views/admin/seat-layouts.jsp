<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="Seat Layouts"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="seat-layouts"/></jsp:include>
        <div class="min-w-0">
            <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                <div><p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p><h1 class="mt-2 text-3xl font-black sm:text-4xl">Seat Layouts</h1><p class="mt-2 max-w-2xl text-zinc-500">Select a showroom to edit its seat layout.</p></div>
            </div>
            <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                <div class="overflow-x-auto">
                    <table class="w-full min-w-[680px] text-left text-sm">
                        <thead class="bg-black/20 text-xs uppercase tracking-wider text-zinc-500">
                            <tr>
                                <th class="px-5 py-4 font-bold">ID</th>
                                <th class="px-5 py-4 font-bold">Showroom Name</th>
                                <th class="px-5 py-4 font-bold">Type</th>
                                <th class="px-5 py-4 font-bold">Capacity</th>
                                <th class="px-5 py-4 text-right font-bold">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/5">
                            <c:forEach var="item" items="${showrooms}">
                                <tr class="hover:bg-white/[.025]">
                                    <td class="max-w-xs truncate px-5 py-4 text-zinc-300"><c:out value="${item.id}"/></td>
                                    <td class="max-w-xs truncate px-5 py-4 text-zinc-300 font-bold"><c:out value="${item.name}"/></td>
                                    <td class="max-w-xs truncate px-5 py-4 text-zinc-300"><c:out value="${item.type}"/></td>
                                    <td class="max-w-xs truncate px-5 py-4 text-zinc-300"><c:out value="${item.capacity}"/></td>
                                    <td class="whitespace-nowrap px-5 py-4 text-right">
                                        <a href="${pageContext.request.contextPath}/admin/seats/view?auditoriumId=${item.id}" class="rounded-lg border border-white/10 bg-black/20 px-4 py-2 text-sm font-bold text-sky-400 hover:bg-white/5 hover:text-sky-300 transition-colors">Edit Layout</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty showrooms}">
                                <tr>
                                    <td colspan="5" class="px-6 py-20 text-center text-zinc-500">No showrooms available.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
