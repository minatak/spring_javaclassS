<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>ajaxTest3_4.jsp</title>
  <jsp:include page="/WEB-INF/views/include/bs4.jsp" />
  <script>
    'use strict';
    
   /*  $(document).ready(function() {
      $("#demo").hide(); 
    }); */
    
    function nameCheck() {
    	let name = document.getElementById("name").value;
    	if(name.trim() == "") {
    		alert("이름을 선택하세요");
    		return false;
    	}
    	
    	$.ajax({
    		url  : "${ctp}/study/ajax/ajaxTest3_4",
    		type : "post",
    		data : {name : name},
    		success:function(res) {
    			//console.log(res);
    			let str = '<option>주소 선택</option>';
    			for(let i=0; i<res.address.length; i++) {
    				str += '<option>'+res.address[i]+'</option>';
    			}
    			$("#address").html(str);
    		},
    		error : function() {
    			alert("전송 오류!");
    		}
    	});
    }
    
    function fCheck() {
    	let name = $("#name").val();
    	let address = $("#address").val();
    	
    	if(name == "" || address == "") {
    		alert("주소를 선택 후 눌러주세요");
    		return false;
    	}
    	
    	$.ajax({
    		url  : "${ctp}/study/ajax/ajaxTest3_4Ok",
    		type : "post",
    		data : {
    			name : name,
    			address : address	
    		},
    		success: function(res) {
    			console.log("res", res);
    			let str = '';
    			
    			if (res.length > 0) {
            str += '<h2 class="text-center">선택하신 회원님의 정보입니다 :)</h2>';
            str += '<table class="table table-hover text-center">';
            str += '<tr class="table-secondary"><th>번호</th><th>아이디</th><th>성명</th><th>나이</th><th>주소</th></tr>';
            for (let i = 0; i < res.length; i++) {
              let vo = res[i];
              str += '<tr>';
              str += '<td>' + vo.idx + '</td>';
              str += '<td>' + vo.mid + '</td>';
              str += '<td>' + vo.name + '</td>';
              str += '<td>' + vo.age + '</td>';
              str += '<td>' + vo.address + '</td>';
              str += '</tr>';
            }
            str += '</table>';
          } 
    			else {
          	str += '<h2 class="text-center">검색하신 회원님의 정보가 존재하지 않습니다</h2>';
          }
          $("#demo").html(str);

          $("#demo").show();
        },
        error: function() {
            alert("전송 오류!");
        }
    	});
    }
  </script>
</head>
<body>
<jsp:include page="/WEB-INF/views/include/nav.jsp" />
<jsp:include page="/WEB-INF/views/include/slide2.jsp" />
<p><br/></p>
<div class="container">
  <h2>ajaxTest3_4.jsp(숙제)</h2>
  <hr/>
  <form>
    <h4>이름을 선택하세요</h4>
    <select name="name" id="name" onchange="nameCheck()" class="form-control">
      <option value="">이름 선택</option>
      <c:forEach var="vo" items="${vos}" varStatus="st">
      	<option>${vo.name}</option>
      </c:forEach>
    </select>
    <h4>주소를 선택하세요</h4>
    <select name="address" id="address" class="form-control">
      <option>주소 선택</option>
    </select>
    <div class="Group mt-3 text-center">
      <input type="button" value="선택" onclick="fCheck()" class="btn btn-info mr-3 mb-3"/>
      <input type="button" value="돌아가기" onclick="location.href='ajaxForm';" class="btn btn-warning mr-3 mb-3"/>
    </div>
  </form>
  <div id="demo" style="display:none;"></div>
</div>
<p><br/></p>
<jsp:include page="/WEB-INF/views/include/footer.jsp" />
</body>
</html>