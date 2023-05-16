<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "vo.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%
	// 1. 유효성 검사
	// 1-1) 세션값
	// 로그아웃 상태면 이 페이지에 올 수 없다
	if(session.getAttribute("loginEmployee") == null) {
		response.sendRedirect(request.getContextPath() + "/employee/employeeList.jsp");
		return;
	}
	// 1-2) 요청값
	// employeeId, firstName, lastName, email, phoneNumber, hireDate, jobId, salary, commissionPct, managerId, departmentId
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
	} else if(request.getParameter("email") == null
			|| request.getParameter("email").equals("")) {
		msg = URLEncoder.encode("email을 입력해주세요", "utf-8");
	} else if(request.getParameter("phoneNumber") == null
			|| request.getParameter("phoneNumber").equals("")) {
		msg = URLEncoder.encode("phoneNumber를 입력해주세요", "utf-8");
	} else if(request.getParameter("hireDate") == null
			|| request.getParameter("hireDate").equals("")) {
		msg = URLEncoder.encode("hireDate를 입력해주세요", "utf-8");
	} else if(request.getParameter("jobId") == null
			|| request.getParameter("jobId").equals("")) {
		msg = URLEncoder.encode("jobId를 입력해주세요", "utf-8");
	} else if(request.getParameter("salary") == null
			|| request.getParameter("salary").equals("")) {
		msg = URLEncoder.encode("salary를 입력해주세요", "utf-8");
	} else if(request.getParameter("commissionPct") == null
			|| request.getParameter("commissionPct").equals("")) {
		msg = URLEncoder.encode("commissionPct를 입력해주세요", "utf-8");
	} else if(request.getParameter("managerId") == null
			|| request.getParameter("managerId").equals("")) {
		msg = URLEncoder.encode("managerId를 입력해주세요", "utf-8");
	} else if(request.getParameter("departmentId") == null
			|| request.getParameter("departmentId").equals("")) {
		msg = URLEncoder.encode("departmentId를 입력해주세요", "utf-8");
	}
	// null이거나 공백이면 msg와 함께 리다이렉션
	if(msg != null) {
		response.sendRedirect(request.getContextPath() + "/employee/addEmployee.jsp?msg=" + msg);
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
	
	// 2-2) employeeId 중복검사
	// employee_id가 기본키이므로 먼저 중복검사를 해본다
	int employeeId = Integer.parseInt(request.getParameter("employeeId"));
	
	String employeeIdCntSql = "SELECT count(*) FROM employees WHERE employee_id = ?";
	PreparedStatement employeeIdCntStmt = conn.prepareStatement(employeeIdCntSql);
	employeeIdCntStmt.setInt(1, employeeId);
	ResultSet employeeIdCntRs = employeeIdCntStmt.executeQuery();
	
	// 갯수 확인
	int employeeIdCnt = 0;
	if(employeeIdCntRs.next()) {
		employeeIdCnt = employeeIdCntRs.getInt("count(*)");
		// 해당 employeeId의 갯수를 cnt 변수에 저장
		// 0일 경우 중복 없음 
	}
	
	// 0보다 클 경우 중복 있음 // msg와 함께 리다이렉션
	if(employeeIdCnt > 0) {
		System.out.println(employeeIdCnt + " <- addEmployeeAction 중복된 아이디 갯수");
		msg = URLEncoder.encode("중복된 employeeId입니다 ", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/addEmployee.jsp?msg=" + msg);
		return;
	} else {
		System.out.println("addEmployeeAction 중복된 아이디 없음");
	}
	
	// 2-3) email 중복검사
	// email이 유니크키이므로 중복검사를 해본다
	String email = request.getParameter("email");
	
	String emailCntSql = "SELECT count(*) FROM employees WHERE email = ?";
	PreparedStatement emailCntStmt = conn.prepareStatement(emailCntSql);
	emailCntStmt.setString(1, email);
	ResultSet emailCntRs = emailCntStmt.executeQuery();
	
	// 갯수 확인
	int emailCnt = 0;
	if(emailCntRs.next()) {
		emailCnt = emailCntRs.getInt("count(*)");
		// 해당 email의 갯수를 cnt 변수에 저장
		// 0일 경우 중복 없음 
	}
	
	// 0보다 클 경우 중복 있음 // msg와 함께 리다이렉션
	if(emailCnt > 0) {
		System.out.println(emailCnt + " <- addEmployeeAction 중복된 이메일 갯수");
		msg = URLEncoder.encode("중복된 email입니다 ", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/addEmployee.jsp?msg=" + msg);
		return;
	} else {
		System.out.println("addEmployeeAction 중복된 이메일 없음");
	}
	
	// 중복 없으면 나머지 값도 저장
	String firstName = request.getParameter("firstName");
	String lastName = request.getParameter("lastName");
	String phoneNumber = request.getParameter("phoneNumber");
	String hireDate = request.getParameter("hireDate");
	String jobId = request.getParameter("jobId");
	double salary = Double.parseDouble(request.getParameter("salary")); // 더블 타입으로 형변환
	double commissionPct = Double.parseDouble(request.getParameter("commissionPct")); // 더블 타입으로 형변환
	int managerId = Integer.parseInt(request.getParameter("managerId"));
	int departmentId = Integer.parseInt(request.getParameter("departmentId"));
	
	// 2-3) 쿼리 작성
	String sql = "INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, employeeId);
	stmt.setString(2, firstName);
	stmt.setString(3, lastName);
	stmt.setString(4, email);
	stmt.setString(5, phoneNumber);
	stmt.setString(6, hireDate);
	stmt.setString(7, jobId);
	stmt.setDouble(8, salary);
	stmt.setDouble(9, commissionPct);
	stmt.setInt(10, managerId);
	stmt.setInt(11, departmentId);
	
	// 2-3) 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) { // 성공시
		System.out.println(row + " <- addEmployeeAction 성공");
		msg = URLEncoder.encode("정상적으로 추가 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/employeeList.jsp?msg=" + msg);
		return;
	} else { // 실패시
		System.out.println(row + " <- addEmployeeAction 실패");
		msg = URLEncoder.encode("추가되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/addEmployee.jsp?msg=" + msg);
		return;
	}
%>