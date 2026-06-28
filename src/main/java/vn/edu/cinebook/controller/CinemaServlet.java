package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.service.ServiceRegistry;
import vn.edu.cinebook.util.WebUtil;

import java.io.IOException;

public class CinemaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("selectedCity", request.getParameter("city"));
        request.setAttribute("query", request.getParameter("q"));
        request.setAttribute("cities", ServiceRegistry.CATALOG.cities());
        request.setAttribute("cinemas", ServiceRegistry.CATALOG.searchCinemas(
                request.getParameter("city"), request.getParameter("q")));
        WebUtil.view(request, response, "cinemas/list");
    }
}
