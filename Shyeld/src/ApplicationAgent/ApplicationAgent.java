package ApplicationAgent;

import java.text.ParseException;
import java.util.ArrayList;

import Db.SuperHero;
import Db.Util;
import Db.Combat;
import Db.Db;
import Db.Participation;
import Db.Reperage;

public class ApplicationAgent {
	
	public static java.util.Scanner scanner = new java.util.Scanner(System.in);
	public static Db connexionDb = new Db();
	private static int idAgent = 1;
	
	public static void main(String[] args) {
		
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
				System.out.println("Mauvais chiffre entré, faites attention la prochaoine fois");
			}
			System.out.println("Voulez vous continuer (O/N)");
		} while(Util.lireCharOouN(scanner.next().charAt(0)));
	}
	
	private static void informationSuperHero(){
		System.out.println("Veuilliez entrer le nom de votre superhero : ");
		String nom = scanner.next();
		ArrayList<SuperHero> listeSuperHero = connexionDb.informationSuperHero(nom);
		if(!listeSuperHero.isEmpty()) {
			for(SuperHero superHero: listeSuperHero) {
				System.out.println(superHero.toString());
			}
		} else {
			System.out.println("Aucun Heros ne correspond au nom entré, le processus d'inscription de l'héros est lancé : ");
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
		System.out.println("Combien de victoires à t'il eu ? ");
		int victoires = scanner.nextInt();
		System.out.println("Combien de défaites à t'il eu ?");
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
			System.out.println("L'ajout n'a pas pu être effectué");
		} else {
			System.out.println("Le SuperHero est ajouté sous l'id : " + idSuperHero);
		}
		return idSuperHero;
	}

	private static void rapportCombat() {
		System.out.println("---------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'un rapport de combat");
		System.out.println("---------------------------------------------------");
		System.out.println("Veuilliez tout d'abord indiquer la date du combat : ");
		String date = scanner.next();
		System.out.println("Quelle était la coordonnée X du combat : ");
		int coordX = scanner.nextInt();
		System.out.println("Quelle était la coordonnée Y du combat : ");
		int coordY = scanner.nextInt();
		int agent = idAgent;
		int nombreParticipants;
		int idCombat = -1;
		try {
			idCombat = connexionDb.combatDejaExistant(date, coordX, coordY);
		} catch (ParseException pe) {
			pe.printStackTrace();
		}
		if(idCombat >= 0) {
			System.out.println("Combien de participants supplémentaires avez vous vu ? ");
			nombreParticipants = scanner.nextInt();
		} else {
			System.out.println("Combien y avait t'il de participants ? ");
			nombreParticipants = scanner.nextInt();
			System.out.println("Combien y avait t'il de gagnants ? ");
			int nombreGagnants = scanner.nextInt();
			System.out.println("Combien y avait t'il de perdants ? ");
			int nombrePerdants = scanner.nextInt();
			System.out.println("Combien de personnes neutres y avait t'il ? ");
			int nombreNeutres = scanner.nextInt();
			System.out.println("Quel clan est sortis vainqueur de ce combat ? ");
			char clan = scanner.next().charAt(0);
			try {
				idCombat = connexionDb.ajouterCombat(new Combat(date, coordX, coordY, agent, nombreParticipants,
						nombreGagnants, nombrePerdants, nombreNeutres, clan));
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		if(idCombat < 0){
			System.out.println("Erreur lors de l'ajout du combat");
		} else {
			System.out.println("Nous allons à présent passer à l'encodage des participations");
			for(int i = 0; i < nombreParticipants; i++){
				ajouterParticipation(idCombat, i);
			}
		}
		
	}
	
	private static void ajouterParticipation(int idCombat, int numeroLigne) {
		System.out.println("------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'une participation");
		System.out.println("-------------------------------------------------");
		System.out.println("Commencer par entrer le surnom du superhéros : ");
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
		System.out.println("Commencer par entrer le nom du superhéros que vous avez aperçu : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		System.out.println("Veuilliez entrer la coordonnée X : ");
		int coordX = scanner.nextInt();
		System.out.println("Veuilliez entrer la coordonnée Y : ");
		int coordY = scanner.nextInt();
		System.out.println("A quelle date l'avez vous vu ? ");
		String date = scanner.next();
		int idReperage = connexionDb.ajouterReperage(new Reperage(idAgent, idSuperHero, coordX, coordY, date));
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
		System.out.println("Nous allons procédé à l'inhumation de ce superhero ...");
		connexionDb.supprimerSuperHero(idSuperHero);
		
	}
}

