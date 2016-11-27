package Db;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;


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
	
	public static String encryptionBcrypt(String mdpClair){
		//a completer
		return mdpClair;
	}
	
	public static java.sql.Date formaterDate(String dateString) throws ParseException {
		SimpleDateFormat formater = new SimpleDateFormat("dd-MM-yyyy");
		Date date = formater.parse(dateString);
		return new java.sql.Date(date.getTime());

	}
}
