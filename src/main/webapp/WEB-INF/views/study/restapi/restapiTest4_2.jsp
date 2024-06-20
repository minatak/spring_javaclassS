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
    
    const API_KEY = '7WMGwpEENfXvFnxY1efwZ4263gPHczyuehE7RyufhGeO4SZPOKxDisyWglB%2BjylPIXZJu8Xxs8BCWVbLqr9PdA%3D%3D';
    
    async function getCrimeDate() {
    	let year = $("#year").val();
    	let apiYear = '';
    	
    	if(year == 2015) apiYear = "/15084592/v1/uddi:fbbfd36d-d528-4c8e-aa9b-d5cdbdeec669";
    	else if(year == 2016) apiYear = "/15084592/v1/uddi:21ec6fa1-a033-413b-b049-8433f5b446ff";
    	else if(year == 2017) apiYear = "/15084592/v1/uddi:67117bd9-5ee1-4e07-ae4a-bfe0861ee116";
    	else if(year == 2018) apiYear = "/15084592/v1/uddi:67117bd9-5ee1-4e07-ae4a-bfe0861ee116";
    	else if(year == 2019) apiYear = "/15084592/v1/uddi:b6cc7731-181b-48e1-9a6c-ae81388e46b0";
    	else if(year == 2020) apiYear = "/15084592/v1/uddi:fdde1218-987c-49ba-9326-8e3ba276141e";
    	else if(year == 2021) apiYear = "/15084592/v1/uddi:fdde1218-987c-49ba-9326-8e3ba276141e";
    	else if(year == 2022) apiYear = "/15084592/v1/uddi:5e08264d-acb3-4842-b494-b08f318aa14c";
    	
    	let url = "https://api.odcloud.kr/api";
    	url += apiYear;
    	url += "?serviceKey=" + API_KEY;
    	url += "&page=1&perPage=200";
    	
    	let response = await fetch(url);
    	//console.log("response : ", response);
    	
    	let res = await response.json();
    	console.log("res : ", res);
    	
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
    
    // 검색한 자료를 DB에 저장하기
    async function saveCrimeDate() {
    	let year = $("#year").val();
    	let apiYear = '';
    	
    	if(year == 2015) apiYear = "/15084592/v1/uddi:fbbfd36d-d528-4c8e-aa9b-d5cdbdeec669";
    	else if(year == 2016) apiYear = "/15084592/v1/uddi:21ec6fa1-a033-413b-b049-8433f5b446ff";
    	else if(year == 2017) apiYear = "/15084592/v1/uddi:67117bd9-5ee1-4e07-ae4a-bfe0861ee116";
    	else if(year == 2018) apiYear = "/15084592/v1/uddi:67117bd9-5ee1-4e07-ae4a-bfe0861ee116";
    	else if(year == 2019) apiYear = "/15084592/v1/uddi:b6cc7731-181b-48e1-9a6c-ae81388e46b0";
    	else if(year == 2020) apiYear = "/15084592/v1/uddi:fdde1218-987c-49ba-9326-8e3ba276141e";
    	else if(year == 2021) apiYear = "/15084592/v1/uddi:fdde1218-987c-49ba-9326-8e3ba276141e";
    	else if(year == 2022) apiYear = "/15084592/v1/uddi:5e08264d-acb3-4842-b494-b08f318aa14c";
    	
    	let url = "https://api.odcloud.kr/api";
    	url += apiYear;
    	url += "?serviceKey=" + API_KEY;
    	url += "&page=1&perPage=200";
    	
    	let response = await fetch(url);
    	
    	let res = await response.json();
    	console.log("res : ", res);
    	
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
    	
    	// 화면에 출력된 자료들을 모두 DB에 저장시켜준다.
    	//alert("경찰서 : " + res.data[0].경찰서);
    	let query = "";
    	for(let i=0; i<res.data.length; i++) {
    		if(res.data[i].경찰서 != null) {
    			query = {
    					year 			: year,
    					police 		: res.data[i].경찰서,
    					robbery 	: res.data[i].강도,
    					theft 		: res.data[i].절도,
    					murder 		: res.data[i].살인,
    					violence 	: res.data[i].폭력
    			}
    		}
    		$.ajax({
    			url : "${ctp}/study/restapi/saveCrimeData",
    			type : "post",
    			data : query,
    			error : function() {
						alert("전송오류");
					}
    		});
    	}
    	alert(year + "년도 자료가 DB에 저장되었습니다");
    }
    
    // 검색한 자료의 정보를 DB에서 삭제하기
    async function deleteCrimeDate() {
    	let year = $("#year").val();
    	let ans = confirm‎(year + "년도의 자료를 데이터베이스에서 삭제하시겠습니까?");
      if(ans) {
    		$.ajax({
    			url : "${ctp}/study/restapi/deleteCrimeDate",
    			type : "post",
    			data : {year : year},
    			success : function(res) {
    				if(res != 0) {
				    	alert(year + "년도 자료가 DB에서 삭제되었습니다");
				    	location.reload();
    				}
    				else {
				    	alert("자료 삭제에 실패했거나 선택하신 년도의 데이터베이스가 비어있습니다.");
    				}
    			},
    			error : function() {
						alert("전송오류");
					}
    		});
    	}
    
    }
    // 선택한 옵션별로 데이터 가져오기
    function yearPoliceCheck() {
    /* 	let year = $("#year").val();
    	let policeArea = $("#policeArea").val();
    	let yearOrder = myform.yearOrder.value(); */
    	
  	 	let year = document.myform.year.value;
      let policeArea = document.myform.policeArea.value;
      let yearOrder = document.myform.yearOrder.value;

      if (!year) {
        alert("년도를 선택하세요.");
        return;
      }
      if (!policeArea) {
        alert("경찰서 지역명을 선택하세요.");
        return;
      }
      if (!yearOrder) {
        alert("정렬순서를 선택하세요.");
        return;
      }
  	
  		$.ajax({
  			url : "${ctp}/study/restapi/yearPoliceCheck",
  			type : "post",
  			data : {
  				year : year,
  				policeArea : policeArea,
  				yearOrder : yearOrder
  			},
  			success : function(vos) {
					let str = '';
					if(vos != '') {
						str = '<h5>'+policeArea+' 지역에 위치한 경찰서의 '+year+'년도 범죄 발생 자료리스트입니다</h5>';
			  		str += '<table class="table table-bordered table-hover text-center">';
			  		str += '<tr class="table-secondary">';
			  		str += '<th>발생년도</th><th>경찰서</th><th>강도</th><th>살인</th><th>절도</th><th>폭력</th></tr>';
						for(let i=0; i<vos.length; i++) {
						  str += '<tr>'
						  + '<td>' + vos[i].year + '년</td>'
						  + '<td>' + vos[i].police + '</td>'
						  + '<td>' + vos[i].robbery + '건</td>'
						  + '<td>' + vos[i].murder + '건</td>'
						  + '<td>' + vos[i].theft + '건</td>'
						  + '<td>' + vos[i].violence + '건</td>'
						  + '</tr>'
						}
			  		str += '</table>';
					}
					else {
						str = "<b>찾으시는 자료가 없습니다 </b>";
					}
		    	$("#demo").html(str);
				},
  			error : function() {
					alert("전송오류");
				}
  		});
    }
  </script>
</head>
<body>
<jsp:include page="/WEB-INF/views/include/nav.jsp" />
<jsp:include page="/WEB-INF/views/include/slide2.jsp" />
<p><br/></p>
<p><br/></p>
<div class="container">
  <h2 class="text-center">경찰청 강력범죄 발생 현황 자료 리스트</h2>
    <hr/>
    <form name="myform" method="post" class="mb-4">
      <div class="form-row">
        <div class="form-group col-md-6">
          <b>년도</b>
          <select name="year" id="year" class="form-control">
            <c:forEach var="i" begin="2015" end="2022">
              <option value="${i}" ${year == i ? 'selected' : ''}>${i}년도</option>
            </c:forEach>
          </select>
        </div>
        <div class="form-group col-md-6">
          <b>경찰서 지역명</b>
          <select name="policeArea" id="policeArea" class="form-control" onchange="policeCheck()">
            <option>서울</option>
            <option>경기</option>
            <option>강원</option>
            <option>충북</option>
            <option>충남</option>
            <option>전북</option>
            <option>전남</option>
            <option>경북</option>
            <option>경남</option>
            <option>제주</option>
          </select>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group col-md-12">
          <b>정렬순서 :&nbsp;</b>
          <input type="radio" name="yearOrder" value="a" />오름차순 &nbsp; 
      		<input type="radio" name="yearOrder" value="d" />내림차순
          <!-- 
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" name="yearOrder" value="a"> 오름차순 
          </div>
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" name="yearOrder" value="d">
            <label class="form-check-label" for="orderDesc">내림차순</label>
          </div>
           -->
          <button type="button" onclick="yearPoliceCheck()" class="btn btn-secondary btn-sm float-right">년도/경찰서별출력</button>
        </div>
      </div>
      <hr/>
      <div class="form-row text-center">
        <div class="form-group col-md-12">
          <button type="button" onclick="getCrimeDate()" class="btn btn-success mb-3 mr-2">강력범죄제공현황조회</button>
          <button type="button" onclick="saveCrimeDate()" class="btn btn-success mb-3 mr-2">강력범죄DB저장</button>
          <button type="button" onclick="deleteCrimeDate()" class="btn btn-success mb-3 mr-2">강력범죄DB삭제</button>
          <button type="button" onclick="listCrimeDate()" class="btn btn-success mb-3">강력범죄DB출력</button>
        </div>
      </div>
    </form>
  <hr/>
  <div id="demo"></div>
  <hr/>
  <h3>범죄 분석 통계</h3>
  <!-- 1. 년도/강도/살인/절도/폭력 -->
  <!-- 2. 경찰서별 통계 : 년도/강도/살인/절도/폭력 -->
  <!-- 3. 범죄 발생 건수가 가장 적은 지역 -->
</div>
<p><br/></p>
<jsp:include page="/WEB-INF/views/include/footer.jsp" />
</body>
</html>