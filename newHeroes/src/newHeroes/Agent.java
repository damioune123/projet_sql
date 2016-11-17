package newHeroes;

public class Agent {
	
	private int idAgent;
	private String prenom;
	private String nom;
	private String dateMiseService;
	private boolean estActif;
	String identifant;
	String mdp_sha256;
	int nbre_rapport;
	
	public Agent(int idAgent, String prenom, String nom, String dateMiseService,String identifant, String mdp_sha256, int nbre_rapport, boolean estActif) {
		super();
		this.idAgent = idAgent;
		this.prenom = prenom;
		this.nom = nom;
		this.dateMiseService = dateMiseService;
		this.estActif = estActif;
		this.identifant = identifant;
		this.mdp_sha256 = mdp_sha256;
		this.nbre_rapport = nbre_rapport;
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
	
	public String getIdentifant() {
		return identifant;
	}

	public void setIdentifant(String identifant) {
		this.identifant = identifant;
	}

	public String getMdp_sha256() {
		return mdp_sha256;
	}

	public void setMdp_sha256(String mdp_sha256) {
		this.mdp_sha256 = mdp_sha256;
	}

	public int getNbre_rapport() {
		return nbre_rapport;
	}

	public void setNbre_rapport(int nbre_rapport) {
		this.nbre_rapport = nbre_rapport;
	}

	public String insertIntoAgent(){
		return "INSERT INTO shyeld.agents VALUES(DEFAULT,'" + this.prenom + "','" + this.nom + "','" + this.dateMiseService +
				"','" +this.identifant+"','"+this.mdp_sha256+"',"+this.nbre_rapport +","+ this.estActif + ");\n";
	}
}
