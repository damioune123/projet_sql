DROP SCHEMA IF EXISTS shyeld CASCADE;


CREATE SCHEMA shyeld;

CREATE TYPE shyeld.type_clan AS ENUM('M','D');
CREATE TYPE shyeld.type_issue AS ENUM('G','P','N');
CREATE TYPE shyeld.row_visibilite AS (nom_superhero varchar(255), date_derniere_apparition timestamp, derniere_coordonneeX integer, derniere_coordonneeY integer);
CREATE TYPE shyeld.row_zone AS (coord_x integer,coord_y integer);
CREATE TYPE shyeld.listeReperagesAgent AS (id_superhero INTEGER, nom_superhero varchar(255), coord_x  INTEGER, coord_y  INTEGER, date timestamp);
CREATE TYPE shyeld.resumeCombatPourHero AS (nom_superhero varchar(255), nombreVictoiresDefaites integer);
CREATE TYPE shyeld.resumeReperagePourAgent AS (nom varchar(255), prenom varchar(255), nombreReperages integer);
CREATE TYPE shyeld.listeCombatsParticipations AS (id_combat INTEGER, date_combat TIMESTAMP, coord_combatX INTEGER, coord_combatY INTEGER, nombre_participants INTEGER, 
							nombre_gagnants INTEGER, nombre_neutres INTEGER , clan_vainqueur shyeld.type_clan, id_superhero INTEGER, nom_superhero varchar(255), issue
							shyeld.type_issue);

/************************************ CREATE TABLE ********************************************/

CREATE TABLE shyeld.superheros(
	id_superhero serial PRIMARY KEY,
	nom_civil varchar(255) CHECK (nom_civil != ''),
	prenom_civil varchar(255) CHECK	(prenom_civil != ''),
	nom_superhero varchar(255) NOT NULL CHECK (nom_superhero != ''),
	adresse_privee varchar(255) CHECK (adresse_privee != ''),
	origine varchar(255) CHECK (origine != ''),
	type_super_pouvoir varchar(255) NOT NULL CHECK (type_super_pouvoir != ''),
	puissance_super_pouvoir integer NOT NULL CHECK (puissance_super_pouvoir >= 1 AND puissance_super_pouvoir <= 10),
	derniere_coordonneeX integer CHECK (derniere_coordonneeX >= 0 AND derniere_coordonneeX <= 100),
	derniere_coordonneeY integer CHECK (derniere_coordonneeY >= 0 AND derniere_coordonneeY <= 100),
	date_derniere_apparition timestamp NOT NULL CHECK (date_derniere_apparition <= now()),
	clan shyeld.type_clan NOT NULL,
	nombre_victoires integer NOT NULL CHECK (nombre_victoires >= 0),
	nombre_defaites integer NOT NULL CHECK (nombre_defaites >= 0),
	est_vivant boolean NOT NULL
);

CREATE TABLE shyeld.agents(
	id_agent serial primary key,
	prenom varchar(255) NOT NULL CHECK(prenom <>''),
	nom varchar(255) NOT NULL CHECK (nom<> ''),
	date_mise_en_service TIMESTAMP NOT NULL CHECK(date_mise_en_service <= now()),
	identifiant varchar(255) NOT NULL CHECK (nom<> ''),
	mdp_sha256 varchar(512) NOT NULL CHECK (mdp_sha256<> ''),
	nbre_rapport INTEGER NOT NULL CHECK (nbre_rapport >=0) DEFAULT 0,
	est_actif boolean NOT NULL
);

CREATE TABLE shyeld.combats(
	id_combat serial PRIMARY KEY,
	date_combat timestamp NOT NULL CHECK (date_combat <= now()),
	coord_combatX integer NOT NULL CHECK (coord_combatX >= 0 AND coord_combatX <= 100),
	coord_combatY integer NOT NULL CHECK (coord_combatY >= 0 AND coord_combatY <= 100),
	agent integer NOT NULL REFERENCES shyeld.agents(id_agent),
	nombre_participants integer NOT NULL CHECK (nombre_participants >= 0),
	nombre_gagnants integer NOT NULL CHECK (nombre_gagnants >= 0),
	nombre_perdants integer NOT NULL CHECK (nombre_perdants >= 0),
	nombre_neutres integer NOT NULL CHECK (nombre_neutres >= 0),
	clan_vainqueur shyeld.type_clan NOT NULL
);

