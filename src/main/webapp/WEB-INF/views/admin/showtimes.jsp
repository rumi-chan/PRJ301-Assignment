<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="cb" uri="/WEB-INF/cinebook.tld" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Showtime Management"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="showtimes"/>
        </jsp:include>
        <div class="min-w-0 space-y-8">
            <div>
                <p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p>
                <h1 class="mt-2 text-3xl font-black sm:text-4xl">Showtime Management</h1>
                <p class="mt-2 max-w-2xl text-zinc-500">Create daily screening schedules by movie, auditorium, start time, format, and base ticket price.</p>
            </div>

            <c:if test="${not empty flashMessage}"><div class="rounded-xl border border-emerald-500/20 bg-emerald-500/10 p-4 text-sm font-semibold text-emerald-400"><c:out value="${flashMessage}"/></div></c:if>
            <c:if test="${not empty error}"><div class="rounded-xl border border-rose-500/20 bg-rose-500/10 p-4 text-sm font-semibold text-rose-400"><c:out value="${error}"/></div></c:if>

            <form method="post" action="<c:url value='/admin/showtimes'/>" class="rounded-2xl border border-white/10 bg-white/[.025] p-6 shadow-xl">
                <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                <c:if test="${not empty showtime}"><input type="hidden" name="id" value="<c:out value='${showtime.id}'/>"></c:if>
                <div class="grid gap-5 lg:grid-cols-3">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Movie</label>
                        <select name="movieId" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white">
                            <c:forEach var="m" items="${movies}">
                                <option value="${m.id}" ${not empty showtime && showtime.movieId == m.id ? 'selected' : ''} class="bg-zinc-900"><c:out value="${m.title}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Auditorium</label>
                        <select name="auditoriumId" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white">
                            <c:forEach var="a" items="${auditoriums}">
                                <option value="${a.id}" ${not empty showtime && showtime.auditoriumId == a.id ? 'selected' : ''} class="bg-zinc-900"><c:out value="${a.cinemaName}"/> - <c:out value="${a.name}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Format</label>
                        <select name="format" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white">
                            <c:forEach var="fmt" items="${formats}">
                                <option value="${fmt}" ${not empty showtime && showtime.format == fmt ? 'selected' : ''} class="bg-zinc-900"><c:out value="${fmt.label}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Starts At</label>
                        <input type="datetime-local" name="startsAt" value="<c:out value='${not empty showtime ? cb:htmlDateTime(showtime.startsAt) : ""}'/>" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Duration</label>
                        <input type="number" name="durationMinutes" value="<c:out value='${not empty showtime ? showtime.durationMinutes : 120}'/>" min="1" max="600" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Base Price</label>
                        <input type="number" name="basePrice" value="<c:out value='${not empty showtime ? showtime.basePrice : 90000}'/>" min="0" step="1000" required class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-wider text-zinc-400">Status</label>
                        <select name="status" class="mt-2 w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3 text-sm text-white">
                            <option value="SCHEDULED" ${empty showtime || showtime.status == 'SCHEDULED' ? 'selected' : ''} class="bg-zinc-900">SCHEDULED</option>
                            <option value="CANCELLED" ${not empty showtime && showtime.status == 'CANCELLED' ? 'selected' : ''} class="bg-zinc-900">CANCELLED</option>
                            <option value="COMPLETED" ${not empty showtime && showtime.status == 'COMPLETED' ? 'selected' : ''} class="bg-zinc-900">COMPLETED</option>
                        </select>
                    </div>
                </div>
                <div class="mt-6 flex justify-end gap-3 border-t border-white/10 pt-5">
                    <a href="<c:url value='/admin/showtimes'/>" class="rounded-xl border border-white/10 px-5 py-3 text-sm font-bold text-zinc-300 hover:bg-white/5">Reset</a>
                    <button class="rounded-xl bg-rose-600 px-6 py-3 text-sm font-black text-white hover:bg-rose-500">${not empty showtime ? 'Update Showtime' : 'Create Showtime'}</button>
                </div>
            </form>

            <div class="overflow-hidden rounded-2xl border border-white/10 bg-white/[.025] shadow-xl">
                <div class="border-b border-white/10 p-4 text-sm font-bold text-white">Scheduled Showtimes</div>
                <div class="overflow-x-auto">
                    <table class="w-full min-w-[900px] text-left text-sm">
                        <thead class="bg-black/40 text-xs uppercase tracking-wider text-zinc-400"><tr><th class="px-5 py-4">Movie</th><th class="px-5 py-4">Cinema / Room</th><th class="px-5 py-4">Time</th><th class="px-5 py-4">Format</th><th class="px-5 py-4">Price</th><th class="px-5 py-4">Status</th><th class="px-5 py-4 text-right">Actions</th></tr></thead>
                        <tbody class="divide-y divide-white/5">
                            <c:forEach var="s" items="${items}">
                                <tr class="hover:bg-white/[.025]">
                                    <td class="px-5 py-4 font-bold text-white"><c:out value="${s.movieTitle}"/></td>
                                    <td class="px-5 py-4 text-zinc-300"><c:out value="${s.cinemaName}"/> / <c:out value="${s.auditoriumName}"/></td>
                                    <td class="px-5 py-4 text-zinc-300"><c:out value="${cb:dateTime(s.startsAt)}"/></td>
                                    <td class="px-5 py-4 text-zinc-300"><c:out value="${s.format.label}"/></td>
                                    <td class="px-5 py-4 text-zinc-300"><c:out value="${cb:money(s.basePrice)}"/></td>
                                    <td class="px-5 py-4"><span class="rounded-full bg-white/10 px-2.5 py-1 text-xs font-bold text-zinc-300"><c:out value="${s.status}"/></span></td>
                                    <td class="px-5 py-4 text-right">
                                        <a href="<c:url value='/admin/showtimes?action=edit&id=${s.id}'/>" class="font-bold text-sky-400 hover:text-sky-300">Edit</a>
                                        <form method="post" action="<c:url value='/admin/showtimes'/>" class="ml-3 inline" onsubmit="return confirm('Cancel this showtime?');">
                                            <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>"><input type="hidden" name="_method" value="DELETE"><input type="hidden" name="id" value="<c:out value='${s.id}'/>">
                                            <button class="font-bold text-rose-400 hover:text-rose-300">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
