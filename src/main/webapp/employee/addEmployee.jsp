<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	// 유효성 검사
	// 로그아웃 상태면 이 페이지에 올 수 없다
	if(session.getAttribute("loginEmployee") == null) {
		response.sendRedirect(request.getContextPath() + "/employeeList.jsp");
		return;
	}

	// 드라이버 로딩 및 db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(driver);
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 외래키 칼럼 조회를 위한 쿼리 작성
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
<title>addEmployee.jsp</title>
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
	<!---------------------- add form 시작 ---------------------->
	<h3>사원 추가</h3>
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
		<form action="<%=request.getContextPath()%>/employee/addEmployeeAction.jsp" method="post">
			<table class="table table-bordered">
				<tr>
					<th class="table-secondary">employeeId</th>
					<td>
						<input type="number" name="employeeId">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">firstName</th>
					<td>
						<input type="text" name="firstName">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">lastName</th>
					<td>
						<input type="text" name="lastName">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">email</th>
					<td>
						<input type="text" name="email">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">phoneNumber</th>
					<td>
						<input type="text" name="phoneNumber">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">hireDate</th>
					<td>
						<input type="date" name="hireDate">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">jobId</th>
					<td>
						<select name="jobId">
							<%
								while(jodRs.next()) {
							%>
								<option value="<%=jodRs.getString("jobId")%>"><%=jodRs.getString("jobId")%></option>
							<%
								}
							%>
						</select>
					</td>
				</tr>
				<tr>
					<th class="table-secondary">salary</th>
					<td>
						<input type="number" name="salary">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">commissionPct</th>
					<td>
						<input type="number" name="commissionPct" step="0.01" max="0.99" placeholder="범위: 1미만">
						<!-- 소숫점 입력 허용, 입력 범위 1미만으로 제한하기 -->
					</td>
				</tr>
				<tr>
					<th class="table-secondary">managerId</th>
					<td>
						<input type="number" name="managerId">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">departmentId</th>
					<td>
						<select name="departmentId">
							<%
								while(departmentRs.next()) {
							%>
								<option value="<%=departmentRs.getInt("deptId")%>"><%=departmentRs.getInt("deptId")%></option>
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
			<button type="submit" class="btn btn-sm btn-secondary">추가</button>
		</form>
	<!---------------------- add form 끝 ---------------------->
</div>
</body>
</html>