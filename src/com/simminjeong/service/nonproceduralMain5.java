package com.simminjeong.service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.simminjeong.util.JDBCUtil;

public class nonproceduralMain5 {

	public static void main(String[] args) throws SQLException {
		
		Statement stmt;
		ResultSet rs;

//		Oracle JDBC 드라이버 로드
		Connection conn = JDBCUtil.getConnection();
		
//		실행 전 현재 시작 측정
		long startTime = System.currentTimeMillis();
		

		String sql="INSERT INTO BONUS\r\n"
				+ "SELECT E.ENAME, E.JOB,E.SAL,\r\n"
				+ "                    CASE WHEN E.JOB IN ('ANALYST','PRESIDENT') THEN 0\r\n"
				+ "                         WHEN C.CUSCNT >= 100000 THEN NVL(E.COMM,0)+2000\r\n"
				+ "                         ELSE NVL(E.COMM,0)+1000\r\n"
				+ "                    END AS COMM\r\n"
				+ "FROM EMP E\r\n"
				+ "LEFT JOIN (SELECT ACCOUNT_MGR,COUNT(ACCOUNT_MGR) AS CUSCNT\r\n"
				+ "            FROM CUSTOMER\r\n"
				+ "            GROUP BY ACCOUNT_MGR) C\r\n"
				+ "ON E.EMPNO=C.ACCOUNT_MGR";
		
//		C : Customer 테이블 groupby활용하여 ACCOUNT_MGR별 관리 고객수 COUNT (13 rows)
//		E : EMP 테이블 (14 rows)
//		E LEFT JOIN C : E가 한 행 더 많아서 LEFT JOIN
//		CASE WHEN : 조건에 맞게 보너스 지급
//		INSERT : SELECT문의 결과 BONUS TABLE에 INSERT
		
//		stmt 객체 생성
		stmt = conn.createStatement();
//		sql쿼리 실행하고 결과를 가져옴
		stmt.executeQuery(sql);

		
//		실행 후 현재 시작 측정
		long endTime = System.currentTimeMillis();

//		실행 전과 실행 후 시간 측정
		double time = (endTime - startTime) / 1000.0;
		System.out.println("소요 시간 : " + time + "초");

//		connection close
		conn.close();

	}

}
