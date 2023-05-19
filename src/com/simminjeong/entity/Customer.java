package com.simminjeong.entity;

import java.util.Date;
import java.util.Objects;

public class Customer {

	private String id;
	private String pwd;
	private String name;
	private String zipcode;
	private String address1;
	private String address2;
	private String mobile_no;
	private String phone_no;
	private int credit_limit;
	private String email;
	private int account_mgr;
	private Date birth_dt;
	private Date enroll_dt;
	private String gender;
	
	
	public Customer(int account_mgr) {
		super();
		this.account_mgr = account_mgr;
	}


	public int getAccount_mgr() {
		return account_mgr;
	}


	public void setAccount_mgr(int account_mgr) {
		this.account_mgr = account_mgr;
	}


	@Override
	public int hashCode() {
		return Objects.hash(account_mgr);
	}


	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Customer other = (Customer) obj;
		return account_mgr == other.account_mgr;
	}
	
	
}
