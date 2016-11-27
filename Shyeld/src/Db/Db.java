package Db;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;


public class Db {

	protected Connection connexionDb;
	
	public static String nomBDDN ="postgres"; //a changer
	
	protected Db(String userDb, String passwordDb) {
		if(connexionDb == null) {
			try {
				Class.forName("org.postgresql.Driver");
			} catch (ClassNotFoundException e) {
				System.out.println("Driver PostgreSQL manquant !");
				System.exit(1);
			}	
			String url="jdbc:postgresql://localhost:5432/"+nomBDDN+ "?user="+userDb+"&password="+passwordDb;
			try {
				this.connexionDb=DriverManager.getConnection(url);
			} catch (SQLException e) {
				System.out.println("Impossible de joindre le server !");
				System.exit(1);
			}
		}
	}
	public ArrayList<SuperHero> informationSuperHero(String nomSuperHero){
		ArrayList<SuperHero> listeSuperHero = new ArrayList<SuperHero>();
		String query ="SELECT * FROM shyeld.rechercherSuperHerosParNomSuperHero(?);";
		try (PreparedStatement infoSH = this.connexionDb.prepareStatement(query);){
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
	
	public int supprimerSuperHero(int idSuperHero) {
		String query = "SELECT * FROM shyeld.supprimerSuperHeros(?);";
		try(PreparedStatement suppSH =this.connexionDb.prepareStatement(query);) {
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
