package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.Banner;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

public class AdminBannerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("adminSection", "banners");
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            request.setAttribute("mode", "form");
            request.setAttribute("formTitle", "Create Banner");
            WebUtil.view(request, response, "admin/banners");
            return;
        }
        if ("edit".equals(action)) {
            long id = Validation.positiveLong(request.getParameter("id"), "Banner ID");
            Banner banner = ServiceRegistry.BANNERS.findById(id).orElse(null);
            if (banner != null) {
                request.setAttribute("mode", "form");
                request.setAttribute("formTitle", "Edit Banner");
                request.setAttribute("banner", banner);
            }
            WebUtil.view(request, response, "admin/banners");
            return;
        }

        List<Banner> banners = ServiceRegistry.BANNERS.findAll();
        request.setAttribute("banners", banners);
        request.setAttribute("totalCount", banners.size());
        WebUtil.view(request, response, "admin/banners");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action) || "DELETE".equalsIgnoreCase(request.getParameter("_method"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Banner ID");
            ServiceRegistry.BANNERS.delete(id);
            WebUtil.flash(request, "success", "Banner deleted successfully.");
            WebUtil.redirect(request, response, "/admin/banners");
            return;
        }

        String title = request.getParameter("title");
        String subtitle = request.getParameter("subtitle");
        String imageUrl = request.getParameter("imageUrl");
        String targetUrl = request.getParameter("targetUrl");
        String placement = request.getParameter("placement");
        int displayOrder = Validation.nonNegativeInt(request.getParameter("displayOrder"), "Display Order");
        boolean active = "on".equals(request.getParameter("active")) || "true".equals(request.getParameter("active"));
        LocalDateTime startsAt = parseDateTime(request.getParameter("startsAt"));
        LocalDateTime endsAt = parseDateTime(request.getParameter("endsAt"));
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        Long createdBy = currentUser != null ? currentUser.getId() : null;

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isBlank()) {
            long id = Validation.positiveLong(idParam, "Banner ID");
            Banner banner = new Banner(id, title, subtitle, imageUrl, targetUrl, placement, displayOrder, startsAt, endsAt, active, createdBy);
            ServiceRegistry.BANNERS.update(banner);
            WebUtil.flash(request, "success", "Banner updated successfully.");
        } else {
            Banner banner = new Banner(0, title, subtitle, imageUrl, targetUrl, placement, displayOrder, startsAt, endsAt, active, createdBy);
            ServiceRegistry.BANNERS.insert(banner);
            WebUtil.flash(request, "success", "Banner created successfully.");
        }
        WebUtil.redirect(request, response, "/admin/banners");
    }

    private LocalDateTime parseDateTime(String val) {
        if (val == null || val.isBlank()) return LocalDateTime.now();
        try {
            if (val.length() == 16) val += ":00";
            return LocalDateTime.parse(val);
        } catch (Exception e) {
            return LocalDateTime.now();
        }
    }
}
