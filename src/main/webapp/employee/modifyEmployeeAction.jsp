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
	
	// 요청값
	// firstName, lastName, email, phoneNumber, hireDate, jobId, salary, commissionPct, managerId, departmentId
	String msg = null;
	if(request.getParameter("firstName") == null
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
		response.sendRedirect(request.getContextPath() + "/employee/modifyEmployee.jsp?employeeId=" + paramEmployeeId + "&msg=" + msg);
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
	
	// 2-2) email 중복검사
	// email이 유니크키이므로 중복검사를 해본다
	String email = request.getParameter("email");
	// 기존 입력 값을 제외하고 조회해야하기 때문에 WHERE절에 employee_id가 일치하지 않는다는 조건을 추가
	String emailCntSql = "SELECT count(*) FROM employees WHERE email = ? AND employee_id != ?";
	PreparedStatement emailCntStmt = conn.prepareStatement(emailCntSql);
	emailCntStmt.setString(1, email);
	emailCntStmt.setInt(2, paramEmployeeId);
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
		System.out.println(emailCnt + " <- modifyEmployeeAction 중복된 이메일 갯수");
		msg = URLEncoder.encode("중복된 email입니다 ", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/modifyEmployee.jsp?employeeId=" + paramEmployeeId + "&msg=" + msg);
		return;
	} else {
		System.out.println("modifyEmployeeAction 중복된 이메일 없음");
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
	String sql = "UPDATE employees SET first_name = ?, last_name = ?, email = ?, phone_number = ?, hire_date = ?, job_id = ?, salary = ?, commission_pct = ?, manager_id = ?, department_id = ? WHERE employee_id = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, firstName);
	stmt.setString(2, lastName);
	stmt.setString(3, email);
	stmt.setString(4, phoneNumber);
	stmt.setString(5, hireDate);
	stmt.setString(6, jobId);
	stmt.setDouble(7, salary);
	stmt.setDouble(8, commissionPct);
	stmt.setInt(9, managerId);
	stmt.setInt(10, departmentId);
	stmt.setInt(11, paramEmployeeId);
	
	// 2-3) 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) { // 성공시
		System.out.println(row + " <- modifyEmployeeAction 성공");
		msg = URLEncoder.encode("정상적으로 수정 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/employeeList.jsp?msg=" + msg);
		return;
	} else { // 실패시
		System.out.println(row + " <- modifyEmployeeAction 실패");
		msg = URLEncoder.encode("수정되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/employee/modifyEmployee.jsp?employeeId=" + paramEmployeeId + "&msg=" + msg);
		return;
	}
%>