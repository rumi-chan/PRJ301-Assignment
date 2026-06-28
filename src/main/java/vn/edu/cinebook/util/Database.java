package vn.edu.cinebook.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public final class Database {
    private static final String DEFAULT_URL =
            "jdbc:sqlserver://localhost:1433;databaseName=CineBook;encrypt=true;trustServerCertificate=true";
    private static final Properties LOCAL_SETTINGS = loadLocalSettings();

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException exception) {
            throw new ExceptionInInitializerError(
                    "Microsoft SQL Server JDBC driver is missing from WEB-INF/lib.");
        }
    }

    private Database() {
    }

    public static Connection getConnection() throws SQLException {
        String url = setting("cinebook.db.url", "CINEBOOK_DB_URL", "url", DEFAULT_URL);
        String user = setting("cinebook.db.user", "CINEBOOK_DB_USER", "user", null);
        String password = setting("cinebook.db.password", "CINEBOOK_DB_PASSWORD", "password", null);
        Connection connection;
        if (user == null && url.toLowerCase().contains("integratedsecurity=true")) {
            connection = DriverManager.getConnection(url);
        } else if (user == null || password == null) {
            throw new SQLException(
                    "Set CINEBOOK_DB_USER and CINEBOOK_DB_PASSWORD, or configure integratedSecurity=true.");
        } else {
            connection = DriverManager.getConnection(url, user, password);
        }
        configureSqlServerSession(connection);
        return connection;
    }

    private static String setting(String property, String environment,
                                  String localKey, String fallback) {
        String value = System.getProperty(property);
        if (value == null || value.isBlank()) {
            value = System.getenv(environment);
        }
        if (value == null || value.isBlank()) {
            value = LOCAL_SETTINGS.getProperty(localKey);
        }
        return value == null || value.isBlank() ? fallback : value;
    }

    private static Properties loadLocalSettings() {
        Properties properties = new Properties();
        try (InputStream input = Database.class.getClassLoader()
                .getResourceAsStream("cinebook-local.properties")) {
            if (input != null) {
                properties.load(input);
            }
        } catch (IOException exception) {
            throw new ExceptionInInitializerError(exception);
        }
        return properties;
    }

    private static void configureSqlServerSession(Connection connection) throws SQLException {
        try (Statement statement = connection.createStatement()) {
            statement.execute("""
                    SET ANSI_NULLS ON;
                    SET QUOTED_IDENTIFIER ON;
                    SET ANSI_PADDING ON;
                    SET ANSI_WARNINGS ON;
                    SET ARITHABORT ON;
                    SET CONCAT_NULL_YIELDS_NULL ON;
                    SET NUMERIC_ROUNDABORT OFF;
                    """);
        }
    }
}
