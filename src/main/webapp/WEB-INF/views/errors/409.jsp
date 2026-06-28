<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/errors/error.jsp">
    <jsp:param name="code" value="409"/><jsp:param name="heading" value="Someone beat you to that seat."/><jsp:param name="message" value="The booking changed while you were choosing. Refresh the seat map and pick from the latest availability."/>
</jsp:include>
