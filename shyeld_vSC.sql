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

INSERT INTO shyeld.superheros VALUES(DEFAULT,'HUET','Marianne','A-Bomb','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Invisibility',9,1,81,'1969/11/21','M',1,12,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'POULAIN','Mégan','Abe','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Mediumship',6,4,47,'1962/6/18','M',3,19,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BERTIN','Marianne','Sapien','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Age manipulation',10,49,89,'1957/1/28','M',7,13,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PERRIER','Aurélie','Abin','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Microwave emission',7,62,11,'1955/7/9','D',6,18,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'OLIVIER','Malik','Sur','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Spider mimicry',10,16,6,'1955/12/18','M',8,18,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MONNIER','Lucas','Abomination','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Mass manipulation',9,33,54,'1975/10/12','D',1,16,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'REMY','Maélie','Abraxas','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Light manipulation',9,90,8,'1998/11/13','D',13,1,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'OLIVIER','Mégan','Absorbing','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Shattering',6,61,91,'1980/9/6','D',18,21,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MATHIEU','Jérémy','Man','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Gas mimicry',1,9,8,'1971/6/2','M',4,19,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PELLETIER','Nathan','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Fire casting',7,5,34,'1969/5/3','M',18,20,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PHILIPPE','Olivia','Monroe','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Telepathy',1,73,91,'1966/7/11','M',2,25,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DUMONT','Gabriel','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Rock formation',3,43,64,'1959/8/25','M',5,18,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MERCIER','Emma','Strange','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Gas mimicry',5,54,91,'1982/9/18','M',3,20,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BLANC','Ève','Bob','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Mass manipulation',6,81,74,'1996/8/11','M',11,7,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'RODRIGUEZ','Anthony','Zero','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Space-time manipulation',2,22,61,'1958/2/15','M',4,6,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BOURGEOIS','Félix','Air-Walker','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Dream manipulation',2,64,23,'1961/5/8','D',20,25,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BENARD','Coralie','Ajax','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Sound absorption',6,18,48,'1990/6/16','M',18,22,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROBERT','Anthony','Alan','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Enhanced hearing',8,12,91,'1979/6/2','M',5,10,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'REMY','Océane','Scott','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Disintegration touch',7,35,36,'1999/10/20','M',19,1,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PERRIER','Simon','Alex','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Alejandro_s ability',1,55,70,'1999/2/8','M',20,9,true);

INSERT INTO shyeld.agents VALUES(DEFAULT,'Maxime','BERTRAND','1951/2/25','BERTRAND0','123456',8,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Lucas','PICARD','1976/11/21','PICARD1','123456',23,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Ludovic','LOUIS','1960/4/17','LOUIS2','123456',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Maude','POULAIN','1964/7/13','POULAIN3','123456',9,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Mélodie','LEBLANC','1961/12/10','LEBLANC4','123456',11,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Justin','LEMOINE','1982/9/23','LEMOINE5','123456',24,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Victoria','PETIT','1983/3/9','PETIT6','123456',25,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Jacob','GILLET','1965/6/24','GILLET7','123456',6,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Amélie','GAILLARD','1966/2/8','GAILLARD8','123456',10,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'David','ETIENNE','1974/3/20','ETIENNE9','123456',4,true);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1996/11/7',45,95,9,19,4,7,0,'D');
INSERT INTO shyeld.participations VALUES(7,1,'N');
INSERT INTO shyeld.participations VALUES(8,1,'N');
INSERT INTO shyeld.participations VALUES(9,1,'N');
INSERT INTO shyeld.participations VALUES(10,1,'G');
INSERT INTO shyeld.participations VALUES(11,1,'N');
INSERT INTO shyeld.participations VALUES(12,1,'P');
INSERT INTO shyeld.participations VALUES(13,1,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1978/3/4',31,52,7,13,2,6,5,'M');
INSERT INTO shyeld.participations VALUES(11,2,'N');
INSERT INTO shyeld.participations VALUES(12,2,'G');
INSERT INTO shyeld.participations VALUES(13,2,'P');
INSERT INTO shyeld.participations VALUES(14,2,'N');
INSERT INTO shyeld.participations VALUES(15,2,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1982/11/25',72,44,9,13,7,7,2,'M');
INSERT INTO shyeld.participations VALUES(10,3,'G');
INSERT INTO shyeld.participations VALUES(11,3,'P');
INSERT INTO shyeld.participations VALUES(12,3,'P');
INSERT INTO shyeld.participations VALUES(13,3,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1969/2/7',93,71,3,4,2,8,2,'D');
INSERT INTO shyeld.participations VALUES(5,4,'G');
INSERT INTO shyeld.participations VALUES(6,4,'N');
INSERT INTO shyeld.participations VALUES(7,4,'P');
INSERT INTO shyeld.participations VALUES(8,4,'G');
INSERT INTO shyeld.participations VALUES(9,4,'P');
INSERT INTO shyeld.participations VALUES(10,4,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1992/2/13',35,17,8,3,9,10,5,'D');
INSERT INTO shyeld.participations VALUES(6,5,'G');
INSERT INTO shyeld.participations VALUES(7,5,'N');
INSERT INTO shyeld.participations VALUES(8,5,'G');
INSERT INTO shyeld.participations VALUES(9,5,'P');
INSERT INTO shyeld.participations VALUES(10,5,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1952/4/22',64,81,1,2,8,6,5,'M');
INSERT INTO shyeld.participations VALUES(5,6,'N');
INSERT INTO shyeld.participations VALUES(6,6,'P');
INSERT INTO shyeld.participations VALUES(7,6,'P');
INSERT INTO shyeld.participations VALUES(8,6,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1950/8/22',0,29,10,3,0,5,2,'D');
INSERT INTO shyeld.participations VALUES(4,7,'N');
INSERT INTO shyeld.participations VALUES(5,7,'N');
INSERT INTO shyeld.participations VALUES(6,7,'N');
INSERT INTO shyeld.participations VALUES(7,7,'P');
INSERT INTO shyeld.participations VALUES(8,7,'N');
INSERT INTO shyeld.participations VALUES(9,7,'N');
INSERT INTO shyeld.participations VALUES(10,7,'P');
INSERT INTO shyeld.participations VALUES(11,7,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1953/4/3',34,81,2,16,8,9,5,'M');
INSERT INTO shyeld.participations VALUES(10,8,'N');
INSERT INTO shyeld.participations VALUES(11,8,'G');
INSERT INTO shyeld.participations VALUES(12,8,'N');
INSERT INTO shyeld.participations VALUES(13,8,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1955/7/2',69,45,4,3,2,8,4,'M');
INSERT INTO shyeld.participations VALUES(11,9,'G');
INSERT INTO shyeld.participations VALUES(12,9,'N');
INSERT INTO shyeld.participations VALUES(13,9,'N');
INSERT INTO shyeld.participations VALUES(14,9,'P');
INSERT INTO shyeld.participations VALUES(15,9,'P');
INSERT INTO shyeld.participations VALUES(16,9,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1956/2/27',81,86,9,20,4,4,4,'M');
INSERT INTO shyeld.participations VALUES(3,10,'P');
INSERT INTO shyeld.participations VALUES(4,10,'P');
INSERT INTO shyeld.participations VALUES(5,10,'N');
INSERT INTO shyeld.participations VALUES(6,10,'N');
INSERT INTO shyeld.participations VALUES(7,10,'P');
INSERT INTO shyeld.participations VALUES(8,10,'N');
INSERT INTO shyeld.participations VALUES(9,10,'G');
INSERT INTO shyeld.participations VALUES(10,10,'G');


INSERT INTO shyeld.reperages VALUES(DEFAULT,1,17,0,37,'1984/8/24');
INSERT INTO shyeld.reperages VALUES(DEFAULT,5,13,23,65,'1958/10/3');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,17,67,39,'1953/6/18');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,16,95,84,'1969/3/13');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,11,70,15,'1981/9/21');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,10,53,85,'1952/6/11');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,11,26,51,'1986/8/17');
INSERT INTO shyeld.reperages VALUES(DEFAULT,10,10,79,38,'1973/12/8');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,11,53,32,'1997/8/22');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,18,95,36,'1957/12/18');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,20,56,61,'1967/1/18');
INSERT INTO shyeld.reperages VALUES(DEFAULT,7,2,66,52,'1977/8/25');
INSERT INTO shyeld.reperages VALUES(DEFAULT,5,14,5,23,'1952/1/1');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,5,65,4,'1967/10/7');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,16,82,22,'1954/3/27');

/***************************************** APPEL FONCTIONS ***********************************************************************/
SELECT * FROM shyeld.historiqueCombatsAgent( now()::timestamp- interval '2000000000 min', now()::timestamp);
