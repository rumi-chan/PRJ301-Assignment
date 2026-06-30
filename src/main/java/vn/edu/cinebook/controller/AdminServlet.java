package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.dao.SeatDAO;
import vn.edu.cinebook.dao.jdbc.JdbcSeatDAO;
import vn.edu.cinebook.model.Auditorium;
import vn.edu.cinebook.model.Cinema;
import vn.edu.cinebook.model.Review;
import vn.edu.cinebook.model.Seat;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@WebServlet({"/admin", "/admin/*"})
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

    private final SeatDAO seatDAO = new JdbcSeatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getPathInfo();

        // 1. Separate routing for seat layout visualization
        if (path != null && path.startsWith("/seats/view")) {
            handleViewSeats(request, response);
            return;
        }

        String section = path == null || path.equals("/") ? "dashboard" : path.substring(1);
        if (!SECTIONS.containsKey(section)) {
            throw new AppException(404, "Admin section not found.");
        }

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
        } else if ("showrooms".equals(section)) {
            List<Auditorium> showrooms = ServiceRegistry.CATALOG.getAllShowroomsForAdmin();
            request.setAttribute("items", showrooms);
            request.setAttribute("columns", List.of(
                Map.of("label", "ID", "key", "id"),
                Map.of("label", "Cinema ID", "key", "cinemaId"),
                Map.of("label", "Name", "key", "name"),
                Map.of("label", "Type", "key", "type"),
                Map.of("label", "Capacity", "key", "capacity"),
                Map.of("label", "Active", "key", "active")
            ));
            String action = request.getParameter("action");
            if ("create".equals(action)) {
                request.setAttribute("cinemas", ServiceRegistry.CATALOG.getAllCinemasForAdmin());
                request.getRequestDispatcher("/WEB-INF/views/admin/showroom-form.jsp").forward(request, response);
                return;
            } else if ("edit".equals(action)) {
                long id = Long.parseLong(request.getParameter("id"));
                Auditorium showroom = ServiceRegistry.CATALOG.getShowroomById(id);
                request.setAttribute("showroom", showroom);
                request.setAttribute("cinemas", ServiceRegistry.CATALOG.getAllCinemasForAdmin());
                request.getRequestDispatcher("/WEB-INF/views/admin/showroom-form.jsp").forward(request, response);
                return;
            }
        } else if ("cinemas".equals(section)) {
            String action = request.getParameter("action");
            if ("create".equals(action)) {
                request.getRequestDispatcher("/WEB-INF/views/admin/cinema-form.jsp").forward(request, response);
                return;
            } else if ("edit".equals(action)) {
                long id = Long.parseLong(request.getParameter("id"));
                Cinema cinema = ServiceRegistry.CATALOG.getCinemaById(id);
                request.setAttribute("cinema", cinema);
                request.getRequestDispatcher("/WEB-INF/views/admin/cinema-form.jsp").forward(request, response);
                return;
            }
            List<Cinema> cinemas = ServiceRegistry.CATALOG.getAllCinemasForAdmin();
            request.setAttribute("items", cinemas);
            request.setAttribute("columns", List.of(
                Map.of("label", "ID", "key", "id"),
                Map.of("label", "Name", "key", "name"),
                Map.of("label", "City", "key", "city"),
                Map.of("label", "Phone", "key", "phone"),
                Map.of("label", "Active", "key", "active")
            ));
        } else if ("seat-layouts".equals(section)) {
            List<Auditorium> showrooms = ServiceRegistry.CATALOG.getAllShowroomsForAdmin();
            request.setAttribute("showrooms", showrooms);
        }

        request.setAttribute("adminSection", section);
        request.setAttribute("adminTitle", SECTIONS.get(section));
        request.setAttribute("adminSections", SECTIONS);
        WebUtil.view(request, response, "admin/" + section);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getPathInfo();
        String action = request.getParameter("action");

        if ("generateSeats".equals(action)) {
            handleGenerateSeats(request, response);
            return;
        } else if ("saveSeatLayout".equals(action)) {
            handleSaveSeatLayout(request, response);
            return;
        }

        String section = path == null || path.equals("/") ? "dashboard" : path.substring(1);
        if (!SECTIONS.containsKey(section)) {
            throw new AppException(404, "Admin section not found.");
        }

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
        } else if ("cinemas".equals(section)) {
            if ("delete".equals(action)) {
                long id = Long.parseLong(request.getParameter("id"));
                ServiceRegistry.CATALOG.deleteCinema(id);
                WebUtil.flash(request, "success", "Cinema archived successfully.");
                WebUtil.redirect(request, response, "/admin/cinemas");
            } else {
                String idStr = request.getParameter("id");
                String name = request.getParameter("name");
                String city = request.getParameter("city");
                String district = request.getParameter("district");
                String address = request.getParameter("address");
                String phone = request.getParameter("phone");
                boolean isActive = request.getParameter("is_active") != null;
                
                if (idStr == null || idStr.isEmpty()) {
                    ServiceRegistry.CATALOG.addCinema(name, city, district, address, phone, isActive);
                    WebUtil.flash(request, "success", "Cinema created successfully.");
                } else {
                    long id = Long.parseLong(idStr);
                    ServiceRegistry.CATALOG.updateCinema(id, name, city, district, address, phone, isActive);
                    WebUtil.flash(request, "success", "Cinema updated successfully.");
                }
                WebUtil.redirect(request, response, "/admin/cinemas");
            }
            return;
        } else if ("showrooms".equals(section)) {
            if ("delete".equals(action)) {
                long id = Long.parseLong(request.getParameter("id"));
                ServiceRegistry.CATALOG.deleteShowroom(id);
                WebUtil.flash(request, "success", "Showroom archived successfully.");
                WebUtil.redirect(request, response, "/admin/showrooms");
            } else {
                String idStr = request.getParameter("id");
                long cinemaId = Long.parseLong(request.getParameter("cinemaId"));
                String name = request.getParameter("name");
                String type = request.getParameter("type");
                int capacity = Integer.parseInt(request.getParameter("capacity"));
                boolean isActive = request.getParameter("is_active") != null;

                if (idStr == null || idStr.isEmpty()) {
                    ServiceRegistry.CATALOG.addShowroom(cinemaId, name, type, capacity, isActive);
                    WebUtil.flash(request, "success", "Showroom created successfully.");
                } else {
                    long id = Long.parseLong(idStr);
                    ServiceRegistry.CATALOG.updateShowroom(id, cinemaId, name, type, capacity, isActive);
                    WebUtil.flash(request, "success", "Showroom updated successfully.");
                }
                WebUtil.redirect(request, response, "/admin/showrooms");
            }
            return;
        }

        throw new AppException(400, "POST action not supported for this section yet.");
    }

    private void handleViewSeats(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("auditoriumId");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                long auditoriumId = Long.parseLong(idStr);
                List<Seat> seats = seatDAO.getSeatsByAuditorium(auditoriumId);
                Auditorium auditorium = ServiceRegistry.CATALOG.getShowroomById(auditoriumId);
                request.setAttribute("seats", seats);
                request.setAttribute("auditorium", auditorium);
                request.getRequestDispatcher("/WEB-INF/views/admin/seat-layout-editor.jsp").forward(request, response);
            } catch (Exception e) {
                WebUtil.redirect(request, response, "/admin/showrooms");
            }
        } else {
            WebUtil.redirect(request, response, "/admin/showrooms");
        }
    }

    private void handleGenerateSeats(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            long auditoriumId = Long.parseLong(request.getParameter("auditoriumId"));
            ServiceRegistry.CATALOG.generateSeats(auditoriumId);
            WebUtil.redirect(request, response, "/admin/seats/view?auditoriumId=" + auditoriumId + "&msg=success");
        } catch (Exception e) {
            WebUtil.redirect(request, response, "/admin/showrooms?msg=error");
        }
    }

    private void handleSaveSeatLayout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            ObjectMapper mapper = new ObjectMapper();
            Map<String, String> payload = mapper.readValue(request.getInputStream(), new TypeReference<Map<String, String>>(){});
            
            Map<Long, String> updates = new HashMap<>();
            for (Map.Entry<String, String> entry : payload.entrySet()) {
                updates.put(Long.parseLong(entry.getKey()), entry.getValue());
            }
            
            ServiceRegistry.CATALOG.updateSeatTypes(updates);
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": true}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        }
    }
}