CREATE TABLE shyeld.participations(
	superhero integer NOT NULL REFERENCES shyeld.superheros(id_superhero),
	combat integer NOT NULL REFERENCES shyeld.combats(id_combat),
	issue shyeld.type_issue NOT NULL DEFAULT 'N',
	PRIMARY KEY (superhero,combat) 
);

CREATE TABLE shyeld.reperages(
	id_reperage serial primary key,
	agent integer NOT NULL references shyeld.agents(id_agent),
	superhero integer NOT NULL references shyeld.superheros(id_superhero),
	coord_x integer NOT NULL CHECK (coord_x>=0 AND coord_x<=100),
	coord_y integer NOT NULL CHECK (coord_y >=0 AND coord_y <=100),
	date timestamp CHECK (date <= now())	
);


--partie 1 inscription agent

/********************************************************* FUNCTIONS **************************************************/

CREATE OR REPLACE FUNCTION inscription_agent(varchar(255), varchar(255), VARCHAR(255), VARCHAR(512), INTEGER) RETURNS integer as $$
DECLARE
	_nomAgent ALIAS FOR $1;
	_prenomAgent ALIAS FOR $2;
	_identifiantAgent ALIAS FOR $3;
	_mdpAgent ALIAS FOR $4;
	_nbre_rapportAgent ALIAS FOR $5;
	_id integer := 0;
BEGIN
	INSERT INTO shyeld.agents VALUES(DEFAULT, _prenomAgent, _nomAgent, now(), _identifiantAgent, _mdpAgent,_nbre_rapportAgent, true) RETURNING id_agent INTO _id;
	RETURN id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'inscription pas avoir lieu';
END
$$ LANGUAGE plpgsql;


-- PARTIE 2 DELETE d'un agent
CREATE OR REPLACE FUNCTION shyeld.supprimerAgent(INTEGER) RETURNS INTEGER as $$
DECLARE
	_agentId ALIAS FOR $1;
BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.agents a
			WHERE a.id_agent = _agentId)
			THEN RAISE foreign_key_violation;
	END IF;
	UPDATE shyeld.agents SET est_actif = 'false' WHERE agent_id = _agentId;
	RETURN _agentId;
END;
$$ LANGUAGE plpgsql;

--partie 3 information de pertes de visibilité
CREATE OR REPLACE FUNCTION perte_visibilite() RETURNS SETOF shyeld.row_visibilite as $$
DECLARE
	_superhero RECORD;
	_sortie shyeld.row_visibilite; 
BEGIN
	FOR _superhero IN SELECT * FROM s.shyeld.superheros  WHERE (date_part('year', age(s.date_derniere_apparition)) >= 1
															OR date_part('month', age(s.date_derniere_apparition)) >= 1
															OR date_part('day', age(s.date_derniere_apparition)) > 15) LOOP
		SELECT _superhero.nom_superhero, _superhero.date_derniere_apparition, _superhero.derniere_coordonneeX, _superhero.derniere_coordonneeY INTO _sortie;
		RETURN NEXT _sortie;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;



-- PARTIE 4 DELETE d'un super-héros
CREATE OR REPLACE FUNCTION shyeld.supprimerSuperHeros(INTEGER) RETURNS INTEGER as $$
DECLARE
	_superHeroId ALIAS FOR $1;
BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.superheros sh
			WHERE sh.id_superhero = _superHeroId)
			THEN RAISE foreign_key_violation;
	END IF;
	UPDATE shyeld.superheros SET est_vivant = 'false' WHERE id_superhero = _superHeroId;
	RETURN _superHeroId;
