<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/errors/error.jsp">
    <jsp:param name="code" value="500"/><jsp:param name="heading" value="The projector needs a moment."/><jsp:param name="message" value="Something unexpected happened on our side. Please try again shortly."/>
</jsp:include>
