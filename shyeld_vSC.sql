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
	numero_ligne integer NOT NULL CHECK (numero_ligne >= 0),
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


-- Partie 1.a inscription agent

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
	RETURN _id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'agent incorrect';
END;
$$ LANGUAGE plpgsql;

-- PARTIE 1.b création repérage

CREATE OR REPLACE FUNCTION creation_reperage(integer, integer, integer, integer, timestamp) RETURNS integer as $$
DECLARE
	_agent ALIAS FOR $1;
	_superhero ALIAS FOR $2;
	_coordX ALIAS FOR $3;
	_coordY ALIAS FOR $4;
	_date ALIAS FOR $5;
	_id integer := 0;
BEGIN
	IF NOT EXISTS (SELECT a.* FROM shyeld.agents a WHERE a.id_agent = _agent) THEN 
		RAISE foreign_key_violation;
	END IF;

	IF NOT EXISTS (SELECT s.* FROM shyeld.superheros s WHERE s.id_superhero = _superhero) THEN
		RAISE foreign_key_violation;
	END IF;

	INSERT INTO shyeld.reperages VALUES(DEFAULT, _agent, _superhero, _coordX, _coordY, _date) RETURNING id_reperage INTO _id;
	RETURN _id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'reperage incorrect';
END;
$$ LANGUAGE plpgsql;

--- PARTIE 1.c creation superhero ---

CREATE OR REPLACE FUNCTION creation_superhero(varchar, varchar, varchar, varchar, varchar, varchar, integer, integer, integer, timestamp,
 shyeld.type_clan, integer, integer, boolean) RETURNS integer as $$
DECLARE
	_nom ALIAS FOR $1;
	_prenom ALIAS FOR $2;
	_nomSuperHero ALIAS FOR $3;
	_adressePrivee ALIAS FOR $4;
	_origine ALIAS FOR $5;
	_typeSuperPouvoir ALIAS FOR $6;
	_puissanceSuperPouvoir ALIAS FOR $7;
	_coordX ALIAS FOR $8;
	_coordY ALIAS FOR $9;
	_date ALIAS FOR $10;
	_clan ALIAS FOR $11;
	_nombreVictoires ALIAS FOR $12;
	_nombreDefaites ALIAS FOR $13;
	_estVivant ALIAS FOR $14;
	_id integer := 0;
BEGIN
	IF EXISTS (SELECT s.* FROM shyeld.superheros s WHERE s.nom_superhero = _nomSuperHero AND s.est_vivant = TRUE) THEN
		RAISE foreign_key_violation;
	END IF;

	INSERT INTO shyeld.superheros VALUES (DEFAULT, _nom, _prenom, _nomSuperHero, _adressePrivee, _origine, _typeSuperPouvoir, _puissanceSuperPouvoir,
		_coordX, _coordY, _date, _clan, _nombreVictoires, _nombreDefaites, _estVivant) RETURNING id_superhero INTO _id;
	RETURN _id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'superhero incorrect';
END;
$$ LANGUAGE plpgsql;

--- PARTIE 1.d creation combat ---

CREATE OR REPLACE FUNCTION creation_combat(timestamp, integer, integer, integer, integer, integer, integer, integer, shyeld.type_clan) RETURNS integer as $$
DECLARE
	_date ALIAS FOR $1;
	_coordX ALIAS FOR $2;
	_coordY ALIAS FOR $3;
	_agent ALIAS FOR $4;
	_nombreParticipants ALIAS FOR $5;
	_nombreGagnants ALIAS FOR $6;
	_nombrePerdants ALIAS FOR $7;
	_nombreNeutres ALIAS FOR $8;
	_clanVainqueur ALIAS FOR $9;
	_id integer := 0;
BEGIN
	IF NOT EXISTS (SELECT a.* FROM shyeld.agents a WHERE a.id_agent = _agent) THEN 
		RAISE foreign_key_violation;
	END IF;

	INSERT INTO shyeld.combats VALUES (DEFAULT, _date, _coordX, _coordY, _agent, _nombreParticipants,
	 _nombreGagnants, _nombrePerdants, _nombreNeutres, _clanVainqueur) RETURNING id_combat INTO _id;
	RETURN _id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'combat incorrect';
END;
$$ LANGUAGE plpgsql;

--- PARTIE 1.e creation participation ---

CREATE OR REPLACE FUNCTION creation_participation(integer, integer, shyeld.type_issue) RETURNS integer as $$
DECLARE
	_superhero ALIAS FOR $1;
	_combat ALIAS FOR $2;
	_issue ALIAS FOR $3;
	_numLigne integer := 0;
BEGIN
	IF NOT EXISTS (SELECT s.* FROM shyeld.superheros s WHERE s.id_superhero = _superhero) THEN
		RAISE foreign_key_violation;
	END IF;

	IF NOT EXISTS (SELECT c.* FROM shyeld.combats c WHERE c.id_combat = _combat) THEN
		RAISE foreign_key_violation;
	END IF;

	_numLigne:=(SELECT count(p.numero_ligne) as "nombre_ligne" FROM shyeld.participations WHERE p.combat = _combat);

	INSERT INTO shyeld.participations VALUES (_superhero, _combat, _issue, _numLigne);

	RETURN _numLigne;

	EXCEPTION 
		WHEN check_violation THEN RAISE EXCEPTION 'participation incorrecte';
