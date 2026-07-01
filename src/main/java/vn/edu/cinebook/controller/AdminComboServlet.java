package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.Combo;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Locale;

@WebServlet("/admin/combos")
public class AdminComboServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("edit".equals(request.getParameter("action"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Combo ID");
            request.setAttribute("combo", ServiceRegistry.BOOKING.combo(id));
        }
        prepare(request);
        WebUtil.view(request, response, "admin/combos");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String method = request.getParameter("_method");
        if ("DELETE".equalsIgnoreCase(method) || "delete".equals(request.getParameter("action"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Combo ID");
            ServiceRegistry.BOOKING.deleteCombo(id);
            WebUtil.flash(request, "success", "Combo disabled successfully.");
            WebUtil.redirect(request, response, "/admin/combos");
            return;
        }

        try {
            Combo combo = readCombo(request);
            if (combo.id() == 0) {
                ServiceRegistry.BOOKING.createCombo(combo);
                WebUtil.flash(request, "success", "Combo created successfully.");
            } else {
                ServiceRegistry.BOOKING.updateCombo(combo);
                WebUtil.flash(request, "success", "Combo updated successfully.");
            }
            WebUtil.redirect(request, response, "/admin/combos");
        } catch (Exception exception) {
            String msg = exception instanceof AppException ae ? ae.getMessage() : "An error occurred saving the combo.";
            request.setAttribute("error", msg);
            prepare(request);
            WebUtil.view(request, response, "admin/combos");
        }
    }

    private void prepare(HttpServletRequest request) {
        request.setAttribute("adminSection", "combos");
        request.setAttribute("items", ServiceRegistry.BOOKING.adminCombos());
    }

    private Combo readCombo(HttpServletRequest request) {
        long id = optionalId(request.getParameter("id"));
        String sku = Validation.required(request.getParameter("sku"), "SKU", 40).toUpperCase(Locale.ROOT);
        String name = Validation.required(request.getParameter("name"), "Name", 150);
        String description = request.getParameter("description");
        String imageUrl = request.getParameter("imageUrl");
        BigDecimal price = money(request.getParameter("price"), "Price");
        int displayOrder = (int) Validation.positiveLong(request.getParameter("displayOrder"), "Display order");
        boolean active = request.getParameter("active") != null;
        return new Combo(id, sku, name, description == null ? "" : description.trim(),
                imageUrl == null ? "" : imageUrl.trim(), price, active, displayOrder);
    }

    private long optionalId(String value) {
        return value == null || value.isBlank() ? 0 : Validation.positiveLong(value, "Combo ID");
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
