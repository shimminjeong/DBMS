package com.simminjeong.procedure.service;

import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

import com.simminjeong.procedure.util.JDBCUtil;

public class plsqlBulkBindingMain4 {

	public static void main(String[] args) throws SQLException {

		Connection conn = JDBCUtil.getConnection();

		String plsql = "DECLARE\r\n" + "--    EMP 커서 정의\r\n" + "    CURSOR CUR_EMP IS \r\n"
				+ "                    SELECT EMPNO,ENAME,JOB,SAL,NVL(COMM,0) AS COMM FROM EMP;\r\n"
				+ "--    CUSTOMER 커서 정의\r\n" + "    CURSOR CUR_CUSTOMER IS \r\n"
				+ "            SELECT ACCOUNT_MGR FROM CUSTOMER;\r\n" + "    \r\n"
				+ "--    multiple row를 처리할떄 배열처럼 접근하기 위해 table 타입으로 정의\r\n"
				+ "    TYPE T_CUSTOMER IS TABLE OF CUSTOMER.ACCOUNT_MGR%TYPE;\r\n" + "    TAB_CUSTOMER T_CUSTOMER;\r\n"
				+ "            \r\n" + "--    ACCOUNT_MGR별로 관리하는 고객수 COUNT 하기 위한 SCALAR TYPE 변수 선언\r\n"
				+ "    CUSCNT NUMBER;\r\n" + "--    EMP COMM의 DATA TYPE, LENGTH 참조하여 변수 선언 \r\n"
				+ "    V_COMM EMP.COMM%TYPE;\r\n" + "    \r\n" + "BEGIN\r\n" + "--    EMP 테이블 가져오기\r\n"
				+ "    FOR R_CUR_EMP IN CUR_EMP\r\n" + "    LOOP\r\n" + "        CUSCNT:=0;\r\n"
				+ "--        커서 OPEN\r\n" + "        OPEN CUR_CUSTOMER;\r\n" + "        LOOP\r\n"
				+ "--            BULK BINDING을 통해 LIMIT 1000으로 1000개씩 FETCH\r\n"
				+ "            FETCH CUR_CUSTOMER BULK COLLECT INTO TAB_CUSTOMER LIMIT 1000;\r\n"
				+ "--            CUSTOMER의 ACCOUNT_MGR를 FOR문으로 돌면서 EMP의 EMPNO와 같은 경우의 수 COUNT \r\n"
				+ "            FOR I IN 1..TAB_CUSTOMER.COUNT\r\n" + "            LOOP\r\n"
				+ "                IF TAB_CUSTOMER(I) = R_CUR_EMP.EMPNO THEN\r\n"
				+ "                    CUSCNT:=CUSCNT+1;\r\n" + "                END IF;\r\n"
				+ "            END LOOP;\r\n" + "--            CUR_CUSTOMER이 더이상 없으면 LOOP문 종료\r\n"
				+ "            EXIT WHEN CUR_CUSTOMER%NOTFOUND;\r\n" + "        END LOOP;    \r\n"
				+ "--        커서 CLOSE\r\n" + "        CLOSE CUR_CUSTOMER;\r\n" + "        \r\n"
				+ "--        조건에 맞게 COMM 계산\r\n" + "        IF R_CUR_EMP.JOB IN ('ANALYST','PRESIDENT') THEN\r\n"
				+ "            V_COMM:=0;\r\n" + "        ELSIF CUSCNT>=100000 THEN\r\n"
				+ "            V_COMM:=2000;\r\n" + "        ELSE\r\n" + "            V_COMM:=1000;\r\n"
				+ "        END IF;\r\n" + "\r\n" + "--        BONUS테이블에 INSERT        \r\n"
				+ "        INSERT INTO BONUS(ENAME,JOB,SAL,COMM)\r\n"
				+ "        VALUES(R_CUR_EMP.ENAME,R_CUR_EMP.JOB,R_CUR_EMP.SAL,R_CUR_EMP.COMM+V_COMM); \r\n"
				+ "    END LOOP;\r\n" + "        \r\n" + "\r\n" + "--    트랜잭션 COMMIT\r\n" + "    COMMIT;\r\n" + "\r\n"
				+ "--    예외처리\r\n" + "    EXCEPTION\r\n" + "                WHEN OTHERS THEN \r\n"
				+ "                ROLLBACK;\r\n" + "                DBMS_OUTPUT.PUT_LINE('ERROR: '||SQLERRM);     \r\n"
				+ "END;";

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
