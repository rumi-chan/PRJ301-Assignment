<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/shared/header.jsp">
    <jsp:param name="title" value="Showroom Form"/>
    <jsp:param name="active" value="admin"/>
</jsp:include>

<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
            <jsp:param name="section" value="showrooms"/>
        </jsp:include>
        
        <div class="min-w-0">
            <div class="flex justify-between items-center mb-6">
                <h1 class="text-3xl font-black">${empty showroom ? 'Add New Showroom' : 'Edit Showroom'}</h1>
                <c:if test="${not empty showroom}">
                    <a href="${pageContext.request.contextPath}/admin/seats/view?auditoriumId=${showroom.id}" class="rounded-xl bg-amber-600 px-6 py-3 text-sm font-black hover:bg-amber-500 text-white">Manage Seats</a>
                </c:if>
            </div>
            
            <form action="${pageContext.request.contextPath}/admin/showrooms" method="POST" class="max-w-2xl bg-white/[.025] border border-white/10 p-6 rounded-2xl flex flex-col gap-4">
                <input type="hidden" name="_csrf" value="<c:out value='${csrfToken}'/>">
                <c:if test="${not empty showroom}">
                    <input type="hidden" name="id" value="${showroom.id}"/>
                </c:if>
                
                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">Cinema</label>
                    <select name="cinemaId" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500">
                        <option value="">Select a Cinema</option>
                        <c:forEach var="cinema" items="${cinemas}">
                            <option value="${cinema.id}" ${not empty showroom and showroom.cinemaId == cinema.id ? 'selected' : ''}>${cinema.name} - ${cinema.city}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">Room Name</label>
                    <input type="text" name="name" value="${showroom.name}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500" placeholder="e.g. Hall 1"/>
                </div>
                
                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">Type</label>
                    <input type="text" name="type" value="${showroom.type}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500" placeholder="STANDARD, IMAX, PREMIUM"/>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="font-bold text-sm">Capacity</label>
                    <input type="number" name="capacity" value="${showroom.capacity}" required class="rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 outline-none focus:border-rose-500"/>
                </div>
                
                <div class="flex items-center gap-2 mt-2">
                    <input type="checkbox" name="is_active" id="isActive" ${empty showroom or showroom.active ? 'checked' : ''} class="w-4 h-4"/>
                    <label for="isActive" class="font-bold text-sm">Active</label>
                </div>
                
                <div class="flex gap-4 mt-6">
                    <button type="submit" class="rounded-xl bg-rose-600 px-6 py-3 text-sm font-black hover:bg-rose-500">Save</button>
                    <a href="${pageContext.request.contextPath}/admin/showrooms" class="rounded-xl border border-white/10 px-6 py-3 text-sm font-black hover:bg-white/5">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
