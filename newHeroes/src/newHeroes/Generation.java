package newHeroes;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;

public class Generation {
	
	private ArrayList<SuperHero> superheros = new ArrayList<SuperHero>();
	private static int NOMBRE_SUPERHEROS = 20;
	private static int NOMBRE_AGENTS = 10;
	private static int NOMBRE_COMBATS = 10;
	private static int NOMBRE_REPERAGES = 15;

	public static void main(String[] args) {
		
		String text = "";
		
		for(int i = 0; i < NOMBRE_SUPERHEROS; i++){
			SuperHero superhero = Util.createNewHero();
			text += superhero.insertIntoSuperHero();
		}
		
		text += "\n";
		
		for(int i = 0; i < NOMBRE_AGENTS; i++){
			Agent agent = Util.createNewAgent();
			text += agent.insertIntoAgent();
		}
		
		text += "\n";
		
		for(int i = 0; i < NOMBRE_COMBATS; i++){
			Combat combat = Util.createNewCombat();
			text += combat.insertIntoCombats();
			int alea = Util.unEntierAuHasardEntre(4, 8);
			int compteur = Util.unEntierAuHasardEntre(9, Util.compteurHero) - 8;
			for(int j = 0; j < alea; j++){
				Participation participation = Util.createNewParticipation(compteur);
				text += participation.insertIntoParticipation();
				compteur++;
			}
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
