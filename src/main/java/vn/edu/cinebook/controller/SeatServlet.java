package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.dto.BookingDraft;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

public class SeatServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long showtimeId = Validation.positiveLong(request.getParameter("showtimeId"), "Showtime");
        BookingDraft draft = (BookingDraft) request.getSession().getAttribute("bookingDraft");
        String token = draft != null && draft.showtimeId() == showtimeId ? draft.holdToken() : null;
        request.setAttribute("showtime", ServiceRegistry.CATALOG.showtime(showtimeId));
        request.setAttribute("movie", ServiceRegistry.CATALOG.movie(
                ServiceRegistry.CATALOG.showtime(showtimeId).movieId()));
        request.setAttribute("seats", ServiceRegistry.BOOKING.seats(showtimeId, token));
        request.setAttribute("holdToken", token);
        if (token != null) {
            request.setAttribute("hold", ServiceRegistry.BOOKING.activeHold(token));
        }
        List<Long> selectedSeatIds = token == null
                ? List.of()
                : ServiceRegistry.BOOKING.activeHold(token).seats().stream().map(seat -> seat.id()).toList();
        request.setAttribute("selectedSeatIds", selectedSeatIds);
        request.setAttribute("selectedSeatIdsCsv", selectedSeatIds.stream()
                .map(String::valueOf).collect(Collectors.joining(",")));
        WebUtil.view(request, response, "booking/seats");
    }
}
