package Db;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Scanner;



public class Db {
	static final String USER = "postgres";
	static final String PASS = "azerty";
	private Connection connexionDb;
	
	public Db() {
		if(connexionDb == null) {
			try {
				Class.forName("org.postgresql.Driver");
			} catch (ClassNotFoundException e) {
				System.out.println("Driver PostgreSQL manquant !");
				System.exit(1);
			}	
			String url="jdbc:postgresql://localhost:5432/postgres" + "?user="+USER+"&password="+PASS; //Attention A MODIFIER
			System.out.println(url);
			try {
				this.connexionDb=DriverManager.getConnection(url);
			} catch (SQLException e) {
				System.out.println("Impossible de joindre le server !");
				System.exit(1);
			}
		}
	}
	public void inscriptionAgent(){
		System.out.println("Vous avez choisi d'inscrir un nouvel agent");
		System.out.println("Quel est le prénom de l'agent ?");
		Scanner scanner = new Scanner(System.in);
		String prenom = scanner.next();
		System.out.println("Quel est le nom de l'agent ?");
		String nom = scanner.next();
		System.out.println("Quel est l'identifiant de l'agent ?");
		String identifiant = scanner.next();
		System.out.println("Quel est le mot de passe de l'agent ?");
		String mdp_clair = scanner.next();
		System.out.println("Vous avez choisi d'inscrir un nouvel agent");
		System.out.println("Quel est le prénom de l'agent ?");
		PreparedStatement ps;
		try {
			String query = "SELECT shyeld.inscription_agent(?, ?, ?, ?);";
			ps = this.connexionDb.prepareStatement(query);
			ps.setString(1, nom);
			ps.setString(2, prenom);
			ps.setString(3, identifiant);
			ps.setString(4, mdp_clair);
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
		finally{
			/*if (ps != null) { ps.close(); }*/
		}		
	}
	public void suppressionAgent(){
		System.out.println("Vous avez choisi de supprimer un agent, voici une liste complète de ceux-ci :");
		System.out.println("Veuillez rentrer l'id de l'agent à supprimer");
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.affichageAgents;";
			s= this.connexionDb.createStatement();
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
		
		System.out.println("Rentrez l'id de l'agent :");
		Scanner scanner = new Scanner(System.in);
		int id = scanner.nextInt();
		PreparedStatement ps;
		try {
			String query = "SELECT shyeld.supprimerAgent(?);";
			ps = this.connexionDb.prepareStatement(query);
			ps.setInt(1, id);
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
		finally{
			/*
			if (ps != null) { ps.close(); }
			if (s != null) { s.close(); } */
		}
		
	}
	public void infoPerteVisibiliteSuperHero(){
		System.out.println("Vous avez choisi d'inspecter la perte de visibilité des super héros");
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.perte_visibilite;";
			s= this.connexionDb.createStatement();
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
	public void supprimerSuperHero(){
		System.out.println("Vous avez choisi de supprimer un super-héro, voici une liste complète de ceux-ci :");
		System.out.println("Veuillez rentrer l'id du super-héro à supprimer");
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.rechercherSuperHerosParNomSuperHero(''); ";
			s= this.connexionDb.createStatement();
			try(ResultSet rs= s.executeQuery(query)) {
				int nombreColonnes=rs.getMetaData().getColumnCount();
				String row1 = "";
				
				for (int i = 1; i <= nombreColonnes; i++) {
		            row1 += rs.getMetaData().getColumnName(i) + ", ";          
		        }
				System.out.println(row1);
				while(rs.next()) {
					;
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
		
		System.out.println("Rentrez l'id du super-héro:");
		Scanner scanner = new Scanner(System.in);
		int id = scanner.nextInt();
		PreparedStatement ps;
		try {
			String query = "SELECT shyeld.supprimerSuperHeros(?);";
			ps = this.connexionDb.prepareStatement(query);
			ps.setInt(1, id);
			try(ResultSet rs= ps.executeQuery()) {
				while(rs.next()) {
					System.out.println("Le super-héro à l'id : "+rs.getInt("supprimersuperheros")+ " a bien été supprimé !");
				}
				
			}
		} catch (SQLException se) {
			
			System.out.println(se.getMessage());
			se.printStackTrace();
			System.exit(1);
		}
		finally{
			/*
			if (ps != null) { ps.close(); }
			if (s != null) { s.close(); } */
		}
	}
	public void listerZonesConflits(){
		System.out.println("Vous avez choisi d'inspecter les zones à conflits");
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.zone_conflit;";
			s= this.connexionDb.createStatement();
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
	public void historiqueAgentEntreDates() throws ParseException{
		System.out.println("Vous avez de visionner l'historique d'un agent");
		System.out.println("Veuillez rentrer l'id de l'agent dont vous souhaitez voir l'historique");
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.affichageAgents;";
			s= this.connexionDb.createStatement();
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
		
		System.out.println("Rentrez l'id de l'agent :");
		Scanner scanner = new Scanner(System.in);
		int id = scanner.nextInt();
		
		System.out.println("Rentrez la date de début au dormat dd-MM-YYYY");
		String dateDebutString = scanner.next();
		System.out.println("Rentrez la date de fin au dormat dd-MM-YYYY");
		String dateFinString = scanner.next();
		SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy");
		Date dateDebut = formatter.parse(dateDebutString);
		java.sql.Date dateDebutSQL = new java.sql.Date(dateDebut.getTime());
		Date dateFin = formatter.parse(dateFinString);
		java.sql.Date dateFinSQL = new java.sql.Date(dateFin.getTime());
		
		PreparedStatement ps;
		try {
			String query = "SELECT * FROM shyeld.historiqueReperagesAgent(?, ?, ?);";
			ps = this.connexionDb.prepareStatement(query);
			ps.setInt(1, id);
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
		finally{
			/*
			if (ps != null) { ps.close(); }
			if (s != null) { s.close(); } */
		}
		
	}
	public void classementVictoires(){
		System.out.println("Vous avez choisi de voir le classement des victoires des super-héros");
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.classementVictoires;";
			s= this.connexionDb.createStatement();
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
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.classementDefaites;";
			s= this.connexionDb.createStatement();
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
		Statement s;
		try {
			String query = "SELECT * FROM shyeld.classementReperages;";
			s= this.connexionDb.createStatement();
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
