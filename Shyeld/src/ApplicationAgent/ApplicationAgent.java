package ApplicationAgent;

import java.text.ParseException;
import java.util.ArrayList;

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
		
		System.out.println("-----------------------------------------");
		System.out.println("Bienvenue dans la fen�tre de connexion");
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
		
		do {
			System.out.println("--------------------------------------");
			System.out.println(" Bienvenue dans l'Agent App");
			System.out.println("--------------------------------------");
			System.out.println("1. Information sur un Superhero");
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
				System.out.println("Mauvais chiffre entr�, faites attention la prochaine fois");
			}
			System.out.println("Voulez vous continuer (O/N)");
		} while(Util.lireCharOouN(scanner.next().charAt(0)));
	}
		
	private static void login(){
		System.out.println("Entrez votre identifiant : ");
		String identifiant = scanner.next();
		System.out.println("Entrez votre mot de passe : ");
		String mdp = scanner.next();
		idAgent = connexionDb.checkConnexion(identifiant, mdp);
		if(idAgent >= 0) {
			estConnecte = true;
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
			System.out.println("Aucun Heros ne correspond au nom entr�, le processus d'inscription de l'h�ros est lanc� : ");
			creationSuperHero(nom);
		}
	}
	
	private static int creationSuperHero(String nomSuperHero) {
		System.out.println("Veuilliez entrer le nom civil du superh�ros : ");
		String nom = scanner.next();
		System.out.println("Veuilliez entrer le prenom civil du superh�ros");
		String prenom = scanner.next();
		if(nomSuperHero == null) {
			System.out.println("Veuilliez entrer le surnom : ");
			nomSuperHero = scanner.next();
		}
		System.out.println("Entrer l'adresse du superhero : ");
		String adresse = scanner.next();
		System.out.println("Entrer l'origine du superh�ros : ");
		String origine = scanner.next();
		System.out.println("Entrer le type de super pouvoir qu'il possede : ");
		String typePouvoir = scanner.next();
		System.out.println("Entrer la puissance du super pouvoir : ");
		int puissancePouvoir = scanner.nextInt();
		System.out.println("Entrer la coordonn�e X o� vous l'avez aper�u : ");
		int coordX = scanner.nextInt();
		System.out.println("Entrer � pr�sent la coordonn�e Y o� vous l'avez aper�u : ");
		int coordY = scanner.nextInt();
		System.out.println("A quelle date l'avez vous aper�u : ");
		String date = scanner.next();
		System.out.println("Quel est son clan ? (M/D)");
		char clan = scanner.next().charAt(0);
		System.out.println("Combien de victoires � t'il eu ? ");
		int victoires = scanner.nextInt();
		System.out.println("Combien de d�faites � t'il eu ?");
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
			e.printStackTrace();
		}
		if(idSuperHero < 0){
			System.out.println("L'ajout n'a pas pu �tre effectu�");
		} else {
			System.out.println("Le SuperHero est ajout� sous l'id : " + idSuperHero);
		}
		return idSuperHero;
	}

	private static void rapportCombat() {
		System.out.println("---------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'un rapport de combat");
		System.out.println("---------------------------------------------------");
		System.out.println("Veuilliez tout d'abord indiquer la date du combat :(dd-mm-yyyy) ");
		String date = scanner.next();
		System.out.println("Quelle �tait la coordonn�e X du combat : ");
		int coordX = scanner.nextInt();
		System.out.println("Quelle �tait la coordonn�e Y du combat : ");
		int coordY = scanner.nextInt();
		int nombreParticipants;
		int idCombat = -1;
		/* try {
			idCombat = connexionDb.combatDejaExistant(date, coordX, coordY); => supprimer la totalite de ce qui y est rattache ? 
		} catch (ParseException pe) {
			pe.printStackTrace();
		}*/
		
		System.out.println("Quel clan est sortis vainqueur de ce combat ? M-D");
			char clan = Character.toUpperCase((scanner.next().charAt(0)));
		try {
			idCombat = connexionDb.ajouterCombat(new Combat(date, coordX, coordY, idAgent, 0, 0, 0, 0, clan));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		if(idCombat < 0){
			System.out.println("Erreur lors de l'ajout du combat");
		} else {
			System.out.println("Nous allons � pr�sent passer � l'encodage des participations");
			int i = 0;
			char boucle;
			do {
				ajouterParticipation(idCombat, i);
				i++;
				System.out.println("Voulez vous ajouter une autre participation ? (O/N)");
				boucle = scanner.next().charAt(0);
			} while (Util.lireCharOouN(boucle));
		}
		
	}
	
	private static void ajouterParticipation(int idCombat, int numeroLigne) {
		System.out.println("------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'une participation");
		System.out.println("-------------------------------------------------");
		System.out.println("Commencer par entrer le surnom du superh�ros : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Comment s'est termine le combat pour cette personne (G/P/N) ? ");
		char issue = scanner.next().charAt(0); //A AMELIORER
		int idParticipation = connexionDb.ajouterParticipation(new Participation(idSuperHero, idCombat, issue, numeroLigne));
		if(idParticipation < 0) {
			System.out.println("Erreur lors de l'ajout de la participation");
		}
	}
	
	private static void reperage(){
		System.out.println("-------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'un reperage");
		System.out.println("-------------------------------------------");
		System.out.println("Commencer par entrer le nom du superh�ros que vous avez aper�u : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Veuilliez entrer la coordonn�e X : ");
		int coordX = scanner.nextInt();
		System.out.println("Veuilliez entrer la coordonn�e Y : ");
		int coordY = scanner.nextInt();
		System.out.println("A quelle date l'avez vous vu ? (dd-mm-yyyy)");
		String date = scanner.next();
		int idReperage = -1;
		try {
			idReperage = connexionDb.ajouterReperage(new Reperage(idAgent, idSuperHero, coordX, coordY, date));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		if(idReperage < 0) {
			System.out.println("Erreur lors de l'ajout du rep�rage");
		} else {
			System.out.println("Le rep�rage a bien �t� ajout�");
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
		System.out.println("Veuilliez entrer le nom du superhero : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Nous allons proc�d� � l'inhumation de ce superhero ...");
		connexionDb.supprimerSuperHero(idSuperHero);
	}
}

