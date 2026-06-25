<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<c:set var="viewer" value="${sessionScope.currentUser}" scope="request"/>
<!DOCTYPE html>
<html lang="en" class="h-full bg-zinc-950">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#09090b">
    <title><c:out value="${empty param.title ? 'CineBook' : param.title}"/> · CineBook</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { cinema: { red: "#e11d48", gold: "#f5c451", ink: "#09090b" } },
                    fontFamily: { sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"] }
                }
            }
        };
    </script>
    <link rel="stylesheet" href="<c:url value='/assets/css/app.css'/>">
</head>
<body class="min-h-full overflow-x-hidden font-sans text-zinc-100 antialiased">
<div class="min-h-screen">
    <header class="sticky top-0 z-50 border-b border-white/10 bg-zinc-950/85 backdrop-blur-xl">
        <nav class="mx-auto flex max-w-7xl items-center justify-between px-4 py-3 sm:px-6 lg:px-8" aria-label="Main navigation">
            <a href="<c:url value='/movies'/>" class="group flex items-center gap-3" aria-label="CineBook home">
                <span class="grid h-10 w-10 place-items-center rounded-xl bg-rose-600 shadow-lg shadow-rose-950/50 transition group-hover:rotate-3">
                    <svg viewBox="0 0 24 24" class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
                        <path d="M4 7h16v12H4zM7 4l2 3m3-3 2 3m3-3 2 3M8 11v4m4-4v4m4-4v4"/>
                    </svg>
                </span>
                <span>
                    <span class="block text-lg font-black tracking-tight">Cine<span class="text-rose-500">Book</span></span>
                    <span class="block text-[10px] uppercase tracking-[.24em] text-zinc-500">Your seat awaits</span>
                </span>
            </a>

            <div class="hidden items-center gap-1 lg:flex">
                <a href="<c:url value='/movies'/>" class="rounded-lg px-3 py-2 text-sm font-medium ${param.active == 'movies' ? 'bg-white/10 text-white' : 'text-zinc-400 hover:bg-white/5 hover:text-white'}">Movies</a>
                <a href="<c:url value='/cinemas'/>" class="rounded-lg px-3 py-2 text-sm font-medium ${param.active == 'cinemas' ? 'bg-white/10 text-white' : 'text-zinc-400 hover:bg-white/5 hover:text-white'}">Cinemas</a>
                <c:if test="${not empty viewer}">
                    <a href="<c:url value='/profile/bookings'/>" class="rounded-lg px-3 py-2 text-sm font-medium ${param.active == 'bookings' ? 'bg-white/10 text-white' : 'text-zinc-400 hover:bg-white/5 hover:text-white'}">My bookings</a>
                    <a href="<c:url value='/profile/watchlist'/>" class="rounded-lg px-3 py-2 text-sm font-medium ${param.active == 'watchlist' ? 'bg-white/10 text-white' : 'text-zinc-400 hover:bg-white/5 hover:text-white'}">Watchlist</a>
                </c:if>
                <c:if test="${viewer.role == 'ADMIN'}">
                    <a href="<c:url value='/admin'/>" class="rounded-lg px-3 py-2 text-sm font-medium ${param.active == 'admin' ? 'bg-white/10 text-white' : 'text-zinc-400 hover:bg-white/5 hover:text-white'}">Admin</a>
                </c:if>
            </div>

            <div class="hidden items-center gap-3 lg:flex">
                <c:choose>
                    <c:when test="${not empty viewer}">
                        <div class="text-right">
                            <p class="max-w-40 truncate text-sm font-semibold"><c:out value="${empty viewer.fullName ? viewer.name : viewer.fullName}"/></p>
                            <p class="text-xs text-zinc-500"><c:out value="${viewer.role}"/></p>
                        </div>
                        <form action="<c:url value='/auth/logout'/>" method="post">
                            <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                            <button class="rounded-xl border border-white/10 px-4 py-2 text-sm font-semibold text-zinc-300 hover:border-white/20 hover:bg-white/5">Sign out</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <a href="<c:url value='/auth/login'/>" class="px-3 py-2 text-sm font-semibold text-zinc-300 hover:text-white">Sign in</a>
                        <a href="<c:url value='/auth/register'/>" class="rounded-xl bg-rose-600 px-4 py-2 text-sm font-bold text-white shadow-lg shadow-rose-950/40 hover:bg-rose-500">Join CineBook</a>
                    </c:otherwise>
                </c:choose>
            </div>

            <button type="button" data-mobile-menu-button aria-expanded="false" aria-controls="mobile-menu" class="grid h-10 w-10 place-items-center rounded-lg border border-white/10 text-zinc-300 lg:hidden">
                <span class="sr-only">Toggle navigation</span>
                <svg viewBox="0 0 24 24" class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
            </button>
        </nav>
        <div id="mobile-menu" data-mobile-menu class="hidden border-t border-white/10 px-4 py-4 lg:hidden">
            <div class="mx-auto grid max-w-7xl gap-2">
                <a href="<c:url value='/movies'/>" class="rounded-lg px-3 py-2 hover:bg-white/5">Movies</a>
                <a href="<c:url value='/cinemas'/>" class="rounded-lg px-3 py-2 hover:bg-white/5">Cinemas</a>
                <c:if test="${not empty viewer}">
                    <a href="<c:url value='/profile/bookings'/>" class="rounded-lg px-3 py-2 hover:bg-white/5">My bookings</a>
                    <a href="<c:url value='/profile/watchlist'/>" class="rounded-lg px-3 py-2 hover:bg-white/5">Watchlist</a>
                    <c:if test="${viewer.role == 'ADMIN'}"><a href="<c:url value='/admin'/>" class="rounded-lg px-3 py-2 hover:bg-white/5">Admin</a></c:if>
                    <form action="<c:url value='/auth/logout'/>" method="post" class="mt-2">
                        <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                        <button class="w-full rounded-lg border border-white/10 px-3 py-2 text-left">Sign out</button>
                    </form>
                </c:if>
                <c:if test="${empty viewer}">
                    <a href="<c:url value='/auth/login'/>" class="rounded-lg px-3 py-2 hover:bg-white/5">Sign in</a>
                    <a href="<c:url value='/auth/register'/>" class="rounded-lg bg-rose-600 px-3 py-2 text-center font-bold">Join CineBook</a>
                </c:if>
            </div>
        </div>
    </header>
    <main>
        <jsp:include page="/WEB-INF/views/shared/alerts.jsp"/>
