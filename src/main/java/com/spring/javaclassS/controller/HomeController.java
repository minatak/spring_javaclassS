package com.spring.javaclassS.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.spring.javaclassS.service.HomeService;
import com.spring.javaclassS.service.NotifyService;
import com.spring.javaclassS.service.StudyService;
import com.spring.javaclassS.vo.NotifyVO;
import com.spring.javaclassS.vo.WebChattingVO;

@Controller
public class HomeController {
	
	private static final Logger logger = LoggerFactory.getLogger(HomeController.class);
	
	@Autowired
	StudyService studyService;
	
	@Autowired
	HomeService homeService;
	
	@Autowired
	NotifyService notifyService;
	
	@RequestMapping(value = {"/","/h"}, method = RequestMethod.GET)
	public String homeGet(Locale locale, Model model) {
		logger.info("Welcome home! The client locale is {}.", locale);
		
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
		
		String formattedDate = dateFormat.format(date);
		
		model.addAttribute("serverTime", formattedDate );
		
		// 첫화면에 공지사항 팝업으로 띄우기
		List<NotifyVO> popupVos = notifyService.getNotifyPopup();
		//System.out.println(popupVos);
		model.addAttribute("popupVos", popupVos);
		
		return "home";
	}
	
  // ckeditor에서의 그림파일 업로드시 수행처리되는 부분
	@RequestMapping(value = "/imageUpload")
	public void imageUploadGet(MultipartFile upload, HttpServletRequest request, HttpServletResponse response) throws IOException {
		response.setCharacterEncoding("utf-8");
		response.setContentType("text/html; charset=utf-8");
		
		String realPath = request.getSession().getServletContext().getRealPath("/resources/data/ckeditor/");
		String oFileName = upload.getOriginalFilename();
		
		// 파일명 중복방지를 위한 이름 설정하기(날짜로 분류처리...)
		Date date = new Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yyMMddHHmmss");
		oFileName = sdf.format(date) + "_" + oFileName;
		
		byte[] bytes = upload.getBytes();
		FileOutputStream fos = new FileOutputStream(new File(realPath + oFileName));
		//fos.write(upload.getBytes());
		fos.write(bytes);
		
		PrintWriter out = response.getWriter();
		String fileUrl = request.getContextPath() + "/data/ckeditor/" + oFileName;
		out.println("{\"originalFilename\":\""+oFileName+"\",\"uploaded\":1,\"url\":\""+fileUrl+"\"}");
		
		out.flush();
		fos.close();
	}
	
	// data폴더 아래쪽의 파일들을 다운받고자 할때 수행하는 메소드(다운받을 경로와 파일명을 넘겨주어 처리한다.)
	@RequestMapping(value = "/fileDownAction", method = RequestMethod.GET)
	public void fileDownActionGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
		String path = request.getParameter("path");
		String file = request.getParameter("file");
		
		if(path.equals("pds")) path += "/temp/";
		
		String realPathFile = request.getSession().getServletContext().getRealPath("/resources/data/" + path) + file;
		
		File downFile = new File(realPathFile);
		String downFileName = new String(file.getBytes("UTF-8"), "8859_1");
		response.setHeader("Content-Disposition", "attachment;filename=" + downFileName);
		
		FileInputStream fis = new FileInputStream(downFile);
		ServletOutputStream sos = response.getOutputStream();
		
		byte[] bytes = new byte[2048];
		int data;
		while((data = fis.read(bytes, 0, bytes.length)) != -1) {
			sos.write(bytes, 0, data);
		}
		sos.flush();
		sos.close();
		fis.close();
		
		// 다운로드 완료후에 서버에 저장된 zip파일을 삭제처리한다.
		downFile.delete();
	}
	
	// 채팅창 띄우기
	@RequestMapping(value = "/webSocket/webSocket", method = RequestMethod.GET)
	public String webSocketGet() {
    return "webSocket/webSocket";
	}
	
	// 채팅메세지 DB에 저장하기
	@ResponseBody
	@RequestMapping(value = "/webSocket/msgInput", method = RequestMethod.POST)
	public String msgInputPost(WebChattingVO vo) {
		return homeService.setMsgInput(vo) + "";
	}
	
	// 1대1 채팅폼
	@RequestMapping(value = "/webSocket/endPoint", method = RequestMethod.GET)
	public String endPointGet() {
		return "webSocket/endPoint";
	}
	
}