END;
$$ LANGUAGE plpgsql;

--partie 5 lister ensembles zone / zones adjacentes superheros
CREATE OR REPLACE FUNCTION zone_conflit() RETURNS SETOF shyeld.row_zone as $$
DECLARE
	_zone RECORD;
	_sortie shyeld.row_zone;
BEGIN
	/* SELECTION ZONE CONFLIT */
	FOR _zone IN SELECT r.* 
				FROM shyeld.reperages r, shyeld.superheros s 
				WHERE r.superhero = s.id_superhero
				AND (date_part('year', age(s.date_derniere_apparition)) < 1
															OR date_part('month', age(s.date_derniere_apparition)) < 1
															OR date_part('day', age(s.date_derniere_apparition)) < 10)
				AND 2 = (SELECT count(DISTINCT s1.clan) 
					FROM shyeld.reperages r1
					WHERE r.id_reperage = r1.id_reperage) LOOP
		SELECT _zone.coord_x, _zone.coord_y INTO _sortie;
		RETURN NEXT _sortie;
		/* SELECTION ZONE ADJACENTE x + 1*/
		SELECT _zone.coord_x + 1, _zone.coord_y INTO _sortie;
		RETURN NEXT _sortie;
		/* SELECTION ZONE ADJACENTE x - 1*/
		SELECT _zone.coord_x - 1, _zone.coord_y INTO _sortie;
		RETURN NEXT _sortie;
		/* SELECTION ZONE ADJACENTE y + 1*/
		SELECT _zone.coord_x, _zone.coord_y + 1 INTO _sortie;
		RETURN NEXT _sortie;
		/* SELECTION ZONE ADJACENTE y - 1*/
		SELECT _zone.coord_x, _zone.coord_y - 1 INTO _sortie;
		RETURN NEXT _sortie;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;


-- PARTIE 6 Historique d'un agent
CREATE OR REPLACE FUNCTION shyeld.historiqueReperagesAgent(INTEGER, TIMESTAMP, TIMESTAMP) RETURNS SETOF
shyeld.listeReperagesAgent as $$
DECLARE
	_agentId ALIAS FOR $1;
	_dateInf ALIAS FOR $2;
	_dateSup ALIAS FOR $3;
	_super_hero RECORD;
	_reperage RECORD;
	_sortie RECORD;
BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.agents a
			WHERE a.id_agent = _agentId)
			THEN RAISE foreign_key_violation;
	END IF;
	FOR _super_hero IN SELECT * FROM shyeld.superheros LOOP
		FOR _reperage IN SELECT * FROM shyeld.reperages r WHERE r.date >= _dateInf AND r.date <= _dateSup LOOP
			SELECT _super_hero.id_superhero, _super_hero.nom_superhero, _reperage.coord_x, _reperage.coord_y, _reperage.date INTO _sortie;
			RETURN NEXT _sortie;
		END LOOP;		
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;

/* ---------------- Partie 7 ----------------- */

/* ---> a) <--- */

CREATE OR REPLACE FUNCTION classementVictoires() RETURNS SETOF shyeld.resumeCombatPourHero as $$
DECLARE
	_resume RECORD;
	_sortie shyeld.resumeCombatPourHero;
BEGIN
	FOR _resume IN (SELECT * FROM shyeld.superheros s WHERE s.est_vivant = TRUE) LOOP
		SELECT _resume.nom_superhero, _resume.nombre_victoires INTO _sortie;
		RETURN NEXT _sortie;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION classementDefaites() RETURNS SETOF shyeld.resumeCombatPourHero as $$
DECLARE
	_resume RECORD;
	_sortie shyeld.resumeCombatPourHero;
BEGIN
	FOR _resume IN (SELECT * FROM shyeld.superheros s WHERE s.est_vivant = TRUE) LOOP
		SELECT _resume.nom_superhero, _resume.nombre_defaites INTO _sortie;
		RETURN NEXT _sortie;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;

/* ---> b) <--- */

