package newHeroes;

public class Reperage {
	
	private int idReperage;
	private int agent;
	private int superhero;
	private int coordX;
	private int coordY;
	private String date;
	
	public Reperage(int idReperage, int agent, int superhero, int coordX, int coordY, String date) {
		super();
		this.idReperage = idReperage;
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

	public String getDate() {
		return date;
	}
	
	public String insertIntoReperage(){
		return "INSERT INTO shyeld.reperages VALUES(DEFAULT," + this.agent + "," + this.superhero + ","
	+ this.coordX + "," + this.coordY + ",'" + this.date + "');\n";
	}
}
