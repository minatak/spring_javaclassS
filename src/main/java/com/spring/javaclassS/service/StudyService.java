package com.spring.javaclassS.service;

import java.util.ArrayList;

import com.spring.javaclassS.vo.CrimeVO;
import com.spring.javaclassS.vo.UserVO;

public interface StudyService {

	public String[] getCityStringArray(String dodo);

	public ArrayList<String> getCityArrayList(String dodo);

	public ArrayList<UserVO> getNameList();

	public ArrayList<String> getNameArrayList(String name);

	public ArrayList<UserVO> getUserList(String name, String gender);

	public UserVO getUserMidSearch(String mid);

	public ArrayList<UserVO> getUserMidList(String mid);

	public void setSaveCrimeData(CrimeVO vo);

	public int setDeleteCrimeDate(int year);

	public ArrayList<CrimeVO> getYearPoliceCheck(int year, String policeArea, String yearOrder);

	
}
