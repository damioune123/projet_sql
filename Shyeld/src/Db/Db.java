package Db;
import java.sql.Connection;
import java.util.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

public class Db {
	
	private Connection connexionDb;
	private PreparedStatement infoSH;
	private PreparedStatement ajoutSH;
	private PreparedStatement ajoutComb;
	private PreparedStatement ajoutPa;
	private PreparedStatement cDJ;
	private PreparedStatement ajoutRep;
	private PreparedStatement suppSH;
	private PreparedStatement checkCo;
	
	
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
		try {
			this.infoSH = this.connexionDb.prepareStatement("SELECT * FROM shyeld.rechercherSuperHerosParNomSuperHero(?);");
			this.ajoutSH = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_superhero(?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
			this.ajoutComb = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_combat(?,?,?,?,?,?,?,?,?);");
			this.ajoutPa = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_participation(?,?,?);");
			this.cDJ = this.connexionDb.prepareStatement("SELECT * FROM shyeld.check_si_combat(?,?,?);");
			this.ajoutRep = this.connexionDb.prepareStatement("SELECT * FROM shyeld.creation_reperage(?,?,?,?,?);");
			this.suppSH = connexionDb.prepareStatement("SELECT * FROM shyeld.supprimerSuperHeros(?);");
			this.checkCo = connexionDb.prepareStatement("SELECT * FROM shyeld.check_connexion(?,?);");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public ArrayList<SuperHero> informationSuperHero(String nomSuperHero){
		ArrayList<SuperHero> listeSuperHero = new ArrayList<SuperHero>();
		try {
			infoSH.setString(1, nomSuperHero);
			try(ResultSet rs = infoSH.executeQuery()) {
				while(rs.next()) {
					String x1 = rs.getString(1);
					System.out.println(x1);
					listeSuperHero.add(new SuperHero(Integer.valueOf(rs.getString(1)),rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6),
							rs.getString(7), Integer.valueOf(rs.getString(8)), Integer.valueOf(rs.getString(9)), Integer.valueOf(rs.getString(10)), rs.getString(11),
							rs.getString(12).charAt(0), Integer.valueOf(rs.getString(13)), Integer.valueOf(rs.getString(14)), Boolean.valueOf(rs.getString(15))));
				}
				return listeSuperHero;
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return null;
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
			ajoutSH.setDate(10, formaterDate(superhero.getDateDerniereApparition()));
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
	
	public int ajouterCombat(Combat combat) throws ParseException {
		try {
			ajoutComb.setDate(1, formaterDate(combat.getDateCombat()));
			System.out.println(formaterDate(combat.getDateCombat()));
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
			se.printStackTrace();
			return -1;
		}
	}
	
	public int combatDejaExistant(String date, int coordX, int coordY) throws ParseException {
		try {
			cDJ.setDate(1, formaterDate(date));
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
		try {
			ajoutRep.setInt(1, reperage.getAgent());
			ajoutRep.setInt(2, reperage.getSuperhero());
			ajoutRep.setInt(3, reperage.getCoordX());
			ajoutRep.setInt(4, reperage.getCoordY());
			ajoutRep.setDate(5, formaterDate(reperage.getDate()));
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
	
	public int supprimerSuperHero(int idSuperHero) {
		try {
			suppSH.setInt(1, idSuperHero);
			try(ResultSet rs = suppSH.executeQuery()) {
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
	
	private static java.sql.Date formaterDate(String dateString) throws ParseException {
		SimpleDateFormat formater = new SimpleDateFormat("dd-MM-yyyy");
		Date date = formater.parse(dateString);
		return new java.sql.Date(date.getTime());
		
	}
	
	public int checkConnexion(String identifiant, String mdp) {
		try {
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
