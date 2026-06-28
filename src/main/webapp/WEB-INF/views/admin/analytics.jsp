<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="Revenue Analytics"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="analytics"/></jsp:include>
        <div class="min-w-0 space-y-10">
            <div>
                <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Reporting Surface</p>
                <h1 class="mt-2 text-3xl font-black sm:text-4xl text-white">Revenue Analytics</h1>
                <p class="mt-2 text-zinc-500">Explore financial performance across movies, cinema locations, and recent dates.</p>
            </div>

            <!-- Revenue by Movie Table -->
            <div class="overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                <div class="border-b border-white/10 bg-black/20 px-6 py-4">
                    <h2 class="text-lg font-black text-white">Top Movies by Revenue</h2>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-black/10 text-xs uppercase tracking-wider text-zinc-500">
                            <tr>
                                <th class="px-6 py-3 font-bold">Movie Title</th>
                                <th class="px-6 py-3 font-bold text-right">Bookings</th>
                                <th class="px-6 py-3 font-bold text-right">Tickets Sold</th>
                                <th class="px-6 py-3 font-bold text-right">Total Revenue</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/5">
                            <c:forEach var="item" items="${movieReports}">
                                <tr class="hover:bg-white/[.025]">
                                    <td class="px-6 py-4 font-bold text-white"><c:out value="${item.name}"/></td>
                                    <td class="px-6 py-4 text-right text-zinc-300"><fmt:formatNumber value="${item.totalBookings}"/></td>
                                    <td class="px-6 py-4 text-right text-zinc-300"><fmt:formatNumber value="${item.totalTickets}"/></td>
                                    <td class="px-6 py-4 text-right font-black text-emerald-400"><fmt:formatNumber value="${item.totalRevenue}" type="currency" currencySymbol="₫"/></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty movieReports}">
                                <tr><td colspan="4" class="px-6 py-8 text-center text-zinc-600">No revenue data available yet.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Revenue by Cinema Table -->
            <div class="overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                <div class="border-b border-white/10 bg-black/20 px-6 py-4">
                    <h2 class="text-lg font-black text-white">Revenue by Cinema Location</h2>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-black/10 text-xs uppercase tracking-wider text-zinc-500">
                            <tr>
                                <th class="px-6 py-3 font-bold">Cinema Name</th>
                                <th class="px-6 py-3 font-bold text-right">Bookings</th>
                                <th class="px-6 py-3 font-bold text-right">Tickets Sold</th>
                                <th class="px-6 py-3 font-bold text-right">Total Revenue</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/5">
                            <c:forEach var="item" items="${cinemaReports}">
                                <tr class="hover:bg-white/[.025]">
                                    <td class="px-6 py-4 font-bold text-white"><c:out value="${item.name}"/></td>
                                    <td class="px-6 py-4 text-right text-zinc-300"><fmt:formatNumber value="${item.totalBookings}"/></td>
                                    <td class="px-6 py-4 text-right text-zinc-300"><fmt:formatNumber value="${item.totalTickets}"/></td>
                                    <td class="px-6 py-4 text-right font-black text-emerald-400"><fmt:formatNumber value="${item.totalRevenue}" type="currency" currencySymbol="₫"/></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty cinemaReports}">
                                <tr><td colspan="4" class="px-6 py-8 text-center text-zinc-600">No cinema revenue data available yet.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Daily Revenue Table -->
            <div class="overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                <div class="border-b border-white/10 bg-black/20 px-6 py-4">
                    <h2 class="text-lg font-black text-white">Daily Revenue Breakdown (Last 30 Days)</h2>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-black/10 text-xs uppercase tracking-wider text-zinc-500">
                            <tr>
                                <th class="px-6 py-3 font-bold">Date</th>
                                <th class="px-6 py-3 font-bold text-right">Bookings</th>
                                <th class="px-6 py-3 font-bold text-right">Tickets Sold</th>
                                <th class="px-6 py-3 font-bold text-right">Total Revenue</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/5">
                            <c:forEach var="item" items="${dailyReports}">
                                <tr class="hover:bg-white/[.025]">
                                    <td class="px-6 py-4 font-bold text-zinc-300"><c:out value="${item.name}"/></td>
                                    <td class="px-6 py-4 text-right text-zinc-300"><fmt:formatNumber value="${item.totalBookings}"/></td>
                                    <td class="px-6 py-4 text-right text-zinc-300"><fmt:formatNumber value="${item.totalTickets}"/></td>
                                    <td class="px-6 py-4 text-right font-black text-emerald-400"><fmt:formatNumber value="${item.totalRevenue}" type="currency" currencySymbol="₫"/></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty dailyReports}">
                                <tr><td colspan="4" class="px-6 py-8 text-center text-zinc-600">No daily revenue records found in the past 30 days.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
