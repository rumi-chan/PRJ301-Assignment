package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.model.Banner;
import vn.edu.cinebook.model.User;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.AppException;
import vn.edu.cinebook.util.Validation;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet({"/admin/banners", "/admin/banners/*"})
public class AdminBannerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        request.setAttribute("adminSection", "banners");

        if ("create".equals(action)) {
            WebUtil.view(request, response, "admin/banner-form");
            return;
        }

        if ("edit".equals(action)) {
            long id = Validation.positiveLong(request.getParameter("id"), "Banner ID");
            request.setAttribute("banner", ServiceRegistry.CATALOG.banner(id));
            WebUtil.view(request, response, "admin/banner-form");
            return;
        }

        List<Banner> banners = ServiceRegistry.CATALOG.adminBanners();
        request.setAttribute("items", banners);
        request.setAttribute("totalCount", banners.size());
        WebUtil.view(request, response, "admin/banners");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String method = request.getParameter("_method");
        if ("DELETE".equalsIgnoreCase(method) || "delete".equals(request.getParameter("action"))) {
            long id = Validation.positiveLong(request.getParameter("id"), "Banner ID");
            ServiceRegistry.CATALOG.deleteBanner(id);
            WebUtil.flash(request, "success", "Banner deleted successfully.");
            WebUtil.redirect(request, response, "/admin/banners");
            return;
        }

        try {
            String title = Validation.required(request.getParameter("title"), "Title", 200);
            String subtitle = request.getParameter("subtitle");
            if (subtitle == null) subtitle = "";
            String imageUrl = Validation.required(request.getParameter("imageUrl"), "Image URL", 1000);
            String targetUrl = internalTargetUrl(request.getParameter("targetUrl"));
            String placement = Validation.required(request.getParameter("placement"), "Placement", 30);
            int displayOrder = Integer.parseInt(request.getParameter("displayOrder"));

            String startsStr = request.getParameter("startsAt");
            if (startsStr != null && startsStr.length() == 16) startsStr += ":00";
            LocalDateTime startsAt = LocalDateTime.parse(startsStr);

            String endsStr = request.getParameter("endsAt");
            if (endsStr != null && endsStr.length() == 16) endsStr += ":00";
            LocalDateTime endsAt = LocalDateTime.parse(endsStr);

            boolean active = request.getParameter("active") != null;

            User user = (User) request.getSession().getAttribute("currentUser");
            Long createdBy = user != null ? user.id() : null;

            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isBlank()) {
                Banner banner = new Banner(0, title, subtitle, imageUrl, targetUrl, placement, displayOrder, startsAt, endsAt, active);
                ServiceRegistry.CATALOG.createBanner(banner, createdBy);
                WebUtil.flash(request, "success", "Banner created successfully.");
            } else {
                long id = Validation.positiveLong(idParam, "Banner ID");
                Banner banner = new Banner(id, title, subtitle, imageUrl, targetUrl, placement, displayOrder, startsAt, endsAt, active);
                ServiceRegistry.CATALOG.updateBanner(banner);
                WebUtil.flash(request, "success", "Banner updated successfully.");
            }
            WebUtil.redirect(request, response, "/admin/banners");
        } catch (Exception ex) {
            String msg = ex instanceof AppException ae ? ae.getMessage() : "An error occurred saving the banner.";
            request.setAttribute("error", msg);
            request.setAttribute("adminSection", "banners");
            WebUtil.view(request, response, "admin/banner-form");
        }
    }

    private String internalTargetUrl(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }
        String targetUrl = value.trim();
        if (!targetUrl.startsWith("/") || targetUrl.startsWith("//")) {
            throw new AppException(400, "Target URL must be an internal path.");
        }
        return targetUrl;
    }
}
