package newHeroes;

import java.util.Random;

import org.mindrot.BCrypt;

public class Util {
	
	public static Random numRandom = new Random();
	public static final String[] NOM = { "MARTIN", "BERNARD", "THOMAS", "PETIT", "ROBERT", "RICHARD", "DURAND",
			"DUBOIS", "MOREAU", "LAURENT", "SIMON", "MICHEL", "LEFEBVRE", "LEROY", "ROUX", "DAVID", "BERTRAND", "MOREL",
			"FOURNIER", "GIRARD", "BONNET", "DUPONT", "LAMBERT", "FONTAINE", "ROUSSEAU", "VINCENT", "MULLER", "LEFEVRE",
			"FAURE", "ANDRE", "MERCIER", "BLANC", "GUERIN", "BOYER", "GARNIER", "CHEVALIER", "FRANCOIS", "LEGRAND",
			"GAUTHIER", "GARCIA", "PERRIN", "ROBIN", "CLEMENT", "MORIN", "NICOLAS", "HENRY", "ROUSSEL", "MATHIEU",
			"GAUTIER", "MASSON", "MARCHAND", "DUVAL", "DENIS", "DUMONT", "MARIE", "LEMAIRE", "NOEL", "MEYER", "DUFOUR",
			"MEUNIER", "BRUN", "BLANCHARD", "GIRAUD", "JOLY", "RIVIERE", "LUCAS", "BRUNET", "GAILLARD", "BARBIER",
			"ARNAUD", "MARTINEZ", "GERARD", "ROCHE", "RENARD", "SCHMITT", "ROY", "LEROUX", "COLIN", "VIDAL", "CARON",
			"PICARD", "ROGER", "FABRE", "AUBERT", "LEMOINE", "RENAUD", "DUMAS", "LACROIX", "OLIVIER", "PHILIPPE",
			"BOURGEOIS", "PIERRE", "BENOIT", "REY", "LECLERC", "PAYET", "ROLLAND", "LECLERCQ", "GUILLAUME", "LECOMTE",
			"LOPEZ", "JEAN", "DUPUY", "GUILLOT", "HUBERT", "BERGER", "CARPENTIER", "SANCHEZ", "DUPUIS", "MOULIN",
			"LOUIS", "DESCHAMPS", "HUET", "VASSEUR", "PEREZ", "BOUCHER", "FLEURY", "ROYER", "KLEIN", "JACQUET", "ADAM",
			"PARIS", "POIRIER", "MARTY", "AUBRY", "GUYOT", "CARRE", "CHARLES", "RENAULT", "CHARPENTIER", "MENARD",
			"MAILLARD", "BARON", "BERTIN", "BAILLY", "HERVE", "SCHNEIDER", "FERNANDEZ", "LE GALL", "COLLET", "LEGER",
			"BOUVIER", "JULIEN", "PREVOST", "MILLET", "PERROT", "DANIEL", "LE ROUX", "COUSIN", "GERMAIN", "BRETON",
			"BESSON", "LANGLOIS", "REMY", "LE GOFF", "PELLETIER", "LEVEQUE", "PERRIER", "LEBLANC", "BARRE", "LEBRUN",
			"MARCHAL", "WEBER", "MALLET", "HAMON", "BOULANGER", "JACOB", "MONNIER", "MICHAUD", "RODRIGUEZ", "GUICHARD",
			"GILLET", "ETIENNE", "GRONDIN", "POULAIN", "TESSIER", "CHEVALLIER", "COLLIN", "CHAUVIN", "DA SILVA",
			"BOUCHET", "GAY", "LEMAITRE", "BENARD", "MARECHAL", "HUMBERT", "REYNAUD", "ANTOINE", "HOARAU", "PERRET",
			"BARTHELEMY", "CORDIER", "PICHON", "LEJEUNE", "GILBERT", "LAMY", "DELAUNAY", "PASQUIER", "CARLIER",
			"LAPORTE" };
	public static final String[] PRENOM = { "Adam", "Alex", "Alexandre", "Alexis", "Anthony", "Antoine", "Benjamin",
			"C�dric", "Charles", "Christopher", "David", "Dylan", "�douard", "Elliot", "�mile", "�tienne", "F�lix",
			"Gabriel", "Guillaume", "Hugo", "Isaac", "Jacob", "J�r�my", "Jonathan", "Julien", "Justin", "L�o", "Logan",
			"Lo�c", "Louis", "Lucas", "Ludovic", "Malik", "Mathieu", "Mathis", "Maxime", "Micha�l", "Nathan", "Nicolas",
			"Noah", "Olivier", "Philippe", "Rapha�l", "Samuel", "Simon", "Thomas", "Tommy", "Tristan", "Victor",
			"Vincent", "Alexia", "Alice", "Alicia", "Am�lie", "Ana�s", "Annabelle", "Arianne", "Audrey", "Aur�lie",
			"Camille", "Catherine", "Charlotte", "Chlo�", "Clara", "Coralie", "Daphn�e", "Delphine", "Elizabeth",
			"�lodie", "�milie", "Emma", "Emy", "�ve", "Florence", "Gabrielle", "Jade", "Juliette", "Justine",
			"Laurence", "Laurie", "L�a", "L�anne", "Ma�lie", "Ma�va", "Maika", "Marianne", "Marilou", "Maude", "Maya",
			"M�gan", "M�lodie", "Mia", "No�mie", "Oc�ane", "Olivia", "Rosalie", "Rose", "Sarah", "Sofia", "Victoria" };
	public static final String[] ORIGINE = { "Alien", "Parasite", "Genetique", "Radioactivit�", "Experiences",
			"Entrainement", "Potentiel cach�" };
	public static final String[] TYPE = { "Ability absorption", "Ability augmentation", "Ability replication",
			"Accelerated probability", "Acid secretion", "Acidic blood", "Activation and deactivation",
			"Adoptive muscle memory", "Age shifting", "Age transferal", "Alchemy", "Alejandro_s ability",
			"Animal control", "Appearance alteration", "Aquatic breathing", "Aura absorption", "Bliss and horror",
			"Bone spike protrusion", "Chlorine gas exudation", "Clairsentience", "Clairvoyance", "Cloaking", "Cloning",
			"Constriction", "Crumpling", "Cyberpathy", "Danger sensing", "David_s ability", "Dehydration",
			"Disintegration", "Disintegration touch", "Dream manipulation", "Elasticity", "Electric manipulation",
			"Electrical absorption", "Elemental control", "Empathic manipulation", "Empathic mimicry", "Empathy",
			"Energy absorption", "Enhanced hearing", "Enhanced memory", "Enhanced strength",
			"Enhanced strength and senses", "Enhanced synesthesia", "Fire breathing", "Fire casting", "Flight",
			"Forcefields", "Freezing", "Future terrorist_s ability", "Gold mimicry", "Granulation",
			"Gravitational manipulation", "Green energy blast", "Hachiro_s ability", "Healing", "Healing touch",
			"Heat generation", "Illusion", "Image projection", "Impenetrable skin", "Imprinting",
			"Induced radioactivity", "Intuitive aptitude", "Invisibility", "Laser emission", "Levitation",
			"Lie detection", "Luke_s ability", "Luminescence", "Lung adaptation", "Magnetism", "Mass manipulation",
			"Mediumship", "Melting", "Memory manipulation", "Memory storage", "Mental manipulation", "Metal mimicry",
			"Microwave emission", "Miko_s ability", "Mist mimicry", "Nerve gas emission", "Nerve manipulation",
			"Neurocognitive deficit", "Oil secretion", "Omnilingualism", "Persuasion", "Phasing", "Phoenix mimicry",
			"Plant growth", "Plant manipulation", "Plasmakinesis", "Poison emission", "Possession", "Precognition",
			"Precognitive dreaming", "Primal rage", "Probability computation", "Puppet master", "Pyrokinesis",
			"Rapid cell regeneration", "Sedation", "Seismic burst", "Shape shifting", "Shattering", "Sound absorption",
			"Sound manipulation", "Space-time manipulation", "Spider mimicry", "Spontaneous combustion", "Super speed",
			"Supercharging", "Technopathy", "Telekinesis", "Telepathy", "Teleportation", "Telescopic vision",
			"Temporal rewind", "Terrakinesis", "Umbrakinesis", "Wall crawling", "Water mimicry", "Weather control",
			"Belief induction", "Carbon isolation and formation", "Dimension hopping", "Dimensional storage",
			"Enhanced breath", "Enhanced teleporting", "Extraskeletal manipulation", "Fireworks creation",
			"Health optimizing", "Inflammation", "Light absorption", "Light manipulation", "Non-biological duplication",
			"Rock formation", "Shifting", "Water generation", "Acid secretion", "Age manipulation", "Astral vision",
			"Claircognizance", "Corrosion", "Deoxygenation", "Dynamic camouflage", "Earthquake causing",
			"Electric mimicry", "Electronic data manipulation", "Evolved human detection", "Gas mimicry",
			"Hair manipulation", "Induced explosion", "Intuitive empathy and empathy communication", "Memory theft",
			"Metal duplication", "Metallic sweat", "Nervous system manipulation", "Object displacement",
			"Power manipulation", "Reality distortion", "Shadow mimicry", "Silicon manipulation", "Size alteration",
			"Snake mimicry", "Summoning", "Temperature manipulation", "Transportation" };
	public static final int[] PUISSANCE = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	public static final String[] SUPERHERO = {"A-Bomb","Abe","Sapien","Abin","Sur","Abomination","Abraxas","Absorbing","Man",
			"Adam","Monroe","Adam","Strange","Bob","Zero","Air-Walker","Ajax","Alan","Scott","Alex","Mercer","Alex",
			"WoolslyAlfred","Pennyworth","Alien","Allan","QuatermainAmazo","AmmoAndo","MasahashiAngel","Angel","Angel",
			"Dust","Angel","Salvadore","AngelaAnimal","Man","Annihilus","Ant-Man","Ant-Man","II",
			"Anti-Monitor","Anti-SpawnAnti-Venom","Apocalypse","Aquababy","Aqualad","Aquaman","Arachne","Archangel","Arclight","Ares","Ariel","Armor","ArsenalAstro","BoyAtlas","AtomAtom","Girl","Atom","IAtom","II","Atom","IIIAtom","IVAurora","Azazel","Azrael","Aztar","B","Bane","Banshee","Bantam","Batgirl","Batgirl","IBatgirl","IIIBatgirl","IV","Batgirl","VBatgirl","VI","Batman","Batman","II","Battlestar","Batwoman","V","BeakBeast","Beast","Boy","BeetleBen","","Beta","Ray","Bill","Beyonder","Big","Barda","Big","Daddy","Big","Man","Bill","Harken","Billy","KincaidBinaryBionic","Woman","Bird-Brain","Bird-ManBird-Man","IIBirdmanBishop","Bizarro","Black","AbbottBlack","Adam","Black","Bolt","Black","Canary","Black","Canary","Black","Cat","Black","GoliathBlack","Knight","III","Black","Lightning","Black","Mamba","Black","Manta","Black","Panther","Black","Widow","Black","Widow","IIBlackout","Blackwing","Blackwulf","Blade","BlaquesmithBling!","Blink","BlizzardBlizzard","IBlizzard","II","Blob","Bloodaxe","Bloodhawk","BloodwraithBlue","BeetleBlue","Beetle","IBlue","Beetle","IIBlue","Beetle","III","Boba","Fett","BoltBomb","QueenBoom","Boom","BoomerBooster","Gold","BoxBox","IIIBox","IV","Brainiac","Brainiac","","Brother","VoodooBrundlefly","Buffy","Bullseye","Bumblebee","BumbleboyBushido","","C","Cable","Callisto","Cameron","Hicks","Cannonball","Captain","America","Captain","AtomCaptain","Britain","Captain","Cold","Captain","EpicCaptain","Hindsight","Captain","Mar-vellCaptain","Marvel","Captain","Marvel","Captain","Marvel","II","Captain","MidnightCaptain","Planet","Captain","UniverseCarnage","CatCat","IICatwoman","Cecilia","ReyesCentury","CerebraChamber","Chameleon","Changeling","Cheetah","ICheetah","IICheetah","IIIChromosChuck","Norris","Citizen","Steel","Claire","Bennet","CleaCloak","Clock","King","CogliostroColin","WagnerColossal","BoyColossus","Copycat","CorsairCottonmouth","Crimson","CrusaderCrimson","Dynamo","ICrystal","CurseCy-GorCyborg","Cyborg","Superman","Cyclops","Cypher","D","Dagger","Danny","CooperDaphne","Powell","Daredevil","Darkhawk","Darkman","Darkseid","DarksideDarkstar","Darth","Maul","Darth","Vader","Dash","Dazzler","Deadman","Deadpool","Deadshot","Deathlok","Deathstroke","Demogoblin","Destroyer","Diamondback","DL","Hawkins","Doc","Samson","Doctor","Doom","Doctor","Doom","IIDoctor","Fate","Doctor","Octopus","Doctor","Strange","Domino","Donatello","Donna","TroyDoomsday","Doppelganger","Dormammu","Dr","Manhattan","Drax","the","Destroyer","","E","Ego","Elastigirl","Electro","Elektra","Elle","Bishop","Elongated","Man","Emma","Frost","Enchantress","EnergyERG-Ethan","Hunt","Etrigan","Evil","Deadpool","Evilhawk","Exodus","","F","Fabian","CortezFalcon","Fallen","One","II","Faora","Feral","Fighting","SpiritFin","Fang","Foom","Firebird","Firelord","Firestar","Firestorm","Firestorm","FixerFlash","GordonFlash","I","Flash","II","Flash","III","Flash","IV","Forge","Franklin","RichardsFranklin","Storm","Frenzy","Frigga","G","Galactus","Gambit","Gamora","Garbage","ManGary","Bell","General","Zod","GenesisGhost","Rider","Ghost","Rider","IIGiant-ManGiant-Man","IIGiganta","Gladiator","Goblin","Queen","Godzilla","Gog","Goku","GoliathGoliath","IIGoliath","IIIGoliath","IVGorilla","Grodd","Granny","GoodnessGravity","Greedo","Green","Arrow","Green","Goblin","Green","Goblin","II","Green","Goblin","IIIGreen","Goblin","IVGroot","GuardianGuy","Gardner","","H","Hal","Jordan","Han","Solo","Hancock","Harley","Quinn","Havok","Hawk","Hawkeye","Hawkeye","II","Hawkgirl","HawkmanHawkwoman","IHawkwoman","IIHawkwoman","IIIHeat","Wave","Hellboy","Hellcat","HellstormHercules","Hiro","NakamuraHit-Girl","HobgoblinHollowHope","Summers","Howard","the","DuckHulk","Human","Torch","Huntress","Husk","Hybrid","Hydro-Man","Hyperion","","I","Iceman","Impulse","Indiana","Jones","Indigo","Ink","Invisible","Woman","Iron","Fist","Iron","Man","Iron","Monger","Isis","","J","Jack","BauerJack","of","Hearts","Jack-Jack","James","Bond","James","T.","Kirk","Jar","Jar","Binks","Jason","Bourne","Jean","Grey","Jean-Luc","Picard","Jennifer","Kale","Jesse","QuickJessica","Cruz","Jessica","Jones","Jessica","SandersJigsawJim","Powell","JJ","Powell","Johann","KraussJohn","Constantine","John","Stewart","John","Wraith","Joker","Jolt","Jubilee","Judge","Dredd","Juggernaut","Junkpile","Justice","Jyn","Erso","K","K-SOKang","Kathryn","Janeway","Katniss","Everdeen","Kevin","","Kick-Ass","Kid","Flash","Kid","Flash","IIKiller","Croc","Killer","Frost","Kilowog","King","Kong","King","Shark","Kingpin","Klaw","Kool-Aid","Man","Kraven","II","Kraven","the","Hunter","Krypto","Kylo","Ren","","L","Lady","BullseyeLady","DeathstrikeLeader","Leech","Legion","Leonardo","Lex","Luthor","Light","Lass","Lightning","Lad","Lightning","Lord","Living","Brain","Liz","ShermanLizard","Lobo","Loki","Longshot","Luke","Cage","Luke","CampbellLuke","Skywalker","Luna","Lyja","M","Mach-IV","Machine","Man","Magneto","Magog","Magus","Man-Bat","Man-Thing","Man-Wolf","Mandarin","Martian","Manhunter","Marvel","Girl","Master","BroodMaster","Chief","Match","Matt","Parkman","Maverick","Maxima","Maya","Herrera","Medusa","Meltdown","Mephisto","Mera","Metallo","MetamorphoMeteoriteMetron","Micah","Sanders","Michelangelo","Micro","Lad","Mimic","Minna","MurrayMisfit","Miss","Martian","Mister","Fantastic","Mister","Freeze","Mister","Knife","Mister","Mxyzptlk","Mister","Sinister","Mister","Zsasz","Mockingbird","MogoMohinder","SureshMolochMolten","Man","MonarchMonica","Dawson","Moon","Knight","Moonstone","Morlun","MorphMoses","Magnum","Mr","Incredible","Ms","Marvel","II","Multiple","Man","Mysterio","Mystique","","N","NamorNamor","Namora","Namorita","Naruto","Uzumaki","Nathan","PetrelliNegasonic","Teenage","Warhead","Nick","Fury","Nightcrawler","Nightwing","Niki","Sanders","Nina","Theroux","Nite","Owl","IINorthstar","Nova","Nova","","O","Offspring","Omega","RedOmniscientOne","Punch","Man","Onslaught","Oracle","Osiris","Overtkill","P","Paul","Blart","PenancePenance","IPenance","IIPenguin","Peter","Petrelli","PhantomPhantom","Girl","Phoenix","Plantman","Plastic","LadPlastic","Man","Plastique","Poison","Ivy","Polaris","Power","Girl","Power","ManPredator","Professor","X","Professor","Zoom","Proto-Goblin","Psylocke","Punisher","Purple","Man","Pyro","","Q","QuantumQuestion","Quicksilver","Quill","","R","Ra's","Al","Ghul","Rachel","Pirzad","Rambo","Raphael","Raven","Razor-Fist","IIRed","Arrow","Red","Hood","Red","Hulk","Red","Mist","Red","Robin","Red","Skull","Red","Tornado","Redeemer","IIRedeemer","IIIRenata","SolizRey","Rhino","Rick","Flag","Riddler","Rip","Hunter","RipcordRobin","I","Robin","IIRobin","III","Robin","V","Robin","VI","Rocket","Raccoon","Rogue","Ronin","Rorschach","","S","Sabretooth","Sage","Sandman","Sasquatch","Savage","Dragon","Scarecrow","Scarlet","Spider","Scarlet","Spider","II","Scarlet","Witch","Scorpia","Scorpion","Sebastian","Shaw","Sentry","Shadow","King","Shadowcat","Shang-Chi","Shatterstar","She-Hulk","She-ThingShocker","Shriek","Shrinking","VioletSif","Silk","Silk","Spectre","ISilk","Spectre","IISilver","Surfer","Silverclaw","Simon","Baz","Sinestro","Siren","Siren","IISiryn","Skaar","Snake-EyesSnowbird","Sobek","Solomon","Grundy","Songbird","Space","Ghost","Spawn","Spectre","SpeedballSpeedySpeedy","Spider-CarnageSpider-Girl","Spider-Gwen","Spider-Man","Spider-ManSpider-ManSpider-Woman","Spider-Woman","IISpider-Woman","III","Spider-Woman","IVSpock","Spyke","Stacy","XStar-Lord","Stardust","Starfire","Stargirl","Static","Steel","Stephanie","Powell","Steppenwolf","Storm","Stormtrooper","Sunspot","Superboy","Superboy-Prime","Supergirl","Superman","Swamp","Thing","Swarm","Sylar","Synch","","T","T-","T-","T-","T-X","Tempest","Thanos","The","Cape","The","Comedian","Thing","Thor","Thor","Girl","Thunderbird","Thunderbird","IIThunderbird","IIIThunderstrike","Thundra","Tiger","Shark","Tigra","Tinkerer","TitanToad","Toxin","Toxin","Tracy","StraussTricksterTrigonTriplicate","Girl","Triton","Two-Face","","U","Ultragirl","Ultron","Utgard-Loki","","V","VagabondValerie","HartValkyrieVanisher","Venom","Venom","II","Venom","III","Venompool","Vertigo","IIVibe","Vindicator","VindicatorViolatorViolet","Parr","Vision","Vision","IIVixen","VulcanVulture","","W","Walrus","War","Machine","WarbirdWarlock","Warp","Warpath","Wasp","Watcher","Weapon","XIWhite","Canary","White","QueenWildfire","Winter","Soldier","Wiz","KidWolfsbane","Wolverine","Wonder","Girl","Wonder","Man","Wonder","Woman","WondraWyatt","Wingfoot","","X","X-","X-Man","","Y","Yellow","ClawYellowjacket","Yellowjacket","II","Ymir","Yoda","","Z","Zatanna"};
	public static final char[] CLAN = {'M','D'};
	public static final char[] ISSUE = {'G', 'P', 'N'};
	public static int compteurHero = 0;
	public static int compteurAgent = 0;
	public static int compteurCombat = 0;
	public static int compteurReperage = 0;
	public static int COORD_MAX = 100;
	public static int NOMBRE_HEROS = 20;
	public static int NOMBRE_RAPPORTS = 25;
	public static String MOT_DE_PASSE = encryptionBcrypt("azerty");
	public static int[] PARTICIPATIONS = new int[Generation.NOMBRE_COMBATS];
	
