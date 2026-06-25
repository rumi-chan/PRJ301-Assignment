<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Sign in"/>
</jsp:include>
<section class="mx-auto grid min-h-[72vh] max-w-7xl items-center gap-12 px-4 py-12 sm:px-6 lg:grid-cols-2 lg:px-8">
    <div class="hidden lg:block">
        <p class="text-sm font-black uppercase tracking-[.3em] text-rose-500">Tonight starts here</p>
        <h1 class="mt-4 max-w-xl text-6xl font-black leading-[.98] tracking-tight">Your next great story is one sign-in away.</h1>
        <p class="mt-6 max-w-lg text-lg leading-8 text-zinc-400">Pick the screen, claim the perfect seat, and keep every ticket in one place.</p>
        <div class="mt-10 flex gap-8 text-sm text-zinc-500">
            <span><strong class="block text-2xl text-white">7 min</strong> secure seat hold</span>
            <span><strong class="block text-2xl text-white">25</strong> booking features</span>
            <span><strong class="block text-2xl text-white">1 tap</strong> ticket access</span>
        </div>
    </div>
    <div class="glass-panel mx-auto w-full max-w-md rounded-3xl p-6 sm:p-8">
        <div>
            <p class="text-sm font-bold text-rose-400">Welcome back</p>
            <h2 class="mt-1 text-3xl font-black tracking-tight">Sign in to CineBook</h2>
            <p class="mt-2 text-sm text-zinc-500">Use your email and password to continue.</p>
        </div>
        <form action="<c:url value='/auth/login'/>" method="post" class="mt-8 space-y-5">
            <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
            <input type="hidden" name="returnTo" value="<c:out value='${empty returnTo ? param.returnTo : returnTo}'/>">
            <c:if test="${not empty error}"><p class="rounded-xl border border-rose-500/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-300"><c:out value="${error}"/></p></c:if>
            <div>
                <label for="email" class="mb-2 block text-sm font-semibold text-zinc-300">Email address</label>
                <input id="email" name="email" type="email" autocomplete="email" required value="<c:out value='${not empty email ? email : param.email}'/>"
                       class="w-full rounded-xl border border-white/10 bg-black/25 px-4 py-3 text-white outline-none placeholder:text-zinc-600 focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10" placeholder="you@example.com">
                <c:if test="${not empty errors.email}"><p class="mt-2 text-xs text-rose-400"><c:out value="${errors.email}"/></p></c:if>
            </div>
            <div>
                <div class="mb-2 flex items-center justify-between">
                    <label for="password" class="text-sm font-semibold text-zinc-300">Password</label>
                    <span class="text-xs text-zinc-600">Minimum 8 characters</span>
                </div>
                <input id="password" name="password" type="password" autocomplete="current-password" required
                       class="w-full rounded-xl border border-white/10 bg-black/25 px-4 py-3 text-white outline-none placeholder:text-zinc-600 focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10" placeholder="••••••••">
                <c:if test="${not empty errors.password}"><p class="mt-2 text-xs text-rose-400"><c:out value="${errors.password}"/></p></c:if>
            </div>
            <label class="flex items-center gap-3 text-sm text-zinc-400">
                <input type="checkbox" name="rememberMe" value="true" class="h-4 w-4 rounded border-white/20 bg-zinc-900 text-rose-600 focus:ring-rose-500">
                Keep me signed in on this device
            </label>
            <button class="w-full rounded-xl bg-rose-600 px-5 py-3.5 font-black text-white shadow-lg shadow-rose-950/50 transition hover:bg-rose-500 focus:outline-none focus:ring-4 focus:ring-rose-500/25">Sign in</button>
        </form>
        <p class="mt-6 text-center text-sm text-zinc-500">New to CineBook? <a href="<c:url value='/auth/register'/>" class="font-bold text-rose-400 hover:text-rose-300">Create an account</a></p>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
