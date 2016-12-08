package Db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;

public class DbShyeld extends Db{
	private static String userDb="dmeur15";
	private static String passwordDb="XcU46ay";
	private PreparedStatement ia;
	private PreparedStatement aa;
	private PreparedStatement sa;
	private PreparedStatement pv;
	private PreparedStatement zc;
	private PreparedStatement hr;
	private PreparedStatement cv;
	private PreparedStatement cd;
	private PreparedStatement cr;
	public DbShyeld(){
		super(userDb, passwordDb);
		try{
			ia = this.connexionDb.prepareStatement("SELECT shyeld.inscription_agent(?, ?, ?, ?);");
			aa = this.connexionDb.prepareStatement("SELECT * FROM shyeld.affichageAgents;",ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
			sa= this.connexionDb.prepareStatement("SELECT shyeld.supprimerAgent(?);");
			pv = this.connexionDb.prepareStatement("SELECT * FROM shyeld.perte_visibilite;");
			zc = this.connexionDb.prepareStatement("SELECT DISTINCT * FROM shyeld.zone_conflit();");
			hr =this.connexionDb.prepareStatement("SELECT * FROM shyeld.historiqueReperagesAgent(?, ?, ?);");
			cv= this.connexionDb.prepareStatement("SELECT * FROM shyeld.classementVictoires;");
			cd = this.connexionDb.prepareStatement("SELECT * FROM shyeld.classementDefaites;");
			cr = this.connexionDb.prepareStatement( "SELECT * FROM shyeld.classementReperages;");
		} catch (SQLException se){
			se.printStackTrace();
		}
	}
	public void inscriptionAgent(String nom, String prenom, String identifiant, String mdp){
		try  {
			ia.setString(1, nom);
			ia.setString(2, prenom);
			ia.setString(3, identifiant);
			ia.setString(4, mdp);
			try(ResultSet rs = ia.executeQuery()) {
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
			try(ResultSet rs= aa.executeQuery()) {
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
			sa.setInt(1, id_agent);
			try(ResultSet rs= sa.executeQuery()) {
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
			try(ResultSet rs= pv.executeQuery()) {
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
			try(ResultSet rs= zc.executeQuery()) {
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
			hr.setInt(1, id_agent);
			hr.setDate(2, dateDebutSQL);
			hr.setDate(3, dateFinSQL);
			try(ResultSet rs= hr.executeQuery()) {
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
			try(ResultSet rs= cv.executeQuery()) {
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
			try(ResultSet rs= cd.executeQuery()) {
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
			try(ResultSet rs= cr.executeQuery()) {
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
