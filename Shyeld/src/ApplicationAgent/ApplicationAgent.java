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
	
	private java.util.Scanner scanner = new java.util.Scanner(System.in); 
	private DbAgent connexionDb = new DbAgent();
	private int idAgent;
	private boolean estConnecte;


	public ApplicationAgent() {
		super();
	}

	public void menuPrincipal() {
		try {
			do {
				System.out.println("--------------------------------------");
				System.out.println(" Bienvenue dans l'Agent App");
				System.out.println("--------------------------------------");
				System.out.println("1. Informations sur un Superhero");
				System.out.println("2. Ajouter son rapport au sujet d'un combat");
				System.out.println("3. Ajouter un Reperage");
				System.out.println("4. Signaler la mort d'un Superhero");
				System.out.println("5. Quitter l'application");
				
				int choix;
				choix = scanner.nextInt();
	
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
				case 5:
					System.exit(0);
				default :	
					System.out.println("Mauvais chiffre entré, faites attention la prochaine fois");
				}
				System.out.println("Voulez vous continuer (O/N)");
			} while(Util.lireCharOouN(scanner.next().charAt(0)));
		} catch (InputMismatchException im){
			System.out.println("Attention à votre écriture !");
			scanner = new java.util.Scanner(System.in);
			this.menuPrincipal();
		}
	}

	public void connexion() {
		try {
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
		} catch (InputMismatchException im) {
			System.out.println("Faites attention à votre écriture !");
			scanner = new java.util.Scanner(System.in);
			this.connexion();
		}
	}
	private void login(){
		while(true){
			System.out.println("Entrez votre identifiant : ");
			String identifiant = scanner.next();
			System.out.println("Entrez votre mot de passe : ");
			String mdpClair = scanner.next();
			String mdpHashed = connexionDb.checkConnexion(identifiant);
			if(mdpHashed != null && Util.verifPasswordBcrypt(mdpClair, mdpHashed)) {
				try {
					this.idAgent = connexionDb.getAgent(identifiant);
				} catch (SQLException e) {
					e.printStackTrace();
				}
				estConnecte = true;
				return;
			}
			System.out.println("Mauvais identifiants !");
		}
		
	}
		
	
	
	public void informationSuperHero(){
		System.out.println("Veuilliez entrer le nom de votre superhero : ");
		String nom = scanner.next();
		SuperHero superHero = connexionDb.informationSuperHero(nom);
		if(superHero != null) {
			/*for(SuperHero superHero: listeSuperHero) {
				System.out.println(superHero.toString());
			}*/
		} else {
			System.out.println("Aucun Héros ne correspond au nom entré, le processus d'inscription est lancé : ");
			creationSuperHero(nom);
		}
	}
	
	public int creationSuperHero(String nomSuperHero) {
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
		int puissancePouvoir = Util.checkSiEntre(Util.lireEntierAuClavier("Entrer la puissance du super pouvoir : "), 0, 10);
		if(puissancePouvoir == -1)
			return -1;
		int coordX = Util.checkSiEntre(Util.lireEntierAuClavier("Entrer la coordonnée X où vous l'avez aperçu : "), 0, 100);
		if(coordX == -1)
			return -1;
		int coordY = Util.checkSiEntre(Util.lireEntierAuClavier("Entrer à présent la coordonnée Y où vous l'avez aperçu : "), 0, 100);
		if(coordY == -1)
			return -1;
		System.out.println("A quelle date l'avez vous aperçu : ");
		String date = scanner.next();
		System.out.println("Quel est son clan ? (M/D)");
		char clan = scanner.next().charAt(0);
		int victoires = Util.lireEntierAuClavier("Combien de victoires a t'il eu ? ");
		int defaites = Util.lireEntierAuClavier("Combien de défaites a t'il eu ?");
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

	public void rapportCombat() {
		ArrayList<Participation> participations = new ArrayList<Participation>();
		System.out.println("---------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'un rapport de combat");
		System.out.println("---------------------------------------------------");
		System.out.println("Veuilliez tout d'abord indiquer la date du combat :(dd-mm-yyyy) ");
		String date = scanner.next();
		int coordX = Util.checkSiEntre(Util.lireEntierAuClavier("Quelle était la coordonnée X du combat : "), 0, 100);
		if(coordX == -1)
			return;
		int coordY = Util.checkSiEntre(Util.lireEntierAuClavier("Quelle était la coordonnée Y du combat : "), 0, 100);
		if(coordY == -1)
			return;
		int idCombat = -1;
		try {
			System.out.println("Nous allons à présent passer à l'encodage des participations");
			int i = 0;
			char boucle;
			do {
				Participation participation = ajouterParticipation(idCombat, i);
				if(participation == null)
					return;
				participations.add(participation); 
				i++;
				System.out.println("Voulez vous ajouter une autre participation ? (O/N)");
				boucle = scanner.next().charAt(0);
			} while (Util.lireCharOouN(boucle));
			idCombat = connexionDb.ajouterCombat(new Combat(date, coordX, coordY, idAgent, 0, 0, 0, 0), participations);
		} catch (ParseException e) {
			System.out.println("Erreur lors de l'encodage de la date");
		}
		if(idCombat == -1){
			System.out.println("Erreur lors de l'ajout du combat");
		} else if (idCombat != -2) {
			System.out.println("Le combat a été ajouté sous l'id : " + idCombat);
		}
		
	}
	
	public Participation ajouterParticipation(int idCombat, int numeroLigne) {
		System.out.println("------------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'une participation");
		System.out.println("-------------------------------------------------");
		System.out.println("Commencer par entrer le surnom du superhéros : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		if(idSuperHero == -1){
			System.out.println("Ce héros n'est malheureusement pas connus de nos systèmes, le processus d'inscription va commencer");
			idSuperHero = creationSuperHero(nomSuperHero);
		}
		if(idSuperHero == -1)
			return null;
		System.out.println("Comment s'est termine le combat pour cette personne (G/P/N) ? ");
		char issue = scanner.next().charAt(0); 
		return new Participation(idSuperHero, idCombat, issue, numeroLigne);
	}
	
	public void reperage(){
		System.out.println("-------------------------------------------");
		System.out.println("Bienvenue dans l'encodage d'un reperage");
		System.out.println("-------------------------------------------");
		System.out.println("Commencer par entrer le nom du superhéros que vous avez aperçu : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		if(idSuperHero == -1){
			System.out.println("Ce héros n'est malheureusement pas connus de nos systèmes, le processus d'inscription va commencer");
			idSuperHero = creationSuperHero(nomSuperHero);
		}
		if(idSuperHero == -1)
			return;
		int coordX = Util.checkSiEntre(Util.lireEntierAuClavier("Veuilliez entrer la coordonnée X où vous avez aperçu le superhéro: "), 0, 100);
		int coordY = Util.checkSiEntre(Util.lireEntierAuClavier("Veuilliez entrer la coordonnée Y où vous avez aperçu le superhéro: "), 0, 100);
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

	public int checkSiPresent(String nomSuperHero) {
		SuperHero superhero = connexionDb.informationSuperHero(nomSuperHero);
		int idSuperHero = -1;
		if(superhero != null) {
			System.out.println("S'agit t'il de celui-ci ? (O/N)");
			char choix = scanner.next().charAt(0);
			if(Util.lireCharOouN(choix)){
				idSuperHero = superhero.getIdSuperhero();
			} else {
				idSuperHero = -2;
			}
			if(idSuperHero < 0){
				idSuperHero = creationSuperHero(null);
			}
		}
		return idSuperHero;
	}
	
	public void signalerDecesSH(){
		System.out.println("----------------------------------");
		System.out.println("Bienvenue en ce jour funeste");
		System.out.println("----------------------------------");
		System.out.println("Veuilliez entrer le nom du superhéro : ");
		String nomSuperHero = scanner.next();
		int idSuperHero = checkSiPresent(nomSuperHero);
		if(idSuperHero < -1) {
			System.out.println("Le héros à miraculeusement survécus");
		} else if (idSuperHero < 0) {
			System.out.println("Aucun héro présent sous ce nom là");
		}else {
			System.out.println("Nous allons inhumer ce superhéro ...");
			connexionDb.supprimerSuperHero(idSuperHero);
		}
	}
}

