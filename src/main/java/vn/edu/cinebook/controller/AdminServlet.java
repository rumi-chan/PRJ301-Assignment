package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.Review;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class AdminServlet extends HttpServlet {
    private static final Map<String, String> SECTIONS = Map.ofEntries(
            Map.entry("dashboard", "Dashboard"),
            Map.entry("movies", "Movie Management"),
            Map.entry("cinemas", "Cinema Management"),
            Map.entry("showrooms", "Showroom Management"),
            Map.entry("showtimes", "Showtime Management"),
            Map.entry("combos", "Combo Management"),
            Map.entry("seat-layouts", "Seat Layouts"),
            Map.entry("analytics", "Revenue Analytics"),
            Map.entry("accounts", "Customer Accounts"),
            Map.entry("promotions", "Promotions"),
            Map.entry("reviews", "Review Moderation"),
            Map.entry("banners", "Homepage Banners")
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        String section = path == null || path.equals("/") ? "dashboard" : path.substring(1);
        if (!SECTIONS.containsKey(section)) {
            throw new AppException(404, "Admin section not found.");
        }

        // CÁC NHÁNH NẠP DỮ LIỆU THỰC TẾ CHO ADMIN ĐÃ ĐƯỢC THÊM SẴN Ở ĐÂY:
        if ("dashboard".equals(section)) {
            request.setAttribute("dashboardMetrics", ServiceRegistry.ANALYTICS.getDashboardMetrics());
        } else if ("analytics".equals(section)) {
            request.setAttribute("movieReports", ServiceRegistry.ANALYTICS.getMovieRevenueReport());
            request.setAttribute("cinemaReports", ServiceRegistry.ANALYTICS.getCinemaRevenueReport());
            request.setAttribute("dailyReports", ServiceRegistry.ANALYTICS.getDailyRevenueReport(30));
        } else if ("accounts".equals(section)) {
            String q = request.getParameter("q");
            List<User> users = ServiceRegistry.AUTH.searchUsers(q);
            request.setAttribute("users", users);
            request.setAttribute("totalCount", users.size());
        } else if ("reviews".equals(section)) {
            String q = request.getParameter("q");
            List<Review> reviews = ServiceRegistry.REVIEW.searchReviews(q);
            request.setAttribute("reviews", reviews);
            request.setAttribute("totalCount", reviews.size());
        }

        request.setAttribute("adminSection", section);
        request.setAttribute("adminTitle", SECTIONS.get(section));
        request.setAttribute("adminSections", SECTIONS);
        WebUtil.view(request, response, "admin/" + section);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();
        String section = path == null || path.equals("/") ? "dashboard" : path.substring(1);
        if (!SECTIONS.containsKey(section)) {
            throw new AppException(404, "Admin section not found.");
        }

        // CÁC THAO TÁC KHÓA TÀI KHOẢN VÀ DUYỆT BÌNH LUẬN ĐÃ ĐƯỢC XỬ LÝ Ở ĐÂY:
        if ("accounts".equals(section)) {
            String userIdStr = request.getParameter("userId");
            String lockStr = request.getParameter("lock");
            if (userIdStr != null && lockStr != null) {
                long userId = Long.parseLong(userIdStr);
                boolean lock = "true".equals(lockStr);
                ServiceRegistry.AUTH.toggleLockStatus(userId, lock);
                WebUtil.flash(request, "success", lock ? "Account locked successfully." : "Account unlocked successfully.");
            }
            WebUtil.redirect(request, response, "/admin/accounts");
            return;
        } else if ("reviews".equals(section)) {
            long reviewId = Long.parseLong(request.getParameter("reviewId"));
            String status = request.getParameter("status");
            String note = request.getParameter("note");
            User currentUser = (User) request.getSession().getAttribute("currentUser");
            long modId = currentUser != null ? currentUser.id() : 1L;
            ServiceRegistry.REVIEW.moderateReview(reviewId, status, modId, note);
            WebUtil.flash(request, "success", "Review status updated to " + status + ".");
            WebUtil.redirect(request, response, "/admin/reviews");
            return;
        }

        throw new AppException(400, "POST action not supported for this section yet.");
    }
}