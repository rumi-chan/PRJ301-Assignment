<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="successMessage" value="${not empty requestScope.success ? requestScope.success : (flashType == 'success' ? flashMessage : sessionScope.flashSuccess)}"/>
<c:set var="errorMessage" value="${not empty requestScope.error ? requestScope.error : (flashType == 'error' ? flashMessage : sessionScope.flashError)}"/>
<c:set var="infoMessage" value="${not empty requestScope.message ? requestScope.message : ((empty flashType or flashType == 'info') ? flashMessage : null)}"/>
<c:if test="${not empty successMessage or not empty errorMessage or not empty infoMessage}">
    <div class="fixed inset-x-4 top-20 z-[60] mx-auto max-w-xl space-y-2">
        <c:if test="${not empty successMessage}">
            <div role="alert" data-auto-dismiss class="flex items-start gap-3 rounded-xl border border-emerald-400/20 bg-emerald-950/95 p-4 text-emerald-100 shadow-2xl transition duration-300">
                <span class="mt-0.5 text-emerald-400">✓</span>
                <p class="flex-1 text-sm"><c:out value="${successMessage}"/></p>
                <button data-dismiss type="button" class="text-emerald-300/70 hover:text-white" aria-label="Dismiss">×</button>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div role="alert" class="flex items-start gap-3 rounded-xl border border-rose-400/20 bg-rose-950/95 p-4 text-rose-100 shadow-2xl">
                <span class="mt-0.5 text-rose-400">!</span>
                <p class="flex-1 text-sm"><c:out value="${errorMessage}"/></p>
                <button data-dismiss type="button" class="text-rose-300/70 hover:text-white" aria-label="Dismiss">×</button>
            </div>
        </c:if>
        <c:if test="${not empty infoMessage}">
            <div role="alert" data-auto-dismiss class="flex items-start gap-3 rounded-xl border border-sky-400/20 bg-sky-950/95 p-4 text-sky-100 shadow-2xl transition duration-300">
                <span class="mt-0.5 text-sky-400">i</span>
                <p class="flex-1 text-sm"><c:out value="${infoMessage}"/></p>
                <button data-dismiss type="button" class="text-sky-300/70 hover:text-white" aria-label="Dismiss">×</button>
            </div>
        </c:if>
    </div>
</c:if>
