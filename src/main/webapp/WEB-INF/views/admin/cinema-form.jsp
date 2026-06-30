<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Cinema Form"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>

<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="cinemas"/>
        </jsp:include>
        
        <div class="min-w-0">
            <h1 class="text-3xl font-black mb-6">${empty cinema ? 'Add New Cinema' : 'Edit Cinema'}</h1>
            
            <form action="${pageContext.request.contextPath}/admin/cinemas" method="POST" class="max-w-2xl bg-white/[.025] border border-white/10 p-6 rounded-2xl flex flex-col gap-4">
                <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                <c:if test="${not empty cinema}">
                    <input type="hidden" name="id" value="${cinema.id}"/>
                </c:if>
                
                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">Name</label>
                    <input type="text" name="name" value="${cinema.name}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500"/>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">City</label>
                    <input type="text" name="city" value="${cinema.city}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500"/>
                </div>
                
                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">District</label>
                    <input type="text" name="district" value="${cinema.district}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500"/>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">Address</label>
                    <input type="text" name="address" value="${cinema.address}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500"/>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">Phone</label>
                    <input type="text" name="phone" value="${cinema.phone}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500"/>
                </div>
                
                <div class="flex items-center gap-2 mt-2">
                    <input type="checkbox" name="is_active" id="isActive" ${empty cinema or cinema.active ? 'checked' : ''} class="w-4 h-4"/>
                    <label for="isActive" class="font-bold text-sm">Active</label>
                </div>
                
                <div class="flex gap-4 mt-6">
                    <button type="submit" class="rounded-xl bg-rose-600 px-6 py-3 text-sm font-black hover:bg-rose-500">Save</button>
                    <a href="${pageContext.request.contextPath}/admin/cinemas" class="rounded-xl border border-white/10 px-6 py-3 text-sm font-black hover:bg-white/5">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
