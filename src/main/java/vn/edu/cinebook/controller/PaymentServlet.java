package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.dto.BookingDraft;
import vn.edu.cinebook.dto.PaymentResult;
import vn.edu.cinebook.model.PaymentStatus;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;

public class PaymentServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BookingDraft draft = (BookingDraft) request.getSession().getAttribute("bookingDraft");
        if (draft == null) {
            throw new AppException(409, "Your booking session is empty.");
        }
        User user = (User) request.getSession().getAttribute("currentUser");
        PaymentResult result = ServiceRegistry.BOOKING.pay(
                draft.holdToken(), user.id(), draft.combos(), draft.promotionCode(),
                request.getParameter("outcome"));
        request.setAttribute("paymentResult", result);
        request.setAttribute("paymentStatus", result.status().name());
        request.setAttribute("paymentMessage", result.message());
        request.setAttribute("holdToken", draft.holdToken());
        if (result.status() == PaymentStatus.SUCCEEDED) {
            request.getSession().removeAttribute("bookingDraft");
            WebUtil.flash(request, "success", result.message());
            WebUtil.redirect(request, response, "/tickets/" + result.bookingCode());
            return;
        }
        if (result.status() == PaymentStatus.CANCELLED) {
            request.getSession().removeAttribute("bookingDraft");
        }
        request.setAttribute("draft", draft);
        WebUtil.view(request, response, "payment/result");
    }
}
