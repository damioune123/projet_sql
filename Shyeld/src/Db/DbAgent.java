package Db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;


public class DbAgent extends Db{
	private static String userDb="postgres";
	private static String passwordDb="Tiffy0603";
	public DbAgent(){
		super(userDb, passwordDb);
	}
	
	
	public int ajouterCombat(Combat combat, ArrayList<Participation> participations) throws ParseException {
		int id = -1;
		try {
			connexionDb.setAutoCommit(false);
			String query = "SELECT * FROM shyeld.creation_combat(?,?,?,?,?,?,?,?);";
			System.out.println(combat.getAgent());
			try (PreparedStatement ajoutComb = this.connexionDb.prepareStatement(query);){
				ajoutComb.setDate(1, Util.formaterDate(combat.getDateCombat()));
				ajoutComb.setInt(2, combat.getCoordCombatX());
				ajoutComb.setInt(3, combat.getCoordCombatY());
				ajoutComb.setInt(4, combat.getAgent());
				ajoutComb.setInt(5, combat.getNombreParticipants());
				ajoutComb.setInt(6, combat.getNombreGagnants());
				ajoutComb.setInt(7, combat.getNombrePerdants());
				ajoutComb.setInt(8, combat.getNombreNeutres());
				try(ResultSet rs = ajoutComb.executeQuery()) {
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
				se.printStackTrace();
				id = -1;
			}
		} catch (SQLException se) {
			try {
				connexionDb.rollback();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} finally {
			try {
				connexionDb.setAutoCommit(true);
				return id;
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return id;
	}

	public int ajouterParticipation(Participation participation) {
		String query = "SELECT * FROM shyeld.creation_participation(?,?,?);";
		try (PreparedStatement ajoutPa = this.connexionDb.prepareStatement(query)) {
			ajoutPa.setInt(1, participation.getSuperhero());
			ajoutPa.setInt(2, participation.getCombat());
			ajoutPa.setString(3, String.valueOf(participation.getIssue()));
			try(ResultSet rs = ajoutPa.executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}

	public int combatDejaExistant(String date, int coordX, int coordY) throws ParseException {
		String query = "SELECT * FROM shyeld.check_si_combat(?,?,?);";
		try (PreparedStatement cDJ = this.connexionDb.prepareStatement(query);){
			cDJ.setDate(1, Util.formaterDate(date));
			cDJ.setInt(2, coordX);
			cDJ.setInt(3, coordY);
			try(ResultSet rs = cDJ.executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}

	public int ajouterReperage(Reperage reperage) throws ParseException {
		String query ="SELECT * FROM shyeld.creation_reperage(?,?,?,?,?);";
		try (PreparedStatement ajoutRep = this.connexionDb.prepareStatement(query);){
			ajoutRep.setInt(1, reperage.getAgent());
			ajoutRep.setInt(2, reperage.getSuperhero());
			ajoutRep.setInt(3, reperage.getCoordX());
			ajoutRep.setInt(4, reperage.getCoordY());
			ajoutRep.setDate(5, Util.formaterDate(reperage.getDate()));
			try(ResultSet rs = ajoutRep.executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch(SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}


	public String checkConnexion(String identifiant){
		String query = "SELECT * FROM shyeld.check_connexion(?);";
		try(PreparedStatement checkCo = this.connexionDb.prepareStatement(query);) {
			checkCo.setString(1, identifiant);
			try (ResultSet rs = checkCo.executeQuery()) {
				while(rs.next()){
					return rs.getString(1);
				}
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return null;
		}
		return null;
	}
	public int getAgent(String identifiant) throws SQLException {
		String query = "SELECT * FROM shyeld.get_agent(?);";
		try(PreparedStatement getAg = this.connexionDb.prepareStatement(query);) {
			getAg.setString(1, identifiant);
			try(ResultSet rs = getAg.executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		}
	}
	public int ajouterSuperHero(SuperHero superhero) throws ParseException {
		String query ="SELECT * FROM shyeld.creation_superhero(?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
		try(PreparedStatement ajoutSH = this.connexionDb.prepareStatement(query);) {
			ajoutSH.setString(1, superhero.getNomCivil());
			ajoutSH.setString(2, superhero.getPrenomCivil());
			ajoutSH.setString(3, superhero.getNomSuperhero());
			ajoutSH.setString(4, superhero.getAdressePrivee());
			ajoutSH.setString(5, superhero.getOrigine());
			ajoutSH.setString(6, superhero.getTypeSuperPouvoir());
			ajoutSH.setInt(7, superhero.getPuissanceSuperPouvoir());
			ajoutSH.setInt(8, superhero.getDerniereCoordonneeX());
			ajoutSH.setInt(9, superhero.getDerniereCoordonneeY());
			ajoutSH.setDate(10, Util.formaterDate(superhero.getDateDerniereApparition()));
			ajoutSH.setString(11, String.valueOf(superhero.getClan())); //A REVISER
			ajoutSH.setInt(12, superhero.getNombreVictoires());
			ajoutSH.setInt(13, superhero.getNombreDefaites());
			ajoutSH.setBoolean(14, superhero.isEstVivant());
			try(ResultSet rs = ajoutSH.executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
	}

}
