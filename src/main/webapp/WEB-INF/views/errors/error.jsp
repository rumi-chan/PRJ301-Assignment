<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="${param.code} error"/></jsp:include>
<section class="mx-auto flex min-h-[68vh] max-w-4xl items-center px-4 py-14 sm:px-6 lg:px-8">
    <div class="w-full text-center">
        <p class="bg-gradient-to-r from-rose-500 to-amber-300 bg-clip-text text-8xl font-black leading-none text-transparent sm:text-9xl"><c:out value="${param.code}"/></p>
        <h1 class="mt-6 text-3xl font-black sm:text-5xl"><c:out value="${param.heading}"/></h1>
        <p class="mx-auto mt-4 max-w-xl text-lg leading-8 text-zinc-500"><c:out value="${not empty requestScope.errorMessage ? requestScope.errorMessage : param.message}"/></p>
        <c:if test="${not empty requestScopeId}"><p class="mt-4 font-mono text-xs text-zinc-700">Reference: <c:out value="${requestScopeId}"/></p></c:if>
        <div class="mt-9 flex flex-col justify-center gap-3 sm:flex-row">
            <a href="<c:url value='/movies'/>" class="rounded-xl bg-rose-600 px-6 py-3 font-black hover:bg-rose-500">Browse movies</a>
            <button type="button" onclick="history.back()" class="rounded-xl border border-white/10 px-6 py-3 font-black hover:bg-white/5">Go back</button>
        </div>
    </div>
</section>
<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