	public static SuperHero createNewHero(){
		String date = date();
		SuperHero superhero = new SuperHero(compteurHero+1, NOM[unEntierAuHasardEntre(0, NOM.length - 1)],
				PRENOM[unEntierAuHasardEntre(0, PRENOM.length - 1)], SUPERHERO[compteurHero],
				"Pour le moment pas d idees 35 1000 Bruxelles",ORIGINE[unEntierAuHasardEntre(0, ORIGINE.length - 1)],
				TYPE[unEntierAuHasardEntre(0, TYPE.length - 1)], PUISSANCE[unEntierAuHasardEntre(0, PUISSANCE.length - 1)],
				unEntierAuHasardEntre(0, COORD_MAX), unEntierAuHasardEntre(0, COORD_MAX), date, CLAN[unEntierAuHasardEntre(0, CLAN.length - 1)],
				unEntierAuHasardEntre(0, 0), unEntierAuHasardEntre(0, 0), true);
		compteurHero++;
		return superhero;
	}
	
	public static Agent createNewAgent(){
		String date = date();
		Agent agent = new Agent(compteurAgent+1, PRENOM[unEntierAuHasardEntre(0, PRENOM.length - 1)],
				NOM[unEntierAuHasardEntre(0, NOM.length - 1)], date, MOT_DE_PASSE, unEntierAuHasardEntre(0, NOMBRE_RAPPORTS) ,true);
		compteurAgent++;
		return agent;
	}
	public static String encryptionBcrypt(String mdpClair){
		String hashed = BCrypt.hashpw(mdpClair, BCrypt.gensalt());
		return hashed;
	}
	
