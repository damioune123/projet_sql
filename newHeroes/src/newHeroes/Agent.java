package newHeroes;

public class Agent {
	
	private int idAgent;
	private String prenom;
	private String nom;
	private String dateMiseService;
	private boolean estActif;
	
	public Agent(int idAgent, String prenom, String nom, String dateMiseService, boolean estActif) {
		super();
		this.idAgent = idAgent;
		this.prenom = prenom;
		this.nom = nom;
		this.dateMiseService = dateMiseService;
		this.estActif = estActif;
	}

	public int getIdAgent() {
		return idAgent;
	}

	public String getPrenom() {
		return prenom;
	}

	public String getNom() {
		return nom;
	}

	public String getDateMiseService() {
		return dateMiseService;
	}

	public boolean isEstActif() {
		return estActif;
	}
	
	public String insertIntoAgent(){
		return "INSERT INTO shyeld.agents VALUES(DEFAULT,'" + this.prenom + "','" + this.nom + "','" + this.dateMiseService +
				"'," + this.estActif + ");\n";
	}
}
