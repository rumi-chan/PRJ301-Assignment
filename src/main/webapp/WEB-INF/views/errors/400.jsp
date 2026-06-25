<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/errors/error.jsp">
    <jsp:param name="code" value="400"/><jsp:param name="heading" value="That request missed the mark."/><jsp:param name="message" value="Some information was missing or invalid. Check your input and try again."/>
</jsp:include>