END;
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

INSERT INTO shyeld.superheros VALUES(DEFAULT,'GAUTHIER','Tristan','A-Bomb','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Empathy',3,40,41,'1964/8/10','D',0,11,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'FRANCOIS','Mathis','Abe','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Appearance alteration',6,46,97,'1997/2/16','M',10,20,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'AUBERT','Étienne','Sapien','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Rapid cell regeneration',5,57,12,'1983/5/27','D',11,9,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'HENRY','Ludovic','Abin','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Fire breathing',3,67,70,'1971/2/2','M',3,2,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DESCHAMPS','Dylan','Sur','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Electronic data manipulation',6,13,82,'1997/4/22','M',12,24,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LEBLANC','Alicia','Abomination','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Terrakinesis',8,5,8,'1962/10/7','D',5,6,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'CARON','Alex','Abraxas','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel caché','Alejandro_s ability',10,92,57,'1963/3/25','D',20,16,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'HENRY','Dylan','Absorbing','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Wall crawling',4,4,23,'1967/10/14','D',7,24,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LANGLOIS','Tommy','Man','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Age manipulation',4,80,26,'1969/6/6','M',20,25,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'GUILLAUME','Thomas','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Silicon manipulation',9,26,94,'1955/3/14','M',12,15,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BLANC','Olivier','Monroe','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Nervous system manipulation',4,40,98,'1959/6/27','D',15,7,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'FAURE','Camille','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Aura absorption',3,21,53,'1992/8/23','D',2,14,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DANIEL','Léanne','Strange','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Luke_s ability',10,38,57,'1967/12/19','M',10,19,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'SCHNEIDER','Benjamin','Bob','Pour le moment pas d idees 35 1000 Bruxelles','Radioactivité','Enhanced strength and senses',2,77,28,'1983/8/11','M',1,12,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MOULIN','Laurence','Zero','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Plant manipulation',1,12,69,'1971/1/20','D',8,11,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MARTINEZ','Chloé','Air-Walker','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Dimension hopping',4,27,28,'1968/5/19','D',7,3,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'CARLIER','Alicia','Ajax','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Aquatic breathing',1,28,30,'1969/3/2','D',1,20,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'CARON','Mathis','Alan','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Spider mimicry',8,46,60,'1983/5/26','D',3,20,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'KLEIN','Arianne','Scott','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Healing',8,57,25,'1982/11/28','M',3,1,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROGER','Aurélie','Alex','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Neurocognitive deficit',4,39,70,'1965/9/4','D',18,2,true);

