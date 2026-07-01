package cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import cinebook.model.Promotion;
import cinebook.service.ServiceRegistry;
import cinebook.util.AppException;
import cinebook.util.DisplayUtil;
import cinebook.util.Validation;
import cinebook.util.WebUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Locale;

@WebServlet("/admin/promotions")
public class AdminPromotionServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("edit".equals(request.getParameter("action"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Promotion ID");
            request.setAttribute("promotion", ServiceRegistry.BOOKING.adminPromotion(id));
        }
        prepare(request);
        WebUtil.view(request, response, "admin/promotions");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String method = request.getParameter("_method");
        if ("DELETE".equalsIgnoreCase(method) || "delete".equals(request.getParameter("action"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Promotion ID");
            ServiceRegistry.BOOKING.deletePromotion(id);
            WebUtil.flash(request, "success", "Promotion disabled successfully.");
            WebUtil.redirect(request, response, "/admin/promotions");
            return;
        }

        try {
            Promotion promotion = readPromotion(request);
            if (promotion.id() == 0) {
                ServiceRegistry.BOOKING.createPromotion(promotion);
                WebUtil.flash(request, "success", "Promotion created successfully.");
            } else {
                ServiceRegistry.BOOKING.updatePromotion(promotion);
                WebUtil.flash(request, "success", "Promotion updated successfully.");
            }
            WebUtil.redirect(request, response, "/admin/promotions");
        } catch (Exception exception) {
            String msg = exception instanceof AppException ae ? ae.getMessage() : "An error occurred saving the promotion.";
            request.setAttribute("error", msg);
            prepare(request);
            WebUtil.view(request, response, "admin/promotions");
        }
    }

    private void prepare(HttpServletRequest request) {
        request.setAttribute("adminSection", "promotions");
        request.setAttribute("items", ServiceRegistry.BOOKING.adminPromotions());
    }

    private Promotion readPromotion(HttpServletRequest request) {
        long id = optionalId(request.getParameter("id"));
        String code = Validation.required(request.getParameter("code"), "Code", 40).toUpperCase(Locale.ROOT);
        String name = Validation.required(request.getParameter("name"), "Name", 150);
        String description = request.getParameter("description");
        String discountType = Validation.required(request.getParameter("discountType"), "Discount type", 20);
        BigDecimal discountValue = money(request.getParameter("discountValue"), "Discount value");
        if ("PERCENT".equals(discountType) && discountValue.compareTo(new BigDecimal("100")) > 0) {
            throw new AppException(400, "Percent discount cannot exceed 100.");
        }
        if (!"PERCENT".equals(discountType) && !"FIXED".equals(discountType)) {
            throw new AppException(400, "Discount type is invalid.");
        }
        BigDecimal minimumOrder = optionalMoney(request.getParameter("minimumOrder"));
        BigDecimal maximumDiscount = optionalMoney(request.getParameter("maximumDiscount"));
        LocalDateTime startsLocal = LocalDateTime.parse(Validation.required(request.getParameter("startsAt"), "Start time", 30));
        LocalDateTime endsLocal = LocalDateTime.parse(Validation.required(request.getParameter("endsAt"), "End time", 30));
        if (!endsLocal.isAfter(startsLocal)) {
            throw new AppException(400, "End time must be after start time.");
        }
        Integer usageLimit = optionalInt(request.getParameter("usageLimit"), "Usage limit");
        Integer perUserLimit = optionalInt(request.getParameter("perUserLimit"), "Per-user limit");
        boolean active = request.getParameter("active") != null;
        return new Promotion(id, code, name, description == null ? "" : description.trim(), discountType,
                discountValue, maximumDiscount, minimumOrder == null ? BigDecimal.ZERO : minimumOrder,
                startsLocal.atZone(DisplayUtil.DISPLAY_ZONE).toInstant(),
                endsLocal.atZone(DisplayUtil.DISPLAY_ZONE).toInstant(),
                active, usageLimit, perUserLimit, 0);
    }

    private long optionalId(String value) {
        return value == null || value.isBlank() ? 0 : Validation.positiveLong(value, "Promotion ID");
    }

    private BigDecimal money(String value, String field) {
        BigDecimal amount = optionalMoney(value);
        if (amount == null || amount.signum() <= 0) {
            throw new AppException(400, field + " is invalid.");
        }
        return amount;
    }

    private BigDecimal optionalMoney(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            BigDecimal amount = new BigDecimal(value.trim());
            if (amount.signum() < 0) {
                throw new NumberFormatException();
            }
            return amount;
        } catch (NumberFormatException exception) {
            throw new AppException(400, "Amount is invalid.");
        }
    }

    private Integer optionalInt(String value, String field) {
        if (value == null || value.isBlank()) {
            return null;
        }
        long parsed = Validation.positiveLong(value, field);
        if (parsed > Integer.MAX_VALUE) {
            throw new AppException(400, field + " is invalid.");
        }
        return (int) parsed;
    }
}
