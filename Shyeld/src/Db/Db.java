package Db;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;


public class Db {

	protected Connection connexionDb;
	
	public static String IPHOST_PORT ="172.24.2.6";//172.24.2.6
	public static String nomBDDN ="dbdmeur15"; //dbdmeur15
	private HashMap<String,PreparedStatement> tableStatement = new HashMap<String,PreparedStatement>();
	
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
				PreparedStatement infoSH = this.connexionDb.prepareStatement("SELECT * FROM shyeld.rechercherSuperHerosParNomSuperHero(?);",
						ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
				this.tableStatement.put("infoSH", infoSH);
				PreparedStatement suppSH =this.connexionDb.prepareStatement("SELECT * FROM shyeld.supprimerSuperHeros(?);");
				this.tableStatement.put("suppSH", suppSH);
			} catch (SQLException e) {
				System.out.println("Impossible de joindre le serveur !");
				System.exit(1);
			}
		}
	}
	
	public SuperHero informationSuperHero(String nomSuperHero){
		try {
			this.tableStatement.get("infoSH").setString(1, nomSuperHero);
			try(ResultSet rs = this.tableStatement.get("infoSH").executeQuery()) {
				if(rs.isBeforeFirst()){
					DBTablePrinter.printResultSet(rs);
					rs.beforeFirst();
				}
				while(rs.next()) {
					return new SuperHero(Integer.valueOf(rs.getString(1)),rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getString(6),
								rs.getString(7), Integer.valueOf(rs.getString(8)), Integer.valueOf(rs.getString(9)), Integer.valueOf(rs.getString(10)), Util.formaterDate(rs.getString(11)),
								rs.getString(12).charAt(0), Integer.valueOf(rs.getString(13)), Integer.valueOf(rs.getString(14)), Boolean.valueOf(rs.getString(15)));
				}
			}
		} catch (SQLException se) {
			se.printStackTrace();
			return null;
		}
		return null;
	}
	
	private boolean toBoolean(String boolString){
		System.out.println(boolString);
		return boolString.equals("(t)");
	}
	
	public int supprimerSuperHero(int idSuperHero) {
		try {
			this.tableStatement.get("suppSH").setInt(1, idSuperHero);
			try(ResultSet rs = this.tableStatement.get("suppSH").executeQuery()) {
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
