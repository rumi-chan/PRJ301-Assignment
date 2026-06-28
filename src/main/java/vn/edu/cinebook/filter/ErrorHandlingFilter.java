package vn.edu.cinebook.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.util.AppException;

import java.io.IOException;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ErrorHandlingFilter implements Filter {
    private static final Logger LOGGER = Logger.getLogger(ErrorHandlingFilter.class.getName());
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        try {
            chain.doFilter(request, response);
        } catch (AppException exception) {
            handle((HttpServletRequest) request, (HttpServletResponse) response,
                    exception.getStatusCode(), exception.getMessage(), exception);
        } catch (Throwable exception) {
            Throwable root = exception;
            while (root.getCause() != null && root.getCause() != root) {
                root = root.getCause();
            }
            String detail = root.getMessage() != null ? root.getMessage() : root.toString();
            handle((HttpServletRequest) request, (HttpServletResponse) response,
                    500, "An unexpected error occurred.", exception instanceof Exception ? (Exception) exception : new Exception(exception), detail);
        }
    }

    private void handle(HttpServletRequest request, HttpServletResponse response,
                        int status, String message, Exception exception)
            throws IOException, ServletException {
        handle(request, response, status, message, exception, exception != null ? exception.toString() : "");
    }

    private void handle(HttpServletRequest request, HttpServletResponse response,
                        int status, String message, Exception exception, String detail)
            throws IOException, ServletException {
        LOGGER.log(Level.SEVERE,
                "Request failed: " + request.getMethod() + " " + request.getRequestURI(),
                exception);
        if (response.isCommitted()) {
            throw new ServletException(exception);
        }
        response.reset();
        response.setStatus(status);
        if (request.getRequestURI().contains("/api/")) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            mapper.writeValue(response.getWriter(), Map.of("error", message, "status", status, "detail", detail != null ? detail : ""));
            return;
        }
        request.setAttribute("errorStatus", status);
        request.setAttribute("errorMessage", message);
        request.setAttribute("errorDetail", detail);
        String page = status == 404 ? "404" : status == 403 ? "403" : "500";
        request.getRequestDispatcher("/WEB-INF/views/errors/" + page + ".jsp").forward(request, response);
    }
}
