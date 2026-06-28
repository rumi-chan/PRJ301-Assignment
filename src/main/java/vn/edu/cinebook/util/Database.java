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

    private static volatile boolean seeded = false;

    private Database() {
    }

    public static Connection getConnection() throws SQLException {
        String url = setting("cinebook.db.url", "CINEBOOK_DB_URL", "url", DEFAULT_URL);
        String user = setting("cinebook.db.user", "CINEBOOK_DB_USER", "user", null);
        String password = setting("cinebook.db.password", "CINEBOOK_DB_PASSWORD", "password", null);
        Connection connection = null;
        try {
            if (user == null && url.toLowerCase().contains("integratedsecurity=true")) {
                connection = DriverManager.getConnection(url);
            } else if (user == null || password == null) {
                throw new SQLException(
                        "Set CINEBOOK_DB_USER and CINEBOOK_DB_PASSWORD, or configure integratedSecurity=true.");
            } else {
                connection = DriverManager.getConnection(url, user, password);
            }
        } catch (SQLException exception) {
            if (exception.getErrorCode() == 4060 || (exception.getMessage() != null && exception.getMessage().contains("Cannot open database"))) {
                createDatabaseIfMissing(url, user, password);
                if (user == null && url.toLowerCase().contains("integratedsecurity=true")) {
                    connection = DriverManager.getConnection(url);
                } else {
                    connection = DriverManager.getConnection(url, user, password);
                }
            } else {
                throw exception;
            }
        }
        configureSqlServerSession(connection);
        ensureSeeded(connection);
        return connection;
    }

    private static synchronized void createDatabaseIfMissing(String url, String user, String password) throws SQLException {
        String dbName = "CineBook";
        int dbIdx = url.toLowerCase().indexOf("databasename=");
        if (dbIdx != -1) {
            int endIdx = url.indexOf(';', dbIdx);
            dbName = endIdx != -1 ? url.substring(dbIdx + 13, endIdx) : url.substring(dbIdx + 13);
        }
        String masterUrl = url.replaceAll("(?i);?databaseName=[^;]+", "");
        try (Connection masterConn = user == null ? DriverManager.getConnection(masterUrl) : DriverManager.getConnection(masterUrl, user, password);
             Statement stmt = masterConn.createStatement()) {
            stmt.executeUpdate("IF DB_ID('" + dbName + "') IS NULL CREATE DATABASE " + dbName);
        }
    }

    private static synchronized void ensureSeeded(Connection conn) {
        if (seeded) return;
        seeded = true;
        try (Statement stmt = conn.createStatement()) {
            stmt.executeQuery("SELECT 1 FROM banners");
        } catch (SQLException exception) {
            try {
                runScript(conn, "/db/schema.sql");
                runScript(conn, "/db/seed.sql");
            } catch (Exception ex) {
                System.err.println("Warning: Auto init database failed: " + ex.getMessage());
            }
        }
    }

    private static void runScript(Connection conn, String path) throws Exception {
        try (InputStream input = Database.class.getResourceAsStream(path)) {
            if (input == null) return;
            String content = new String(input.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
            String[] chunks = content.split("(?im)^\\s*GO\\s*$");
            try (Statement stmt = conn.createStatement()) {
                for (String chunk : chunks) {
                    if (!chunk.trim().isEmpty()) {
                        stmt.execute(chunk.trim());
                    }
                }
            }
        }
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
