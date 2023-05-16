<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
	// 1. 유효성 검사
	// 1-1) 세션값
	// 로그인 되어 있는 상태면 이 페이지에 올 수 없다
	if(session.getAttribute("loginEmployee") != null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// 1-2) 요청값
	// employeeId, firstName, lastName
	String msg = null;
	if(request.getParameter("employeeId") == null
			|| request.getParameter("employeeId").equals("")) {
		msg = URLEncoder.encode("employeeId를 입력해주세요", "utf-8");
	} else if(request.getParameter("firstName") == null
			|| request.getParameter("firstName").equals("")) {
		msg = URLEncoder.encode("firstName을 입력해주세요", "utf-8");	
 	} else if(request.getParameter("lastName") == null
			|| request.getParameter("lastName").equals("")) {
		msg = URLEncoder.encode("lastName을 입력해주세요", "utf-8");
	}
	// null이거나 공백이면 home으로
	if(msg != null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	}
	// null이거나 공백이 아니면 값 받아오기
	int employeeId = Integer.parseInt(request.getParameter("employeeId"));
	String firstName = request.getParameter("firstName");
	String lastName = request.getParameter("lastName");
	System.out.println(employeeId + " <- loginAction employeeId");
	System.out.println(firstName + " <- loginAction firstName");
	System.out.println(lastName + " <- loginAction lastName");
	
	// 2. 모델값 구하기
	// 2-1) 드라이버 로딩 및 db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(driver);
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-2) 쿼리 작성
	// 입력한 정보가 db에 있는지 조회
	String sql = "SELECT count(*) FROM employees WHERE employee_id = ? AND first_name = ? AND last_name = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, employeeId);
	stmt.setString(2, firstName);
	stmt.setString(3, lastName);
	ResultSet rs = stmt.executeQuery();
	
	// 모델값을 변수에 저장
	int empCnt = 0;
	if(rs.next()) {
		empCnt = rs.getInt(1);
	}
	
	// 입력한 정보가 존재하면(count가 1이면) 세션에 저장
	if(empCnt == 1) {
		Employee loginEmployee = new Employee();
		loginEmployee.setEmployeeId(employeeId);
		loginEmployee.setFirstName(firstName);
		loginEmployee.setLastName(lastName);
		session.setAttribute("loginEmployee", loginEmployee);
		System.out.println("로그인 성공");
	} else {
		msg = URLEncoder.encode("로그인에 실패하였습니다", "utf-8");
		System.out.println("로그인 실패");
	}
	
	// 홈으로 리다이렉션
	response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
%>