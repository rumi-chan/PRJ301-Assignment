<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/errors/error.jsp">
    <jsp:param name="code" value="404"/><jsp:param name="heading" value="This scene is not in the cut."/><jsp:param name="message" value="The page may have moved, expired, or never existed."/>
</jsp:include>
