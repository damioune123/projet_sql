package Db;

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
}
