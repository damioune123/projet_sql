package Db;

public class SuperHero {
	
	private int idSuperhero;
	private String nomCivil;
	private String prenomCivil;
	private String nomSuperhero;
	private String adressePrivee;
	private String origine;
	private String typeSuperPouvoir;
	private int puissanceSuperPouvoir;
	private int derniereCoordonneeX;
	private int derniereCoordonneeY;
	private String dateDerniereApparition;
	private char clan;
	private int nombreVictoires;
	private int nombreDefaites;
	private boolean estVivant;
	
	
	public SuperHero(int idSuperhero, String nomCivil, String prenomCivil, String nomSuperhero, String adressePrivee,
			String origine, String typeSuperPouvoir, int puissanceSuperPouvoir, int derniereCoordonneeX,
			int derniereCoordonneeY, String dateDerniereApparition, char clan, int nombreVictoires, int nombreDefaites,
			boolean estVivant) {
		super();
		this.idSuperhero = idSuperhero;
		this.nomCivil = nomCivil;
		this.prenomCivil = prenomCivil;
		this.nomSuperhero = nomSuperhero;
		this.adressePrivee = adressePrivee;
		this.origine = origine;
		this.typeSuperPouvoir = typeSuperPouvoir;
		this.puissanceSuperPouvoir = puissanceSuperPouvoir;
		this.derniereCoordonneeX = derniereCoordonneeX;
		this.derniereCoordonneeY = derniereCoordonneeY;
		this.dateDerniereApparition = dateDerniereApparition;
		this.clan = clan;
		this.nombreVictoires = nombreVictoires;
		this.nombreDefaites = nombreDefaites;
		this.estVivant = estVivant;
	}
	
	//Constructeur sans ID

	public SuperHero(String nomCivil, String prenomCivil, String nomSuperhero, String adressePrivee, String origine,
			String typeSuperPouvoir, int puissanceSuperPouvoir, int derniereCoordonneeX, int derniereCoordonneeY,
			String dateDerniereApparition, char clan, int nombreVictoires, int nombreDefaites, boolean estVivant) {
		super();
		this.nomCivil = nomCivil;
		this.prenomCivil = prenomCivil;
		this.nomSuperhero = nomSuperhero;
		this.adressePrivee = adressePrivee;
		this.origine = origine;
		this.typeSuperPouvoir = typeSuperPouvoir;
		this.puissanceSuperPouvoir = puissanceSuperPouvoir;
		this.derniereCoordonneeX = derniereCoordonneeX;
		this.derniereCoordonneeY = derniereCoordonneeY;
		this.dateDerniereApparition = dateDerniereApparition;
		this.clan = clan;
		this.nombreVictoires = nombreVictoires;
		this.nombreDefaites = nombreDefaites;
		this.estVivant = estVivant;
	}



	public int getIdSuperhero() {
		return idSuperhero;
	}

	public String getNomCivil() {
		return nomCivil;
	}

	public String getPrenomCivil() {
		return prenomCivil;
	}

	public String getNomSuperhero() {
		return nomSuperhero;
	}

	public String getAdressePrivee() {
		return adressePrivee;
	}

	public String getOrigine() {
		return origine;
	}

	public String getTypeSuperPouvoir() {
		return typeSuperPouvoir;
	}

	public int getPuissanceSuperPouvoir() {
		return puissanceSuperPouvoir;
	}

	public int getDerniereCoordonneeX() {
		return derniereCoordonneeX;
	}

	public int getDerniereCoordonneeY() {
		return derniereCoordonneeY;
	}

	public String getDateDerniereApparition() {
		return dateDerniereApparition;
	}

	public char getClan() {
		return clan;
	}

	public int getNombreVictoires() {
		return nombreVictoires;
	}

	public int getNombreDefaites() {
		return nombreDefaites;
	}

	public boolean isEstVivant() {
		return estVivant;
	}
	
	public String toString() {
		return "Heros N°" + this.idSuperhero + ", nom : " + this.nomCivil + ", prenom : " + this.prenomCivil + ", nomSuperHero : "
	+ this.nomSuperhero + ", adresse : " + this.adressePrivee + ", origine : " + this.origine + ", type super pouvoir : " + this.typeSuperPouvoir +
	", Puissance super pouvoir : " + this.puissanceSuperPouvoir + ", CoordX : " + this.derniereCoordonneeX + ", Coord Y : " + this.derniereCoordonneeY +
	"Date Apparition : " + this.dateDerniereApparition + ", Clan : " + this.clan + ", Nombre Victoires : " + this.nombreVictoires + ", Nombre Défaites : " + 
	this.nombreDefaites + "est Vivant : " + this.estVivant;
	}
}
