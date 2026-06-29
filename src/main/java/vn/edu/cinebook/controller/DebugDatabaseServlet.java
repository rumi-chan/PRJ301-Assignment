package vn.edu.cinebook.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.edu.cinebook.util.Database;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet("/debug/db")
public class DebugDatabaseServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection connection = Database.getConnection();
             Statement statement = connection.createStatement()) {
            out.println("CineBook database diagnostic");
            out.println("============================");
            printValue(out, statement, "Database", "SELECT DB_NAME()");
            printValue(out, statement, "Login", "SELECT SUSER_SNAME()");
            printValue(out, statement, "User", "SELECT USER_NAME()");
            printValue(out, statement, "Total movies", "SELECT COUNT(*) FROM dbo.movies");
            printValue(out, statement, "Active movies", "SELECT COUNT(*) FROM dbo.movies WHERE is_active = 1");
            printValue(out, statement, "Now showing", "SELECT COUNT(*) FROM dbo.movies WHERE is_active = 1 AND status = 'NOW_SHOWING'");
            printValue(out, statement, "Coming soon", "SELECT COUNT(*) FROM dbo.movies WHERE is_active = 1 AND status = 'COMING_SOON'");
            printValue(out, statement, "Real Lotte movies", "SELECT COUNT(*) FROM dbo.movies WHERE source_ref LIKE 'LOTTE-%'");
            out.println();
            out.println("If these counts are correct but /movies is empty, the problem is JSP rendering.");
            out.println("If these counts are 0, Tomcat is connected to the wrong database or the seed was not run there.");
        } catch (Exception exception) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println("CineBook database diagnostic failed");
            out.println(exception.getClass().getName() + ": " + exception.getMessage());
            Throwable cause = exception.getCause();
            while (cause != null) {
                out.println("Caused by " + cause.getClass().getName() + ": " + cause.getMessage());
                cause = cause.getCause();
            }
        }
    }

    private static void printValue(PrintWriter out, Statement statement, String label, String sql) throws Exception {
        try (ResultSet result = statement.executeQuery(sql)) {
            if (result.next()) {
                out.println(label + ": " + result.getString(1));
            }
        }
    }
}
