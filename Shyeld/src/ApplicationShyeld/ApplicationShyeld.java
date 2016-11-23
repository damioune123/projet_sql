package ApplicationShyeld;
import java.text.ParseException;
import java.util.Scanner;

public class ApplicationShyeld {
	
	public static void main(String[] args) throws ParseException {
		Db.Db accesBDDN= new Db.Db();
		int choix;
		while((choix=menuPrincipal())!=10){
			switch(choix){
				case 1: accesBDDN.inscriptionAgent();
						break;
				case 2: accesBDDN.suppressionAgent();
						break;
				case 3: accesBDDN.infoPerteVisibiliteSuperHero();
						break;
				case 4: accesBDDN.supprimerSuperHero();
						break;
				case 5 : accesBDDN.listerZonesConflits();
						break;
				case 6 : accesBDDN.historiqueAgentEntreDates();
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
	

}
