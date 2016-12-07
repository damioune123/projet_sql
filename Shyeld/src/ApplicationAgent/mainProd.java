package ApplicationAgent;

import java.sql.SQLException;
import java.util.InputMismatchException;
import Db.DbAgent;
import Db.Util;

public class mainProd {
	public static void main(String[] args) {
		ApplicationAgent appA = new ApplicationAgent();
		appA.connexion();
		appA.menuPrincipal();
		
	}
	
}
