package com.simminjeong.procedure.util;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class JDBCUtil {

	public static Connection getConnection() {

		Connection conn = null;

		String driver = "oracle.jdbc.driver.OracleDriver";
		String url = "jdbc:oracle:thin:@192.168.119.119:1521/dink11.dbsvr";
		String user = "scott";
		String password = "tiger";

		try {

			Class.forName(driver);
//			System.out.println("jdbc driver 로딩 성공");
			conn = DriverManager.getConnection(url, user, password);
//			System.out.println("오라클 연결 성공");
		} catch (ClassNotFoundException e) {
			System.out.println("jdbc driver 로딩 실패");
		} catch (SQLException e) {
			System.out.println("오라클 연결 실패");
		}

		return conn;
	}

}