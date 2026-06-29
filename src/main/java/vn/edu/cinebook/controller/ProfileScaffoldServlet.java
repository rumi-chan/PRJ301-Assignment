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
import java.util.Set;

@WebServlet({"/profile/watchlist", "/profile/reviews"})
public class ProfileScaffoldServlet extends HttpServlet {
    private static final Set<String> SECTIONS = Set.of("watchlist", "reviews");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String section = request.getServletPath().substring(request.getServletPath().lastIndexOf('/') + 1);
        if (!SECTIONS.contains(section)) {
            throw new AppException(404, "Profile section not found.");
        }
        
        // ĐOẠN CODE NẠP LỊCH SỬ ĐÁNH GIÁ CÁ NHÂN ĐÃ ĐƯỢC THÊM SẴN Ở ĐÂY:
        if ("reviews".equals(section)) {
            HttpSession session = request.getSession(false);
            User currentUser = session == null ? null : (User) session.getAttribute("currentUser");
            if (currentUser != null) {
                request.setAttribute("reviews", ServiceRegistry.REVIEW.getUserReviews(currentUser.id()));
            }
        }
        
        request.setAttribute("profileSection", section);
        WebUtil.view(request, response, "profile/" + section);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        WebUtil.flash(request, "info",
                "This profile module is a navigable scaffold ready for its member implementation.");
        WebUtil.redirect(request, response, request.getServletPath());
    }
}