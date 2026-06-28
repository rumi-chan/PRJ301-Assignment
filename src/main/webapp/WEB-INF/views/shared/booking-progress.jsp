<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="mb-8 overflow-x-auto">
    <ol class="mx-auto flex min-w-[34rem] max-w-3xl items-center" aria-label="Booking progress">
        <c:forEach var="label" items="${['Showtime','Seats','Combos','Checkout']}" varStatus="loop">
            <c:set var="stepNumber" value="${loop.index + 1}"/>
            <li class="flex flex-1 items-center ${loop.last ? '' : 'after:mx-3 after:h-px after:flex-1 after:bg-white/10'}">
                <span class="flex items-center gap-2">
                    <span class="grid h-8 w-8 place-items-center rounded-full text-xs font-black ${stepNumber <= param.step ? 'bg-rose-600 text-white shadow-lg shadow-rose-950/50' : 'border border-white/10 bg-zinc-900 text-zinc-500'}">${stepNumber}</span>
                    <span class="text-xs font-semibold ${stepNumber <= param.step ? 'text-zinc-100' : 'text-zinc-600'}"><c:out value="${label}"/></span>
                </span>
            </li>
        </c:forEach>
    </ol>
</div>
