package Db;

public class Combat {
	private int idCombat;
	private java.sql.Date dateCombat;
	private int coordCombatX;
	private int coordCombatY;
	private int agent; //REFERENCIE AGENT
	private int nombreParticipants;
	private int nombreGagnants;
	private int nombrePerdants;
	private int nombreNeutres;
	
	public Combat(int idCombat, java.sql.Date dateCombat, int coordCombatX, int coordCombatY, int agent,
			int nombreParticipants, int nombreGagnants, int nombrePerdants, int nombreNeutres) {
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
	}
	

	public Combat(java.sql.Date dateCombat, int coordCombatX, int coordCombatY, int agent, int nombreParticipants,
			int nombreGagnants, int nombrePerdants, int nombreNeutres) {
		super();
		this.dateCombat = dateCombat;
		this.coordCombatX = coordCombatX;
		this.coordCombatY = coordCombatY;
		this.agent = agent;
		this.nombreParticipants = nombreParticipants;
		this.nombreGagnants = nombreGagnants;
		this.nombrePerdants = nombrePerdants;
		this.nombreNeutres = nombreNeutres;
	}



	public int getIdCombat() {
		return idCombat;
	}

	public java.sql.Date getDateCombat() {
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
}
