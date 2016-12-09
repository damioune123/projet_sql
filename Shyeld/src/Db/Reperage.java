package Db;

public class Reperage {
	
	private int idReperage;
	private int agent;
	private int superhero;
	private int coordX;
	private int coordY;
	private java.sql.Date date;
	
	public Reperage(int idReperage, int agent, int superhero, int coordX, int coordY, java.sql.Date date) {
		super();
		this.idReperage = idReperage;
		this.agent = agent;
		this.superhero = superhero;
		this.coordX = coordX;
		this.coordY = coordY;
		this.date = date;
	}
	

	public Reperage(int agent, int superhero, int coordX, int coordY, java.sql.Date date) {
		super();
		this.agent = agent;
		this.superhero = superhero;
		this.coordX = coordX;
		this.coordY = coordY;
		this.date = date;
	}



	public int getIdReperage() {
		return idReperage;
	}

	public int getAgent() {
		return agent;
	}

	public int getSuperhero() {
		return superhero;
	}

	public int getCoordX() {
		return coordX;
	}

	public int getCoordY() {
		return coordY;
	}

	public java.sql.Date getDate() {
		return date;
	}
}
