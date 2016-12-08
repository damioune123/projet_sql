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
	
	public static String IPHOST_PORT ="localhost:5433";//a changer
	public static String nomBDDN ="shyeld"; //a changer
	
	protected Db(String userDb, String passwordDb) {
		if(connexionDb == null) {
			try {
				Class.forName("org.postgresql.Driver");
			} catch (ClassNotFoundException e) {
				System.out.println("Driver PostgreSQL manquant !");
				System.exit(1);
			}	
			String url="jdbc:postgresql://"+IPHOST_PORT+"/"+nomBDDN+ "?user="+userDb+"&password="+passwordDb;
			try {
				this.connexionDb=DriverManager.getConnection(url);
			} catch (SQLException e) {
				System.out.println("Impossible de joindre le server !");
				System.exit(1);
			}
		}
	}
	public SuperHero informationSuperHero(String nomSuperHero){
		ArrayList<SuperHero> listeSuperHero = new ArrayList<SuperHero>();
		String query ="SELECT * FROM shyeld.rechercherSuperHerosParNomSuperHero(?);";
		try (PreparedStatement infoSH = this.connexionDb.prepareStatement(query, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);){
			infoSH.setString(1, nomSuperHero);
			try(ResultSet rs = infoSH.executeQuery()) {
				if(rs.isBeforeFirst()){
					DBTablePrinter.printResultSet(rs);
					rs.beforeFirst();
				}
				while(rs.next()) {
					return new SuperHero(Integer.valueOf(rs.getString(1)),rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6),
								rs.getString(7), Integer.valueOf(rs.getString(8)), Integer.valueOf(rs.getString(9)), Integer.valueOf(rs.getString(10)), rs.getString(11),
								rs.getString(12).charAt(0), Integer.valueOf(rs.getString(13)), Integer.valueOf(rs.getString(14)), Boolean.valueOf(rs.getString(15)));
				}
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return null;
		}
		return null;
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
}
