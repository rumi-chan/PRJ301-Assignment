<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/errors/error.jsp">
    <jsp:param name="code" value="403"/><jsp:param name="heading" value="This screening is invite-only."/><jsp:param name="message" value="You do not have permission to view this page. Sign in with an authorized account."/>
</jsp:include>
