<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vo.*" %>
<%@ page import="java.sql.*" %>
<%
	// 1. 유효성 검사
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
	// 드라이버 로딩 및 db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(driver);
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) 수정 전 입력값 조회를 위한 쿼리 작성
	// SELECT * FROM employees WHERE employee_Id = ?
	String sql = "SELECT employee_id employeeId, first_name firstName, last_name lastName, email email, phone_number phoneNumber, hire_date hireDate, job_id jobId, Salary salary, commission_pct commissionPct, manager_id managerId, department_id departmentId FROM employees WHERE employee_id = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, paramEmployeeId);
	ResultSet rs = stmt.executeQuery();
	
	// Vo타입으로 바꾸기
	Employee employee = null;
	if(rs.next()) {
		employee = new Employee();
		employee.setEmployeeId(rs.getInt("employeeId"));
		employee.setFirstName(rs.getString("firstName"));
		employee.setLastName(rs.getString("lastName"));
		employee.setEmail(rs.getString("email"));
		employee.setPhoneNumber(rs.getString("phoneNumber"));
		employee.setHireDate(rs.getString("hireDate"));
		employee.setJobId(rs.getString("jobId"));
		employee.setSalary(rs.getDouble("salary"));
		employee.setCommissionPct(rs.getDouble("commissionPct"));
		employee.setManagerId(rs.getInt("managerId"));
		employee.setDepartmentId(rs.getInt("departmentId"));
	}
	
	// 2-2) 외래키 칼럼 조회를 위한 쿼리 작성
	// JOBS
	String jobSql = "SELECT job_id jobId FROM JOBS";
	PreparedStatement jodStmt = conn.prepareStatement(jobSql);
	ResultSet jodRs = jodStmt.executeQuery();
	// DEPARTMENTS
	String departmentSql = "SELECT department_id deptId FROM DEPARTMENTS";
	PreparedStatement departmentStmt = conn.prepareStatement(departmentSql);
	ResultSet departmentRs = departmentStmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>modifyEmployee.jsp</title>
	<!-- 부트스트랩5 사용 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<!-- include 페이지 : 메인메뉴(가로) -->	
<div>
	<!-- 액션태그 -->
	<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
</div>
<!-------- include 페이지 끝 ------->	

<div class="container mt-5">
	<!---------------------- modify form 시작 ---------------------->
	<h3>정보 수정</h3>
		<!-- 실패시 에러메세지 출력 -->
		<div class="text-danger">
			<%
				if(request.getParameter("msg") != null) {
			%>
					<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
		<form action="<%=request.getContextPath()%>/employee/modifyEmployeeAction.jsp" method="post">
			<table class="table table-bordered">
				<tr>
					<th class="table-secondary">employeeId</th>
					<td>
						<input type="number" name="employeeId" value="<%=employee.getEmployeeId()%>" readonly>
						<!-- 기본키이므로 수정불가(readonly) -->
					</td>
				</tr>
				<tr>
					<th class="table-secondary">firstName</th>
					<td>
						<input type="text" name="firstName" value="<%=employee.getFirstName()%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">lastName</th>
					<td>
						<input type="text" name="lastName" value="<%=employee.getLastName()%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">email</th>
					<td>
						<input type="text" name="email" value="<%=employee.getEmail()%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">phoneNumber</th>
					<td>
						<input type="text" name="phoneNumber" value="<%=employee.getPhoneNumber()%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">hireDate</th>
					<td>
						<input type="date" name="hireDate" value="<%=employee.getHireDate().substring(0,10)%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">jobId</th>
					<td>
						<select name="jobId">
							<%
								while(jodRs.next()) {
							%>
								<option value="<%=jodRs.getString("jobId")%>" <%if(jodRs.getString("jobId").equals(employee.getJobId())) {%> selected <%}%>>
									<%=jodRs.getString("jobId")%>
								</option>
							<%
								}
							%>
						</select>
					</td>
				</tr>
				<tr>
					<th class="table-secondary">salary</th>
					<td>
						<input type="number" name="salary" value="<%=employee.getSalary()%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">commissionPct</th>
					<td>
						<input type="number" name="commissionPct" value="<%=employee.getCommissionPct()%>" step="0.01" max="0.99" placeholder="범위: 1미만">
						<!-- 소숫점 입력 허용, 입력 범위 1미만으로 제한하기 -->
					</td>
				</tr>
				<tr>
					<th class="table-secondary">managerId</th>
					<td>
						<input type="number" name="managerId" value="<%=employee.getManagerId()%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">departmentId</th>
					<td>
						<select name="departmentId">
							<%
								while(departmentRs.next()) {
							%>
								<option value="<%=departmentRs.getInt("deptId")%>" <%if(departmentRs.getInt("deptId") == employee.getDepartmentId()) {%> selected <%}%>>
									<%=departmentRs.getInt("deptId")%>
								</option>
							<%
								}
							%>
						</select>
					</td>
				</tr>
			</table>
			<a href="<%=request.getContextPath()%>/employee/employeeList.jsp" class="btn btn-sm btn-outline-secondary">
				뒤로가기
			</a>
			<button type="submit" class="btn btn-sm btn-secondary">수정</button>
		</form>
	<!---------------------- modify form 끝 ---------------------->
</div>
</body>
</html>