package cinebook.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class AuthenticationFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) request;
        if (http.getSession(false) == null
                || http.getSession(false).getAttribute("currentUser") == null) {
            String target = http.getRequestURI();
            if (http.getQueryString() != null) {
                target += "?" + http.getQueryString();
            }
            ((HttpServletResponse) response).sendRedirect(
                    http.getContextPath() + "/login?returnTo="
                            + URLEncoder.encode(target, StandardCharsets.UTF_8));
            return;
        }
        chain.doFilter(request, response);
    }
}
