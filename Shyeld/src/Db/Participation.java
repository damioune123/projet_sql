package Db;

public class Participation {
	
	private int superhero;
	private int combat;
	private char issue;
	private int numeroLigne;
	
	public Participation(int superhero, int combat, char issue, int numeroLigne) {
		super();
		this.superhero = superhero;
		this.combat = combat;
		this.issue = issue;
		this.numeroLigne = numeroLigne;
	}
	
	

	public int getSuperhero() {
		return superhero;
	}

	public void setCombat(int combat) {
		this.combat = combat;
	}

	public int getCombat() {
		return combat;
	}

	public char getIssue() {
		return issue;
	}
	
	public int getNumeroLigne(){
		return this.numeroLigne;
	}
	
	public String insertIntoParticipation(){
		return "INSERT INTO shyeld.participations VALUES(" + this.superhero + "," + this.combat + ",'" + this.issue + "'," + this.numeroLigne + ");\n";
	}
	
}
