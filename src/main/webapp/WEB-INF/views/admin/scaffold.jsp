<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/shared/header.jsp"><jsp:param name="title" value="${param.title}"/><jsp:param name="active" value="admin"/></jsp:include>
<section class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
    <div class="grid gap-7 lg:grid-cols-[220px_1fr]">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="section" value="${param.section}"/></jsp:include>
        <div class="min-w-0">
            <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
                <div><p class="text-sm font-black uppercase tracking-[.25em] text-rose-500">Administration</p><h1 class="mt-2 text-3xl font-black sm:text-4xl"><c:out value="${param.title}"/></h1><p class="mt-2 max-w-2xl text-zinc-500"><c:out value="${param.description}"/></p></div>
                <c:if test="${param.readOnly != 'true'}"><a href="?action=create" class="rounded-xl bg-rose-600 px-5 py-3 text-center text-sm font-black hover:bg-rose-500">Add new</a></c:if>
            </div>
            <div class="mt-8 overflow-hidden rounded-2xl border border-white/10 bg-white/[.025]">
                <div class="flex flex-col gap-3 border-b border-white/10 p-4 sm:flex-row">
                    <form method="get" class="flex min-w-0 flex-1 gap-2"><input name="q" value="<c:out value='${param.q}'/>" placeholder="Search records…" class="min-w-0 flex-1 rounded-lg border border-white/10 bg-black/20 px-4 py-2.5 text-sm outline-none focus:border-rose-500"><button class="rounded-lg border border-white/10 px-4 py-2 text-sm font-bold hover:bg-white/5">Search</button></form>
                    <span class="self-center text-xs text-zinc-600"><c:out value="${empty totalCount ? 0 : totalCount}"/> records</span>
                </div>
                <c:choose>
                    <c:when test="${not empty items}">
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[680px] text-left text-sm">
                                <thead class="bg-black/20 text-xs uppercase tracking-wider text-zinc-500"><tr><c:forEach var="column" items="${columns}"><th class="px-5 py-4 font-bold"><c:out value="${column.label}"/></th></c:forEach><th class="px-5 py-4 text-right font-bold">Actions</th></tr></thead>
                                <tbody class="divide-y divide-white/5">
                                    <c:forEach var="item" items="${items}">
                                        <tr class="hover:bg-white/[.025]"><c:forEach var="column" items="${columns}"><td class="max-w-xs truncate px-5 py-4 text-zinc-300"><c:out value="${item[column.key]}"/></td></c:forEach><td class="whitespace-nowrap px-5 py-4 text-right"><a href="?action=edit&id=<c:out value='${item.id}'/>" class="font-bold text-sky-400 hover:text-sky-300">Edit</a><c:if test="${param.readOnly != 'true'}"><button type="button" data-id="<c:out value='${item.id}'/>" data-confirm="Delete this record?" class="ml-4 font-bold text-rose-400 hover:text-rose-300 delete-btn">Delete</button></c:if></td></tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="px-6 py-20 text-center"><div class="text-4xl">◫</div><h2 class="mt-4 text-lg font-black">No records to display</h2><p class="mt-2 text-sm text-zinc-600">This scaffold is ready for its controller data.</p></div>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="mt-5 rounded-xl border border-amber-400/10 bg-amber-400/5 p-4 text-xs leading-5 text-amber-200/70">Template module: navigation and presentation are ready; persistence actions depend on the corresponding admin controller.</div>
        </div>
    </div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const deleteBtns = document.querySelectorAll('.delete-btn');
    deleteBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            if (confirm(this.getAttribute('data-confirm') || 'Are you sure?')) {
                const id = this.getAttribute('data-id');
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = ''; // current URL

                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';
                form.appendChild(actionInput);

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = id;
                form.appendChild(idInput);

                const csrfInput = document.createElement('input');
                csrfInput.type = 'hidden';
                csrfInput.name = '_csrf';
                csrfInput.value = '<c:out value="${csrfToken}"/>';
                form.appendChild(csrfInput);

                document.body.appendChild(form);
                form.submit();
            }
        });
    });
});
</script>

<jsp:include page="/WEB-INF/views/shared/footer.jsp"/>
