package Db;
import java.sql.*;
import java.util.ArrayList;

public class Db {
	
	private Connection connexionDb;
	
	public Db() {
		if(connexionDb == null) {
			try {
				Class.forName("org.postgresql.Driver");
			} catch (ClassNotFoundException e) {
				System.out.println("Driver PostgreSQL manquant !");
				System.exit(1);
			}	
			String url="jdbc:postgresql://localhost:5433/shyeld" + "?user=postgres&password=Tiffy0603"; //Attention A MODIFIER
			try {
				this.connexionDb=DriverManager.getConnection(url);
			} catch (SQLException e) {
				System.out.println("Impossible de joindre le server !");
				System.exit(1);
			}
		}
	}
	
	public void test() {
		try {
			Statement s = this.connexionDb.createStatement();
			try(ResultSet rs= s.executeQuery("SELECT s.* FROM shyeld.superheros s;")) {
				while(rs.next()) {
					System.out.println(rs.getString(2));
				}
			}
		} catch (SQLException se) {
				se.printStackTrace();
				System.exit(1);
			}
	}
	
	public ArrayList<SuperHero> informationSuperHero(String nomSuperHero){
		ArrayList<SuperHero> listeSuperHero = new ArrayList<SuperHero>();
		try {
			Statement s = this.connexionDb.createStatement();
			try(ResultSet rs = s.executeQuery("SELECT shyeld.rechercherSuperHerosParNomSuperHero('" + nomSuperHero + "');")) {
				while(rs.next()) {
					listeSuperHero.add(new SuperHero(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6),
							rs.getString(7), rs.getInt(8), rs.getInt(9), rs.getInt(10), rs.getString(11), rs.getString(12).charAt(0), rs.getInt(13),
							rs.getInt(14), rs.getBoolean(15)));
				}
				return listeSuperHero;
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return null;
		}
	}
	
	public int ajouterSuperHero(SuperHero superhero) {
		try {
			Statement s = this.connexionDb.createStatement();
			try(ResultSet rs = s.executeQuery("SELECT shyeld.creation_superhero('" + superhero.getNomCivil() + "','" + superhero.getPrenomCivil() +
					"','" + superhero.getNomSuperhero() + "','" +  superhero.getAdressePrivee() + "','" + superhero.getOrigine() + "','" +
					superhero.getTypeSuperPouvoir() + "'," + superhero.getPuissanceSuperPouvoir() + "," + superhero.getDerniereCoordonneeX() +
					"," + superhero.getDerniereCoordonneeY() + "','" + superhero.getDateDerniereApparition() + "','" + superhero.getClan() + "'," +
					superhero.getNombreVictoires() + "," + superhero.getNombreDefaites() + "," + superhero.isEstVivant() + ");")) {
				return rs.getInt(1);
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}
	
	public int ajouterCombat(Combat combat) {
		try {
			Statement s = this.connexionDb.createStatement();
			try(ResultSet rs = s.executeQuery("SELECT shyeld.creation_combat('" + combat.getDateCombat() + "'," +
						combat.getCoordCombatX()  +  "," + combat.getCoordCombatY() + "," + combat.getAgent() + "," +
						combat.getNombreParticipants() + "," + combat.getNombreGagnants() + "," + combat.getNombrePerdants() +
						"," + combat.getNombreNeutres() + ",'" + combat.getClan() + "');")) {
				return rs.getInt(1);
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}
	
	public int ajouterParticipation(Participation participation) {
		try {
			Statement s = this.connexionDb.createStatement();
			try(ResultSet rs = s.executeQuery("SELECT shyeld.creation_participation(" + participation.getSuperhero() + "," +
						participation.getCombat() + "," + participation.getIssue() + ");")) {
				return rs.getInt(1);
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}
	
	public int combatDejaExistant(String date, int coordX, int coordY) {
		try {
			Statement s = this.connexionDb.createStatement();
			try(ResultSet rs = s.executeQuery("SELECT shyeld.check_si_combat('" + date + "," + coordX + "," + coordY + ");")) {
				return rs.getInt(1);
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}
	
	public int ajouterReperage(Reperage reperage) {
		try {
			Statement s = this.connexionDb.createStatement();
			try(ResultSet rs = s.executeQuery("SELECT shyeld.creation_reperage(" + reperage.getAgent() + "," + reperage.getSuperhero() +
					"," + reperage.getCoordX() + "," + reperage.getCoordY() + ",'" + reperage.getDate() + "');")) {
				return rs.getInt(1);
				
			}
		} catch(SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}
}
