<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="container mt-5">
	<ul class="nav nav-tabs" role="tablist">
	<%
		// 세션 값이 null이 아니면 추가/로그아웃 출력
		if(session.getAttribute("loginEmployee") != null) {
	%>
			<li class="nav-item">
				<a href="<%=request.getContextPath()%>/employee/addEmployee.jsp" class="nav-link active">
					사원 추가
				</a>
			</li>
			<li class="nav-item">
				<a href="<%=request.getContextPath()%>/employee/logoutAction.jsp" class="nav-link active">
					로그아웃
				</a>
			</li>
	<%
		// 세션 값이 null이면 로그인 출력
		} else {
	%>
			<li class="nav-item">
				<a href="<%=request.getContextPath()%>/home.jsp" class="nav-link active">
					로그인
				</a>
			</li>
	<%
		}
	%>
	</ul>
</div>