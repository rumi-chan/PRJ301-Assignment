<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Create account"/>
</jsp:include>
<section class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-2xl">
        <div class="text-center">
            <p class="text-sm font-black uppercase tracking-[.3em] text-rose-500">Membership is free</p>
            <h1 class="mt-3 text-4xl font-black tracking-tight sm:text-5xl">Make movie night yours.</h1>
            <p class="mx-auto mt-4 max-w-lg text-zinc-400">Create an account for faster checkout, booking history, watchlists, and electronic tickets.</p>
        </div>
        <form action="<c:url value='/auth/register'/>" method="post" class="glass-panel mt-10 grid gap-5 rounded-3xl p-6 sm:grid-cols-2 sm:p-8">
            <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
            <c:if test="${not empty error}"><p class="rounded-xl border border-rose-500/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-300 sm:col-span-2"><c:out value="${error}"/></p></c:if>
            <div class="sm:col-span-2">
                <label for="fullName" class="mb-2 block text-sm font-semibold text-zinc-300">Full name</label>
                <input id="fullName" name="fullName" autocomplete="name" required maxlength="100" value="<c:out value='${fullName}'/>"
                       class="w-full rounded-xl border border-white/10 bg-black/25 px-4 py-3 outline-none focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10" placeholder="Nguyen Minh Anh">
                <c:if test="${not empty errors.fullName}"><p class="mt-2 text-xs text-rose-400"><c:out value="${errors.fullName}"/></p></c:if>
            </div>
            <div class="sm:col-span-2">
                <label for="email" class="mb-2 block text-sm font-semibold text-zinc-300">Email address</label>
                <input id="email" name="email" type="email" autocomplete="email" required maxlength="160" value="<c:out value='${email}'/>"
                       class="w-full rounded-xl border border-white/10 bg-black/25 px-4 py-3 outline-none focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10" placeholder="you@example.com">
                <c:if test="${not empty errors.email}"><p class="mt-2 text-xs text-rose-400"><c:out value="${errors.email}"/></p></c:if>
            </div>
            <div class="sm:col-span-2">
                <label for="phone" class="mb-2 block text-sm font-semibold text-zinc-300">Phone number <span class="text-zinc-600">(optional)</span></label>
                <input id="phone" name="phone" autocomplete="tel" maxlength="30" value="<c:out value='${phone}'/>"
                       class="w-full rounded-xl border border-white/10 bg-black/25 px-4 py-3 outline-none focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10" placeholder="+84 90 123 4567">
            </div>
            <div>
                <label for="password" class="mb-2 block text-sm font-semibold text-zinc-300">Password</label>
                <input id="password" name="password" type="password" autocomplete="new-password" required minlength="8"
                       class="w-full rounded-xl border border-white/10 bg-black/25 px-4 py-3 outline-none focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10" placeholder="8+ characters">
                <c:if test="${not empty errors.password}"><p class="mt-2 text-xs text-rose-400"><c:out value="${errors.password}"/></p></c:if>
            </div>
            <div>
                <label for="confirmPassword" class="mb-2 block text-sm font-semibold text-zinc-300">Confirm password</label>
                <input id="confirmPassword" name="passwordConfirmation" type="password" autocomplete="new-password" required minlength="8"
                       class="w-full rounded-xl border border-white/10 bg-black/25 px-4 py-3 outline-none focus:border-rose-500 focus:ring-4 focus:ring-rose-500/10" placeholder="Repeat password">
                <c:if test="${not empty errors.confirmPassword}"><p class="mt-2 text-xs text-rose-400"><c:out value="${errors.confirmPassword}"/></p></c:if>
            </div>
            <label class="flex items-start gap-3 text-sm text-zinc-400 sm:col-span-2">
                <input type="checkbox" name="termsAccepted" value="true" required class="mt-0.5 h-4 w-4 rounded border-white/20 bg-zinc-900 text-rose-600 focus:ring-rose-500">
                <span>I agree to the demo terms and understand this project uses simulated payments.</span>
            </label>
            <button class="rounded-xl bg-rose-600 px-5 py-3.5 font-black text-white shadow-lg shadow-rose-950/50 hover:bg-rose-500 sm:col-span-2">Create my account</button>
            <p class="text-center text-sm text-zinc-500 sm:col-span-2">Already a member? <a href="<c:url value='/auth/login'/>" class="font-bold text-rose-400 hover:text-rose-300">Sign in</a></p>
        </form>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
