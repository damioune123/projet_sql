package ApplicationShyeld;
import java.text.ParseException;
import java.util.InputMismatchException;
import java.util.Scanner;
import Db.DbShyeld;
import Db.SuperHero;
import Db.Util;

public class ApplicationShyeld {
	private DbShyeld accesBDDN = new DbShyeld();
	private java.util.Scanner scanner  = new java.util.Scanner(System.in);
	
	public ApplicationShyeld() {
		super();
	}

	public void menuPrincipal(){
		try{
			char boucle;
			do {
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
				choix = scanner.nextInt();
				while(choix <1 && choix >9){
						System.out.println("Veuillez choisir un chiffre entre 1 et 10");
						scanner = new Scanner(System.in);
						choix = scanner.nextInt();
				}
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
					case 10:
						System.out.println("Au revoir !");
						System.exit(0);						
				}
				System.out.println();
				System.out.println("Voulez vous continuer ? (O/N)");
				boucle = scanner.next().charAt(0);
			}while(Util.lireCharOouN(boucle));
		}catch(InputMismatchException im){
			System.out.println("Attention � votre �criture !");
			scanner = new java.util.Scanner(System.in);
			this.menuPrincipal();
		}
		
	}

	
	private void inscriptionAgent(){
		System.out.println("Vous avez choisi d'inscrire un nouvel agent");
		System.out.println("Quel est le prénom de l'agent ?");
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
	private void suppressionAgent(){
		System.out.println("Vous avez choisi de supprimer un agent, voici une liste complète de ceux-ci :");
		accesBDDN.affichageAllAgents();
		System.out.println("Rentrez l'id de l'agent :");
		int id_agent= scanner.nextInt();
		accesBDDN.suppressionAgent(id_agent);
	
	}
	
	private void historiqueAgentEntreDates(){
		System.out.println("Vous avez de visionner l'historique d'un agent");
		System.out.println("Veuillez rentrer l'id de l'agent dont vous souhaitez voir l'historique");
		accesBDDN.affichageAllAgents();
		System.out.println("Rentrez l'id de l'agent :");
		int id_agent = scanner.nextInt();
		System.out.println("Rentrez la date de début au dormat dd-MM-YYYY");
		String dateDebutString = scanner.next();
		java.sql.Date dateDebutSQL = null;
		try {
			dateDebutSQL = Util.formaterDate(dateDebutString);
		} catch (ParseException e) {
			System.out.println("Votre date est incorrecte !");
			menuPrincipal();
		}
		System.out.println("Rentrez la date de fin au dormat dd-MM-YYYY");
		String dateFinString = scanner.next();
		java.sql.Date dateFinSQL = null;
		try {
			dateFinSQL = Util.formaterDate(dateFinString);
		} catch (ParseException e) {
			System.out.println("Votre date est incorrecte !");
			menuPrincipal();
		}
		try {
			accesBDDN.historiqueAgentEntreDates(id_agent, dateDebutSQL, dateFinSQL);
		} catch (ParseException e) {
			System.out.println("Erreur lors de l'encodage de la date");
		}

	}
	
	private int checkSiPresent(String nomSuperHero) {
		SuperHero superhero = accesBDDN.informationSuperHero(nomSuperHero);
		int idSuperHero = -1;
		if(superhero != null) {
			System.out.println("S'agit t'il de celui-ci ? (O/N)");
			char choix = scanner.next().charAt(0);
			if(Util.lireCharOouN(choix)){
				idSuperHero = superhero.getIdSuperhero();
			} else {
				idSuperHero = -2;
			}
		}
		return idSuperHero;
	}
	
	
	private void signalerDecesSH(){
		System.out.println("----------------------------------");
		System.out.println("Bienvenue en ce jour funeste");
		System.out.println("----------------------------------");
		System.out.println("Veuilliez entrer le nom du superhero : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		if(idSuperHero < -1) {
			System.out.println("Le héros à miraculeusement survécus");
		} else if (idSuperHero < 0) {
			System.out.println("Aucun héro présent sous ce nom là");
		}
		else {
			System.out.println("Nous allons inhumer ce superhéro ...");
			accesBDDN.supprimerSuperHero(idSuperHero);
		}
	}


}
