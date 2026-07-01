package cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import cinebook.dto.BookingDraft;
import cinebook.dto.ComboSelection;
import cinebook.service.ServiceRegistry;
import cinebook.util.AppException;
import cinebook.util.Validation;
import cinebook.util.WebUtil;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/booking/combos")
public class ComboServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BookingDraft draft = requireDraft(request);
        request.setAttribute("draft", draft);
        request.setAttribute("hold", ServiceRegistry.BOOKING.activeHold(draft.holdToken()));
        request.setAttribute("showtime", ServiceRegistry.CATALOG.showtime(draft.showtimeId()));
        request.setAttribute("combos", ServiceRegistry.BOOKING.combos());
        WebUtil.view(request, response, "booking/combos");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        BookingDraft draft = requireDraft(request);
        String[] ids = request.getParameterValues("comboId");
        String[] quantities = request.getParameterValues("quantity");
        List<Long> comboIds = new ArrayList<>();
        List<Integer> comboQuantities = new ArrayList<>();
        if (ids != null && quantities != null && ids.length == quantities.length) {
            for (int index = 0; index < ids.length; index++) {
                comboIds.add(Validation.positiveLong(ids[index], "Combo"));
                comboQuantities.add(Validation.nonNegativeInt(quantities[index], "Quantity"));
            }
        }
        List<ComboSelection> selections = ServiceRegistry.BOOKING.comboSelections(comboIds, comboQuantities);
        request.getSession().setAttribute("bookingDraft", draft.withCombos(selections));
        WebUtil.redirect(request, response, "/checkout");
    }

    private BookingDraft requireDraft(HttpServletRequest request) {
        BookingDraft draft = (BookingDraft) request.getSession().getAttribute("bookingDraft");
        if (draft == null) {
            throw new AppException(409, "Select a showtime and seats before choosing combos.");
        }
        return draft;
    }
}
