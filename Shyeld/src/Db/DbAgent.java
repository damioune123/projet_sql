package Db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;


public class DbAgent extends Db{
	private static String userDb="postgres";
	private static String passwordDb="azerty";
	public DbAgent(){
		super(userDb, passwordDb);
	}
	
	
	public int ajouterCombat(Combat combat) throws ParseException {
		String query = "SELECT * FROM shyeld.creation_combat(?,?,?,?,?,?,?,?,?);";
		try (PreparedStatement ajoutComb = this.connexionDb.prepareStatement(query);){
			ajoutComb.setDate(1, Util.formaterDate(combat.getDateCombat()));
			System.out.println(Util.formaterDate(combat.getDateCombat()));
			ajoutComb.setInt(2, combat.getCoordCombatX());
			ajoutComb.setInt(3, combat.getCoordCombatY());
			ajoutComb.setInt(4, combat.getAgent());
			ajoutComb.setInt(5, combat.getNombreParticipants());
			ajoutComb.setInt(6, combat.getNombreGagnants());
			ajoutComb.setInt(7, combat.getNombrePerdants());
			ajoutComb.setInt(8, combat.getNombreNeutres());
			ajoutComb.setString(9, String.valueOf(combat.getClan()));
			try(ResultSet rs = ajoutComb.executeQuery()) {
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


	public int checkConnexion(String identifiant, String mdp) {
		String query = "SELECT * FROM shyeld.check_connexion(?,?);";
		try(PreparedStatement checkCo = this.connexionDb.prepareStatement(query);) {
			checkCo.setString(1, identifiant);
			checkCo.setString(2, mdp);
			try (ResultSet rs = checkCo.executeQuery()) {
				while(rs.next()){
					return Integer.valueOf(rs.getString(1));
				}
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return -1;
		}
		return -1;
	}

}
