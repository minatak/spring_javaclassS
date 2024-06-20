package com.spring.javaclassS.dao;

import java.util.ArrayList;

import org.apache.ibatis.annotations.Param;

import com.spring.javaclassS.vo.CrimeVO;
import com.spring.javaclassS.vo.UserVO;

public interface StudyDAO {

	public ArrayList<UserVO> getNameList();

	public ArrayList<UserVO> getUserList(@Param("name") String name, @Param("address") String address);

	public UserVO getUserMidSearch(@Param("mid") String mid);

	public ArrayList<UserVO> getUserMidList(@Param("mid") String mid);

	public void setSaveCrimeData(@Param("vo") CrimeVO vo);

	public ArrayList<CrimeVO> yearPoliceCheck(@Param("year") int year, @Param("policeArea") String policeArea, @Param("yearOrder") String yearOrder);

	public int setDeleteCrimeDate(@Param("year") int year);

}
