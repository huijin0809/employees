<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "vo.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>home.jsp</title>
	<!-- 부트스트랩5 사용 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container mt-5">
	<!------------------------------------------ 로그인 폼 시작 ------------------------------------------>
	<%
		// 세션값이 null일때만 로그인 폼 출력
		if(session.getAttribute("loginEmployee") == null) {
	%>
			<h1>로그인</h1>
			<div class="text-danger">
				<%	// msg 발생시 출력
					if(request.getParameter("msg") != null) {
				%>
						<%=request.getParameter("msg")%>
				<%
					}
				%>
			</div>
			<!-- employeeId, firstName, lastName 을 이용하여 로그인 -->
			<form action="<%=request.getContextPath()%>/employee/loginAction.jsp" method="post">
				<table>
					<tr>
						<th>employeeId</th>
						<td>
							<input type="number" name="employeeId">
						</td>
					</tr>
					<tr>
						<th>firstName</th>
						<td>
							<input type="text" name="firstName">
						</td>
					</tr>
					<tr>
						<th>lastName</th>
						<td>
							<input type="text" name="lastName">
						</td>
					</tr>
				</table>
				<button type="submit" class="btn btn-secondary">로그인</button>
			</form>
	<%
		}
	%>
	<!------------------------------------------ 로그인 폼 끝 ------------------------------------------>
	
	<!------------------------------------------ 시작페이지 출력 ------------------------------------------>
	<%
		// 세션값이 null이 아니면 출력
		if(session.getAttribute("loginEmployee") != null) {
			// 세션값 받아오기
			Object o = session.getAttribute("loginEmployee");
			Employee sessionEmployee = null;
			if(o instanceof Employee) { // instanceof연산자 : 객체변수 instanceof 타입
				sessionEmployee = (Employee)o;
			}
	%>
			<h1>welcome!</h1>
			<p class="card-text">환영합니다 <%=sessionEmployee.getFirstName()%>님 :)</p>
			<div class="card" style="width:400px">
				<img class="card-img-top" src="<%=request.getContextPath()%>/img/cardImg.png" alt="Card image" style="width:100%">
				<div class="card-body">
					<h4 class="card-title"><%=sessionEmployee.getFirstName()%> <%=sessionEmployee.getLastName()%></h4>
				    <p class="card-text"> employeeId : <%=sessionEmployee.getEmployeeId()%></p>
				    <a href="<%=request.getContextPath()%>/employee/logoutAction.jsp" class="btn btn-outline-secondary">
						로그아웃
					</a>
				</div>
			</div>
	<%
		}
	%>
	<!------------------------------------------ 시작페이지 끝 ------------------------------------------>
	<br>
	<div>
		<a href="<%=request.getContextPath()%>/employee/employeeList.jsp" class="btn btn-outline-secondary">
			사원 목록 보기
		</a>
	</div>
</div>
</body>
</html>