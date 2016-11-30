package ApplicationAgent;

import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.InputMismatchException;

import Db.SuperHero;
import Db.Util;
import Db.Combat;
import Db.DbAgent;
import Db.Participation;
import Db.Reperage;

public class ApplicationAgent {
	
	public static java.util.Scanner scanner = new java.util.Scanner(System.in);
	public static DbAgent connexionDb = new DbAgent();
	private static int idAgent;
	private static boolean estConnecte;
	
	public static void main(String[] args) {
		
		try {
			connexion();			
			menuPrincipal();
		} catch (InputMismatchException ie) {
			scanner = new java.util.Scanner(System.in);
			if(estConnecte)
				menuPrincipal();
			main(args);
		}
	}

	private static void menuPrincipal() {
		do {
			System.out.println("--------------------------------------");
			System.out.println(" Bienvenue dans l'Agent App");
			System.out.println("--------------------------------------");
			System.out.println("1. Informations sur un Superhero");
			System.out.println("2. Ajouter son rapport au sujet d'un combat");
			System.out.println("3. Ajouter un Reperage");
			System.out.println("4. Signaler la mort d'un Superhero");
			int choix = scanner.nextInt();
			switch(choix){
			case 1 :
				informationSuperHero();
				break;
			case 2 :
				rapportCombat();
				break;
			case 3 : 
				reperage();
				break;
			case 4 :
				signalerDecesSH();
				break;
			default :	
				System.out.println("Mauvais chiffre entré, faites attention la prochaine fois");
			}
			System.out.println("Voulez vous continuer (O/N)");
		} while(Util.lireCharOouN(scanner.next().charAt(0)));
	}

	private static void connexion() {
		System.out.println("-----------------------------------------");
		System.out.println("Bienvenue dans la fenêtre de connexion");
		System.out.println("-----------------------------------------");
		System.out.println("1. Se connecter");
		System.out.println("2. Quitter l'application");
		do {
			int choixLogin = scanner.nextInt();
			switch(choixLogin) {
			case 1 :
				login();
				break;
			case 2 :
				System.exit(0);
			}
		} while(!estConnecte);
	}
		
	private static void login(){
		while(true){
			System.out.println("Entrez votre identifiant : ");
			String identifiant = scanner.next();
			System.out.println("Entrez votre mot de passe : ");
			String mdpClair = scanner.next();
			String mdpHashed = connexionDb.checkConnexion(identifiant);
			if(mdpHashed != null && Util.verifPasswordBcrypt(mdpClair, mdpHashed)) {
				try {
					idAgent = connexionDb.getAgent(identifiant);
				} catch (SQLException e) {
					e.printStackTrace();
				}
				estConnecte = true;
				return;
			}
			System.out.println("Mauvais identifiants !");
		}
		
	}
	
	private static void informationSuperHero(){
		System.out.println("Veuilliez entrer le nom de votre superhero : ");
		String nom = scanner.next();
		System.out.println("yoyo "+nom);
		ArrayList<SuperHero> listeSuperHero = connexionDb.informationSuperHero(nom);
		if(!listeSuperHero.isEmpty()) {
			for(SuperHero superHero: listeSuperHero) {
				System.out.println(superHero.toString());
			}
		} else {
			System.out.println("Aucun Héros ne correspond au nom entré, le processus d'inscription de l'hï¿½ros est lancï¿½ : ");
			creationSuperHero(nom);
		}
	}
	
	private static int creationSuperHero(String nomSuperHero) {
		System.out.println("Veuilliez entrer le nom civil du superhéros : ");
		String nom = scanner.next();
		System.out.println("Veuilliez entrer le prenom civil du superhéros");
		String prenom = scanner.next();
		if(nomSuperHero == null) {
			System.out.println("Veuilliez entrer le surnom : ");
			nomSuperHero = scanner.next();
		}
		System.out.println("Entrer l'adresse du superhero : ");
		String adresse = scanner.next();
		System.out.println("Entrer l'origine du superhéros : ");
		String origine = scanner.next();
		System.out.println("Entrer le type de super pouvoir qu'il possede : ");
		String typePouvoir = scanner.next();
		System.out.println("Entrer la puissance du super pouvoir : ");
		int puissancePouvoir = scanner.nextInt();
		System.out.println("Entrer la coordonnée X où vous l'avez aperçu : ");
		int coordX = scanner.nextInt();
		System.out.println("Entrer à présent la coordonnée Y où vous l'avez aperçu : ");
		int coordY = scanner.nextInt();
		System.out.println("A quelle date l'avez vous aperçu : ");
		String date = scanner.next();
		System.out.println("Quel est son clan ? (M/D)");
		char clan = scanner.next().charAt(0);
		System.out.println("Combien de victoires a t'il eu ? ");
		int victoires = scanner.nextInt();
		System.out.println("Combien de défaites a t'il eu ?");
		int defaites = scanner.nextInt();
		boolean estVivant;
		char vivantChar;
		do {
			System.out.println("Est t'il encore en vie ? (O/N)");
			vivantChar = scanner.next().charAt(0);
			estVivant = true;
			if(vivantChar == 'O' || vivantChar == 'o') {
				estVivant = true;
			} else if(vivantChar == 'N' || vivantChar == 'n') {
				estVivant = false;
			}
		} while (vivantChar != 'o' && vivantChar != 'O' && vivantChar != 'n' && vivantChar != 'N');
		int idSuperHero = - 1;
		try {
			idSuperHero = connexionDb.ajouterSuperHero(new SuperHero(nom, prenom, nomSuperHero, adresse, origine, typePouvoir,
					puissancePouvoir, coordX, coordY, date, clan, victoires, defaites, estVivant));
		} catch (ParseException e) {
			System.out.println("Erreur lors de l'encodage de la date");
		}
		if(idSuperHero < 0){
			System.out.println("L'ajout n'a pas pu être effectué");
		} else {
			System.out.println("Le SuperHero est ajouté sous l'id : " + idSuperHero);
		}
		return idSuperHero;
	}

