<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import = "java.util.*" %> <!-- ArrayList 사용 -->
<%@ page import = "vo.*" %>
<%
	// 1. 유효성 검사
	// 페이징을 위한 요청값 처리
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	if(request.getParameter("rowPerPage") != null) {
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	// 마리아db와 다르게 오라클은 limit을 쓸 수 없기 때문에 beginRow와 endRow 둘다 구해야 한다
	/*
		rowPerPage가 10일 때
		currentPage		beginRow		endRow
		1				1				10
		2				11				20
		3				21				30
		4				31				40
	*/
	int beginRow = (currentPage - 1) * rowPerPage + 1;
	int endRow = beginRow + (rowPerPage - 1);
	
	// 2. 모델값 구하기
	// 드라이버 로딩 및 db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(driver);
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) totalCnt 모델셋
	// 마지막 페이지에서 endRow의 값이 달라지기 때문에 totalCnt를 구해야 한다
	int totalCnt = 0;
	
	// 쿼리 작성
	String totalCntSql = "SELECT count(*) FROM EMPLOYEES";
	PreparedStatement totalCntStmt = conn.prepareStatement(totalCntSql);
	ResultSet totalCntRs = totalCntStmt.executeQuery();
	
	// 모델셋 값을 변수에 저장
	if(totalCntRs.next()) {
		totalCnt = totalCntRs.getInt(1);
		// 반환할 컬럼이 하나일 때에는 index(숫자) 사용을 권장
	}
	
	// endRow if문 추가
	if(endRow > totalCnt) {
		endRow = totalCnt;
	}
	
	// 디버깅
	System.out.println("현재 " + currentPage + "페이지 <- employeeList currentPage");
	System.out.println(rowPerPage + "개씩 <- employeeList rowPerPage");
	System.out.println(beginRow + "번부터 <- employeeList beginRow");
	System.out.println(endRow + "번까지 <- employeeList endRow");
	System.out.println("전체 행 갯수: " + totalCnt + "개 <- employeeList totalCnt");
	
	// 2-2) employeeList 모델셋
	// employees 테이블의 모든 정보를 조회 // 페이징을 위해 rownum 사용 // hireDate 내림차순으로 정렬
	/*
		SELECT e3.*
			FROM
				(SELECT
					rownum rnum,
					e2.*
				FROM
					(SELECT
						rownum,
						e1.*
					FROM employees e1
					ORDER BY e1.hire_date DESC) e2) e3
		WHERE e3.rnum BETWEEN ? AND ?
	*/
	String employeeListSql = "SELECT e3.* FROM (SELECT rownum rnum, e2.* FROM (SELECT rownum, e1.* FROM employees e1 ORDER BY e1.hire_date DESC) e2) e3 WHERE e3.rnum BETWEEN ? AND ?";
	PreparedStatement employeeListStmt = conn.prepareStatement(employeeListSql);
	employeeListStmt.setInt(1, beginRow);
	employeeListStmt.setInt(2, endRow);
	ResultSet employeeListRs = employeeListStmt.executeQuery();
	
	// ArrayList로 바꾸기
	ArrayList<Employee> employeeList = new ArrayList<Employee>();
	while(employeeListRs.next()) {
		Employee e = new Employee();
		e.setEmployeeId(employeeListRs.getInt("employee_id"));
		e.setFirstName(employeeListRs.getString("first_name"));
		e.setLastName(employeeListRs.getString("last_name"));
		e.setEmail(employeeListRs.getString("email"));
		e.setPhoneNumber(employeeListRs.getString("phone_number"));
		e.setHireDate(employeeListRs.getString("hire_date"));
		e.setJobId(employeeListRs.getString("job_id"));
		e.setSalary(employeeListRs.getDouble("salary"));
		e.setCommissionPct(employeeListRs.getDouble("commission_pct"));
		e.setManagerId(employeeListRs.getInt("manager_id"));
		e.setDepartmentId(employeeListRs.getInt("department_id"));
		employeeList.add(e);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>employeeList.jsp</title>
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
	<!---------------------- employeeList 모델셋 시작 ---------------------->
	<table class="table table-bordered">
		<thead class="table-secondary">
			<tr>
				<th>employeeId</th>
				<th>firstName</th>
				<th>lastName</th>
				<th>email</th>
				<th>phoneNumber</th>
				<th>hireDate</th>
				<th>jobId</th>
				<th>salary</th>
				<th>commissionPct</th>
				<th>managerId</th>
				<th>departmentId</th>
				<th>수정 / 삭제</th>
			</tr>
		</thead>
		<tbody>
			<%
				for(Employee e : employeeList) {
			%>
					<tr>
						<td><%=e.getEmployeeId()%></td>
						<td><%=e.getFirstName()%></td>
						<td><%=e.getLastName()%></td>
						<td><%=e.getEmail()%></td>
						<td><%=e.getPhoneNumber()%></td>
						<td><%=e.getHireDate().substring(0, 10)%></td>
						<td><%=e.getJobId()%></td>
						<td><%=e.getSalary()%></td>
						<td><%=e.getCommissionPct()%></td>
						<td><%=e.getManagerId()%></td>
						<td><%=e.getDepartmentId()%></td>
						<td>
							<!-- 세션 정보가 일치할 때만 수정 / 삭제 버튼 출력 -->
							<% 
								if(session.getAttribute("loginEmployee") != null) {
									// 세션 값 불러오기
									Object o = session.getAttribute("loginEmployee");
									Employee sessionEmployee = null;
									if(o instanceof Employee) { // instanceof연산자 : 객체변수 instanceof 타입
										sessionEmployee = (Employee)o;
									}
									// 세션 정보 변수에 저장
									int sessionEmployeeId = sessionEmployee.getEmployeeId();
										// 세션 정보가 일치하는지 확인
										if(sessionEmployeeId == e.getEmployeeId()) {
							%>
											<a href="<%=request.getContextPath()%>/employee/modifyEmployee.jsp?employeeId=<%=e.getEmployeeId()%>" class="btn btn-sm">
												&#x270F;
											</a>
											<a href="<%=request.getContextPath()%>/employee/removeEmployeeAction.jsp?employeeId=<%=e.getEmployeeId()%>" class="btn btn-sm">
												&#x1F5D1;
											</a>
							<%
										}
									
								}
							%>
						</td>
					</tr>
			<%
				}
			%>
		</tbody>
	</table>
	<!---------------------- employeeList 모델셋 끝 ---------------------->
	
	<div class="text-center">
		<!---------------------------- 페이징 시작 ---------------------------->
		<%
			if(currentPage > 1) { // 1페이지면 "이전"을 출력하지 않는다
		%>
				<a href="<%=request.getContextPath()%>/employee/employeeList.jsp?currentPage=<%=currentPage - 1%>&rowPerPage=<%=rowPerPage%>" class="btn btn-sm btn-secondary">이전</a>
		<%
			}
		%>
		
		<%=currentPage%>페이지
		
		<%
			if(endRow != totalCnt) { // 마지막 페이지면 "다음"을 출력하지 않는다
		%>
				<a href="<%=request.getContextPath()%>/employee/employeeList.jsp?currentPage=<%=currentPage + 1%>&rowPerPage=<%=rowPerPage%>" class="btn btn-sm btn-secondary">다음</a>
		<%
			}
		%>
		<!---------------------------- 페이징 끝 ---------------------------->
	</div>
</div>
</body>
</html>