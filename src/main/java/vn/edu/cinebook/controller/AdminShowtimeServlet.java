package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.MovieFormat;
import vn.edu.cinebook.model.Showtime;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.DisplayUtil;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@WebServlet("/admin/showtimes")
public class AdminShowtimeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("edit".equals(action)) {
            long id = Validation.positiveLong(request.getParameter("id"), "Showtime ID");
            request.setAttribute("showtime", ServiceRegistry.CATALOG.adminShowtime(id));
        }
        prepare(request);
        WebUtil.view(request, response, "admin/showtimes");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String method = request.getParameter("_method");
        if ("DELETE".equalsIgnoreCase(method) || "delete".equals(request.getParameter("action"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Showtime ID");
            ServiceRegistry.CATALOG.deleteShowtime(id);
            WebUtil.flash(request, "success", "Showtime cancelled successfully.");
            WebUtil.redirect(request, response, "/admin/showtimes");
            return;
        }

        try {
            Showtime showtime = readShowtime(request);
            if (showtime.id() == 0) {
                ServiceRegistry.CATALOG.createShowtime(showtime);
                WebUtil.flash(request, "success", "Showtime created successfully.");
            } else {
                ServiceRegistry.CATALOG.updateShowtime(showtime);
                WebUtil.flash(request, "success", "Showtime updated successfully.");
            }
            WebUtil.redirect(request, response, "/admin/showtimes");
        } catch (Exception exception) {
            String msg = exception instanceof AppException ae ? ae.getMessage() : "An error occurred saving the showtime.";
            request.setAttribute("error", msg);
            prepare(request);
            WebUtil.view(request, response, "admin/showtimes");
        }
    }

    private void prepare(HttpServletRequest request) {
        request.setAttribute("adminSection", "showtimes");
        request.setAttribute("items", ServiceRegistry.CATALOG.adminShowtimes());
        request.setAttribute("movies", ServiceRegistry.CATALOG.searchMovies("all", null, null, null));
        request.setAttribute("auditoriums", ServiceRegistry.CATALOG.activeAuditoriums());
        request.setAttribute("formats", MovieFormat.values());
    }

    private Showtime readShowtime(HttpServletRequest request) {
        long id = optionalId(request.getParameter("id"));
        long movieId = Validation.positiveLong(request.getParameter("movieId"), "Movie");
        long auditoriumId = Validation.positiveLong(request.getParameter("auditoriumId"), "Auditorium");
        LocalDateTime startsLocal = LocalDateTime.parse(Validation.required(request.getParameter("startsAt"), "Start time", 30));
        int duration = (int) Validation.positiveLong(request.getParameter("durationMinutes"), "Duration");
        if (duration > 600) {
            throw new AppException(400, "Duration must be 600 minutes or less.");
        }
        BigDecimal basePrice = money(request.getParameter("basePrice"), "Base price");
        MovieFormat format = MovieFormat.valueOf(Validation.required(request.getParameter("format"), "Format", 10));
        String status = Validation.required(request.getParameter("status"), "Status", 20);
        if (!"SCHEDULED".equals(status) && !"CANCELLED".equals(status) && !"COMPLETED".equals(status)) {
            throw new AppException(400, "Showtime status is invalid.");
        }
        var startsAt = startsLocal.atZone(DisplayUtil.DISPLAY_ZONE).toInstant();
        var endsAt = startsLocal.plusMinutes(duration).atZone(DisplayUtil.DISPLAY_ZONE).toInstant();
        var salesOpenAt = startsLocal.minusDays(7).atZone(DisplayUtil.DISPLAY_ZONE).toInstant();
        return new Showtime(id, movieId, "", 0, "", auditoriumId, "", format,
                startsAt, endsAt, salesOpenAt, basePrice, status, 0);
    }

    private long optionalId(String value) {
        return value == null || value.isBlank() ? 0 : Validation.positiveLong(value, "Showtime ID");
    }

    private BigDecimal money(String value, String field) {
        try {
            BigDecimal amount = new BigDecimal(Validation.required(value, field, 30));
            if (amount.signum() < 0) {
                throw new NumberFormatException();
            }
            return amount;
        } catch (NumberFormatException exception) {
            throw new AppException(400, field + " is invalid.");
        }
    }
}