	private static void rapportCombat() {
		ArrayList<Participation> participations = new ArrayList<Participation>();
		System.out.println("---------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'un rapport de combat");
		System.out.println("---------------------------------------------------");
		System.out.println("Veuilliez tout d'abord indiquer la date du combat :(dd-mm-yyyy) ");
		String date = scanner.next();
		System.out.println("Quelle était la coordonnée X du combat : ");
		int coordX = scanner.nextInt();
		System.out.println("Quelle était la coordonnée Y du combat : ");
		int coordY = scanner.nextInt();
		int idCombat = -1;
		try {
			System.out.println("Nous allons à présent passer à l'encodage des participations");
			int i = 0;
			char boucle;
			do {
				Participation participation = ajouterParticipation(idCombat, i);
				participations.add(participation); 
				i++;
				System.out.println("Voulez vous ajouter une autre participation ? (O/N)");
				boucle = scanner.next().charAt(0);
			} while (Util.lireCharOouN(boucle));
			idCombat = connexionDb.ajouterCombat(new Combat(date, coordX, coordY, idAgent, 0, 0, 0, 0), participations);
		} catch (ParseException e) {
			System.out.println("Erreur lors de l'encodage de la date");
		}
		if(idCombat < 0){
			System.out.println("Erreur lors de l'ajout du combat");
		} else {
			System.out.println("Le combat a été ajouté sous l'id : " + idCombat);
		}
		
	}
	
	private static Participation ajouterParticipation(int idCombat, int numeroLigne) {
		System.out.println("------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'une participation");
		System.out.println("-------------------------------------------------");
		System.out.println("Commencer par entrer le surnom du superhéros : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Comment s'est termine le combat pour cette personne (G/P/N) ? ");
		char issue = scanner.next().charAt(0); //A AMELIORER
		return new Participation(idSuperHero, idCombat, issue, numeroLigne);
	}
	
	private static void reperage(){
		System.out.println("-------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'un reperage");
		System.out.println("-------------------------------------------");
		System.out.println("Commencer par entrer le nom du superhéros que vous avez aperçu : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Veuilliez entrer la coordonnée X : ");
		int coordX = scanner.nextInt();
		System.out.println("Veuilliez entrer la coordonnée Y : ");
		int coordY = scanner.nextInt();
		System.out.println("A quelle date l'avez vous vu ? (dd-mm-yyyy)");
		String date = scanner.next();
		int idReperage = -1;
		try {
			idReperage = connexionDb.ajouterReperage(new Reperage(idAgent, idSuperHero, coordX, coordY, date));
		} catch (ParseException e) {
			System.out.println("Erreur lors de l'encodage de la date");
		}
		if(idReperage < 0) {
			System.out.println("Erreur lors de l'ajout du repérage");
		} else {
			System.out.println("Le repérage a bien été ajouté");
		}
	}

	private static int checkSiPresent(String nomSuperHero) {
		ArrayList<SuperHero> superheros = connexionDb.informationSuperHero(nomSuperHero);
		int idSuperHero = -1;
		for(SuperHero superhero : superheros) {
			System.out.println("S'agit t'il de celui-ci ? (O/N)");
			System.out.println(superhero.toString());
			char choix = scanner.next().charAt(0);
			if(Util.lireCharOouN(choix)){
				idSuperHero = superhero.getIdSuperhero();
				break;
			} 
		}
		if(idSuperHero < 0){
			idSuperHero = creationSuperHero(null);
		}
		return idSuperHero;
	}
	
	private static void signalerDecesSH(){
		System.out.println("----------------------------------");
		System.out.println("Bienvenue en ce jour funeste");
		System.out.println("----------------------------------");
		System.out.println("Veuilliez entrer le nom du superhéro : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Nous allons inhumer ce superhéro ...");
		connexionDb.supprimerSuperHero(idSuperHero);
	}
}