	public static Combat createNewCombat(char clanGagnant, int nombreHerosMarvelle, int nombreHerosDc){
		String date = date();
		int nombre_gagnants=0;
		int nombre_participants = 0;
		int nombre_perdants = 0; 
		if(clanGagnant == 'M') {
			nombre_gagnants = unEntierAuHasardEntre(1, nombreHerosMarvelle-1);
			nombre_perdants =unEntierAuHasardEntre(1, nombreHerosDc-1);
			
		}
		if(clanGagnant == 'D'){
			nombre_gagnants = unEntierAuHasardEntre(1, nombreHerosDc-1);
			nombre_perdants =unEntierAuHasardEntre(1, nombreHerosMarvelle-1);
		}
		nombre_participants = unEntierAuHasardEntre((nombre_gagnants +nombre_perdants), NOMBRE_HEROS);
		int nombre_neutres = nombre_participants - nombre_gagnants - nombre_perdants;
		Combat combat = new Combat(compteurCombat+1, date, unEntierAuHasardEntre(0, COORD_MAX), unEntierAuHasardEntre(0, COORD_MAX),
				unEntierAuHasardEntre(1, compteurAgent), nombre_participants,
				nombre_gagnants, nombre_perdants,
				nombre_neutres, clanGagnant);
		compteurCombat++;
		return combat;
	}
	
