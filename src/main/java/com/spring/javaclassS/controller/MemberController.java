package com.spring.javaclassS.controller;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.UUID;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import com.spring.javaclassS.common.JavaclassProvide;
import com.spring.javaclassS.service.MemberService;
import com.spring.javaclassS.vo.MemberVO;

@Controller
@RequestMapping("/member")
public class MemberController {
	
	@Autowired
	MemberService memberService;
	
	@Autowired
	BCryptPasswordEncoder passwordEncoder;
	
	@Autowired
	JavaMailSender mailSender;
	
	@Autowired
	JavaclassProvide javaclassProvide;
	
	// 일반 로그인 폼
	@RequestMapping(value = "/memberLogin", method = RequestMethod.GET)
	public String memberLoginGet(HttpServletRequest request) {
		// 로그인창에 아이디 체크 유무에 대한 처리
		// 쿠키를 검색해서 cMid가 있을때 가져와서 아이디입력창에 뿌릴수 있게 한다.
		Cookie[] cookies = request.getCookies();

		if(cookies != null) {
			for(int i=0; i<cookies.length; i++) {
				if(cookies[i].getName().equals("cMid")) {
					request.setAttribute("mid", cookies[i].getValue());
					break;
				}
			}
		}
		return "member/memberLogin";
	}
	
	// 카카오 로그인
	@RequestMapping(value = "/kakaoLogin", method = RequestMethod.GET)
	public String kakaoLoginGet(String nickName, String email, String accessToken,
			HttpServletRequest request,
			HttpSession session
		) throws MessagingException {
		System.out.println("nickName:"+nickName);
		// 카카오 로그아웃을 위한 카카오앱키를 세션에 저장시켜둔다.
		session.setAttribute("sAccessToken", accessToken);
		
		// 카카오 로그인한 회원인 경우에는 우리 회원인지를 조사한다.(넘어온 이메일을 @를 기준으로 아이디와 분리해서 기존 memeber2테이블의 아이디와 비교한다.)
		MemberVO vo = memberService.getMemberNickNameEmailCheck(nickName, email);
		
		// 현재 카카오로그인에의한 우리회원이 아니였다면, 자동으로 우리회원에 가입처리한다.
		// 필수입력:아이디, 닉네임, 이메일, 성명(닉네임으로 대체), 비밀번호(임시비밀번호 발급처리)
		String newMember = "NO"; // 신규회원인지에 대한 정의(신규회원:OK, 기존회원:NO)
		if(vo == null) {
			// 아이디 결정하기
			String mid = email.substring(0, email.indexOf("@"));
			
			// 만약에 기존에 같은 아이디가 존재한다면 가입처리 불가...
			MemberVO vo2 = memberService.getMemberIdCheck(mid);
			if(vo2 != null) return "redirect:/message/midSameSearch";
			
			// 비밀번호(임시비밀번호 발급처리)
			UUID uid = UUID.randomUUID();
			String pwd = uid.toString().substring(0,8);
			session.setAttribute("sImsiPwd", pwd);
			
			// 새로 발급된 비밀번호를 암호화 시켜서 db에 저장처리한다.(카카오 로그인한 신입회원은 바로 정회원으로 등업 시켜준다.)
			memberService.setKakaoMemberInput(mid, passwordEncoder.encode(pwd), nickName, email);
			
			// 새로 발급받은 임시비밀번호를 메일로 전송한다.
			javaclassProvide.mailSend(email, "임시 비밀번호를 발급하였습니다.", pwd);
			
			// 새로 가입처리된 회원의 정보를 다시 vo에 담아준다.
			vo = memberService.getMemberIdCheck(mid);
			
			// 비밀번호를 새로 발급처리했을때 sLogin세션을 발생시켜주고, memberMain창에 비밀번호 변경메세지를 지속적으로 뿌려준다.
			session.setAttribute("sLogin", "OK");
			
			newMember = "OK";
		}
		
		// 로그인 인증완료시 처리할 부분(1.세션, 3.기타 설정값....)
		// 1.세션처리
		String strLevel = "";
		if(vo.getLevel() == 0) strLevel = "관리자";
		else if(vo.getLevel() == 1) strLevel = "우수회원";
		else if(vo.getLevel() == 2) strLevel = "정회원";
		else if(vo.getLevel() == 3) strLevel = "준회원";
		
		session.setAttribute("sMid", vo.getMid());
		session.setAttribute("sNickName", vo.getNickName());
		session.setAttribute("sLevel", vo.getLevel());
		session.setAttribute("strLevel", strLevel);
		
		// 2.쿠키 저장/삭제
		
		// 3. 기타처리(DB에 처리해야할것들(방문카운트, 포인트,... 등)
		// 방문포인트 : 1회방문시 point 10점할당, 1일 최대 50점까지 할당가능
		// 숙제...
		int point = 10;
		
		// 방문카운트
		memberService.setMemberInforUpdate(vo.getMid(), point);
		
		// 로그인 완료후 모든 처리가 끝나면 필요한 메세지처리후 memberMain으로 보낸다.
		if(newMember.equals("NO")) return "redirect:/message/memberLoginOk?mid="+vo.getMid();
		else return "redirect:/message/memberLoginNewOk?mid="+vo.getMid();
	}
	
