package Db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;


public class DbAgent extends Db{
	
	private PreparedStatement ajoutComb;
	private PreparedStatement ajoutPa;
	private PreparedStatement ajoutRep;
	private PreparedStatement checkCo;
	private PreparedStatement getAg;
	private PreparedStatement ajoutSH;
	
	private static String userDb="csacre15";
	private static String passwordDb="8AWU2aF";
	public DbAgent(){
		super(userDb, passwordDb);
		try {
		ajoutComb = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_combat(?,?,?,?,?,?,?,?);");
		ajoutPa = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_participation(?,?,?);");
		ajoutRep = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_reperage(?,?,?,?,?);");
		checkCo = this.connexionDb.prepareStatement("SELECT * FROM shyeld.check_connexion(?);");
		getAg = this.connexionDb.prepareStatement("SELECT * FROM shyeld.get_agent(?);");
		ajoutSH = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_superhero(?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
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
			System.out.println("La participation n'a pas pû être ajoutée");
			return -1;
		}
	}

	public int ajouterReperage(Reperage reperage) throws ParseException {
		try {
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
			System.out.println("Le repérage n'a pas pû être ajouté");
			return -1;
		}
	}


	public String checkConnexion(String identifiant){
		try {
			checkCo.setString(1, identifiant);
			try (ResultSet rs = checkCo.executeQuery()) {
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
			getAg.setString(1, identifiant);
			try(ResultSet rs = getAg.executeQuery()) {
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
			System.out.println("Erreur lors de l'ajout du superhéros");
			return -1;
		}
	}

}
