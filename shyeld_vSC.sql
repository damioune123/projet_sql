DROP SCHEMA IF EXISTS shyeld CASCADE;
DROP TYPE IF EXISTS  type_clan;
DROP TYPE IF EXISTS  type_issue;
DROP TYPE IF EXISTS  listesReperagesAgent;


CREATE SCHEMA shyeld;

CREATE TYPE shyeld.type_clan AS ENUM('M','D');
CREATE TYPE shyeld.type_issue AS ENUM('G','P','N');
CREATE TYPE shyeld.row_visibilite AS (nom_superhero varchar(255), date_derniere_apparition timestamp, derniere_coordonneeX integer, derniere_coordonneeY integer);
CREATE TYPE shyeld.row_zone AS (coord_x integer,coord_y integer);
CREATE TYPE shyeld.listesReperagesAgent AS (id_superhero INTEGER, nom_superhero varchar(255), coord_x  INTEGER, coord_y  INTEGER, date timestamp);
CREATE TYPE shyeld.resumeCombatPourHero AS (nom_superhero varchar(255), nombreVictoiresDefaites integer);
CREATE TYPE shyeld.resumeReperagePourAgent AS (nom varchar(255), prenom varchar(255), nombreReperages integer);

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
CREATE OR REPLACE FUNCTION shyeld.historiqueAgent(INTEGER, TIMESTAMP, TIMESTAMP) RETURNS SETOF shyeld.listesReperagesAgent as $$
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


/************************************** INSERT INTO (META DONNEES) **************************************************************/
INSERT INTO shyeld.superheros VALUES(DEFAULT,'HOARAU','Jonathan','A-Bomb','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Intuitive aptitude',3,37,95,'16/1/1974','M',19,25,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'RENAULT','Mélodie','Abe','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Danger sensing',5,17,24,'2/12/1977','D',6,15,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROGER','Raphaël','Sapien','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Umbrakinesis',10,50,69,'18/7/1968','D',18,4,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MALLET','Justin','Abin','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Mist mimicry',10,89,100,'28/5/1997','M',7,11,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'OLIVIER','Gabrielle','Sur','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Sedation',8,76,78,'21/6/1988','M',3,12,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BARTHELEMY','Cédric','Abomination','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Enhanced synesthesia',2,87,56,'8/10/1986','D',13,5,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROY','Michaël','Abraxas','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Intuitive aptitude',7,10,45,'22/6/1961','M',20,23,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'GRONDIN','Nicolas','Absorbing','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Sound manipulation',5,4,80,'28/7/1957','M',8,9,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BENARD','Laurence','Man','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Disintegration touch',6,34,94,'24/6/1984','M',9,8,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PERRIN','Audrey','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Cloaking',1,29,53,'13/5/1964','D',12,2,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LE ROUX','Michaël','Monroe','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Sedation',10,14,99,'26/11/1966','M',15,2,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'RENAUD','Noémie','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Clairsentience',3,20,63,'23/8/1999','M',11,19,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'AUBERT','Anaïs','Strange','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Activation and deactivation',2,47,56,'25/1/1961','D',13,12,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'FAURE','Louis','Bob','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Metal duplication',10,29,14,'27/11/1992','M',12,11,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'FRANCOIS','Jade','Zero','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Cloning',9,64,37,'4/6/1995','M',13,24,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BERNARD','Sofia','Air-Walker','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Health optimizing',9,49,78,'16/3/1961','D',16,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROY','Jonathan','Ajax','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Animal control',8,62,59,'9/11/1977','M',13,24,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROBIN','Daphnée','Alan','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Shape shifting',1,49,38,'28/7/1973','M',7,24,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BOULANGER','Dylan','Scott','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Acidic blood',6,22,26,'27/2/1969','D',0,17,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BOULANGER','Michaël','Alex','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Disintegration touch',7,51,41,'25/2/1962','D',4,3,true);

