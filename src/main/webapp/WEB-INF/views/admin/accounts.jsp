<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="Customer Accounts"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="accounts"/></jsp:include>
        <div class="min-w-0">
            <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                <div>
                    <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                    <h1 class="mt-2 text-3xl font-black sm:text-4xl">Customer Accounts</h1>
                    <p class="mt-2 max-w-2xl text-zinc-500">Review customer details and lock or unlock access when needed.</p>
                </div>
            </div>

            <c:if test="${not empty flashMessage}">
                <div class="mt-6 rounded-2xl border border-emerald-500/20 bg-emerald-500/10 p-4 text-sm font-bold text-emerald-300">
                    <c:out value="${flashMessage}"/>
                </div>
            </c:if>

            <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                <div class="flex flex-col gap-3 border-b border-white/10 p-4 sm:flex-row">
                    <form method="get" action="<c:url value='/admin/accounts'/>" class="flex min-w-0 flex-1 gap-2">
                        <input name="q" value="<c:out value='${param.q}'/>" placeholder="Search by name, email or phone…" class="min-w-0 flex-1 rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 text-sm text-white outline-none focus:border-rose-500">
                        <button type="submit" class="rounded-lg border border-white/10 px-4 py-2 text-sm font-bold hover:bg-white/5">Search</button>
                    </form>
                    <span class="self-center text-xs text-zinc-600"><c:out value="${empty totalCount ? 0 : totalCount}"/> records</span>
                </div>
                <c:choose>
                    <c:when test="${not empty users}">
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[750px] text-left text-sm">
                                <thead class="bg-black/20 text-xs uppercase tracking-wider text-zinc-500">
                                    <tr>
                                        <th class="px-5 py-4 font-bold">User Info</th>
                                        <th class="px-5 py-4 font-bold">Contact</th>
                                        <th class="px-5 py-4 font-bold">Role</th>
                                        <th class="px-5 py-4 font-bold">Status</th>
                                        <th class="px-5 py-4 font-bold">Registered</th>
                                        <th class="px-5 py-4 text-right font-bold">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-white/5">
                                    <c:forEach var="u" items="${users}">
                                        <tr class="hover:bg-white/[.025]">
                                            <td class="px-5 py-4">
                                                <div class="font-bold text-white"><c:out value="${u.fullName}"/></div>
                                                <div class="text-xs text-zinc-500">ID: #<c:out value="${u.id}"/></div>
                                            </td>
                                            <td class="px-5 py-4 text-zinc-300">
                                                <div><c:out value="${u.email}"/></div>
                                                <div class="text-xs text-zinc-500"><c:out value="${empty u.phone ? 'No phone' : u.phone}"/></div>
                                            </td>
                                            <td class="px-5 py-4">
                                                <span class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-bold ${u.role == 'ADMIN' ? 'bg-purple-500/20 text-purple-300 border border-purple-500/30' : 'bg-zinc-800 text-zinc-400'}">
                                                    <c:out value="${u.role}"/>
                                                </span>
                                            </td>
                                            <td class="px-5 py-4">
                                                <c:choose>
                                                    <c:when test="${u.locked}">
                                                        <span class="inline-flex items-center gap-1.5 rounded-full bg-rose-500/20 px-2.5 py-0.5 text-xs font-bold text-rose-300 border border-rose-500/30">
                                                            <span class="h-1.5 w-1.5 rounded-full bg-rose-400"></span> Locked
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-500/20 px-2.5 py-0.5 text-xs font-bold text-emerald-300 border border-emerald-500/30">
                                                            <span class="h-1.5 w-1.5 rounded-full bg-emerald-400"></span> Active
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="px-5 py-4 text-xs text-zinc-400">
                                                <c:out value="${u.createdAtDisplay}"/>
                                            </td>
                                            <td class="whitespace-nowrap px-5 py-4 text-right">
                                                <c:if test="${u.role != 'ADMIN'}">
                                                    <form action="<c:url value='/admin/accounts'/>" method="post" class="inline">
                                                        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                                                        <input type="hidden" name="userId" value="<c:out value='${u.id}'/>">
                                                        <c:choose>
                                                            <c:when test="${u.locked}">
                                                                <input type="hidden" name="lock" value="false">
                                                                <button type="submit" class="rounded-lg border border-emerald-500/30 bg-emerald-500/10 px-3 py-1.5 text-xs font-bold text-emerald-300 hover:bg-emerald-500/20">Unlock</button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <input type="hidden" name="lock" value="true">
                                                                <button type="submit" onclick="return confirm('Lock this account? The user will not be able to sign in.');" class="rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-1.5 text-xs font-bold text-rose-300 hover:bg-rose-500/20">Lock</button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="px-6 py-20 text-center"><div class="text-4xl">👥</div><h2 class="mt-4 text-lg font-black">No accounts found</h2><p class="mt-2 text-sm text-zinc-600">Try adjusting your search criteria.</p></div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