  // 일반 로그인 처리하기
	@RequestMapping(value = "/memberLogin", method = RequestMethod.POST)
	public String memberLoginPost(HttpServletRequest request, HttpServletResponse response, HttpSession session,
			@RequestParam(name="mid", defaultValue = "hkd1234", required = false) String mid,
			@RequestParam(name="pwd", defaultValue = "1234", required = false) String pwd,
			@RequestParam(name="idSave", defaultValue = "1234", required = false) String idSave
		) {
		//  로그인 인증처리(스프링 시큐리티의 BCryptPasswordEncoder객체를 이용한 암호화되어 있는 비밀번호 비교하기)
		MemberVO vo = memberService.getMemberIdCheck(mid);
		
		if(vo != null && vo.getUserDel().equals("NO") && passwordEncoder.matches(pwd, vo.getPwd())) {
			// 로그인 인증완료시 처리할 부분(1.세션, 2.쿠키, 3.기타 설정값....)
			// 1.세션처리
			String strLevel = "";
			if(vo.getLevel() == 0) strLevel = "관리자";
			else if(vo.getLevel() == 1) strLevel = "우수회원";
			else if(vo.getLevel() == 2) strLevel = "정회원";
			else if(vo.getLevel() == 3) strLevel = "준회원";
			
			session.setAttribute("sMid", mid);
			session.setAttribute("sNickName", vo.getNickName());
			session.setAttribute("sLevel", vo.getLevel());
			session.setAttribute("strLevel", strLevel);
			
			// 2.쿠키 저장/삭제
			if(idSave.equals("on")) {
				Cookie cookieMid = new Cookie("cMid", mid);
				cookieMid.setPath("/");
				cookieMid.setMaxAge(60*60*24*7);		// 쿠키의 만료시간을 7일로 지정
				response.addCookie(cookieMid);
			}
			else {
				Cookie[] cookies = request.getCookies();
				if(cookies != null) {
					for(int i=0; i<cookies.length; i++) {
						if(cookies[i].getName().equals("cMid")) {
							cookies[i].setMaxAge(0);
							response.addCookie(cookies[i]);
							break;
						}
					}
				}
			}
			
			// 3. 기타처리(DB에 처리해야할것들(방문카운트, 포인트,... 등)
			// 방문포인트 : 1회방문시 point 10점할당, 1일 최대 50점까지 할당가능
			// 숙제...
			int point = 10;
			
			// 방문카운트
			memberService.setMemberInforUpdate(mid, point);
			
			return "redirect:/message/memberLoginOk?mid="+mid;
		}
		else {
			return "redirect:/message/memberLoginNo";
		}
	}
	
	// 일반 로그아웃
	@RequestMapping(value = "/memberLogout", method = RequestMethod.GET)
	public String memberMainGet(HttpSession session) {
		String mid = (String) session.getAttribute("sMid");
		session.invalidate();
		
		return "redirect:/message/memberLogout?mid="+mid;
	}
	
