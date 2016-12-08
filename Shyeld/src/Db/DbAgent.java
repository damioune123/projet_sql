package Db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;


public class DbAgent extends Db{
	
	private HashMap<String,PreparedStatement> tableStatement;
	
	private static String userDb="postgres";
	private static String passwordDb="Tiffy0603";
	public DbAgent(){
		super(userDb, passwordDb);
		try {
		tableStatement = new HashMap<String, PreparedStatement>();
		PreparedStatement ajoutComb = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_combat(?,?,?,?,?,?,?,?);");
		tableStatement.put("ajoutComb", ajoutComb);
		PreparedStatement ajoutPa = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_participation(?,?,?);");
		tableStatement.put("ajoutPa", ajoutPa);
		PreparedStatement ajoutRep = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_reperage(?,?,?,?,?);");
		tableStatement.put("ajoutRep", ajoutRep);
		PreparedStatement checkCo = this.connexionDb.prepareStatement("SELECT * FROM shyeld.check_connexion(?);");
		tableStatement.put("checkCo", checkCo);
		PreparedStatement getAg = this.connexionDb.prepareStatement("SELECT * FROM shyeld.get_agent(?);");
		tableStatement.put("getAg", getAg);
		PreparedStatement ajoutSH = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_superhero(?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
		tableStatement.put("ajoutSH", ajoutSH);
		} catch (SQLException se){
			se.printStackTrace();
		}
	}
	
	
	public int ajouterCombat(Combat combat, ArrayList<Participation> participations) throws ParseException {
		int id = -1;
		try {
			connexionDb.setAutoCommit(false);
			System.out.println(combat.getAgent());
			try {
				tableStatement.get("ajoutComb").setDate(1, Util.formaterDate(combat.getDateCombat()));
				tableStatement.get("ajoutComb").setInt(2, combat.getCoordCombatX());
				tableStatement.get("ajoutComb").setInt(3, combat.getCoordCombatY());
				tableStatement.get("ajoutComb").setInt(4, combat.getAgent());
				tableStatement.get("ajoutComb").setInt(5, combat.getNombreParticipants());
				tableStatement.get("ajoutComb").setInt(6, combat.getNombreGagnants());
				tableStatement.get("ajoutComb").setInt(7, combat.getNombrePerdants());
				tableStatement.get("ajoutComb").setInt(8, combat.getNombreNeutres());
				try(ResultSet rs = tableStatement.get("ajoutComb").executeQuery()) {
					while(rs.next()) {
						id = Integer.valueOf(rs.getString(1));
					}
					for(Participation participation : participations){
						participation.setCombat(id);
						ajouterParticipation(participation);
					}
				}
				connexionDb.commit();
			} catch (SQLException se) {
				System.out.println("Le combat n'a pas pu être ajouté");
				id = -1;
			}
		} catch (SQLException se) {
			try {
				connexionDb.rollback();
			} catch (SQLException e) {
				System.out.println("Le retour en arrière n'a pas pû être effectué");
			}
		} finally {
			try {
				connexionDb.setAutoCommit(true);
				return id;
			} catch (SQLException e) {
				System.out.println("La fermeture de la connexion n'a pas pû être effectué");
			}
		}
		return id;
	}

	public int ajouterParticipation(Participation participation) {
		try {
			tableStatement.get("ajoutPa").setInt(1, participation.getSuperhero());
			tableStatement.get("ajoutPa").setInt(2, participation.getCombat());
			tableStatement.get("ajoutPa").setString(3, String.valueOf(participation.getIssue()));
			try(ResultSet rs = tableStatement.get("ajoutPa").executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch (SQLException se) {
			System.out.println("La participation n'a pas pû être ajoutée");
			return -1;
		}
	}

	public int ajouterReperage(Reperage reperage) throws ParseException {
		try {
			tableStatement.get("ajoutRep").setInt(1, reperage.getAgent());
			tableStatement.get("ajoutRep").setInt(2, reperage.getSuperhero());
			tableStatement.get("ajoutRep").setInt(3, reperage.getCoordX());
			tableStatement.get("ajoutRep").setInt(4, reperage.getCoordY());
			tableStatement.get("ajoutRep").setDate(5, Util.formaterDate(reperage.getDate()));
			try(ResultSet rs = tableStatement.get("ajoutRep").executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch(SQLException se) {
			System.out.println("Le repérage n'a pas pû être ajouté");
			return -1;
		}
	}


	public String checkConnexion(String identifiant){
		try {
			tableStatement.get("checkCo").setString(1, identifiant);
			try (ResultSet rs = tableStatement.get("checkCo").executeQuery()) {
				while(rs.next()){
					return rs.getString(1);
				}
			}
		} catch (SQLException se) {
			System.out.println("La connexion n'a pû être effectuée");
			return null;
		}
		return null;
	}
	public int getAgent(String identifiant) throws SQLException {
		try {
			tableStatement.get("getAg").setString(1, identifiant);
			try(ResultSet rs = tableStatement.get("getAg").executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch (SQLException se) {
			System.out.println("Erreur lors de la récupération de l'agent");
			return -1;
		}
	}
	public int ajouterSuperHero(SuperHero superhero) throws ParseException {
		try {
			tableStatement.get("ajoutSH").setString(1, superhero.getNomCivil());
			tableStatement.get("ajoutSH").setString(2, superhero.getPrenomCivil());
			tableStatement.get("ajoutSH").setString(3, superhero.getNomSuperhero());
			tableStatement.get("ajoutSH").setString(4, superhero.getAdressePrivee());
			tableStatement.get("ajoutSH").setString(5, superhero.getOrigine());
			tableStatement.get("ajoutSH").setString(6, superhero.getTypeSuperPouvoir());
			tableStatement.get("ajoutSH").setInt(7, superhero.getPuissanceSuperPouvoir());
			tableStatement.get("ajoutSH").setInt(8, superhero.getDerniereCoordonneeX());
			tableStatement.get("ajoutSH").setInt(9, superhero.getDerniereCoordonneeY());
			tableStatement.get("ajoutSH").setDate(10, Util.formaterDate(superhero.getDateDerniereApparition()));
			tableStatement.get("ajoutSH").setString(11, String.valueOf(superhero.getClan())); //A REVISER
			tableStatement.get("ajoutSH").setInt(12, superhero.getNombreVictoires());
			tableStatement.get("ajoutSH").setInt(13, superhero.getNombreDefaites());
			tableStatement.get("ajoutSH").setBoolean(14, superhero.isEstVivant());
			try(ResultSet rs = tableStatement.get("ajoutSH").executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch (SQLException se) {
			System.out.println("Erreur lors de l'ajout du superhéros");
			return -1;
		}
	}

}
