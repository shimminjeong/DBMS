package com.simminjeong.procedure.service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.simminjeong.procedure.entity.Bonus;
import com.simminjeong.procedure.entity.Emp;
import com.simminjeong.procedure.util.JDBCUtil;

public class statementFetchMain2 {

	public static void main(String[] args) throws SQLException {

		Statement stmt;
		ResultSet rs;

//		Oracle JDBC 드라이버 로드
		Connection conn = JDBCUtil.getConnection();

//		emp 정보를 담을 list객체 생성
		List<Emp> empInfo = new ArrayList<Emp>();

//		bonus 정보를 담을 list객체 생성
		List<Bonus> bonusInfo = new ArrayList<Bonus>();

//		실행 전 현재 시작 측정
		long startTime = System.currentTimeMillis();

//		emp테이블 조회
//		comm이 null인경우 0으로 바꿈
		stmt = conn.createStatement();
		rs = stmt.executeQuery("SELECT EMPNO, ENAME, JOB, SAL, NVL(COMM,0) AS COMM FROM EMP");

		System.out.println("1");
//		empInfo에 넣기
		while (rs.next()) {
			empInfo.add(new Emp(Integer.parseInt(rs.getString("EMPNO")), rs.getString("ENAME"), rs.getString("JOB"),
					Integer.parseInt(rs.getString("SAL")), Integer.parseInt(rs.getString("COMM"))));
		}

//		customer테이블의 매니저 번호(ACCOUNT_MGR) 조회
		stmt = conn.createStatement();
		rs = stmt.executeQuery("SELECT ACCOUNT_MGR FROM CUSTOMER");

//		ACCOUNT_MGR별로 관리하는 고객 수 count
		Map<Integer, Integer> customerMap = new HashMap<>();

//		ACCOUNT_MGR(mgrno)별로 고객 수 count(cuscnt)
		while (rs.next()) {

			Integer mgrno = rs.getInt("ACCOUNT_MGR");
			Integer cuscnt = customerMap.get(mgrno);

			if (cuscnt == null) {
				customerMap.put(mgrno, 1);
			} else {
				customerMap.put(mgrno, cuscnt + 1);
			}
		}

//		관리 고객수가 10만 보다 큰 key를 저장할 리스트
		List<Integer> tenhigher = new ArrayList<>();
//		관리 고객수가 10만 보다 작은 key를 저장할 리스트
		List<Integer> tenlower = new ArrayList<>();

//		조건에 맞게 키 저장
		for (Integer mgrno : customerMap.keySet()) {
			if (customerMap.get(mgrno) >= 100000) {
				tenhigher.add(mgrno);
			} else {
				tenlower.add(mgrno);
			}
		}

//		조건에 맞게 comm 계산해서 bonusinfo객체에 add
		for (Emp emp : empInfo) {
			if (emp.getJob().equals("ANALYST") || emp.getJob().equals("PRESIDENT")) {
				bonusInfo.add(new Bonus(emp.getEname(), emp.getJob(), emp.getSal(), 0));
			} else if (tenhigher.contains(emp.getEmpno())) {
				bonusInfo.add(new Bonus(emp.getEname(), emp.getJob(), emp.getSal(), emp.getComm() + 2000));
			} else {
				bonusInfo.add(new Bonus(emp.getEname(), emp.getJob(), emp.getSal(), emp.getComm() + 1000));
			}
		}

//		bonus list 객체에 있는 정보 bonus테이블에 insert
		for (Bonus bonus : bonusInfo) {
			stmt = conn.createStatement();
			String insertsql = "INSERT INTO BONUS(ENAME,JOB,SAL,COMM) VALUES('" + bonus.getEname() + "','"
					+ bonus.getJob() + "','" + bonus.getSal() + "','" + bonus.getComm() + "')";
			stmt.executeUpdate(insertsql);
		}

//		실행 후 현재 시작 측정
		long endTime = System.currentTimeMillis();

//		실행 전과 실행 후 시간 측정
		double time = (endTime - startTime) / 1000.0;
		System.out.println("소요 시간 : " + time + "초");

//		connection close
		conn.close();

	}

}
