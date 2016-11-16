package newHeroes;

public class Combat {
	private int idCombat;
	private String dateCombat;
	private int coordCombatX;
	private int coordCombatY;
	private int agent; //REFERENCIE AGENT
	private int nombreParticipants;
	private int nombreGagnants;
	private int nombrePerdants;
	private int nombreNeutres;
	private char clan;
	
	public Combat(int idCombat, String dateCombat, int coordCombatX, int coordCombatY, int agent,
			int nombreParticipants, int nombreGagnants, int nombrePerdants, int nombreNeutres, char clan) {
		super();
		this.idCombat = idCombat;
		this.dateCombat = dateCombat;
		this.coordCombatX = coordCombatX;
		this.coordCombatY = coordCombatY;
		this.agent = agent;
		this.nombreParticipants = nombreParticipants;
		this.nombreGagnants = nombreGagnants;
		this.nombrePerdants = nombrePerdants;
		this.nombreNeutres = nombreNeutres;
		this.clan = clan;
	}

	public int getIdCombat() {
		return idCombat;
	}

	public String getDateCombat() {
		return dateCombat;
	}

	public int getCoordCombatX() {
		return coordCombatX;
	}

	public int getCoordCombatY() {
		return coordCombatY;
	}

	public int getAgent() {
		return agent;
	}

	public int getNombreParticipants() {
		return nombreParticipants;
	}

	public int getNombreGagnants() {
		return nombreGagnants;
	}

	public int getNombrePerdants() {
		return nombrePerdants;
	}

	public int getNombreNeutres() {
		return nombreNeutres;
	}

	public char getClan() {
		return clan;
	}
	
	public String insertIntoCombats(){
		return "INSERT INTO shyeld.combats VALUES(DEFAULT,'" + this.dateCombat + "'," + this.coordCombatX + ","
	+ this.coordCombatY + "," + this.agent + "," + this.nombreParticipants + "," + this.nombreGagnants + ","
				+ this.nombrePerdants + "," +this.nombreNeutres + ",'" + this.clan + "');\n";
	}
}
