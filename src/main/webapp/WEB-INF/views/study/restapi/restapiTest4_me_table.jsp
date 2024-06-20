<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>restapiTest4.jsp</title>
  <jsp:include page="/WEB-INF/views/include/bs4.jsp" />
  <script>
  	'use strict';
  	
  	const API_KEY = 'J7IMGMadqPcAc012%2BH%2BG2e%2B2f5VgxsTbVJWXBpQV614KJO1RBzQBIE%2Bu7UfF1AyWkKqiuKJtWf86UvsjMVlNgw%3D%3D';
  	
  	async function getCrimeDate() {
  		let year = $("#year").val();
  		let apiYear = '';
  		
  		if(year == 2015) apiYear = "/15084592/v1/uddi:fbbfd36d-d528-4c8e-aa9b-d5cdbdeec669";
  		else if(year == 2016) apiYear = "/15084592/v1/uddi:21ec6fa1-a033-413b-b049-8433f5b446ff";
  		else if(year == 2017) apiYear = "/15084592/v1/uddi:67117bd9-5ee1-4e07-ae4a-bfe0861ee116";
  		else if(year == 2018) apiYear = "/15084592/v1/uddi:2d687e27-b5c3-4bdb-9b77-c644dcafcbc7";
  		else if(year == 2019) apiYear = "/15084592/v1/uddi:b6cc7731-181b-48e1-9a6c-ae81388e46b0";
  		else if(year == 2020) apiYear = "/15084592/v1/uddi:fdde1218-987c-49ba-9326-8e3ba276141e";
  		else if(year == 2021) apiYear = "/15084592/v1/uddi:943e757d-462b-4b3a-ab9f-9a8553637ca2";
  		else if(year == 2022) apiYear = "/15084592/v1/uddi:943e757d-462b-4b3a-ab9f-9a8553637ca2";
  		
  		let url = "https://api.odcloud.kr/api";
  		url += apiYear;
  		url += "?serviceKey=" + API_KEY;
  		url += "&page=1&perPage=200";
  		
  		let response = await fetch(url);
  		//console.log("response : ", response); -> 'status : 200'이 나오면 성공!
  		
  		let res = await response.json();
  		console.log("res : ", res)
  		
  		/* let str = res.data.map((item, i) => [
  			(i+1) + ". "
  			+ "발생년도 : " + item.발생년도 + "년"
  			+ ", 경찰서 : " + item.경찰서 
  			+ ", 강도 : " + item.강도 + "건"
  			+ ", 살인 : " + item.살인 + "건"
  			+ ", 절도 : " + item.절도 + "건" 
  			+ ", 폭력 : " + item.폭력 + "건" 
  			+ "<br/>" 
  		]); */
  		
  		let str = '';
  		str += '<table class="table table-bordered table-hover text-center">';
  		str += '<tr class="table-secondary">';
  		str += '<th>번호</th><th>발생년도</th><th>경찰서</th><th>강도</th><th>살인</th><th>절도</th><th>폭력</th></tr>';

  		res.data.map((item, i) => [
			  str += '<tr>'
			  + '<td>' + (i + 1) + '</td>'
			  + '<td>' + item.발생년도 + '년</td>'
			  + '<td>' + item.경찰서 + '</td>'
			  + '<td>' + item.강도 + '건</td>'
			  + '<td>' + item.살인 + '건</td>'
			  + '<td>' + item.절도 + '건</td>'
			  + '<td>' + item.폭력 + '건</td>'
			  + '</tr>'
  		]);
  		str += '</table>';
  		
  		$("#demo").html(str);
  	}
  	
  </script>
</head>
<body>
<jsp:include page="/WEB-INF/views/include/nav.jsp" />
<jsp:include page="/WEB-INF/views/include/slide2.jsp" />
<p><br/></p>
<div class="container">
	<h2>경찰청 강력범죄 발생 현황 자료 리스트</h2>
	<hr/>
	<form name="myform" method="post">
		<div>
			<select name="year" id="year">
				<c:forEach var="i" begin="2015" end="2022">
					<option value="${i}" ${year == i ? 'selected' : ''}>${i}년도</option>
				</c:forEach>
			</select>
			<input type="button" value="강력범죄제공현황조회" onclick="getCrimeDate()" class="btn btn-success mb-3" />
		</div>
	</form>
	<hr/>
	<div id="demo"></div>
</div>
<p><br/></p>
<jsp:include page="/WEB-INF/views/include/footer.jsp" />
</body>
</html>