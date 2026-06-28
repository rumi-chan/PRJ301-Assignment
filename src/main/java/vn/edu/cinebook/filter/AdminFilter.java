package vn.edu.cinebook.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.User;

import java.io.IOException;

public class AdminFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) request;
        User user = (User) http.getSession().getAttribute("currentUser");
        if (user == null || !user.isAdmin()) {
            ((HttpServletResponse) response).sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        chain.doFilter(request, response);
    }
}
