package newHeroes;

public class Agent {
	
	private int idAgent;
	private String prenom;
	private String nom;
	private String dateMiseService;
	private String identifiant;
	private String mdpSha256;
	private int nombreRapport;
	private boolean estActif;

	public Agent(int idAgent, String prenom, String nom, String dateMiseService, String mdpSha256, int nombreRapport,
			boolean estActif) {
		super();
		this.idAgent = idAgent;
		this.prenom = prenom;
		this.nom = nom;
		this.dateMiseService = dateMiseService;
		this.identifiant = "" + nom + idAgent;
		this.mdpSha256 = mdpSha256;
		this.nombreRapport = nombreRapport;
		this.estActif = estActif;
	}

	public String getIdentifiant() {
		return identifiant;
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
	
	public String getMdpSha256() {
		return mdpSha256;
	}

	public int getNombreRapport() {
		return nombreRapport;
	}
	
	public String insertIntoAgent(){
		return "INSERT INTO shyeld.agents VALUES(DEFAULT,'" + this.prenom + "','" + this.nom + "','" + this.dateMiseService +
				"','" + this.identifiant + "','" + this.mdpSha256 + "'," + this.nombreRapport + "," + this.estActif + ");\n";
	}
}
