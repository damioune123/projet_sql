package Db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;

public class DbShyeld extends Db{
	private static String userDb="postgres";
	private static String passwordDb="azerty";
	public DbShyeld(){
		super(userDb, passwordDb);
	}
	public void inscriptionAgent(String nom, String prenom, String identifiant, String mdp){
		String query = "SELECT shyeld.inscription_agent(?, ?, ?, ?);";
		try (PreparedStatement ps = this.connexionDb.prepareStatement(query);) {
			ps.setString(1, nom);
			ps.setString(2, prenom);
			ps.setString(3, identifiant);
			ps.setString(4, mdp);
			try(ResultSet rs = ps.executeQuery()) {
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
		String query = "SELECT * FROM shyeld.affichageAgents;";
		try (Statement s = this.connexionDb.createStatement()){
			try(ResultSet rs= s.executeQuery(query)) {
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
		String query = "SELECT shyeld.supprimerAgent(?);";
		try (PreparedStatement ps= this.connexionDb.prepareStatement(query);){
			ps.setInt(1, id_agent);
			try(ResultSet rs= ps.executeQuery()) {
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
		try (Statement s = this.connexionDb.createStatement();){
			String query = "SELECT * FROM shyeld.perte_visibilite;";
			
			try(ResultSet rs= s.executeQuery(query)) {
				int nombreColonnes=rs.getMetaData().getColumnCount();
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
				}	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void listerZonesConflits(){
		System.out.println("Vous avez choisi d'inspecter les zones à conflits");
		String query = "SELECT * FROM shyeld.zone_conflit;";
		try (Statement s = this.connexionDb.createStatement();){
			try(ResultSet rs= s.executeQuery(query)) {
				int nombreColonnes=rs.getMetaData().getColumnCount();
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
				}	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void historiqueAgentEntreDates(int id_agent, java.sql.Date dateDebutSQL, java.sql.Date dateFinSQL) throws ParseException{
		

		String query = "SELECT * FROM shyeld.historiqueReperagesAgent(?, ?, ?);";
		try(PreparedStatement ps =this.connexionDb.prepareStatement(query);) {
			ps.setInt(1, id_agent);
			ps.setDate(2, dateDebutSQL);
			ps.setDate(3, dateFinSQL);
			try(ResultSet rs= ps.executeQuery()) {
				int nombreColonnes=rs.getMetaData().getColumnCount();
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
				}

			}
		} catch (SQLException se) {

			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}
	}
	public void classementVictoires(){
		System.out.println("Vous avez choisi de voir le classement des victoires des super-héros");
		
		try(Statement s = this.connexionDb.createStatement();) {
			String query = "SELECT * FROM shyeld.classementVictoires;";
			try(ResultSet rs= s.executeQuery(query)) {
				int nombreColonnes=rs.getMetaData().getColumnCount();
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
				}	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void classementDefaites(){
		System.out.println("Vous avez choisi de voir le classement des victoires des super-héros");
	
		try(Statement s = this.connexionDb.createStatement();) {
			String query = "SELECT * FROM shyeld.classementDefaites;";
			try(ResultSet rs= s.executeQuery(query)) {
				int nombreColonnes=rs.getMetaData().getColumnCount();
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
				}	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
	public void classementReperages(){
		System.out.println("Vous avez choisi de voir le classement des repérages des agents");
		
		try(Statement s = this.connexionDb.createStatement();)  {
			String query = "SELECT * FROM shyeld.classementReperages;";
			try(ResultSet rs= s.executeQuery(query)) {
				int nombreColonnes=rs.getMetaData().getColumnCount();
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
				}	
			}
		} catch (SQLException se) {
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}

	}
}
