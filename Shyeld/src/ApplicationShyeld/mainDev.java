package ApplicationShyeld;

import Db.DbAgent;
import Db.DbShyeld;
import Db.SuperHero;
import Db.Util;

public class mainDev {
	
	public static void main(String[] args) {
	DbAgent db = new DbAgent();
	int dramas = db.ajouterSuperHero(new SuperHero("Christophe", "Damas", "Docteur Dramas", "IPL", "Terrienne", "Feu", 7, 25, 25, Util.formaterDate("12-12-2000"), 'D', 0, 0, true));
	int faireMieux = db.ajouterSuperHero(new SuperHero("Stéphanie", "Ferneeuw", "Faire Mieux", "IPL", "Terrienne", "Eau", 7, 50, 50, Util.formaterDate("12-12-2000"), 'D', 0, 0, true));
	int gloriaux = db.ajouterSuperHero(new SuperHero("Donatien", "Grolaux", "Gloriaux", "IPL", "Terrienne", "Terre", 7, 75, 75, Util.formaterDate("12-12-2000"), 'M', 0, 0, true));
	int hulkriet = db.ajouterSuperHero(new SuperHero("Bernard", "Henriet", "Hulkriet", "IPL", "Terrienne", "Air", 7, 100, 100, Util.formaterDate("12-12-2000"), 'M', 0, 0, true));
	}
}
