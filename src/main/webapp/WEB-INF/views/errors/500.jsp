<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<jsp:include page="/WEB-INF/views/errors/error.jsp">
    <jsp:param name="code" value="500"/><jsp:param name="heading" value="The projector needs a moment."/><jsp:param name="message" value="Something unexpected happened on our side. Please try again shortly."/>
</jsp:include>
<pre style="color:red; z-index:9999; position:relative;"><% 
Throwable t = exception != null ? exception : (Throwable) request.getAttribute("jakarta.servlet.error.exception");
if (t != null) t.printStackTrace(new java.io.PrintWriter(out)); 
%></pre>