	// kakao 로그아웃
	@RequestMapping(value = "/kakaoLogout", method = RequestMethod.GET)
	public String kakaoLogoutGet(HttpSession session) {
		String mid = (String) session.getAttribute("sMid");
		String accessToken = (String) session.getAttribute("sAccessToken");
		String reqURL = "https://kapi.kakao.com/v1/user/unlink";
		
		try {
			URL url = new URL(reqURL);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Authorization", " " + accessToken);
			
			// 카카오에서 정상적으로 처리 되었다면 200번이 돌아온다.
			int responseCode = conn.getResponseCode();
			System.out.println("responseCode : " + responseCode);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		session.invalidate();
		
		return "redirect:/message/kakaoLogout?mid="+mid;
	}
	
	@RequestMapping(value = "/memberMain", method = RequestMethod.GET)
	public String memberMainGet(HttpSession session, Model model) {
		String mid = (String) session.getAttribute("sMid");
		MemberVO mVo = memberService.getMemberIdCheck(mid);
		model.addAttribute("mVo", mVo);
		
		return "member/memberMain";
	}
	
	// 회원가입시 이메일로 인증번호 전송하기
	@ResponseBody
	@RequestMapping(value = "/memberEmailCheck", method = RequestMethod.POST)
	public String memberEmailCheckPost(String email, HttpSession session) throws MessagingException {
		UUID uid = UUID.randomUUID();
		String emailKey = uid.toString().substring(0,8);
		session.setAttribute("sEmailKey", emailKey);
		
		mailSend(email, "이메일 인증키입니다.", "인증키 : "+emailKey);
		return "1";
	}
	
	// 이메일 확인하기
	@ResponseBody
	@RequestMapping(value = "/memberEmailCheckOk", method = RequestMethod.POST)
	public String memberEmailCheckOkPost(String checkKey, HttpSession session) throws MessagingException {
		String sCheckKey = (String) session.getAttribute("sEmailKey");
		if(checkKey.equals(sCheckKey)) return "1";
		else return "0";
	}
	
	@RequestMapping(value = "/memberJoin", method = RequestMethod.GET)
	public String memberJoinGet() {
		return "member/memberJoin";
	}
	
	@RequestMapping(value = "/memberJoin", method = RequestMethod.POST)
	public String memberJoinPost(MemberVO vo, MultipartFile fName) {
		// 아이디/닉네임 중복체크
		if(memberService.getMemberIdCheck(vo.getMid()) != null) return "redirect:/message/idCheckNo";
		if(memberService.getMemberNickCheck(vo.getNickName()) != null) return "redirect:/message/nickCheckNo";
		
		// 비밀번호 암호화
		vo.setPwd(passwordEncoder.encode(vo.getPwd()));
		
		// 회원 사진 처리(service객체에서 처리후 DB에 저장한다.)
		if(!fName.getOriginalFilename().equals("")) vo.setPhoto(memberService.fileUpload(fName, vo.getMid(), ""));
		else vo.setPhoto("noimage.jpg");
		
		int res = memberService.setMemberJoinOk(vo);
		
		if(res != 0) return "redirect:/message/memberJoinOk";
		else return "redirect:/message/memberJoinNo";
	}
	
	@ResponseBody
	@RequestMapping(value = "/memberIdCheck", method = RequestMethod.GET)
	public String memberIdCheckGet(String mid) {
		MemberVO vo = memberService.getMemberIdCheck(mid);
		if(vo != null) return "1";
		else return "0";
	}
	
	@ResponseBody
	@RequestMapping(value = "/memberNickCheck", method = RequestMethod.GET)
	public String memberNickCheckGet(String nickName) {
		MemberVO vo = memberService.getMemberNickCheck(nickName);
		if(vo != null) return "1";
		else return "0";
	}
	
	@ResponseBody
	@RequestMapping(value = "/memberNewPassword", method = RequestMethod.POST)
	public String memberNewPasswordPost(String mid, String email, HttpSession session) throws MessagingException {
		MemberVO vo = memberService.getMemberIdCheck(mid);
		if(vo != null && vo.getEmail().equals(email)) {
			// 정보확인후 정보가 맞으면 임시 비밀번호를 발급받아서 메일로 전송처리한다.
			
			UUID uid = UUID.randomUUID();
			String pwd = uid.toString().substring(0,8);
			
			// 새로 발급받은 비밀번호를 암호화 한후, DB에 저장한다.
			memberService.setMemberPasswordUpdate(mid, passwordEncoder.encode(pwd));
			
			// 발급받은 비밀번호를 메일로 전송처리한다.
			String title = "임시 비밀번호를 발급하셨습니다.";
			String mailFlag = "임시 비밀번호 : " + pwd;
			String res = mailSend(email, title, mailFlag);
			
			// 새 비밀번호를 발급하였을시에 sLogin이란 세션을 발생시키고, 2분안에 새 비밀번호로 로그인후 비밀번호를 변경처리할수 있도록 처리(___)
			// 숙제___
			session.setAttribute("sLogin", "OK");
			
			
			if(res == "1") return "1";
		}
		return "0";
	}

	// 메일 전송하기(아이디찾기, 비밀번호 찾기)
	private String mailSend(String toMail, String title, String mailFlag) throws MessagingException {
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
		String content = "";
		
		// 메일 전송을 위한 객체 : MimeMessage(), MimeMessageHelper()
		MimeMessage message = mailSender.createMimeMessage();
		MimeMessageHelper messageHelper = new MimeMessageHelper(message, true, "UTF-8");
		
		// 메일보관함에 작성한 메세지들의 정보를 모두 저장시킨후 작업처리...
		messageHelper.setTo(toMail);			// 받는 사람 메일 주소
		messageHelper.setSubject(title);	// 메일 제목
		messageHelper.setText(content);		// 메일 내용
		
		// 메세지 보관함의 내용(content)에 , 발신자의 필요한 정보를 추가로 담아서 전송처리한다.
		content = content.replace("\n", "<br>");
		content += "<br><hr><h3>"+mailFlag+"</h3><hr><br>";
		content += "<p><img src=\"cid:main.jpg\" width='500px'></p>";
		content += "<p>방문하기 : <a href='http://49.142.157.251:9090/cjgreen'>javaclass</a></p>";
		content += "<hr>";
		messageHelper.setText(content, true);
		
		// 본문에 기재될 그림파일의 경로를 별도로 표시시켜준다. 그런후 다시 보관함에 저장한다.
		FileSystemResource file = new FileSystemResource(request.getSession().getServletContext().getRealPath("/resources/images/main.jpg"));
		messageHelper.addInline("main.jpg", file);
		
		// 메일 전송하기
		mailSender.send(message);
		
		return "1";
	}
	
	@RequestMapping(value = "/memberPwdCheck/{pwdFlag}", method = RequestMethod.GET)
	public String memberPwdCheckGet(@PathVariable String pwdFlag, Model model) {
		model.addAttribute("pwdFlag", pwdFlag);
		return "member/memberPwdCheck";
	}
	
	@ResponseBody
	@RequestMapping(value = "/memberPwdCheck", method = RequestMethod.POST)
	public String memberPwdCheckPost(String mid, String pwd) {
		MemberVO vo = memberService.getMemberIdCheck(mid);
		if(passwordEncoder.matches(pwd, vo.getPwd())) return "1";
		return "0";
	}
	
	@ResponseBody
	@RequestMapping(value = "/memberPwdChangeOk", method = RequestMethod.POST)
	public String memberPwdChangeOkPost(String mid, String pwd) {
		return memberService.setPwdChangeOk(mid, passwordEncoder.encode(pwd)) + "";
	}
	
	@RequestMapping(value = "/memberList", method = RequestMethod.GET)
	public String memberListGet(Model model, HttpSession session) {
		int level = (int) session.getAttribute("sLevel");
		ArrayList<MemberVO> vos = memberService.getMemberList(level);
		model.addAttribute("vos", vos);
		return "member/memberList";
	}
	
	@RequestMapping(value = "/memberUpdate", method = RequestMethod.GET)
	public String memberUpdateGet(Model model, HttpSession session) {
		String mid = (String) session.getAttribute("sMid");
		MemberVO vo = memberService.getMemberIdCheck(mid);
		model.addAttribute("vo", vo);
		return "member/memberUpdate";
	}
	
	@RequestMapping(value = "/memberUpdate", method = RequestMethod.POST)
	public String memberUpdatePost(MemberVO vo, MultipartFile fName, HttpSession session) {
		// 닉네임 체크
		String nickName = (String) session.getAttribute("sNickName");
		if(memberService.getMemberNickCheck(vo.getNickName()) != null && !nickName.equals(vo.getNickName())) {
			return "redirect:/message/nickCheckNo";
		}
		
		// 회원 사진 처리(service객체에서 처리후 DB에 저장한다. 원본파일은 noimage.jpg가 아닐경우 삭제한다.)
		if(fName.getOriginalFilename() != null && !fName.getOriginalFilename().equals("")) vo.setPhoto(memberService.fileUpload(fName, vo.getMid(), vo.getPhoto()));
		
		int res = memberService.setMemberUpdateOk(vo);
		if(res != 0) {
			session.setAttribute("sNickName", vo.getNickName());
			return "redirect:/message/memberUpdateOk";
		}
		else return "redirect:/message/memberUpdateNo";
	}

	// 회원 탈퇴...신청...
	@ResponseBody
	@RequestMapping(value = "/userDel", method = RequestMethod.POST)
	public String userDelPost(HttpSession session, HttpServletRequest request) {
		String mid = (String) session.getAttribute("sMid");
		int res = memberService.setUserDel(mid);
		
		if(res == 1) {
			session.invalidate();
			return "1";
		}
		else return "0";
	}
	
}
