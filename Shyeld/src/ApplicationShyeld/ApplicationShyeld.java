package ApplicationShyeld;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Scanner;
import Db.DbShyeld;
import Db.SuperHero;
import Db.Util;

public class ApplicationShyeld {
	public static DbShyeld accesBDDN = new DbShyeld();
	public static void main(String[] args) throws ParseException {
		int choix;
		while((choix=menuPrincipal())!=10){
			switch(choix){
				case 1: inscriptionAgent();
						break;
				case 2: suppressionAgent();
						break;
				case 3: accesBDDN.infoPerteVisibiliteSuperHero();
						break;
				case 4: signalerDecesSH();
						break;
				case 5 : accesBDDN.listerZonesConflits();
						break;
				case 6 :historiqueAgentEntreDates();
						break;
				case 7: accesBDDN.classementVictoires();
						break;
				case 8: accesBDDN.classementDefaites();
						break;
				case 9: accesBDDN.classementReperages();
						break;
						
			}
		}
		System.out.println("Au revoir !");
		System.exit(0);
	}
	
	public static int menuPrincipal(){
		System.out.println("--------------------------------------------- ");
		System.out.println("Bienvenue dans l'application SHYELD");
		System.out.println("--------------------------------------------- ");
		System.out.println("1. Inscription d'un agent");
		System.out.println("2. Suppression d'un agent");
		System.out.println("3. Informations sur la perte de visibilité d'un super-héro");
		System.out.println("4. Supprimer un super-héro ");
		System.out.println("5. Lister les zones à risques de conflit");
		System.out.println("6. Historique d'un agent donné entre deux dates");
		System.out.println("STATISTIQUES :");
		System.out.println("7. Classement des victoires des super-héros");
		System.out.println("8. Classement des défaites des super-héros");
		System.out.println("9. Classement des agents en fonctions du nombre de repérages effectués");
		System.out.println("10. Quitter l'application");
		int choix ;
		Scanner scanner = new Scanner(System.in);
		choix = scanner.nextInt();
		while(choix <1 && choix >9){
				System.out.println("Veuillez choisir un chiffre entre 1 et 10");
				scanner = new Scanner(System.in);
				choix = scanner.nextInt();
		}
		return choix;
	}
	
	public static void inscriptionAgent(){
		System.out.println("Vous avez choisi d'inscrire un nouvel agent");
		System.out.println("Quel est le prénom de l'agent ?");
		Scanner scanner = new Scanner(System.in);
		String prenom = scanner.next();
		System.out.println("Quel est le nom de l'agent ?");
		String nom = scanner.next();
		System.out.println("Quel est l'identifiant de l'agent ?");
		String identifiant = scanner.next();
		System.out.println("Quel est le mot de passe de l'agent ?");
		String mdp_clair = scanner.next();
		System.out.println("Vous avez choisi d'inscrire un nouvel agent");
		System.out.println("Quel est le prénom de l'agent ?");
		String mdpEncrypte = Util.encryptionBcryptInscription(mdp_clair);
		accesBDDN.inscriptionAgent(nom, prenom, identifiant, mdpEncrypte);
		
	}
	public static void suppressionAgent(){
		System.out.println("Vous avez choisi de supprimer un agent, voici une liste complète de ceux-ci :");
		accesBDDN.affichageAllAgents();
		System.out.println("Rentrez l'id de l'agent :");
		Scanner scanner = new Scanner(System.in);
		int id_agent = scanner.nextInt();
		accesBDDN.suppressionAgent(id_agent);
		
		
	}
	
	public static void historiqueAgentEntreDates() throws ParseException{
		System.out.println("Vous avez de visionner l'historique d'un agent");
		System.out.println("Veuillez rentrer l'id de l'agent dont vous souhaitez voir l'historique");
		accesBDDN.affichageAllAgents();
		System.out.println("Rentrez l'id de l'agent :");
		Scanner scanner = new Scanner(System.in);
		int id_agent = scanner.nextInt();
		System.out.println("Rentrez la date de début au dormat dd-MM-YYYY");
		String dateDebutString = scanner.next();
		java.sql.Date dateDebutSQL = Util.formaterDate(dateDebutString);
		System.out.println("Rentrez la date de fin au dormat dd-MM-YYYY");
		String dateFinString = scanner.next();
		java.sql.Date dateFinSQL = Util.formaterDate(dateFinString);
		accesBDDN.historiqueAgentEntreDates(id_agent, dateDebutSQL, dateFinSQL);

	}
	private static int checkSiPresent(String nomSuperHero) {
		ArrayList<SuperHero> superheros = accesBDDN.informationSuperHero(nomSuperHero);
		int idSuperHero = -1;
		for(SuperHero superhero : superheros) {
			System.out.println("S'agit t'il de celui-ci ? (O/N)");
			System.out.println(superhero.toString());
			Scanner scanner = new Scanner(System.in);
			char choix = scanner.next().charAt(0);
			if(Util.lireCharOouN(choix)){
				idSuperHero = superhero.getIdSuperhero();
				break;
			} 
		}
		return idSuperHero;
	}
	
	
	
	
	private static void signalerDecesSH(){
		System.out.println("----------------------------------");
		System.out.println("Bienvenue en ce jour funeste");
		System.out.println("----------------------------------");
		System.out.println("Veuilliez entrer le nom du superhero : ");
		Scanner scanner = new Scanner(System.in);
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Nous allons proc�d� � l'inhumation de ce superhero ...");
		
		accesBDDN.supprimerSuperHero(idSuperHero);
	}
	
	

}
