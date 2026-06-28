package vn.edu.cinebook.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.dto.BookingDraft;
import vn.edu.cinebook.dto.SeatHoldResult;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class SeatHoldApiServlet extends HttpServlet {
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, Object> body = mapper.readValue(request.getInputStream(), new TypeReference<>() {
        });
        long showtimeId = ((Number) body.getOrDefault("showtimeId", 0)).longValue();
        String token = body.get("holdToken") == null ? null : body.get("holdToken").toString();
        @SuppressWarnings("unchecked")
        List<Object> rawSeatIds = (List<Object>) body.getOrDefault("seatIds", List.of());
        List<Long> seatIds = rawSeatIds.stream().map(value -> ((Number) value).longValue()).toList();
        User user = (User) request.getSession().getAttribute("currentUser");
        String sessionKey = (String) request.getSession().getAttribute("bookingSessionKey");

        SeatHoldResult hold = ServiceRegistry.BOOKING.hold(
                showtimeId, seatIds, token, user == null ? null : user.id(), sessionKey);
        BookingDraft draft = new BookingDraft(
                hold.holdToken(), showtimeId, List.of(), null);
        request.getSession().setAttribute("bookingDraft", draft);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("holdToken", hold.holdToken());
        result.put("showtimeId", hold.showtimeId());
        result.put("expiresAt", hold.expiresAt().toString());
        result.put("seats", hold.seats().stream().map(seat -> Map.of(
                "id", seat.id(),
                "label", seat.label(),
                "type", seat.type().name(),
                "price", seat.price()
        )).toList());
        result.put("seatIds", hold.seats().stream().map(seat -> seat.id()).toList());
        result.put("pricing", Map.of(
                "ticketSubtotal", hold.pricing().ticketSubtotal(),
                "serviceFee", hold.pricing().serviceFee(),
                "tax", hold.pricing().tax(),
                "total", hold.pricing().total()
        ));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        mapper.writeValue(response.getWriter(), result);
    }
}