INSERT INTO shyeld.agents VALUES(DEFAULT,'Mélodie','BRETON','18/10/1974',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Charles','BENOIT','9/5/1966',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Anthony','BENOIT','18/10/1980',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Anaïs','GUYOT','15/12/1954',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Marilou','DUPUY','22/9/1962',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Amélie','PIERRE','6/9/1955',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Étienne','LEMAITRE','4/11/1985',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Adam','BERGER','7/2/1983',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Noah','GUERIN','5/1/1993',true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Jade','GUILLOT','4/6/1968',true);

INSERT INTO shyeld.combats VALUES(DEFAULT,'12/2/1991',27,19,4,8,6,7,4,'D');
INSERT INTO shyeld.participations VALUES(9,1,'P');
INSERT INTO shyeld.participations VALUES(10,1,'G');
INSERT INTO shyeld.participations VALUES(11,1,'N');
INSERT INTO shyeld.participations VALUES(12,1,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'2/6/1958',33,75,5,4,1,10,0,'M');
INSERT INTO shyeld.participations VALUES(1,2,'N');
INSERT INTO shyeld.participations VALUES(2,2,'G');
INSERT INTO shyeld.participations VALUES(3,2,'P');
INSERT INTO shyeld.participations VALUES(4,2,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'9/4/1950',4,13,2,9,7,7,5,'M');
INSERT INTO shyeld.participations VALUES(11,3,'N');
INSERT INTO shyeld.participations VALUES(12,3,'N');
INSERT INTO shyeld.participations VALUES(13,3,'N');
INSERT INTO shyeld.participations VALUES(14,3,'P');
INSERT INTO shyeld.participations VALUES(15,3,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'9/7/1964',10,5,4,3,4,4,3,'D');
INSERT INTO shyeld.participations VALUES(5,4,'G');
INSERT INTO shyeld.participations VALUES(6,4,'G');
INSERT INTO shyeld.participations VALUES(7,4,'P');
INSERT INTO shyeld.participations VALUES(8,4,'G');
INSERT INTO shyeld.participations VALUES(9,4,'G');
INSERT INTO shyeld.participations VALUES(10,4,'P');
INSERT INTO shyeld.participations VALUES(11,4,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'14/4/1958',66,22,8,14,3,2,5,'D');
INSERT INTO shyeld.participations VALUES(11,5,'G');
INSERT INTO shyeld.participations VALUES(12,5,'G');
INSERT INTO shyeld.participations VALUES(13,5,'N');
INSERT INTO shyeld.participations VALUES(14,5,'P');
INSERT INTO shyeld.participations VALUES(15,5,'N');
INSERT INTO shyeld.participations VALUES(16,5,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'19/2/1952',26,6,10,4,10,3,2,'M');
INSERT INTO shyeld.participations VALUES(3,6,'G');
INSERT INTO shyeld.participations VALUES(4,6,'N');
INSERT INTO shyeld.participations VALUES(5,6,'N');
INSERT INTO shyeld.participations VALUES(6,6,'P');
INSERT INTO shyeld.participations VALUES(7,6,'N');
INSERT INTO shyeld.participations VALUES(8,6,'N');

INSERT INTO shyeld.combats VALUES(DEFAULT,'23/9/1951',29,98,4,6,6,0,5,'M');
INSERT INTO shyeld.participations VALUES(11,7,'G');
INSERT INTO shyeld.participations VALUES(12,7,'N');
INSERT INTO shyeld.participations VALUES(13,7,'G');
INSERT INTO shyeld.participations VALUES(14,7,'P');

INSERT INTO shyeld.combats VALUES(DEFAULT,'19/2/1981',99,2,8,6,3,8,2,'D');
INSERT INTO shyeld.participations VALUES(6,8,'G');
INSERT INTO shyeld.participations VALUES(7,8,'G');
INSERT INTO shyeld.participations VALUES(8,8,'G');
INSERT INTO shyeld.participations VALUES(9,8,'G');
INSERT INTO shyeld.participations VALUES(10,8,'N');
INSERT INTO shyeld.participations VALUES(11,8,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'2/6/1953',8,22,4,19,7,2,2,'M');
INSERT INTO shyeld.participations VALUES(8,9,'G');
INSERT INTO shyeld.participations VALUES(9,9,'N');
INSERT INTO shyeld.participations VALUES(10,9,'G');
INSERT INTO shyeld.participations VALUES(11,9,'G');

INSERT INTO shyeld.combats VALUES(DEFAULT,'19/4/1958',2,10,6,10,5,6,2,'D');
INSERT INTO shyeld.participations VALUES(1,10,'N');
INSERT INTO shyeld.participations VALUES(2,10,'G');
INSERT INTO shyeld.participations VALUES(3,10,'P');
INSERT INTO shyeld.participations VALUES(4,10,'N');
INSERT INTO shyeld.participations VALUES(5,10,'P');
INSERT INTO shyeld.participations VALUES(6,10,'G');
INSERT INTO shyeld.participations VALUES(7,10,'P');


INSERT INTO shyeld.reperages VALUES(DEFAULT,4,4,4,63,'22/11/1953');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,17,47,12,'23/10/1977');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,12,25,76,'8/11/1985');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,15,76,71,'26/11/1957');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,15,46,0,'8/4/1991');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,5,6,44,'26/4/1968');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,5,84,85,'19/2/1973');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,17,86,61,'10/1/1974');
INSERT INTO shyeld.reperages VALUES(DEFAULT,2,20,91,15,'1/12/1977');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,6,50,58,'17/1/1986');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,13,83,61,'5/6/1957');
INSERT INTO shyeld.reperages VALUES(DEFAULT,10,7,1,34,'28/4/1968');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,14,75,27,'27/8/1988');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,19,37,5,'19/4/1975');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,7,24,22,'13/3/1980');

/***************************************** APPEL FONCTIONS ***********************************************************************/
