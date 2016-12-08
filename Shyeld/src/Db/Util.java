package Db;

import java.text.ParseException;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.InputMismatchException;

import org.mindrot.BCrypt;


public class Util {
	
	private static java.util.Scanner scanner = new java.util.Scanner(System.in);


	public static boolean lireCharOouN(char carac) {
		do {
			if(carac == 'o' || carac == 'O') {
				return true;
			} else if (carac == 'n' || carac == 'N'){
				return false;
			}
		}while(carac != 'o' && carac != 'O' && carac != 'n' && carac != 'N');
		return true; //Uniquement pour la compilation
	}
	
	public static String encryptionBcryptInscription(String mdpClair){
		String hashed = BCrypt.hashpw(mdpClair, BCrypt.gensalt());
		return hashed;
	}
	
	public static boolean verifPasswordBcrypt(String mdpClair, String hashed){
		return BCrypt.checkpw(mdpClair, hashed);
	}

	
	public static java.sql.Date formaterDate(String dateString) {
		try {
			SimpleDateFormat formater = new SimpleDateFormat("dd-MM-yyyy");
			Date date = formater.parse(dateString);
			return new java.sql.Date(date.getTime());
		} catch (ParseException pa){
			System.out.println("Veuilliez entrer à nouveau la date");
			return formaterDate(scanner.next());
		}
	}
	
	public static int lireEntierAuClavier(String message){
		try {
			System.out.println(message);
			return scanner.nextInt();
		} catch (InputMismatchException im){
			scanner = new java.util.Scanner(System.in);
			return lireEntierAuClavier(message);
		}
	}
	
	public static int checkSiEntre(int entier, int entierMin, int entierMax){
		while(entier < entierMin || entier > entierMax) {
			entier = Util.lireEntierAuClavier("L'entier doit être compris entre " + entierMin + " et " + entierMax);
			System.out.println("Voulez vous continuer ? (O/N)");
			char carac = scanner.next().charAt(0);
			if(!Util.lireCharOouN(carac))
				return -1;
		}
		return entier;
	}
}
