package com.simminjeong.procedure.entity;

import java.util.Objects;

public class Bonus {

	private String ename;
	private String job;
	private int sal;
	private int comm;

	public Bonus(String ename, String job, int sal, int comm) {
		super();
		this.ename = ename;
		this.job = job;
		this.sal = sal;
		this.comm = comm;
	}

	public String getEname() {
		return ename;
	}

	public void setEname(String ename) {
		this.ename = ename;
	}

	public String getJob() {
		return job;
	}

	public void setJob(String job) {
		this.job = job;
	}

	public int getSal() {
		return sal;
	}

	public void setSal(int sal) {
		this.sal = sal;
	}

	public int getComm() {
		return comm;
	}

	public void setComm(int comm) {
		this.comm = comm;
	}

	@Override
	public int hashCode() {
		return Objects.hash(comm, ename, job, sal);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Bonus other = (Bonus) obj;
		return comm == other.comm && Objects.equals(ename, other.ename) && Objects.equals(job, other.job)
				&& sal == other.sal;
	}

	@Override
	public String toString() {
		return "bonus [ename=" + ename + ", job=" + job + ", sal=" + sal + ", comm=" + comm + "]";
	}

}
