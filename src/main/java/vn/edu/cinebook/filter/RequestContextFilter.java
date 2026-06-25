package vn.edu.cinebook.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import vn.edu.cinebook.util.DisplayUtil;

import java.io.IOException;
import java.util.UUID;

public class RequestContextFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) request;
        HttpSession session = http.getSession();
        String csrfToken = (String) session.getAttribute("csrfToken");
        if (csrfToken == null) {
            csrfToken = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", csrfToken);
        }
        String sessionKey = (String) session.getAttribute("bookingSessionKey");
        if (sessionKey == null) {
            sessionKey = UUID.randomUUID().toString();
            session.setAttribute("bookingSessionKey", sessionKey);
        }
        request.setAttribute("csrfToken", csrfToken);
        request.setAttribute("currentUser", session.getAttribute("currentUser"));
        request.setAttribute("displayZone", DisplayUtil.DISPLAY_ZONE.getId());

        Object flashMessage = session.getAttribute("flashMessage");
        if (flashMessage != null) {
            request.setAttribute("flashMessage", flashMessage);
            request.setAttribute("flashType", session.getAttribute("flashType"));
            session.removeAttribute("flashMessage");
            session.removeAttribute("flashType");
        }
        chain.doFilter(request, response);
    }
}
