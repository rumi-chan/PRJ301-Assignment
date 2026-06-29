<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="cb" uri="/WEB-INF/cinebook.tld" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Choose a showtime"/>
</jsp:include>
<section class="mx-auto max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
    <jsp:include page="/WEB-INF/views/shared/booking-progress.jsp"><jsp:param name="step" value="1"/></jsp:include>
    <div class="flex flex-col gap-5 border-b border-white/10 pb-8 sm:flex-row sm:items-center">
        <c:if test="${not empty movie.posterUrl}"><img src="<c:out value='${movie.posterUrl}'/>" alt="" class="h-28 w-20 rounded-xl object-cover poster-shadow"></c:if>
        <div>
            <p class="text-sm font-bold text-rose-400">Choose when and where</p>
            <h1 class="mt-1 text-3xl font-black sm:text-4xl"><c:out value="${empty movie.title ? 'Available showtimes' : movie.title}"/></h1>
            <p class="mt-2 text-sm text-zinc-500">
                <c:if test="${not empty movie.durationMinutes && movie.durationMinutes > 0}"><c:out value="${movie.durationMinutes}"/> min · </c:if>
                <c:out value="${movie.genres}"/>
            </p>
        </div>
    </div>

    <div class="mt-8 overflow-x-auto pb-2">
        <div class="flex min-w-max gap-2">
            <c:forEach var="date" items="${availableDates}">
                <c:url var="dateUrl" value="/booking/showtimes"><c:param name="movieId" value="${movie.id}"/><c:param name="date" value="${date}"/><c:if test="${not empty selectedCinemaId}"><c:param name="cinemaId" value="${selectedCinemaId}"/></c:if></c:url>
                <a href="${dateUrl}" class="min-w-24 rounded-xl border px-4 py-3 text-center ${date == selectedDate || param.date == date ? 'border-rose-500 bg-rose-600 text-white' : 'border-white/10 bg-white/[.025] text-zinc-400 hover:bg-white/5'}">
                    <span class="block text-xs font-bold uppercase"><c:out value="${date}"/></span>
                </a>
            </c:forEach>
            <c:if test="${empty availableDates}">
                <span class="rounded-xl border border-rose-500 bg-rose-600 px-5 py-3 text-sm font-bold">Today</span>
            </c:if>
        </div>
    </div>

    <div class="mt-7 space-y-5">
        <c:choose>
            <c:when test="${not empty cinemas}">
                <c:forEach var="cinema" items="${cinemas}">
                    <article class="rounded-2xl border border-white/10 bg-white/[.025] p-5 sm:p-6">
                        <div class="flex flex-col justify-between gap-2 sm:flex-row sm:items-start">
                            <div><h2 class="text-lg font-black"><c:out value="${cinema.name}"/></h2><p class="mt-1 text-sm text-zinc-500"><c:out value="${cinema.address}"/></p></div>
                            <span class="text-xs font-bold text-zinc-500"><c:out value="${cinema.city}"/></span>
                        </div>
                        <div class="mt-5 flex flex-wrap gap-3">
                            <c:set var="cinemaHasShows" value="false"/>
                            <c:forEach var="showtime" items="${showtimes}">
                                <c:if test="${showtime.cinemaId == cinema.id || showtime.cinema.id == cinema.id}">
                                    <c:set var="cinemaHasShows" value="true"/>
                                    <c:url var="seatUrl" value="/booking/seats"><c:param name="showtimeId" value="${showtime.id}"/></c:url>
                                    <a href="${seatUrl}" class="group min-w-28 rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-center hover:border-rose-500/60 hover:bg-rose-500/10">
                                        <span class="block text-base font-black group-hover:text-rose-300"><c:out value="${cb:dateTime(showtime.startTime)}"/></span>
                                        <span class="mt-1 block text-[11px] text-zinc-500"><c:out value="${showtime.format.label}"/> · <c:out value="${showtime.auditoriumName}"/></span>
                                    </a>
                                </c:if>
                            </c:forEach>
                            <c:if test="${not cinemaHasShows}"><p class="text-sm text-zinc-600">No screenings on this date.</p></c:if>
                        </div>
                    </article>
                </c:forEach>
            </c:when>
            <c:when test="${not empty showtimes}">
                <article class="rounded-2xl border border-white/10 bg-white/[.025] p-6">
                    <h2 class="text-lg font-black">Available screenings</h2>
                    <div class="mt-5 flex flex-wrap gap-3">
                        <c:forEach var="showtime" items="${showtimes}">
                            <c:url var="fallbackSeatUrl" value="/booking/seats"><c:param name="showtimeId" value="${showtime.id}"/></c:url>
                            <a href="${fallbackSeatUrl}" class="min-w-28 rounded-xl border border-white/10 bg-zinc-900 px-4 py-3 text-center hover:border-rose-500/60 hover:bg-rose-500/10">
                                <span class="block font-black"><c:out value="${cb:dateTime(showtime.startTime)}"/></span>
                                <span class="text-[11px] text-zinc-500"><c:out value="${showtime.cinemaName}"/> · <c:out value="${showtime.format.label}"/></span>
                            </a>
                        </c:forEach>
                    </div>
                </article>
            </c:when>
            <c:otherwise>
                <div class="glass-panel rounded-3xl px-6 py-20 text-center"><div class="text-4xl">🕒</div><h2 class="mt-4 text-xl font-black">No showtimes available</h2><p class="mt-2 text-zinc-500">Try another date or cinema.</p><a href="<c:url value='/movies'/>" class="mt-6 inline-flex rounded-xl bg-rose-600 px-5 py-3 text-sm font-black">Choose another movie</a></div>
            </c:otherwise>
        </c:choose>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
