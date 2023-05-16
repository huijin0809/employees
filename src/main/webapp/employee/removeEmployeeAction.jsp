<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "vo.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%
	//1. 유효성 검사
	// 세션정보가 없거나 employeeId 값이 없으면 이 페이지에 올 수 없다
	if(session.getAttribute("loginEmployee") == null
			|| request.getParameter("employeeId") == null
			|| request.getParameter("employeeId").equals("")) {
		response.sendRedirect(request.getContextPath() + "/employee/employeeList.jsp");
		return;
	}
	int paramEmployeeId = Integer.parseInt(request.getParameter("employeeId"));
	
	// 세션정보 불러오기
	Object o = session.getAttribute("loginEmployee");
	Employee sessionEmployee = null;
	if(o instanceof Employee) { // instanceof연산자 : 객체변수 instanceof 타입
		sessionEmployee = (Employee)o;
	}
	int sessionEmployeeId = sessionEmployee.getEmployeeId();
	
	// employeeId값과 세션정보가 일치하는지 확인
	if(paramEmployeeId != sessionEmployeeId) {
		response.sendRedirect(request.getContextPath() + "/employee/employeeList.jsp");
		return;
	}
	
	// 2. 모델값 구하기
	// 2-1) 드라이버 로딩 및 db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(driver);
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-2) 쿼리 작성
	String sql = "DELETE FROM employees WHERE employee_id = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, paramEmployeeId);
	
	// 2-3) 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	String msg = null;
	if(row == 1) { // 성공시 로그아웃 되므로 home으로
		System.out.println(row + " <- removeEmployeeAction 성공");
		session.invalidate(); // 사원정보가 삭제되었으므로 세션 초기화
		msg = URLEncoder.encode("정상적으로 삭제 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	} else { // 실패시 msg와 함께 list로
		System.out.println(row + " <- removeEmployeeAction 실패");
		msg = URLEncoder.encode("삭제되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/employeeList.jsp?msg=" + msg);
		return;
	}
%>