	public static Participation createNewParticipation(int compteur) {
		Participation participation = new Participation(compteur,
				compteurCombat, ISSUE[unEntierAuHasardEntre(0, ISSUE.length - 1)], PARTICIPATIONS[compteurCombat - 1]);
		PARTICIPATIONS[compteurCombat - 1]++;
		return participation;
	}
	
	public static Reperage createNewReperage() {
		String date = date();
		Reperage reperage = new Reperage(compteurReperage, unEntierAuHasardEntre(1, compteurAgent),
				unEntierAuHasardEntre(1, compteurHero),
				unEntierAuHasardEntre(0, COORD_MAX), unEntierAuHasardEntre(0, COORD_MAX), date);
		compteurReperage++;
		return reperage;
	}
	
	public static String date(){
		return "" +	unEntierAuHasardEntre(2000, 2015)  + "/" + unEntierAuHasardEntre(1, 12) + "/" +
				unEntierAuHasardEntre(1, 28);
	}
	
	public static int unEntierAuHasardEntre (int valeurMinimale, int valeurMaximale){
		double nombreReel;
		int resultat;

		nombreReel = Math.random();
		resultat = (int) (nombreReel * (valeurMaximale - valeurMinimale + 1)) + valeurMinimale;
		return resultat;
	}
}
