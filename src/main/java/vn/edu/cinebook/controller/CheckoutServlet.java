package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.dto.BookingDraft;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;

public class CheckoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BookingDraft draft = requireDraft(request);
        request.setAttribute("draft", draft);
        request.setAttribute("hold", ServiceRegistry.BOOKING.activeHold(draft.holdToken()));
        request.setAttribute("showtime", ServiceRegistry.CATALOG.showtime(draft.showtimeId()));
        request.setAttribute("movie", ServiceRegistry.CATALOG.movie(
                ServiceRegistry.CATALOG.showtime(draft.showtimeId()).movieId()));
        request.setAttribute("promotionCode", draft.promotionCode());
        request.setAttribute("pricing", ServiceRegistry.BOOKING.price(
                draft.holdToken(), draft.combos(), draft.promotionCode()));
        WebUtil.view(request, response, "booking/checkout");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        BookingDraft draft = requireDraft(request);
        String code = request.getParameter("promotionCode");
        BookingDraft updated = draft.withPromotion(code == null || code.isBlank() ? null : code.trim());
        ServiceRegistry.BOOKING.price(updated.holdToken(), updated.combos(), updated.promotionCode());
        request.getSession().setAttribute("bookingDraft", updated);
        WebUtil.flash(request, "success", updated.promotionCode() == null
                ? "Promotion removed."
                : "Promotion " + updated.promotionCode() + " applied.");
        WebUtil.redirect(request, response, "/checkout");
    }

    private BookingDraft requireDraft(HttpServletRequest request) {
        BookingDraft draft = (BookingDraft) request.getSession().getAttribute("bookingDraft");
        if (draft == null) {
            throw new AppException(409, "Your booking session is empty.");
        }
        return draft;
    }
}
