package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;

public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getSession().getAttribute("currentUser") != null) {
            WebUtil.redirect(request, response, "/movies");
            return;
        }
        request.setAttribute("returnTo", safeReturnTo(request, request.getParameter("returnTo")));
        WebUtil.view(request, response, "auth/login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User user = ServiceRegistry.AUTH.login(
                    request.getParameter("email"), request.getParameter("password"));
            request.changeSessionId();
            request.getSession().setAttribute("currentUser", user);
            request.getSession().setAttribute("userId", user.id());
            WebUtil.flash(request, "success", "Welcome back, " + user.fullName() + ".");
            String returnTo = safeReturnTo(request, request.getParameter("returnTo"));
            if (returnTo != null) {
                response.sendRedirect(returnTo);
            } else {
                WebUtil.redirect(request, response, user.isAdmin() ? "/admin" : "/movies");
            }
        } catch (AppException exception) {
            response.setStatus(exception.getStatusCode());
            request.setAttribute("error", exception.getMessage());
            request.setAttribute("email", request.getParameter("email"));
            request.setAttribute("returnTo", safeReturnTo(request, request.getParameter("returnTo")));
            WebUtil.view(request, response, "auth/login");
        }
    }

    private String safeReturnTo(HttpServletRequest request, String value) {
        if (value == null || value.isBlank() || value.contains("\r") || value.contains("\n")) {
            return null;
        }
        String contextPath = request.getContextPath();
        if (!value.startsWith(contextPath + "/") || value.startsWith("//")) {
            return null;
        }
        return value;
    }
}
