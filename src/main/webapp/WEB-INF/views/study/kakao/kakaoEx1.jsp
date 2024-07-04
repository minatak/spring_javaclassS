<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>kakaoEx1.jsp</title>
  <jsp:include page="/WEB-INF/views/include/bs4.jsp" />
  <!-- <style>
  	.swal2-confirm‎ {
    background-color: white !important;
    color: black !important;
    border-radius: 0px !important;
    box-shadow: none !important;
    font-weight: bold !important;
    font-size: 18px !important;
    margin: 0 !important;
		}
		.custom-swal-popup {
	    width: 350px !important;
	    padding-top: 20px !important;
	    border-radius: 0px !important;
		}
		.swal2-confirm‎:hover {
	    background-color: none !important;
		}
  
  </style> -->
  <script>
    function addressSvae(latitude, longitude) {
    	let address = document.getElementById("address").value;
    	if(address == "") {
    		alert("선택한 지점의 장소명을 입력하세요");
    		document.getElementById("address").focus();
    		return false;
    	}
    	let query = {
    			address  : address,
    			latitude : latitude,
    			longitude: longitude
    	}
    	
    	$.ajax({
    		url  : "${ctp}/study/kakao/kakaoEx1",
    		type : "post",
    		data : query,
    		success:function(res) {
    			if(res != "0") alert("선택한 지점이 MyDB에 저장되었습니다.");
    			else alert("저장 실패~~(같은 지점명이 있습니다. 이름을 변경해서 다시 등록하세요)");
    		},
    		error : function() {
    			alert("전송오류!");
    		}
    	});
    }
    
   /*  function showAlert(‎message) {
        Swal.fire({
            html : message,
            confirm‎ButtonText : '확인',
            customClass : {
                confirm‎Button : 'swal2-confirm‎',
                popup : 'custom-swal-popup',
                htmlContainer : 'custom-swal-text'
            }
        });
    } */
 

  </script>
</head>
<body>
<jsp:include page="/WEB-INF/views/include/nav.jsp" />
<jsp:include page="/WEB-INF/views/include/slide2.jsp" />
<p><br/></p>
<div class="container">
	<h2>클릭한 지점에 마커 표시, DB에 저장</h2>
	<div id="map" style="width:100%;height:500px;"></div>
	
	<form name="myform">
	  <div id="clickLatlng"></div>
	</form>
	
	<!-- 카카오맵 Javascript API -->
	<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=de6e07199c4aa87682edf478ce5966ae"></script>
	<script>
	  // 1.지도를 띄워주는 기본 코드(지도 생성)
		var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
    mapOption = { 
        center: new kakao.maps.LatLng(33.450701, 126.570667), // 지도의 중심좌표
        level: 3 // 지도의 확대 레벨
    };

		var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성합니다

		// 2.지도를 클릭한 위치에 표출할 마커입니다
		var marker = new kakao.maps.Marker({ 
		    // 지도 중심좌표에 마커를 생성합니다 
		    position: map.getCenter() 
		}); 
		// 지도에 마커를 표시합니다
		marker.setMap(map);

		// 지도에 클릭 이벤트를 등록합니다
		// 지도를 클릭하면 마지막 파라미터로 넘어온 함수를 호출합니다
		kakao.maps.event.addListener(map, 'click', function(mouseEvent) {        
		    // 클릭한 위도, 경도 정보를 가져옵니다 
		    var latlng = mouseEvent.latLng; 
		    
		    // 마커 위치를 클릭한 위치로 옮깁니다
		    marker.setPosition(latlng);
		    
		    var message = '클릭한 위치의 위도는 ' + latlng.getLat() + ' 이고, ';
		    message += '경도는 ' + latlng.getLng() + ' 입니다';
		    message += '<p>선택한 지점의 장소명 : <input type="text" name="address" id="address"/> &nbsp;';
		    message += '<input type="button" value="장소저장" onclick="addressSvae('+latlng.getLat()+','+latlng.getLng()+')" class="btn btn-success btn-sm"/></p>';
		    message += '';
		    
		    var resultDiv = document.getElementById('clickLatlng'); 
		    resultDiv.innerHTML = message;
		    
		});
	</script>
	<hr/>
	<jsp:include page="kakaoMenu.jsp" />
</div>
<p><br/></p>
<jsp:include page="/WEB-INF/views/include/footer.jsp" />
</body>
</html>