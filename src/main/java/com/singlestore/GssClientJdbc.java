package com.singlestore;

import java.sql.*;

/**
 * A sample client JDBC application that uses JGSS to do mutual authentication with a server using
 * Kerberos as the underlying mechanism. It then exchanges data securely with the server.
 */

public class GssClientJdbc {

    private static final int PORT = 5506;
    private static final String DB_NAME = "kerberos_db";
    private static final String USER = "singlestore";

    public static void main(String[] args) throws Exception {
        System.setProperty("sun.security.krb5.debug", "true");//enable Krb5LoginModule debug logs
        System.setProperty("sun.security.jgss.debug", "true");
        String dbUrl = String.format("jdbc:singlestore://localhost:%d/%s?user=%s", PORT, DB_NAME, USER);
        try (Connection c = DriverManager.getConnection(dbUrl)) {
            PreparedStatement stmt = c.prepareStatement("SELECT 1");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                System.out.println(rs.getString(1));
            }
            System.out.println("Kerberos authentication success");
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
