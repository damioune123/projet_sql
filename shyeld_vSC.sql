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

CREATE OR REPLACE FUNCTION inscription_agent(varchar(255), varchar(255)) RETURNS integer as $$
DECLARE
	_nomAgent ALIAS FOR $1;
	_prenomAgent ALIAS FOR $2;
	_id integer := 0;
BEGIN
	INSERT INTO shyeld.agents VALUES(DEFAULT, _prenomAgent, _nomAgent, now(), true) RETURNING id_agent INTO _id;
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

INSERT INTO shyeld.superheros VALUES(DEFAULT,'GUERIN','Clara','A-Bomb','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Bliss and horror',8,10,66,'1963/7/9','M',11,3,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DUPONT','Étienne','Abe','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Levitation',9,100,45,'1986/3/8','M',1,5,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MARECHAL','Louis','Sapien','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Age transferal',1,4,83,'1972/7/24','D',12,25,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DELAUNAY','Ludovic','Abin','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Cyberpathy',5,67,3,'1959/11/21','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MARIE','Émilie','Sur','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Imprinting',8,13,85,'1952/9/26','M',3,20,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'JACQUET','Tommy','Abomination','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Chlorine gas exudation',10,35,99,'1989/8/27','M',2,2,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LEBLANC','Maéva','Abraxas','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Poison emission',1,49,29,'2000/3/21','M',10,7,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LEBRUN','Jade','Absorbing','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Hachiro_s ability',8,29,85,'1977/3/21','M',16,22,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'OLIVIER','Noah','Man','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Gold mimicry',10,67,6,'1977/9/8','D',12,14,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DUMAS','Tommy','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Reality distortion',3,23,56,'1954/1/16','M',15,7,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ANTOINE','Victor','Monroe','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Acidic blood',9,80,93,'2000/1/25','M',2,19,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MALLET','Jérémy','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Cyberpathy',5,53,19,'1987/6/19','M',11,5,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MEUNIER','Maika','Strange','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Enhanced memory',2,57,99,'1970/10/26','M',15,24,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'GRONDIN','Jade','Bob','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Cloning',8,24,26,'1991/1/11','M',9,10,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PICHON','Emy','Zero','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Fire breathing',4,97,13,'1979/7/3','D',3,15,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'GUILLAUME','Charles','Air-Walker','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Temperature manipulation',2,66,96,'1982/5/12','M',7,12,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PELLETIER','Michaël','Ajax','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Microwave emission',5,85,70,'1982/3/28','D',3,9,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LECLERCQ','Philippe','Alan','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Forcefields',10,25,55,'1960/9/5','D',13,18,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BONNET','Logan','Scott','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Deoxygenation',1,68,20,'1969/12/1','D',1,16,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'COLLET','Chloé','Alex','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Activation and deactivation',1,100,30,'1950/3/10','D',8,5,true);

INSERT INTO shyeld.agents VALUES(DEFAULT,'Vincent','GERMAIN','1976/3/11',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Édouard','ROCHE','1956/8/3',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Victoria','BERTIN','1998/4/21',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Lucas','ROUSSEL','1979/12/23',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Émilie','AUBERT','1954/3/1',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Charlotte','FOURNIER','1972/3/13',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Alexandre','GARCIA','1974/7/13',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Lucas','BERTIN','1982/12/6',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Samuel','SIMON','1961/10/17',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'David','HERVE','1999/1/18',true);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1994/11/22',83,38,10,16,5,2,5,'D');
INSERT INTO shyeld.participations VALUES(5,1,'N');
INSERT INTO shyeld.participations VALUES(6,1,'N');
INSERT INTO shyeld.participations VALUES(7,1,'N');
INSERT INTO shyeld.participations VALUES(8,1,'P');
INSERT INTO shyeld.participations VALUES(9,1,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1964/3/11',3,50,7,1,9,2,4,'M');
INSERT INTO shyeld.participations VALUES(9,2,'N');
INSERT INTO shyeld.participations VALUES(10,2,'G');
INSERT INTO shyeld.participations VALUES(11,2,'P');
INSERT INTO shyeld.participations VALUES(12,2,'P');
INSERT INTO shyeld.participations VALUES(13,2,'N');
INSERT INTO shyeld.participations VALUES(14,2,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1964/5/15',34,22,10,5,8,2,5,'D');
INSERT INTO shyeld.participations VALUES(1,3,'N');
INSERT INTO shyeld.participations VALUES(2,3,'G');
INSERT INTO shyeld.participations VALUES(3,3,'N');
INSERT INTO shyeld.participations VALUES(4,3,'G');
INSERT INTO shyeld.participations VALUES(5,3,'P');
INSERT INTO shyeld.participations VALUES(6,3,'N');
INSERT INTO shyeld.participations VALUES(7,3,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1985/11/6',26,71,10,0,10,8,1,'M');
INSERT INTO shyeld.participations VALUES(2,4,'P');
INSERT INTO shyeld.participations VALUES(3,4,'P');
INSERT INTO shyeld.participations VALUES(4,4,'P');
INSERT INTO shyeld.participations VALUES(5,4,'P');
INSERT INTO shyeld.participations VALUES(6,4,'G');
INSERT INTO shyeld.participations VALUES(7,4,'P');
INSERT INTO shyeld.participations VALUES(8,4,'G');
INSERT INTO shyeld.participations VALUES(9,4,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1986/9/18',76,50,2,6,3,3,4,'M');
INSERT INTO shyeld.participations VALUES(6,5,'P');
INSERT INTO shyeld.participations VALUES(7,5,'G');
INSERT INTO shyeld.participations VALUES(8,5,'P');
INSERT INTO shyeld.participations VALUES(9,5,'G');
INSERT INTO shyeld.participations VALUES(10,5,'N');
INSERT INTO shyeld.participations VALUES(11,5,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1954/9/28',17,42,5,5,9,3,3,'D');
INSERT INTO shyeld.participations VALUES(4,6,'P');
INSERT INTO shyeld.participations VALUES(5,6,'P');
INSERT INTO shyeld.participations VALUES(6,6,'P');
INSERT INTO shyeld.participations VALUES(7,6,'P');
INSERT INTO shyeld.participations VALUES(8,6,'G');
INSERT INTO shyeld.participations VALUES(9,6,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1985/7/17',90,50,5,3,10,2,0,'M');
INSERT INTO shyeld.participations VALUES(10,7,'G');
INSERT INTO shyeld.participations VALUES(11,7,'P');
INSERT INTO shyeld.participations VALUES(12,7,'G');
INSERT INTO shyeld.participations VALUES(13,7,'P');
INSERT INTO shyeld.participations VALUES(14,7,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1997/12/2',42,98,4,12,3,9,1,'D');
INSERT INTO shyeld.participations VALUES(9,8,'N');
INSERT INTO shyeld.participations VALUES(10,8,'P');
INSERT INTO shyeld.participations VALUES(11,8,'P');
INSERT INTO shyeld.participations VALUES(12,8,'G');
INSERT INTO shyeld.participations VALUES(13,8,'N');
INSERT INTO shyeld.participations VALUES(14,8,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1988/6/16',49,84,8,8,1,10,5,'M');
INSERT INTO shyeld.participations VALUES(2,9,'N');
INSERT INTO shyeld.participations VALUES(3,9,'G');
INSERT INTO shyeld.participations VALUES(4,9,'G');
INSERT INTO shyeld.participations VALUES(5,9,'N');
INSERT INTO shyeld.participations VALUES(6,9,'G');
INSERT INTO shyeld.participations VALUES(7,9,'G');
INSERT INTO shyeld.participations VALUES(8,9,'G');
INSERT INTO shyeld.participations VALUES(9,9,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'1981/3/5',41,66,6,8,1,3,2,'M');
INSERT INTO shyeld.participations VALUES(2,10,'G');
INSERT INTO shyeld.participations VALUES(3,10,'P');
INSERT INTO shyeld.participations VALUES(4,10,'P');
INSERT INTO shyeld.participations VALUES(5,10,'P');
INSERT INTO shyeld.participations VALUES(6,10,'G');
INSERT INTO shyeld.participations VALUES(7,10,'G');
INSERT INTO shyeld.participations VALUES(8,10,'P');


INSERT INTO shyeld.reperages VALUES(DEFAULT,1,1,30,97,'1977/2/3');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,5,74,19,'1951/3/9');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,2,16,84,'1987/4/2');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,9,54,91,'1982/11/22');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,5,18,68,'1969/9/1');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,7,64,77,'1988/6/5');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,20,66,21,'1963/2/2');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,14,27,72,'1965/11/1');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,8,51,3,'1951/11/9');
INSERT INTO shyeld.reperages VALUES(DEFAULT,2,18,64,33,'1984/7/5');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,1,94,40,'1974/12/10');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,15,64,42,'1996/11/5');
INSERT INTO shyeld.reperages VALUES(DEFAULT,5,4,100,81,'1950/12/22');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,1,13,76,'1952/10/1');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,19,15,80,'1967/6/19');

/***************************************** APPEL FONCTIONS ***********************************************************************/
SELECT * FROM shyeld.historiqueCombatsAgent( now()::timestamp- interval '2000000000 min', now()::timestamp);
