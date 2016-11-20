package newHeroes;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;

public class Generation {
	
	private ArrayList<SuperHero> superheros = new ArrayList<SuperHero>();
	public static int NOMBRE_SUPERHEROS = 20;
	public static int NOMBRE_AGENTS = 10;
	public static int NOMBRE_COMBATS = 10;
	public static int NOMBRE_REPERAGES = 15;

	public static void main(String[] args) {
		ArrayList<SuperHero> listeMarvelle = new ArrayList<SuperHero>();
		ArrayList<SuperHero> listeDC = new ArrayList<SuperHero>();
		String text = "";
		for(int i = 0; i < NOMBRE_SUPERHEROS; i++){
			SuperHero superhero = Util.createNewHero();
			if(superhero.getClan()=='M') listeMarvelle.add(superhero);
			else if(superhero.getClan()=='D') listeDC.add(superhero);
			text += superhero.insertIntoSuperHero();
		}
		
		text += "\n";
		
		for(int i = 0; i < NOMBRE_AGENTS; i++){
			Agent agent = Util.createNewAgent();
			text += agent.insertIntoAgent();
		}
		
		text += "\n";
		
		for(int i = 0; i < NOMBRE_COMBATS; i++){
			text += "BEGIN;\n";
			char clanGagnant = Util.CLAN[Util.unEntierAuHasardEntre(0, Util.CLAN.length - 1)];
			Combat combat = Util.createNewCombat(clanGagnant, listeMarvelle.size(), listeDC.size());
			ArrayList<SuperHero> dejaPrisMarvelle = new ArrayList<SuperHero>();
			ArrayList<SuperHero> dejaPrisDC = new ArrayList<SuperHero>();
			text += combat.insertIntoCombats();
			if(combat.getClan() =='M'){	
				for(int j=0 ; j < combat.getNombreGagnants() ; j++){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);	
					
					while(dejaPrisMarvelle.contains(listeMarvelle.get(indiceAuHasard))){
						indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);
					}
					dejaPrisMarvelle.add(listeMarvelle.get(indiceAuHasard));
					Participation participation = new Participation(listeMarvelle.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'G', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
					
				}
				for(int j=0 ; j < combat.getNombrePerdants() ; j++){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					while(dejaPrisDC.contains(listeDC.get(indiceAuHasard))){
						indiceAuHasard =Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					}
					dejaPrisDC.add(listeDC.get(indiceAuHasard));
					Participation participation = new Participation(listeDC.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'P', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
				}
				
				int compteur =0;
				while(compteur < combat.getNombreNeutres() && dejaPrisDC.size()< listeDC.size()){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					while(dejaPrisDC.contains(listeDC.get(indiceAuHasard))){
						indiceAuHasard =Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					}
					dejaPrisDC.add(listeDC.get(indiceAuHasard));
					Participation participation = new Participation(listeDC.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'N', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
					compteur++;
				}
				while(compteur < combat.getNombreNeutres() && dejaPrisMarvelle.size()< listeMarvelle.size()){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);	
					
					while(dejaPrisMarvelle.contains(listeMarvelle.get(indiceAuHasard))){
						indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);
					}
					dejaPrisMarvelle.add(listeMarvelle.get(indiceAuHasard));
					Participation participation = new Participation(listeMarvelle.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'N', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
					compteur++;
				}
				
			}
			if(combat.getClan() =='D'){	
				for(int j=0 ; j < combat.getNombreGagnants() ; j++){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					while(dejaPrisDC.contains(listeDC.get(indiceAuHasard))){
						indiceAuHasard =Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					}
					dejaPrisDC.add(listeDC.get(indiceAuHasard));
					Participation participation = new Participation(listeDC.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'G', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
					
					
				}
				for(int j=0 ; j < combat.getNombrePerdants() ; j++){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);	
					
					while(dejaPrisMarvelle.contains(listeMarvelle.get(indiceAuHasard))){
						indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);
					}
					dejaPrisMarvelle.add(listeMarvelle.get(indiceAuHasard));
					Participation participation = new Participation(listeMarvelle.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'P', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
					
				}
				
				int compteur =0;
				while(compteur < combat.getNombreNeutres() && dejaPrisDC.size()< listeDC.size()){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					while(dejaPrisDC.contains(listeDC.get(indiceAuHasard))){
						indiceAuHasard =Util.unEntierAuHasardEntre(0, listeDC.size()-1);
					}
					dejaPrisDC.add(listeDC.get(indiceAuHasard));
					Participation participation = new Participation(listeDC.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'N', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
					compteur++;
				}
				while(compteur < combat.getNombreNeutres() && dejaPrisMarvelle.size()< listeMarvelle.size()){
					int indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);	
					
					while(dejaPrisMarvelle.contains(listeMarvelle.get(indiceAuHasard))){
						indiceAuHasard = Util.unEntierAuHasardEntre(0, listeMarvelle.size()-1);
					}
					dejaPrisMarvelle.add(listeMarvelle.get(indiceAuHasard));
					Participation participation = new Participation(listeMarvelle.get(indiceAuHasard).getIdSuperhero(), combat.getIdCombat(), 'N', Util.PARTICIPATIONS[Util.compteurCombat - 1]);
					Util.PARTICIPATIONS[Util.compteurCombat - 1]++;
					text += participation.insertIntoParticipation();
					compteur++;
				}
				
			}
			text += "COMMIT;\n";
			text += "\n";
		}
		text += "\n";
		
		for(int i = 0; i < NOMBRE_REPERAGES; i++) {
			Reperage reperage = Util.createNewReperage();
			text += reperage.insertIntoReperage();
		}
		
		BufferedWriter writer = null;
		try {
			File logFile = new File("inserts.sql");
			System.out.println(logFile.getCanonicalPath());
			writer = new BufferedWriter(new FileWriter(logFile));
			writer.write(text);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				writer.close();
			} catch (Exception e) {
			}
		}
	}
}
