<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>.jsp</title>
  <jsp:include page="/WEB-INF/views/include/bs4.jsp" />
  <script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.min.js" ></script>
  <script type="text/javascript" src="https://cdn.iamport.kr/js/iamport.payment-1.2.0.js"></script>
  <script>
    var IMP = window.IMP;
    IMP.init("imp48776633"); // 고객사 식별코드 넣기

    //function requestPay() {
      IMP.request_pay(
        {
          pg: "html5_inicis.INIpayTest", // PG Provider.MID 넣으면 됨
          pay_method: "card",
          merchant_uid: "javaclassS16_" + new Date().getTime(), // 상점이름. 가져오는게 아니라 마음대로 쓰면 됨
          name : "${vo.name}",
          amount : "${vo.amount}",
          buyer_email: "${vo.buyer_email}",
          buyer_name: "${vo.buyer_name}",
          buyer_tel: "${vo.buyer_tel}",
          buyer_addr: "${vo.buyer_addr}",
          buyer_postcode: "${vo.buyer_postcode}",
        }, // 여기까지가 이니시스(결제대행사)에서 처리하는 작업
        function (rsp) {
          if(rsp.success) {
        	  alert("결제가 완료 되었습니다.");
        	  location.href = '${ctp}/study/payment/paymentOk';
          } else {
        	  alert("결제가 취소 되었습니다.");
        	  location.href = '${ctp}/study/payment/payment';
          }
        }
      );
    //}
  </script>
</head>
<body>
<jsp:include page="/WEB-INF/views/include/nav.jsp" />
<jsp:include page="/WEB-INF/views/include/slide2.jsp" />
<p><br/></p>
<div class="container">
  <p>
    <img src="${ctp}/images/payment.gif" />
  </p>
</div>
<p><br/></p>
<jsp:include page="/WEB-INF/views/include/footer.jsp" />
</body>
</html>