CREATE OR REPLACE FUNCTION classementReperages() RETURNS SETOF shyeld.resumeReperagePourAgent as $$
DECLARE
	_resume RECORD;
	_sortie shyeld.resumeReperagePourAgent;
BEGIN
	FOR _resume IN (SELECT a.*, count(r.id_reperage) as "reperages"
	 FROM shyeld.agents a, shyeld.reperages r WHERE a.id_agent = r.agent AND a.est_actif = TRUE GROUP BY a.id_agent) LOOP
		SELECT _resume.nom, _resument.prenom, _resume.reperages INTO _sortie;
		RETURN NEXT _sortie;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;
--partie 7.d - statistiques : historique des combats entre deux dates données, avec la liste des participants, des perdants et des gagnants

CREATE OR REPLACE FUNCTION shyeld.historiqueCombatsAgent(TIMESTAMP, TIMESTAMP) RETURNS SETOF
shyeld.listeCombatsParticipations as $$
DECLARE
	_dateInf ALIAS FOR $1;
	_dateSup ALIAS FOR $2;
	_combat RECORD;
	_participation RECORD;
	_superhero RECORD;
	_sortie RECORD;
BEGIN
	FOR _combat IN SELECT * FROM shyeld.combats c  WHERE c.date_combat >= _dateInf AND c.date_combat <= _dateSup LOOP
		FOR _participation IN SELECT * FROM shyeld.participations LOOP
			FOR _superhero IN SELECT * FROM shyeld.superheros sh WHERE sh.id_superhero = _participation.superhero LOOP
				SELECT _combat.id_combat, _combat.date_combat, _combat.coord_combatX, _combat.coord_combatY , _combat.nombre_participants , _combat.nombre_perdants ,
					_combat.nombre_neutres , _combat.clan_vainqueur, _participation.superhero, _superhero.nom_superhero, _participation.issue INTO _sortie;
				RETURN NEXT _sortie;
			END LOOP;
		END LOOP;		
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;


/************************************** INSERT INTO (META DONNEES) **************************************************************/
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BENOIT','Louis','A-Bomb','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Constriction',7,42,48,'1969/9/16','M',15,13,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'GRONDIN','Rapha�l','Abe','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel cach�','Plasmakinesis',7,11,93,'1955/8/22','M',2,21,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LOPEZ','Marilou','Sapien','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Intuitive aptitude',4,17,2,'1972/2/27','D',19,22,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MARECHAL','Daphn�e','Abin','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Nerve manipulation',6,15,54,'1992/12/26','D',19,11,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'POULAIN','Lo�c','Sur','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Empathic mimicry',4,90,44,'1957/5/26','D',3,21,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MOULIN','�milie','Abomination','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Dimension hopping',6,31,17,'1993/12/2','M',15,3,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MICHAUD','Daphn�e','Abraxas','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Weather control',8,9,68,'1991/8/17','D',12,15,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MASSON','Charles','Absorbing','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Shifting',10,88,23,'1975/3/10','D',19,10,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'RODRIGUEZ','C�dric','Man','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivit�','Future terrorist_s ability',5,76,32,'1952/11/23','D',14,14,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BONNET','Aur�lie','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivit�','Chlorine gas exudation',5,17,66,'1972/11/7','D',3,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DANIEL','Mathis','Monroe','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Intuitive empathy and empathy communication',7,54,58,'1991/9/4','D',6,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LECLERCQ','Clara','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel cach�','Metal mimicry',5,82,67,'1981/1/12','M',13,21,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'CARRE','Justine','Strange','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Disintegration touch',1,81,47,'1957/6/21','M',5,13,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'GERMAIN','Mia','Bob','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Telepathy',10,77,87,'1961/4/19','M',20,7,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'JEAN','Emy','Zero','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Lie detection',5,19,7,'1982/11/9','D',12,4,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BOUVIER','Guillaume','Air-Walker','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel cach�','Power manipulation',5,55,66,'1962/9/24','M',18,3,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MATHIEU','Gabriel','Ajax','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivit�','Crumpling',5,99,38,'1969/6/14','D',19,20,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'VINCENT','Chlo�','Alan','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Accelerated probability',9,28,59,'1986/9/22','M',11,1,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'HUET','Simon','Scott','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Age transferal',1,80,11,'1968/1/24','M',15,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LOPEZ','Emma','Alex','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Nervous system manipulation',4,83,71,'1964/12/6','M',10,24,true);

