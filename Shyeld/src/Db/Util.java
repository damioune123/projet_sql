package Db;

import java.text.ParseException;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.mindrot.BCrypt;


public class Util {


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

	
	public static java.sql.Date formaterDate(String dateString) throws ParseException {
		SimpleDateFormat formater = new SimpleDateFormat("dd-MM-yyyy");
		Date date = formater.parse(dateString);
		return new java.sql.Date(date.getTime());
	}
}
