package vn.edu.cinebook.util;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public final class WebUtil {
    private WebUtil() {
    }

    public static void view(HttpServletRequest request, HttpServletResponse response, String jsp)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/" + jsp + ".jsp").forward(request, response);
    }

    public static void redirect(HttpServletRequest request, HttpServletResponse response, String path)
            throws IOException {
        if (path.startsWith("http://") || path.startsWith("https://")) {
            response.sendRedirect(path);
        } else if (path.startsWith(request.getContextPath() + "/") || path.equals(request.getContextPath())) {
            response.sendRedirect(path);
        } else if (path.startsWith("/")) {
            response.sendRedirect(request.getContextPath() + path);
        } else {
            response.sendRedirect(path);
        }
    }

    public static void flash(HttpServletRequest request, String type, String message) {
        request.getSession().setAttribute("flashType", type);
        request.getSession().setAttribute("flashMessage", message);
    }
}
