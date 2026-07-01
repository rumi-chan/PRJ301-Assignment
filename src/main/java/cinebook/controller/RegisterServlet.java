package cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import cinebook.model.User;
import cinebook.service.ServiceRegistry;
import cinebook.util.AppException;
import cinebook.util.WebUtil;

import java.io.IOException;

@WebServlet({"/register", "/auth/register"})
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        WebUtil.view(request, response, "auth/register");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User user = ServiceRegistry.AUTH.register(
                    request.getParameter("fullName"),
                    request.getParameter("email"),
                    request.getParameter("phone"),
                    request.getParameter("password"),
                    request.getParameter("passwordConfirmation"));
            request.changeSessionId();
            request.getSession().setAttribute("currentUser", user);
            request.getSession().setAttribute("userId", user.id());
            WebUtil.flash(request, "success", "Your CineBook account is ready.");
            WebUtil.redirect(request, response, "/movies");
        } catch (AppException exception) {
            response.setStatus(exception.getStatusCode());
            request.setAttribute("error", exception.getMessage());
            request.setAttribute("fullName", request.getParameter("fullName"));
            request.setAttribute("email", request.getParameter("email"));
            request.setAttribute("phone", request.getParameter("phone"));
            WebUtil.view(request, response, "auth/register");
        }
    }
}
