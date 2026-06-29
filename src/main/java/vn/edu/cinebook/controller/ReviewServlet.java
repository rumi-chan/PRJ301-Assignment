package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;

@WebServlet({"/reviews", "/reviews/*"})
public class ReviewServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            throw new AppException(401, "You must be signed in to submit a review.");
        }

        long movieId = Long.parseLong(request.getParameter("movieId"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        boolean containsSpoiler = "true".equalsIgnoreCase(request.getParameter("containsSpoiler")) || "on".equalsIgnoreCase(request.getParameter("containsSpoiler"));

        try {
            ServiceRegistry.REVIEW.submitReview(currentUser.id(), movieId, rating, title, content, containsSpoiler);
            WebUtil.flash(request, "success", "Your review has been published successfully!");
        } catch (AppException e) {
            WebUtil.flash(request, "error", e.getMessage());
        }

        WebUtil.redirect(request, response, "/movies/" + movieId);
    }
}
