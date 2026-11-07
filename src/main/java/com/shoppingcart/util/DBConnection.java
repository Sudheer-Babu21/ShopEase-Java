package com.shoppingcart.util;

import com.shoppingcart.exception.AppException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Manages database connectivity for Oracle Database XE 10g.
 * Supports Tomcat JNDI DataSource with transparent fallback to JDBC DriverManager.
 */
public final class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static final String DEFAULT_DRIVER = "oracle.jdbc.OracleDriver";
    private static final String DEFAULT_URL = "jdbc:oracle:thin:@localhost:1521:XE";
    private static final String DEFAULT_USER = "shoppingcart";
    private static final String DEFAULT_PASSWORD = "shoppingcart123";
    private static final String JNDI_NAME = "java:comp/env/jdbc/ShoppingCartDB";

    private static DataSource dataSource;
    private static boolean jndiLookupAttempted = false;

    static {
        try {
            Class.forName(DEFAULT_DRIVER);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Failed to load Oracle JDBC Driver: " + DEFAULT_DRIVER, e);
        }
    }

    private DBConnection() {
        // Utility class
    }

    /**
     * Retrieves an active database connection.
     * Tries JNDI DataSource first; if unavailable, falls back to DriverManager.
     *
     * @return active java.sql.Connection
     * @throws AppException if connection cannot be established
     */
    public static Connection getConnection() {
        // Attempt JNDI lookup once
        if (!jndiLookupAttempted) {
            synchronized (DBConnection.class) {
                if (!jndiLookupAttempted) {
                    jndiLookupAttempted = true;
                    try {
                        Context initCtx = new InitialContext();
                        dataSource = (DataSource) initCtx.lookup(JNDI_NAME);
                        LOGGER.info("Tomcat JNDI DataSource initialized successfully: " + JNDI_NAME);
                    } catch (NamingException e) {
                        LOGGER.info("JNDI DataSource not configured, using direct JDBC DriverManager.");
                    }
                }
            }
        }

        if (dataSource != null) {
            try {
                return dataSource.getConnection();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Failed to obtain connection from JNDI DataSource, falling back to DriverManager.", e);
            }
        }

        // Fallback to DriverManager with configurable credentials
        String url = getEnvOrDefault("ORACLE_DB_URL", DEFAULT_URL);
        String user = getEnvOrDefault("ORACLE_DB_USER", DEFAULT_USER);
        String pass = getEnvOrDefault("ORACLE_DB_PASSWORD", DEFAULT_PASSWORD);

        try {
            return DriverManager.getConnection(url, user, pass);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database connection error (user: " + user + ", url: " + url + ")", e);
            throw new AppException("Unable to connect to the database. Please verify Oracle XE is running.", e);
        }
    }

    /**
     * Safely closes one or more JDBC resources without throwing exceptions.
     */
    public static void closeQuietly(AutoCloseable... closeables) {
        if (closeables == null) return;
        for (AutoCloseable c : closeables) {
            if (c != null) {
                try {
                    c.close();
                } catch (Exception e) {
                    LOGGER.log(Level.FINE, "Error closing resource", e);
                }
            }
        }
    }

    /**
     * Rollback a connection safely.
     */
    public static void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Failed to rollback connection", e);
            }
        }
    }

    private static String getEnvOrDefault(String key, String def) {
        String val = System.getenv(key);
        if (val == null || val.trim().isEmpty()) {
            val = System.getProperty(key);
        }
        return (val != null && !val.trim().isEmpty()) ? val.trim() : def;
    }
}
