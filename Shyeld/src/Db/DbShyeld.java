package Db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.HashMap;

public class DbShyeld extends Db{
	private static String userDb="dmeur15";
	private static String passwordDb="XcU46ay";
	private HashMap<String,PreparedStatement> tableStatement;
	public DbShyeld(){
		super(userDb, passwordDb);
		try{
			tableStatement = new HashMap<String,PreparedStatement>();
			PreparedStatement ia = this.connexionDb.prepareStatement("SELECT shyeld.inscription_agent(?, ?, ?, ?);");
			tableStatement.put("ia", ia);
			PreparedStatement aa = this.connexionDb.prepareStatement("SELECT * FROM shyeld.affichageAgents;",ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
			tableStatement.put("aa", aa);
			PreparedStatement sa= this.connexionDb.prepareStatement("SELECT shyeld.supprimerAgent(?);");
			tableStatement.put("sa", sa);
			PreparedStatement pv = this.connexionDb.prepareStatement("SELECT * FROM shyeld.perte_visibilite;");
			tableStatement.put("pv", pv);
			PreparedStatement zc = this.connexionDb.prepareStatement("SELECT DISTINCT * FROM shyeld.zone_conflit();");
			tableStatement.put("zc", zc);
			PreparedStatement hr =this.connexionDb.prepareStatement("SELECT * FROM shyeld.historiqueReperagesAgent(?, ?, ?);");
			tableStatement.put("hr", hr);
			PreparedStatement cv= this.connexionDb.prepareStatement("SELECT * FROM shyeld.classementVictoires;");
			tableStatement.put("cv", cv);
			PreparedStatement cd = this.connexionDb.prepareStatement("SELECT * FROM shyeld.classementDefaites;");
			tableStatement.put("cd", cd);
			PreparedStatement cr = this.connexionDb.prepareStatement( "SELECT * FROM shyeld.classementReperages;");
			tableStatement.put("cr", cr);
		} catch (SQLException se){
			se.printStackTrace();
		}
	}
	public void inscriptionAgent(String nom, String prenom, String identifiant, String mdp){
		try  {
			tableStatement.get("ia").setString(1, nom);
			tableStatement.get("ia").setString(2, prenom);
			tableStatement.get("ia").setString(3, identifiant);
			tableStatement.get("ia").setString(4, mdp);
			try(ResultSet rs = tableStatement.get("ia").executeQuery()) {
				while(rs.next()) {
					System.out.println("L'agent a bien été ajouté (id dans la bddn :"+rs.getInt("inscription_agent")+")");
				}

			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}
		
			
	}
	public void affichageAllAgents(){
		try {
			try(ResultSet rs= tableStatement.get("aa").executeQuery()) {
				if(rs.isBeforeFirst()){
					DBTablePrinter.printResultSet(rs);
					rs.beforeFirst();
				}
				while(rs.next()) {
					System.out.println("id agent :"+rs.getString("id_agent")+"  nom agent :"+rs.getString("nom")+"  prenom agent "
							+rs.getString("prenom")+"  identifiant :"+rs.getString("identifiant") );
				}	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}
	}

	public void suppressionAgent(int id_agent){		
		try {
			tableStatement.get("sa").setInt(1, id_agent);
			try(ResultSet rs= tableStatement.get("sa").executeQuery()) {
				while(rs.next()) {
					System.out.println("L'agent à l'id : "+rs.getInt("supprimeragent")+ " a bien été supprimé !");
				}

			}

		} catch (SQLException se) {

			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void infoPerteVisibiliteSuperHero(){
		System.out.println("Vous avez choisi d'inspecter la perte de visibilité des super héros");
		try {
			try(ResultSet rs= tableStatement.get("pv").executeQuery()) {
				DBTablePrinter.printResultSet(rs);
				/*int nombreColonnes=rs.getMetaData().getColumnCount();
				String row1 = "";
				for (int i = 1; i <= nombreColonnes; i++) {
					row1 += rs.getMetaData().getColumnName(i) + ", ";          
				}
				System.out.println(row1);
				while(rs.next()) {
					String row2="";
					for (int i = 1; i <= nombreColonnes; i++) {
						row2 += rs.getString(i) + ", ";          
					}
					System.out.println(row2);
				}*/	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void listerZonesConflits(){
		System.out.println("Vous avez choisi d'inspecter les zones à conflits");
		try {
			try(ResultSet rs= tableStatement.get("zc").executeQuery()) {
				DBTablePrinter.printResultSet(rs);
				/*int nombreColonnes=rs.getMetaData().getColumnCount();
				String row1 = "";
				for (int i = 1; i <= nombreColonnes; i++) {
					row1 += rs.getMetaData().getColumnName(i) + ", ";          
				}
				System.out.println(row1);
				while(rs.next()) {
					String row2="";
					for (int i = 1; i <= nombreColonnes; i++) {
						row2 += rs.getString(i) + ", ";          
					}
					System.out.println(row2);
				}*/	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void historiqueAgentEntreDates(int id_agent, java.sql.Date dateDebutSQL, java.sql.Date dateFinSQL) throws ParseException{
		try {
			tableStatement.get("hr").setInt(1, id_agent);
			tableStatement.get("hr").setDate(2, dateDebutSQL);
			tableStatement.get("hr").setDate(3, dateFinSQL);
			try(ResultSet rs= tableStatement.get("hr").executeQuery()) {
				DBTablePrinter.printResultSet(rs);
				/*int nombreColonnes=rs.getMetaData().getColumnCount();
				String row1 = "";
				for (int i = 1; i <= nombreColonnes; i++) {
					row1 += rs.getMetaData().getColumnName(i) + ", ";          
				}
				System.out.println(row1);
				while(rs.next()) {
					String row2="";
					for (int i = 1; i <= nombreColonnes; i++) {
						row2 += rs.getString(i) + ", ";          
					}
					System.out.println(row2);		
				}*/

			}
		} catch (SQLException se) {

			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}
	}
	public void classementVictoires(){
		System.out.println("Vous avez choisi de voir le classement des victoires des super-héros");
		
		try {
			try(ResultSet rs= tableStatement.get("cv").executeQuery()) {
				DBTablePrinter.printResultSet(rs);
				/*int nombreColonnes=rs.getMetaData().getColumnCount();
				String row1 = "";
				for (int i = 1; i <= nombreColonnes; i++) {
					row1 += rs.getMetaData().getColumnName(i) + ", ";          
				}
				System.out.println(row1);
				while(rs.next()) {
					String row2="";
					for (int i = 1; i <= nombreColonnes; i++) {
						row2 += rs.getString(i) + ", ";          
					}
					System.out.println(row2);
				}*/	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void classementDefaites(){
		System.out.println("Vous avez choisi de voir le classement des victoires des super-héros");
	
		try {
			try(ResultSet rs= tableStatement.get("cd").executeQuery()) {
				DBTablePrinter.printResultSet(rs);
				/*int nombreColonnes=rs.getMetaData().getColumnCount();
				String row1 = "";
				for (int i = 1; i <= nombreColonnes; i++) {
					row1 += rs.getMetaData().getColumnName(i) + ", ";          
				}
				System.out.println(row1);
				while(rs.next()) {
					String row2="";
					for (int i = 1; i <= nombreColonnes; i++) {
						row2 += rs.getString(i) + ", ";          
					}
					System.out.println(row2);
				}*/	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void classementReperages(){
		System.out.println("Vous avez choisi de voir le classement des repérages des agents");
		try {
			try(ResultSet rs= tableStatement.get("cr").executeQuery()) {
				DBTablePrinter.printResultSet(rs);
				/*int nombreColonnes=rs.getMetaData().getColumnCount();
				String row1 = "";
				for (int i = 1; i <= nombreColonnes; i++) {
					row1 += rs.getMetaData().getColumnName(i) + ", ";          
				}
				System.out.println(row1);
				while(rs.next()) {
					String row2="";
					for (int i = 1; i <= nombreColonnes; i++) {
						row2 += rs.getString(i) + ", ";          
					}
					System.out.println(row2);
				}*/	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
}
