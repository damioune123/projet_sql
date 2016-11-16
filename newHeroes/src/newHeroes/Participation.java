package newHeroes;

public class Participation {
	
	private int superhero;
	private int combat;
	private char issue;
	
	public Participation(int superhero, int combat, char issue) {
		super();
		this.superhero = superhero;
		this.combat = combat;
		this.issue = issue;
	}

	public int getSuperhero() {
		return superhero;
	}

	public int getCombat() {
		return combat;
	}

	public char getIssue() {
		return issue;
	}
	
	public String insertIntoParticipation(){
		return "INSERT INTO shyeld.participations VALUES(" + this.superhero + "," + this.combat + ",'" + this.issue + "');\n";
	}
	
}