INSERT INTO shyeld.agents VALUES(DEFAULT,'Anthony','HERVE','1990/1/23','HERVE0','123456',25,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Océane','FLEURY','1976/2/5','FLEURY1','123456',16,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Malik','FAURE','1953/4/11','FAURE2','123456',8,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Elliot','LAMBERT','1970/7/13','LAMBERT3','123456',4,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Maélie','LAURENT','1977/6/3','LAURENT4','123456',22,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Sarah','RENARD','1951/8/13','RENARD5','123456',10,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Elliot','MULLER','1998/3/13','MULLER6','123456',2,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Maya','HUMBERT','1968/3/10','HUMBERT7','123456',1,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Édouard','LEMOINE','1990/11/6','LEMOINE8','123456',18,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Félix','DAVID','1967/1/1','DAVID9','123456',5,true);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1985/8/4',48,89,5,15,5,0,5,'D');
INSERT INTO shyeld.participations VALUES(11,1,'P',0);
INSERT INTO shyeld.participations VALUES(12,1,'P',1);
INSERT INTO shyeld.participations VALUES(13,1,'N',2);
INSERT INTO shyeld.participations VALUES(14,1,'N',3);
INSERT INTO shyeld.participations VALUES(15,1,'G',4);
INSERT INTO shyeld.participations VALUES(16,1,'N',5);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1954/7/11',98,34,2,18,8,8,2,'D');
INSERT INTO shyeld.participations VALUES(12,2,'G',0);
INSERT INTO shyeld.participations VALUES(13,2,'N',1);
INSERT INTO shyeld.participations VALUES(14,2,'P',2);
INSERT INTO shyeld.participations VALUES(15,2,'G',3);
INSERT INTO shyeld.participations VALUES(16,2,'P',4);
INSERT INTO shyeld.participations VALUES(17,2,'G',5);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1966/12/27',35,48,8,12,2,5,5,'M');
INSERT INTO shyeld.participations VALUES(7,3,'P',0);
INSERT INTO shyeld.participations VALUES(8,3,'N',1);
INSERT INTO shyeld.participations VALUES(9,3,'N',2);
INSERT INTO shyeld.participations VALUES(10,3,'G',3);
INSERT INTO shyeld.participations VALUES(11,3,'P',4);
INSERT INTO shyeld.participations VALUES(12,3,'P',5);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1960/3/17',29,64,3,19,6,8,0,'M');
INSERT INTO shyeld.participations VALUES(6,4,'P',0);
INSERT INTO shyeld.participations VALUES(7,4,'N',1);
INSERT INTO shyeld.participations VALUES(8,4,'P',2);
INSERT INTO shyeld.participations VALUES(9,4,'P',3);
INSERT INTO shyeld.participations VALUES(10,4,'G',4);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1997/8/4',92,9,4,17,10,3,3,'M');
INSERT INTO shyeld.participations VALUES(1,5,'P',0);
INSERT INTO shyeld.participations VALUES(2,5,'P',1);
INSERT INTO shyeld.participations VALUES(3,5,'N',2);
INSERT INTO shyeld.participations VALUES(4,5,'G',3);
INSERT INTO shyeld.participations VALUES(5,5,'P',4);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1985/10/5',39,65,3,15,7,1,1,'M');
INSERT INTO shyeld.participations VALUES(1,6,'G',0);
INSERT INTO shyeld.participations VALUES(2,6,'G',1);
INSERT INTO shyeld.participations VALUES(3,6,'N',2);
INSERT INTO shyeld.participations VALUES(4,6,'P',3);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1957/10/12',21,89,8,20,3,1,5,'M');
INSERT INTO shyeld.participations VALUES(4,7,'G',0);
INSERT INTO shyeld.participations VALUES(5,7,'G',1);
INSERT INTO shyeld.participations VALUES(6,7,'G',2);
INSERT INTO shyeld.participations VALUES(7,7,'N',3);
INSERT INTO shyeld.participations VALUES(8,7,'P',4);
INSERT INTO shyeld.participations VALUES(9,7,'G',5);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1999/8/26',53,16,1,18,5,4,3,'D');
INSERT INTO shyeld.participations VALUES(10,8,'P',0);
INSERT INTO shyeld.participations VALUES(11,8,'P',1);
INSERT INTO shyeld.participations VALUES(12,8,'P',2);
INSERT INTO shyeld.participations VALUES(13,8,'N',3);
INSERT INTO shyeld.participations VALUES(14,8,'P',4);
INSERT INTO shyeld.participations VALUES(15,8,'P',5);
INSERT INTO shyeld.participations VALUES(16,8,'P',6);
INSERT INTO shyeld.participations VALUES(17,8,'N',7);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1981/12/22',78,51,8,18,7,10,5,'M');
INSERT INTO shyeld.participations VALUES(10,9,'N',0);
INSERT INTO shyeld.participations VALUES(11,9,'G',1);
INSERT INTO shyeld.participations VALUES(12,9,'P',2);
INSERT INTO shyeld.participations VALUES(13,9,'P',3);
INSERT INTO shyeld.participations VALUES(14,9,'P',4);
INSERT INTO shyeld.participations VALUES(15,9,'N',5);

INSERT INTO shyeld.combats VALUES(DEFAULT,'1973/10/24',81,39,7,8,10,0,1,'D');
INSERT INTO shyeld.participations VALUES(7,10,'N',0);
INSERT INTO shyeld.participations VALUES(8,10,'P',1);
INSERT INTO shyeld.participations VALUES(9,10,'P',2);
INSERT INTO shyeld.participations VALUES(10,10,'G',3);
INSERT INTO shyeld.participations VALUES(11,10,'G',4);
INSERT INTO shyeld.participations VALUES(12,10,'G',5);
INSERT INTO shyeld.participations VALUES(13,10,'P',6);


INSERT INTO shyeld.reperages VALUES(DEFAULT,4,4,76,9,'1954/8/10');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,15,5,65,'1988/9/12');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,12,71,10,'1977/7/6');
INSERT INTO shyeld.reperages VALUES(DEFAULT,2,9,24,65,'1973/4/8');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,5,27,44,'1994/9/18');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,2,38,100,'1957/5/10');
INSERT INTO shyeld.reperages VALUES(DEFAULT,7,5,37,17,'1982/5/19');
INSERT INTO shyeld.reperages VALUES(DEFAULT,10,3,2,16,'1984/8/9');
INSERT INTO shyeld.reperages VALUES(DEFAULT,7,17,35,90,'1959/12/2');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,11,62,38,'1956/12/25');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,15,15,20,'1983/10/20');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,14,97,6,'1951/3/27');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,19,83,38,'1983/3/25');
INSERT INTO shyeld.reperages VALUES(DEFAULT,2,16,100,61,'1978/3/27');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,2,93,82,'1990/5/8');

/***************************************** APPEL FONCTIONS ***********************************************************************/
SELECT * FROM shyeld.historiqueCombatsAgent( now()::timestamp- interval '2000000000 min', now()::timestamp);

SELECT creation_superhero('GUILLAUME','Thomas','Adamo','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Silicon manipulation',9,26,94,'1955/3/14','M',12,15,true);