INSERT INTO shyeld.agents VALUES(DEFAULT,'Malik','MARIE','1987/8/16','qiTMJVx1er','cslVF1lcac',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Am�lie','RENAUD','1954/8/20','MAxYVtRIXL','5upmhyZQcX',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Maika','ANDRE','1988/4/14','SbLmgPcTya','vgufpAcfes',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Noah','GARCIA','1995/3/9','ypjvmYxkVe','fSpiOgKvCY',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Annabelle','GUICHARD','1985/3/24','PiZVEXNDZX','RcMlsu0EHT',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'L�a','ARNAUD','1989/12/4','EkyAtOK9Kz','lvYPcXKY47',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Laurie','LEMAIRE','1970/3/15','8BlWMoizGD','2J8XNBHqSM',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Maya','HUMBERT','1972/5/22','07Z59rS1w8','PeV6lLXumJ',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Philippe','GILLET','1992/12/22','Lr1hKtOMal','nIfM6gH72t',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Anthony','CORDIER','1982/11/3','jPaiPECuR2','6pXTdJsh0G',0,true);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1983/7/9',100,14,6,15,6,3,5,'M');
INSERT INTO shyeld.participations VALUES(6,1,'P');
INSERT INTO shyeld.participations VALUES(7,1,'P');
INSERT INTO shyeld.participations VALUES(8,1,'P');
INSERT INTO shyeld.participations VALUES(9,1,'G');
INSERT INTO shyeld.participations VALUES(10,1,'N');
INSERT INTO shyeld.participations VALUES(11,1,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1995/9/8',72,15,9,5,9,4,2,'M');
INSERT INTO shyeld.participations VALUES(9,2,'N');
INSERT INTO shyeld.participations VALUES(10,2,'G');
INSERT INTO shyeld.participations VALUES(11,2,'N');
INSERT INTO shyeld.participations VALUES(12,2,'N');
INSERT INTO shyeld.participations VALUES(13,2,'N');
INSERT INTO shyeld.participations VALUES(14,2,'N');
INSERT INTO shyeld.participations VALUES(15,2,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1978/12/28',32,67,4,18,9,10,5,'M');
INSERT INTO shyeld.participations VALUES(7,3,'P');
INSERT INTO shyeld.participations VALUES(8,3,'P');
INSERT INTO shyeld.participations VALUES(9,3,'P');
INSERT INTO shyeld.participations VALUES(10,3,'N');
INSERT INTO shyeld.participations VALUES(11,3,'N');
INSERT INTO shyeld.participations VALUES(12,3,'N');
INSERT INTO shyeld.participations VALUES(13,3,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1989/3/9',97,77,9,8,4,6,5,'M');
INSERT INTO shyeld.participations VALUES(6,4,'G');
INSERT INTO shyeld.participations VALUES(7,4,'G');
INSERT INTO shyeld.participations VALUES(8,4,'N');
INSERT INTO shyeld.participations VALUES(9,4,'G');
INSERT INTO shyeld.participations VALUES(10,4,'N');
INSERT INTO shyeld.participations VALUES(11,4,'N');
INSERT INTO shyeld.participations VALUES(12,4,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1981/7/16',86,64,7,5,0,10,2,'M');
INSERT INTO shyeld.participations VALUES(7,5,'G');
INSERT INTO shyeld.participations VALUES(8,5,'N');
INSERT INTO shyeld.participations VALUES(9,5,'G');
INSERT INTO shyeld.participations VALUES(10,5,'P');
INSERT INTO shyeld.participations VALUES(11,5,'G');
INSERT INTO shyeld.participations VALUES(12,5,'G');
INSERT INTO shyeld.participations VALUES(13,5,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1989/6/1',65,10,3,1,1,0,0,'D');
INSERT INTO shyeld.participations VALUES(2,6,'G');
INSERT INTO shyeld.participations VALUES(3,6,'N');
INSERT INTO shyeld.participations VALUES(4,6,'P');
INSERT INTO shyeld.participations VALUES(5,6,'N');
INSERT INTO shyeld.participations VALUES(6,6,'G');
INSERT INTO shyeld.participations VALUES(7,6,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1995/8/11',46,22,6,4,2,10,1,'D');
INSERT INTO shyeld.participations VALUES(11,7,'N');
INSERT INTO shyeld.participations VALUES(12,7,'P');
INSERT INTO shyeld.participations VALUES(13,7,'P');
INSERT INTO shyeld.participations VALUES(14,7,'N');
INSERT INTO shyeld.participations VALUES(15,7,'N');
INSERT INTO shyeld.participations VALUES(16,7,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1952/8/15',26,51,2,14,10,3,4,'D');
INSERT INTO shyeld.participations VALUES(7,8,'G');
INSERT INTO shyeld.participations VALUES(8,8,'P');
INSERT INTO shyeld.participations VALUES(9,8,'G');
INSERT INTO shyeld.participations VALUES(10,8,'G');
INSERT INTO shyeld.participations VALUES(11,8,'P');
INSERT INTO shyeld.participations VALUES(12,8,'G');
INSERT INTO shyeld.participations VALUES(13,8,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1988/12/16',91,61,2,15,1,5,2,'M');
INSERT INTO shyeld.participations VALUES(5,9,'G');
INSERT INTO shyeld.participations VALUES(6,9,'G');
INSERT INTO shyeld.participations VALUES(7,9,'P');
INSERT INTO shyeld.participations VALUES(8,9,'P');
INSERT INTO shyeld.participations VALUES(9,9,'G');
INSERT INTO shyeld.participations VALUES(10,9,'N');
INSERT INTO shyeld.participations VALUES(11,9,'P');
INSERT INTO shyeld.participations VALUES(12,9,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1991/8/17',55,23,6,18,2,3,3,'M');
INSERT INTO shyeld.participations VALUES(3,10,'G');
INSERT INTO shyeld.participations VALUES(4,10,'N');
INSERT INTO shyeld.participations VALUES(5,10,'P');
INSERT INTO shyeld.participations VALUES(6,10,'P');
INSERT INTO shyeld.participations VALUES(7,10,'N');
INSERT INTO shyeld.participations VALUES(8,10,'P');
INSERT INTO shyeld.participations VALUES(9,10,'P');
INSERT INTO shyeld.participations VALUES(10,10,'N');


INSERT INTO shyeld.reperages VALUES(DEFAULT,2,13,61,53,'1997/2/18');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,2,90,64,'1961/1/17');
INSERT INTO shyeld.reperages VALUES(DEFAULT,5,13,83,36,'1994/9/12');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,7,20,77,'1996/1/22');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,3,16,75,'1978/3/8');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,2,56,29,'1977/4/21');
INSERT INTO shyeld.reperages VALUES(DEFAULT,10,16,97,55,'1969/10/8');
INSERT INTO shyeld.reperages VALUES(DEFAULT,7,3,75,48,'1983/9/9');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,14,39,17,'1994/9/13');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,11,33,69,'2000/11/27');
INSERT INTO shyeld.reperages VALUES(DEFAULT,7,10,1,49,'1957/3/8');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,16,60,83,'1970/11/7');
INSERT INTO shyeld.reperages VALUES(DEFAULT,10,13,16,50,'1994/2/28');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,8,75,4,'1991/4/13');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,7,45,66,'1962/4/1');
/***************************************** APPEL FONCTIONS ***********************************************************************/
SELECT * FROM shyeld.historiqueCombatsAgent( now()::timestamp- interval '2000000000 min', now()::timestamp);
