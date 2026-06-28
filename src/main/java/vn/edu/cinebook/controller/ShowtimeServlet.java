package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.DisplayUtil;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.stream.IntStream;

public class ShowtimeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long movieId = Validation.positiveLong(request.getParameter("movieId"), "Movie");
        Long cinemaId = optionalLong(request.getParameter("cinemaId"));
        LocalDate date = parseDate(request.getParameter("date"));
        request.setAttribute("movie", ServiceRegistry.CATALOG.movie(movieId));
        request.setAttribute("cinemas", ServiceRegistry.CATALOG.searchCinemas(null, null));
        request.setAttribute("showtimes", ServiceRegistry.CATALOG.showtimes(movieId, cinemaId, date));
        request.setAttribute("selectedCinemaId", cinemaId);
        request.setAttribute("selectedDate", date);
        request.setAttribute("availableDates", IntStream.range(0, 7)
                .mapToObj(offset -> LocalDate.now(DisplayUtil.DISPLAY_ZONE).plusDays(offset + 1L))
                .toList());
        WebUtil.view(request, response, "booking/showtimes");
    }

    private LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) {
            return LocalDate.now(DisplayUtil.DISPLAY_ZONE).plusDays(1);
        }
        try {
            LocalDate date = LocalDate.parse(value);
            LocalDate today = LocalDate.now(DisplayUtil.DISPLAY_ZONE);
            if (date.isBefore(today) || date.isAfter(today.plusDays(14))) {
                throw new AppException(400, "Select a date within the next 14 days.");
            }
            return date;
        } catch (DateTimeParseException exception) {
            throw new AppException(400, "Showtime date is invalid.");
        }
    }

    private Long optionalLong(String value) {
        return value == null || value.isBlank() ? null : Validation.positiveLong(value, "Cinema");
    }
}
