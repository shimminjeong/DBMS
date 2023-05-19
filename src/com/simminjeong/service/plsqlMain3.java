package com.simminjeong.service;

import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

import com.simminjeong.util.JDBCUtil;

public class plsqlMain3 {

	public static void main(String[] args) throws SQLException {

		Connection conn = JDBCUtil.getConnection();

		String plsql = "DECLARE\r\n" + "\r\n" + "--    EMP 커서 정의\r\n" + "    CURSOR CUR_EMP IS \r\n"
				+ "            SELECT EMPNO,ENAME,JOB,SAL,NVL(COMM,0) AS COMM FROM EMP;\r\n"
				+ "--    CUSTOMER 커서 정의            \r\n" + "    CURSOR CUR_CUSTOMER IS \r\n"
				+ "            SELECT ACCOUNT_MGR FROM CUSTOMER;\r\n" + "            \r\n"
				+ "--    ACCOUNT_MGR별로 관리하는 고객수 COUNT 하기 위한 SCALAR TYPE 변수 선언\r\n" + "    CUSCNT NUMBER;\r\n"
				+ "--    EMP COMM의 DATA TYPE, LENGTH 참조하여 변수 선언 \r\n" + "    V_COMM EMP.COMM%TYPE;\r\n" + "    \r\n"
				+ "\r\n" + "BEGIN\r\n" + "--    EMP의 EMPNO별로 관리하는 CUSTOMER테이블의 고객 수 COUNT    \r\n"
				+ "--    FOR LOOP 구문에서 R_CUR_EMP CUR_EMP%ROWTYPE;으로 자동 할당됨\r\n" + "    FOR R_CUR_EMP IN CUR_EMP\r\n"
				+ "    LOOP\r\n" + "        CUSCNT:=0;\r\n" + "--        CUSTOMER테이블에 해당 매니저 번호 COUNT        \r\n"
				+ "        FOR R_CUR_CUSTOMER IN CUR_CUSTOMER\r\n" + "        LOOP\r\n"
				+ "            IF R_CUR_CUSTOMER.ACCOUNT_MGR = R_CUR_EMP.EMPNO THEN\r\n"
				+ "                CUSCNT:=CUSCNT+1;\r\n" + "            END IF;\r\n" + "        END LOOP;\r\n"
				+ "        \r\n" + "--        조건에 맞게 COMM 계산\r\n"
				+ "        IF R_CUR_EMP.JOB IN('ANALYST','PRESIDENT') THEN\r\n" + "            V_COMM:=0;\r\n"
				+ "        ELSIF CUSCNT>=100000 THEN\r\n" + "            V_COMM:=2000;\r\n" + "        ELSE\r\n"
				+ "            V_COMM:=1000;\r\n" + "        END IF;\r\n" + "        \r\n"
				+ "--        BONUS테이블에 INSERT        \r\n" + "        INSERT INTO BONUS(ENAME,JOB,SAL,COMM)\r\n"
				+ "        VALUES(R_CUR_EMP.ENAME,R_CUR_EMP.JOB,R_CUR_EMP.SAL,R_CUR_EMP.COMM+V_COMM);\r\n"
				+ "        \r\n" + "    END LOOP;\r\n" + "\r\n" + "--    트랜잭션 COMMIT\r\n" + "    COMMIT;\r\n" + "\r\n"
				+ "--    예외처리\r\n" + "    EXCEPTION\r\n" + "                WHEN OTHERS THEN \r\n"
				+ "                ROLLBACK;\r\n"
				+ "                DBMS_OUTPUT.PUT_LINE('ERROR: '||SQLERRM);          \r\n" + "END;";

//		실행 전 현재 시작 측정
		long startTime = System.currentTimeMillis();

//		DBMS_OUTPUT.ENABLE 프로시저를 호출
		CallableStatement callableStatement = conn.prepareCall(plsql);
		callableStatement.execute();
		callableStatement.close();

//		실행 후 현재 시작 측정
		long endTime = System.currentTimeMillis();

//		실행 전과 실행 후 시간 측정
		double time = (endTime - startTime) / 1000.0;
		System.out.println("소요 시간 : " + time + "초");

	}

}
