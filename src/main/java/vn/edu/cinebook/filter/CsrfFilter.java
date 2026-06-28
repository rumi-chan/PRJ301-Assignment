package vn.edu.cinebook.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;

public class CsrfFilter implements Filter {
    private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS");

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) request;
        if (SAFE_METHODS.contains(http.getMethod())) {
            chain.doFilter(request, response);
            return;
        }
        HttpSession session = http.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute("csrfToken");
        String supplied = http.getHeader("X-CSRF-Token");
        if (supplied == null || supplied.isBlank()) {
            supplied = http.getParameter("_csrf");
        }
        if (expected == null || supplied == null || !constantTimeEquals(expected, supplied)) {
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token.");
            return;
        }
        chain.doFilter(request, response);
    }

    private boolean constantTimeEquals(String expected, String supplied) {
        if (expected.length() != supplied.length()) {
            return false;
        }
        int difference = 0;
        for (int index = 0; index < expected.length(); index++) {
            difference |= expected.charAt(index) ^ supplied.charAt(index);
        }
        return difference == 0;
    }
}
