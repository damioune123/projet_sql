DROP SCHEMA IF EXISTS shyeld CASCADE;
CREATE SCHEMA shyeld;

CREATE TYPE shyeld.type_clan AS ENUM('M','D');
CREATE TYPE shyeld.type_issue AS ENUM('G','P','N');
CREATE TYPE shyeld.listeReperagesAgent AS (id_superhero INTEGER, nom_superhero varchar(255), coord_x  INTEGER, coord_y  INTEGER, date timestamp);
CREATE TYPE shyeld.listeCombatsParticipations AS (id_combat INTEGER, date_combat TIMESTAMP, coord_combatX INTEGER, coord_combatY INTEGER, nombre_participants INTEGER, 
							nombre_gagnants INTEGER, nombre_neutres INTEGER , id_superhero INTEGER, nom_superhero varchar(255), issue
							shyeld.type_issue);
							
CREATE TYPE shyeld.affichageInfoSuperHero AS (id_superhero INTEGER, nom_civil varchar(255), prenom_civil varchar(255), nom_superhero varchar(255),
		 adresse_privee varchar(255), origine varchar(255), type_super_pouvoir VARCHAR(255), puissance_super_pouvoir INTEGER
		 , derniere_coordonneeX INTEGER, derniere_coordonneeY INTEGER, date_derniere_apparition TIMESTAMP,
		 clan shyeld.type_clan, nombre_victoires INTEGER,nombre_defaites INTEGER, est_vivant boolean);


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
	mdp_bcrypt varchar(512) NOT NULL CHECK (mdp_bcrypt<> ''),
	nbre_rapport INTEGER NOT NULL CHECK (nbre_rapport >=0) DEFAULT 0,
	est_actif boolean NOT NULL,
	unique(identifiant)
);

CREATE TABLE shyeld.combats(
	id_combat serial PRIMARY KEY,
	date_combat timestamp NOT NULL CHECK (date_combat <= now()),
	coord_combatX integer NOT NULL CHECK (coord_combatX >= 0 AND coord_combatX <= 100),
	coord_combatY integer NOT NULL CHECK (coord_combatY >= 0 AND coord_combatY <= 100),
	agent integer NOT NULL REFERENCES shyeld.agents(id_agent),
	nombre_participants integer NOT NULL CHECK (nombre_participants >= 0 AND nombre_participants >= (nombre_perdants + nombre_gagnants)),
	nombre_gagnants integer NOT NULL CHECK (nombre_gagnants >= 0 ),
	nombre_perdants integer NOT NULL CHECK (nombre_perdants >= 0),
	nombre_neutres integer NOT NULL CHECK (nombre_neutres >= 0)
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




/********************************************************* FUNCTIONS AND VIEWS - APPLICATION SHYELD **************************************************/
-- Partie 1 inscription agent
CREATE OR REPLACE FUNCTION shyeld.inscription_agent(varchar(255), varchar(255), VARCHAR(255), VARCHAR(512)) RETURNS integer as $$
DECLARE
	_nomAgent ALIAS FOR $1;
	_prenomAgent ALIAS FOR $2;
	_identifiantAgent ALIAS FOR $3;
	_mdpAgent ALIAS FOR $4;
	_id integer := 0;
BEGIN
	INSERT INTO shyeld.agents VALUES(DEFAULT, _prenomAgent, _nomAgent, now(), _identifiantAgent, _mdpAgent,DEFAULT, true) RETURNING id_agent INTO _id;
	RETURN _id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'agent incorrect';
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
	UPDATE shyeld.agents SET est_actif = 'false' WHERE id_agent= _agentId;
	RETURN _agentId;
END;
$$ LANGUAGE plpgsql;

--- PARTIE 2.bis check connexion agent ---

CREATE OR REPLACE FUNCTION shyeld.check_connexion(varchar(255)) RETURNS VARCHAR(512) as $$
DECLARE
	_identifiant ALIAS FOR $1;
	_mdp VARCHAR(512);
BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.agents a WHERE a.identifiant = _identifiant AND a.est_actif = TRUE) THEN
		RETURN NULL; 
	END IF;
	SELECT a.mdp_bcrypt INTO _mdp FROM shyeld.agents a WHERE a.identifiant = _identifiant AND a.est_actif = TRUE ; 
	RETURN _mdp;
	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'login echoue';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION shyeld.get_agent(varchar(255)) RETURNS integer as $$
DECLARE
	_identifiant ALIAS FOR $1;
	_id integer := 0;
BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.agents a WHERE a.identifiant = _identifiant AND a.est_actif = TRUE) THEN
		RETURN NULL; 
	END IF;
	SELECT a.id_agent INTO _id FROM shyeld.agents a WHERE a.identifiant = _identifiant AND a.est_actif = TRUE ; 
		RETURN _id;
	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'get echoue';
END;
$$ LANGUAGE plpgsql;

--partie 3 information de pertes de visibilité

DROP VIEW IF EXISTS shyeld.perte_visibilite;

CREATE VIEW shyeld.perte_visibilite AS
SELECT DISTINCT sh.id_superhero, sh.nom_superhero, sh.date_derniere_apparition, sh.derniere_coordonneeX, sh.derniere_coordonneeY
FROM shyeld.superheros sh
WHERE (date_part('year', age(sh.date_derniere_apparition)) >= 1
	OR date_part('month', age(sh.date_derniere_apparition)) >= 1
	OR date_part('day', age(sh.date_derniere_apparition)) > 15)
	AND sh.est_vivant = TRUE;

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

DROP VIEW IF EXISTS shyeld.zone_conflit;

CREATE VIEW shyeld.zone_conflit AS
SELECT r.id_reperage, r.superhero, r.coord_x , r.coord_y,  (r.coord_x +1) as coord_x_est, r.coord_y as coord_y_est,  (r.coord_x-1) as coord_x_ouest , r.coord_y as coord_y_ouest,  r.coord_x  as coord_x_nord,
	(r.coord_y +1) as coord_y_nord,  r.coord_x as coord_x_sud, (r.coord_y -1) as coord_y_sud
FROM shyeld.reperages r, shyeld.superheros s 
WHERE r.superhero = s.id_superhero
AND (date_part('year', age(s.date_derniere_apparition)) < 1 
     OR date_part('month', age(s.date_derniere_apparition)) < 1
     OR date_part('day', age(s.date_derniere_apparition)) < 10)
     AND s.clan='D'
     AND s.est_vivant = 'TRUE'
     GROUP BY r.id_reperage
     HAVING 1 <= (SELECT count(s1.id_superhero)
		  FROM shyeld.superheros s1, shyeld.reperages r1
		  where r1.coord_x = r.coord_x
			AND r1.coord_y = r.coord_y
			AND (date_part('year', age(s1.date_derniere_apparition)) < 1 
			     OR date_part('month', age(s1.date_derniere_apparition)) < 1
			     OR date_part('day', age(s1.date_derniere_apparition)) < 10)
			AND s1.id_superhero = r1.superhero
			AND s1.est_vivant = 'TRUE'
			AND s1.clan ='D');


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

DROP VIEW IF EXISTS shyeld.classementVictoires;

CREATE VIEW shyeld.classementVictoires AS
SELECT s.nombre_victoires, s.id_superhero, s.nom_superhero
FROM shyeld.superheros s
WHERE s.est_vivant
ORDER BY s.nombre_victoires DESC;

DROP VIEW IF EXISTS shyeld.classementDefaites;

CREATE VIEW shyeld.classementDefaites AS
SELECT s.nombre_defaites, s.id_superhero, s.nom_superhero
FROM shyeld.superheros s
WHERE s.est_vivant
ORDER BY s.nombre_defaites DESC;

/* ---> b) <--- */
CREATE VIEW shyeld.classementReperages AS

SELECT a.nom, a.prenom, count(r.id_reperage) as "reperages"
FROM shyeld.agents a, shyeld.reperages r 
WHERE a.id_agent = r.agent 
AND a.est_actif = TRUE 
GROUP BY a.id_agent
ORDER BY count(r.id_reperage) DESC; /* TO DO */

--partie SHYELD 7.c - statistiques : historique des combats entre deux dates données, avec la liste des participants, des perdants et des gagnants

CREATE OR REPLACE FUNCTION shyeld.historiqueCombatsParticipations(TIMESTAMP, TIMESTAMP) RETURNS SETOF
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
					_combat.nombre_neutres , _participation.superhero, _superhero.nom_superhero, _participation.issue INTO _sortie;
				RETURN NEXT _sortie;
			END LOOP;
		END LOOP;		
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;


/********************************************************* FUNCTIONS AND VIEWS - APPLICATION AGENT**************************************************/
--partie 1 : info super héro sur base du nom
CREATE OR REPLACE FUNCTION shyeld.rechercherSuperHerosParNomSuperHero(varchar(255)) RETURNS SETOF shyeld.affichageInfoSuperHero as $$
DECLARE
	_nomSuperHero ALIAS FOR $1;
	_superhero RECORD;
	_sortie shyeld.affichageInfoSuperHero;
BEGIN
	FOR _superhero IN SELECT * FROM shyeld.superheros s  WHERE lower(s.nom_superhero) LIKE ('%'|| lower(_nomSuperHero) ||'%') AND s.est_vivant ='TRUE' LOOP
		SELECT _superhero.id_superhero, _superhero.nom_civil, _superhero.prenom_civil, _superhero.nom_superhero,
		 _superhero.adresse_privee, _superhero.origine,_superhero.type_super_pouvoir, _superhero.puissance_super_pouvoir
		 , _superhero.derniere_coordonneeX, _superhero.derniere_coordonneeY, _superhero.date_derniere_apparition,
		 _superhero.clan, _superhero.nombre_victoires,_superhero.nombre_defaites, _superhero.est_vivant INTO _sortie;
		RETURN NEXT _sortie;
	END LOOP;
	RETURN;
END;
$$ LANGUAGE plpgsql;

-- partie 2 création d'un super-héro

CREATE OR REPLACE FUNCTION shyeld.creation_superhero(varchar, varchar, varchar, varchar, varchar, varchar, integer, integer, integer, timestamp,
 varchar , integer, integer, boolean) RETURNS integer as $$
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
	_clanInsert shyeld.type_clan;
BEGIN
	IF _clan <> 'M' AND _clan <> 'D' THEN
		RAISE 'type incorrect';
	ELSE
		_clanInsert := _clan;
	END IF;

	IF EXISTS (SELECT s.* FROM shyeld.superheros s WHERE s.nom_superhero = _nomSuperHero AND s.est_vivant = 'TRUE') THEN
		RAISE foreign_key_violation;
	END IF;

	INSERT INTO shyeld.superheros VALUES (DEFAULT, _nom, _prenom, _nomSuperHero, _adressePrivee, _origine, _typeSuperPouvoir, _puissanceSuperPouvoir,
		_coordX, _coordY, _date, _clanInsert, _nombreVictoires, _nombreDefaites, _estVivant) RETURNING id_superhero INTO _id;
	RETURN _id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'superhero incorrect';
END;
$$ LANGUAGE plpgsql;



-- PARTIE 3 :  création repérage

CREATE OR REPLACE FUNCTION shyeld.creation_reperage(integer, integer, integer, integer, timestamp) RETURNS integer as $$
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


--partie 4 rapport de combats agents
--- PARTIE 4.a creation combat ---

CREATE OR REPLACE FUNCTION shyeld.creation_combat(timestamp, integer, integer, integer, integer, integer, integer, integer) RETURNS integer as $$
DECLARE
	_date ALIAS FOR $1;
	_coordX ALIAS FOR $2;
	_coordY ALIAS FOR $3;
	_agent ALIAS FOR $4;
	_nombreParticipants ALIAS FOR $5;
	_nombreGagnants ALIAS FOR $6;
	_nombrePerdants ALIAS FOR $7;
	_nombreNeutres ALIAS FOR $8;
	_id integer := 0;
BEGIN

	IF NOT EXISTS (SELECT a.* FROM shyeld.agents a WHERE a.id_agent = _agent AND a.est_actif = TRUE) THEN 
		RAISE foreign_key_violation;
	END IF;

	INSERT INTO shyeld.combats VALUES (DEFAULT, _date, _coordX, _coordY, _agent, _nombreParticipants,
	 _nombreGagnants, _nombrePerdants, _nombreNeutres) RETURNING id_combat INTO _id;
	RETURN _id;

	EXCEPTION
		WHEN check_violation THEN RAISE EXCEPTION 'combat incorrect';
END;
$$ LANGUAGE plpgsql;

--- PARTIE 4.b creation participation ---

CREATE OR REPLACE FUNCTION shyeld.creation_participation(integer, integer, varchar) RETURNS integer as $$
DECLARE
	_superhero ALIAS FOR $1;
	_combat ALIAS FOR $2;
	_issue ALIAS FOR $3;
	_numLigne integer := 0;
	_issueInsert shyeld.type_issue;
BEGIN
	IF _issue <> 'G' AND _issue <> 'P' AND _issue <> 'N' THEN
		RAISE 'type incorrect';
	ELSE
		_issueInsert := _issue;
	END IF;

	IF NOT EXISTS (SELECT s.* FROM shyeld.superheros s WHERE s.id_superhero = _superhero AND s.est_vivant='TRUE') THEN
		RAISE foreign_key_violation;
	END IF;

	IF NOT EXISTS (SELECT c.* FROM shyeld.combats c WHERE c.id_combat = _combat) THEN
		RAISE foreign_key_violation;
	END IF;

	_numLigne:=(SELECT count(p.numero_ligne) as "nombre_ligne" FROM shyeld.participations p WHERE p.combat = _combat);

	INSERT INTO shyeld.participations VALUES (_superhero, _combat, _issueInsert, _numLigne);

	RETURN _numLigne;

	EXCEPTION 
		WHEN check_violation THEN RAISE EXCEPTION 'participation incorrecte';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION shyeld.check_si_combat(timestamp, integer, integer) RETURNS integer as $$
DECLARE 
	_date ALIAS FOR $1;
	_coordX ALIAS FOR $2;
	_coordY ALIAS FOR $3;
BEGIN
	IF EXISTS (SELECT c.* FROM shyeld.combats c WHERE c.date_combat = _date AND c.coord_combatX = _coordX AND c.coord_combatY = _coordY) THEN
		RETURN (SELECT c.id_combat FROM shyeld.combats c WHERE c.date_combat = _date AND c.coord_combatX = _coordX AND c.coord_combatY = _coordY);
	END IF;

	RETURN -1;

	EXCEPTION
			WHEN check_violation THEN RAISE EXCEPTION 'erreur fonction';
END;
$$ LANGUAGE plpgsql;
/***************************************** TRIGGERS ***********************************************************************/
--  MAJ CHAMP nombre_victoires /nombres_defaites de la table shyeld.superheros
CREATE OR REPLACE FUNCTION shyeld.miseAJourNombreVictoiresDefaites()  RETURNS TRIGGER AS $$
BEGIN
	IF(NEW.issue ='G') THEN
		UPDATE shyeld.superheros SET nombre_victoires = nombre_victoires +1 WHERE id_superhero = NEW.superhero;
		RETURN NEW;
	ELSIF (NEW.issue ='P' )THEN
		UPDATE shyeld.superheros SET nombre_defaites = nombre_defaites +1 WHERE id_superhero = NEW.superhero;
		RETURN NEW;
	ELSIF (NEW.issue ='N' )THEN
		RETURN NEW;
	END IF;
	

END;
$$  LANGUAGE plpgsql; 

CREATE TRIGGER trigger_nbre_victoires_defaites AFTER INSERT ON shyeld.participations
FOR EACH ROW
EXECUTE PROCEDURE shyeld.miseAJourNombreVictoiresDefaites();

--  Création d'un tupe repérage en cas d'insertion d'une participation à un combat dans la bddn
CREATE OR REPLACE FUNCTION shyeld.reperageCombat()  RETURNS TRIGGER AS $$
DECLARE
	_combat RECORD;
	
BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.combats c WHERE c.id_combat = NEW.combat) THEN RAISE foreign_key_violation;
	END IF;
	FOR _combat IN SELECT c.*  FROM shyeld.combats c WHERE  c.id_combat = NEW.combat LOOP
		PERFORM shyeld.creation_reperage(_combat.agent, NEW.superhero, _combat.coord_combatX, _combat.coord_combatY ,_combat.date_combat);
	END LOOP;
	RETURN NEW;
		
	
		
END;
$$  LANGUAGE plpgsql; 

CREATE TRIGGER trigger_reperageCombat AFTER INSERT ON shyeld.participations
FOR EACH ROW
EXECUTE PROCEDURE shyeld.reperageCombat(); 

--- MAJ champ date apparition et dernieres coordonnees de la table shyeld.superheros ---
CREATE OR REPLACE FUNCTION shyeld.miseAJourDateCoordonneeReperage() RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS (SELECT s.* FROM shyeld.superheros s WHERE s.id_superhero = NEW.superhero) THEN
		RAISE foreign_key_violation;
	END IF;

 	UPDATE shyeld.superheros SET date_derniere_apparition = NEW.date, derniere_coordonneeX = NEW.coord_x,
 	 derniere_coordonneeY = NEW.coord_y WHERE id_superhero = NEW.superhero;
 	 	RETURN NEW;
 
 	 EXCEPTION
 	 	WHEN check_violation THEN RAISE EXCEPTION 'trigger date - coord superhero incorrect';
 END;
 $$LANGUAGE plpgsql;
 
 
 
 CREATE TRIGGER trigger_reperage_coordonnee AFTER INSERT ON shyeld.reperages
 FOR EACH ROW
 EXECUTE PROCEDURE shyeld.miseAJourDateCoordonneeReperage();

--  Vérification authenticité d'un combat : au moins deux héros de factions adverses + participations gagnantes correspond au clan vainqueur et paricipations perdantes correspondent au clant perdant
CREATE OR REPLACE FUNCTION shyeld.verificationAuthenticiteCombat()  RETURNS TRIGGER AS $$
DECLARE
	_participation RECORD;
	_superhero RECORD;
	_compteurMarvelle integer := 0;
	_compteurDece integer := 0;

BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.participations p WHERE p.combat = NEW.id_combat) THEN RAISE foreign_key_violation;
	END IF;
	FOR _participation IN SELECT p.*  FROM shyeld.participations p WHERE p.combat = NEW.id_combat LOOP
		IF 'M' = (SELECT s.clan FROM shyeld.superheros s WHERE s.id_superhero = _participation.superhero) THEN
			_compteurMarvelle := _compteurMarvelle + 1;
		ELSE
			_compteurDece := _compteurDece +1;
		END IF;
		UPDATE shyeld.combats SET nombre_participants = nombre_participants + 1 WHERE id_combat = _participation.combat;
		IF 'G' = _participation.issue THEN
			UPDATE shyeld.combats SET nombre_gagnants = nombre_gagnants + 1 WHERE id_combat = _participation.combat;
		ELSIF 'P' = _participation.issue THEN
			UPDATE shyeld.combats SET nombre_perdants = nombre_perdants + 1 WHERE id_combat = _participation.combat;
		ELSE
			UPDATE shyeld.combats SET nombre_neutres = nombre_neutres + 1 WHERE id_combat = _participation.combat;
		END IF;
	END LOOP;
	IF (_compteurDece <= 0 OR _compteurMarvelle <= 0) THEN
		RAISE 'Deux clans adverses sont requis pour le même combat';
	END IF;
	RETURN NEW;
		
END;
$$  LANGUAGE plpgsql; 

CREATE CONSTRAINT TRIGGER trigger_authenticiteCombat AFTER INSERT ON shyeld.combats
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE shyeld.verificationAuthenticiteCombat(); 


/********************************************************* FONCTIONS ET VUES - DIVERS - HORS ENONCE **************************************************/

--affichage de tous les agents actifs
DROP VIEW IF EXISTS shyeld.affichageAgents;

CREATE VIEW shyeld.affichageAgents AS

SELECT a.*
FROM shyeld.agents a
WHERE a.est_actif = 'TRUE';

--affichage de tous les combats sans les participations
DROP VIEW IF EXISTS shyeld.affichageCombats;

CREATE VIEW shyeld.affichageCombats AS

SELECT c.*
FROM shyeld.combats c;

--affichage de tous les reperages
DROP VIEW IF EXISTS shyeld.affichageReperages;

CREATE VIEW shyeld.affichageReperages AS

SELECT r.*
FROM shyeld.reperages r;
/*********************************************************SIGNIN, ACCESS AND APP_USERS **************************************************/

/*
GRANT CONNECT
ON DATABASE dbdmeur15
TO csacre15;

GRANT USAGE
ON SCHEMA shyeld
TO csacre15;

GRANT SELECT ON
shyeld.reperages,
shyeld.combats,
shyeld.participations,
shyeld.superheros,
shyeld.agents
TO csacre15;

GRANT INSERT ON
shyeld.reperages,
shyeld.combats,
shyeld.participations,
shyeld.superheros
TO csacre15;

GRANT UPDATE ON
shyeld.superheros
TO csacre15;

GRANT EXECUTE ON FUNCTION
shyeld.rechercherSuperHerosParNomSuperHero(VARCHAR),
shyeld.creation_superhero(varchar, varchar, varchar, varchar, varchar, varchar, integer, integer, integer, timestamp,varchar , integer, integer, boolean),
shyeld.creation_reperage(integer, integer, integer, integer, timestamp),
shyeld.creation_combat(timestamp, integer, integer, integer, integer, integer, integer, integer, varchar),
shyeld.creation_participation(integer, integer, varchar),
shyeld.supprimerSuperHeros(INTEGER),
shyeld.rechercherSuperHerosParNomSuperHero(varchar),
shyeld.verificationAuthenticiteCombat(),
shyeld.miseAJourDateCoordonneeReperage()
TO csacre15;
*/

/************************************** INSERT INTO (META DONNEES) **************************************************************/
INSERT INTO shyeld.superheros VALUES(DEFAULT,'NICOLAS','Justine','A-Bomb','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Microwave emission',6,47,4,'2014/11/22','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LECLERC','Tommy','Abe','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Metallic sweat',9,62,37,'2006/11/2','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'SCHNEIDER','Christopher','Sapien','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Precognitive dreaming',4,57,21,'2013/7/14','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'SIMON','Malik','Abin','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Acid secretion',3,84,89,'2011/12/14','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BESSON','Christopher','Sur','Pour le moment pas d idees 35 1000 Bruxelles','Experiences','Mediumship',3,60,2,'2008/4/22','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'GRONDIN','�ve','Abomination','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Puppet master',10,75,50,'2015/6/24','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PIERRE','Clara','Abraxas','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Seismic burst',10,47,69,'2009/4/20','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MONNIER','Sarah','Absorbing','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Freezing',6,91,17,'2000/9/12','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'BARBIER','Marianne','Man','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Sound manipulation',3,14,22,'2007/9/20','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MARIE','Delphine','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Adoptive muscle memory',7,69,36,'2012/9/23','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'RENARD','Christopher','Monroe','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Freezing',3,41,34,'2004/10/16','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MICHAUD','Julien','Adam','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Green energy blast',1,68,56,'2008/11/13','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'LEFEVRE','Malik','Strange','Pour le moment pas d idees 35 1000 Bruxelles','Genetique','Empathic manipulation',2,28,23,'2012/10/3','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROUSSEL','Jade','Bob','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Acid secretion',10,65,48,'2002/9/19','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROUSSEL','Louis','Zero','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel cach�','Shifting',4,82,53,'2012/8/22','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'MAILLARD','Marianne','Air-Walker','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Astral vision',9,66,41,'2000/10/14','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'PICARD','Delphine','Ajax','Pour le moment pas d idees 35 1000 Bruxelles','Potentiel cach�','Alejandro_s ability',3,37,100,'2013/12/22','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'ROUSSEL','Gabrielle','Alan','Pour le moment pas d idees 35 1000 Bruxelles','Alien','Ability absorption',4,1,32,'2005/8/23','D',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'NICOLAS','L�anne','Scott','Pour le moment pas d idees 35 1000 Bruxelles','Entrainement','Enhanced synesthesia',2,71,47,'2015/2/9','M',0,0,true);
INSERT INTO shyeld.superheros VALUES(DEFAULT,'DUMAS','Emy','Alex','Pour le moment pas d idees 35 1000 Bruxelles','Parasite','Temperature manipulation',4,28,4,'2007/3/4','D',0,0,true);

INSERT INTO shyeld.agents VALUES(DEFAULT,'Alex','RENAUD','2002/12/22','RENAUD1','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',20,true); --azerty en bcrypt
INSERT INTO shyeld.agents VALUES(DEFAULT,'Benjamin','CHEVALIER','2012/4/23','CHEVALIER2','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',0,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Mathis','DUFOUR','2000/6/11','DUFOUR3','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',3,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Mathieu','BARTHELEMY','2005/6/9','BARTHELEMY4','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',10,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Logan','DUBOIS','2013/11/2','DUBOIS5','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',14,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Alice','GUICHARD','2000/2/4','GUICHARD6','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',16,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'M�lodie','DENIS','2012/5/10','DENIS7','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',10,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Delphine','LEGRAND','2002/3/4','LEGRAND8','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',17,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'Jacob','BARON','2013/10/13','BARON9','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',16,true);
INSERT INTO shyeld.agents VALUES(DEFAULT,'L�a','ETIENNE','2003/10/24','ETIENNE10','$2a$10$mb9Wc1amuo0SR0cmUfOlxe1DC/g9d8ML/pQrotjCX7T7FefrPD3vC',11,true);

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2009/7/12',7,21,4,15,3,1,11);
INSERT INTO shyeld.participations VALUES(6,1,'G',0);
INSERT INTO shyeld.participations VALUES(19,1,'G',1);
INSERT INTO shyeld.participations VALUES(2,1,'G',2);
INSERT INTO shyeld.participations VALUES(10,1,'P',3);
INSERT INTO shyeld.participations VALUES(4,1,'N',4);
INSERT INTO shyeld.participations VALUES(7,1,'N',5);
INSERT INTO shyeld.participations VALUES(15,1,'N',6);
INSERT INTO shyeld.participations VALUES(16,1,'N',7);
INSERT INTO shyeld.participations VALUES(13,1,'N',8);
INSERT INTO shyeld.participations VALUES(14,1,'N',9);
INSERT INTO shyeld.participations VALUES(5,1,'N',10);
INSERT INTO shyeld.participations VALUES(1,1,'N',11);
INSERT INTO shyeld.participations VALUES(20,1,'N',12);
INSERT INTO shyeld.participations VALUES(18,1,'N',13);
INSERT INTO shyeld.participations VALUES(12,1,'N',14);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2003/1/19',18,71,1,15,9,1,5);
INSERT INTO shyeld.participations VALUES(1,2,'G',0);
INSERT INTO shyeld.participations VALUES(18,2,'G',1);
INSERT INTO shyeld.participations VALUES(5,2,'G',2);
INSERT INTO shyeld.participations VALUES(12,2,'G',3);
INSERT INTO shyeld.participations VALUES(4,2,'G',4);
INSERT INTO shyeld.participations VALUES(7,2,'G',5);
INSERT INTO shyeld.participations VALUES(14,2,'G',6);
INSERT INTO shyeld.participations VALUES(13,2,'G',7);
INSERT INTO shyeld.participations VALUES(20,2,'G',8);
INSERT INTO shyeld.participations VALUES(8,2,'P',9);
INSERT INTO shyeld.participations VALUES(16,2,'N',10);
INSERT INTO shyeld.participations VALUES(10,2,'N',11);
INSERT INTO shyeld.participations VALUES(15,2,'N',12);
INSERT INTO shyeld.participations VALUES(17,2,'N',13);
INSERT INTO shyeld.participations VALUES(19,2,'N',14);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2006/4/24',58,79,5,14,1,10,3);
INSERT INTO shyeld.participations VALUES(6,3,'G',0);
INSERT INTO shyeld.participations VALUES(15,3,'P',1);
INSERT INTO shyeld.participations VALUES(7,3,'P',2);
INSERT INTO shyeld.participations VALUES(14,3,'P',3);
INSERT INTO shyeld.participations VALUES(1,3,'P',4);
INSERT INTO shyeld.participations VALUES(10,3,'P',5);
INSERT INTO shyeld.participations VALUES(12,3,'P',6);
INSERT INTO shyeld.participations VALUES(4,3,'P',7);
INSERT INTO shyeld.participations VALUES(5,3,'P',8);
INSERT INTO shyeld.participations VALUES(13,3,'P',9);
INSERT INTO shyeld.participations VALUES(16,3,'P',10);
INSERT INTO shyeld.participations VALUES(20,3,'N',11);
INSERT INTO shyeld.participations VALUES(18,3,'N',12);
INSERT INTO shyeld.participations VALUES(3,3,'N',13);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2015/11/19',16,77,4,11,2,3,6);
INSERT INTO shyeld.participations VALUES(7,4,'G',0);
INSERT INTO shyeld.participations VALUES(15,4,'G',1);
INSERT INTO shyeld.participations VALUES(17,4,'P',2);
INSERT INTO shyeld.participations VALUES(3,4,'P',3);
INSERT INTO shyeld.participations VALUES(8,4,'P',4);
INSERT INTO shyeld.participations VALUES(20,4,'N',5);
INSERT INTO shyeld.participations VALUES(14,4,'N',6);
INSERT INTO shyeld.participations VALUES(13,4,'N',7);
INSERT INTO shyeld.participations VALUES(16,4,'N',8);
INSERT INTO shyeld.participations VALUES(1,4,'N',9);
INSERT INTO shyeld.participations VALUES(18,4,'N',10);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2001/6/21',24,76,2,10,3,4,3);
INSERT INTO shyeld.participations VALUES(14,5,'G',0);
INSERT INTO shyeld.participations VALUES(12,5,'G',1);
INSERT INTO shyeld.participations VALUES(10,5,'G',2);
INSERT INTO shyeld.participations VALUES(2,5,'P',3);
INSERT INTO shyeld.participations VALUES(9,5,'P',4);
INSERT INTO shyeld.participations VALUES(8,5,'P',5);
INSERT INTO shyeld.participations VALUES(17,5,'P',6);
INSERT INTO shyeld.participations VALUES(16,5,'N',7);
INSERT INTO shyeld.participations VALUES(13,5,'N',8);
INSERT INTO shyeld.participations VALUES(20,5,'N',9);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2009/12/24',13,8,3,20,7,2,11);
INSERT INTO shyeld.participations VALUES(8,6,'G',0);
INSERT INTO shyeld.participations VALUES(17,6,'G',1);
INSERT INTO shyeld.participations VALUES(3,6,'G',2);
INSERT INTO shyeld.participations VALUES(9,6,'G',3);
INSERT INTO shyeld.participations VALUES(2,6,'G',4);
INSERT INTO shyeld.participations VALUES(11,6,'G',5);
INSERT INTO shyeld.participations VALUES(6,6,'G',6);
INSERT INTO shyeld.participations VALUES(5,6,'P',7);
INSERT INTO shyeld.participations VALUES(12,6,'P',8);
INSERT INTO shyeld.participations VALUES(4,6,'N',9);
INSERT INTO shyeld.participations VALUES(1,6,'N',10);
INSERT INTO shyeld.participations VALUES(20,6,'N',11);
INSERT INTO shyeld.participations VALUES(7,6,'N',12);
INSERT INTO shyeld.participations VALUES(13,6,'N',13);
INSERT INTO shyeld.participations VALUES(10,6,'N',14);
INSERT INTO shyeld.participations VALUES(15,6,'N',15);
INSERT INTO shyeld.participations VALUES(16,6,'N',16);
INSERT INTO shyeld.participations VALUES(18,6,'N',17);
INSERT INTO shyeld.participations VALUES(14,6,'N',18);
INSERT INTO shyeld.participations VALUES(19,6,'N',19);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2000/12/26',94,27,5,15,2,1,12);
INSERT INTO shyeld.participations VALUES(3,7,'G',0);
INSERT INTO shyeld.participations VALUES(6,7,'G',1);
INSERT INTO shyeld.participations VALUES(20,7,'P',2);
INSERT INTO shyeld.participations VALUES(18,7,'N',3);
INSERT INTO shyeld.participations VALUES(1,7,'N',4);
INSERT INTO shyeld.participations VALUES(7,7,'N',5);
INSERT INTO shyeld.participations VALUES(4,7,'N',6);
INSERT INTO shyeld.participations VALUES(10,7,'N',7);
INSERT INTO shyeld.participations VALUES(5,7,'N',8);
INSERT INTO shyeld.participations VALUES(13,7,'N',9);
INSERT INTO shyeld.participations VALUES(16,7,'N',10);
INSERT INTO shyeld.participations VALUES(15,7,'N',11);
INSERT INTO shyeld.participations VALUES(12,7,'N',12);
INSERT INTO shyeld.participations VALUES(14,7,'N',13);
INSERT INTO shyeld.participations VALUES(19,7,'N',14);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2002/10/26',19,22,2,16,3,1,12);
INSERT INTO shyeld.participations VALUES(19,8,'G',0);
INSERT INTO shyeld.participations VALUES(8,8,'G',1);
INSERT INTO shyeld.participations VALUES(9,8,'G',2);
INSERT INTO shyeld.participations VALUES(14,8,'P',3);
INSERT INTO shyeld.participations VALUES(20,8,'N',4);
INSERT INTO shyeld.participations VALUES(5,8,'N',5);
INSERT INTO shyeld.participations VALUES(4,8,'N',6);
INSERT INTO shyeld.participations VALUES(10,8,'N',7);
INSERT INTO shyeld.participations VALUES(7,8,'N',8);
INSERT INTO shyeld.participations VALUES(18,8,'N',9);
INSERT INTO shyeld.participations VALUES(15,8,'N',10);
INSERT INTO shyeld.participations VALUES(1,8,'N',11);
INSERT INTO shyeld.participations VALUES(16,8,'N',12);
INSERT INTO shyeld.participations VALUES(12,8,'N',13);
INSERT INTO shyeld.participations VALUES(13,8,'N',14);
INSERT INTO shyeld.participations VALUES(2,8,'N',15);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2014/2/4',37,5,1,18,7,3,8);
INSERT INTO shyeld.participations VALUES(18,9,'G',0);
INSERT INTO shyeld.participations VALUES(5,9,'G',1);
INSERT INTO shyeld.participations VALUES(13,9,'G',2);
INSERT INTO shyeld.participations VALUES(4,9,'G',3);
INSERT INTO shyeld.participations VALUES(12,9,'G',4);
INSERT INTO shyeld.participations VALUES(16,9,'G',5);
INSERT INTO shyeld.participations VALUES(1,9,'G',6);
INSERT INTO shyeld.participations VALUES(19,9,'P',7);
INSERT INTO shyeld.participations VALUES(2,9,'P',8);
INSERT INTO shyeld.participations VALUES(11,9,'P',9);
INSERT INTO shyeld.participations VALUES(15,9,'N',10);
INSERT INTO shyeld.participations VALUES(20,9,'N',11);
INSERT INTO shyeld.participations VALUES(14,9,'N',12);
INSERT INTO shyeld.participations VALUES(10,9,'N',13);
INSERT INTO shyeld.participations VALUES(7,9,'N',14);
INSERT INTO shyeld.participations VALUES(8,9,'N',15);
INSERT INTO shyeld.participations VALUES(9,9,'N',16);
INSERT INTO shyeld.participations VALUES(6,9,'N',17);
COMMIT;

BEGIN;
INSERT INTO shyeld.combats VALUES(DEFAULT,'2003/3/22',75,10,9,0,0,0,0);
INSERT INTO shyeld.participations VALUES(17,10,'G',0);
INSERT INTO shyeld.participations VALUES(2,10,'G',1);
INSERT INTO shyeld.participations VALUES(12,10,'P',2);
INSERT INTO shyeld.participations VALUES(14,10,'N',3);
INSERT INTO shyeld.participations VALUES(16,10,'N',4);
INSERT INTO shyeld.participations VALUES(1,10,'N',5);
INSERT INTO shyeld.participations VALUES(18,10,'N',6);
INSERT INTO shyeld.participations VALUES(15,10,'N',7);
INSERT INTO shyeld.participations VALUES(13,10,'N',8);
INSERT INTO shyeld.participations VALUES(7,10,'N',9);
INSERT INTO shyeld.participations VALUES(10,10,'N',10);
INSERT INTO shyeld.participations VALUES(5,10,'N',11);
INSERT INTO shyeld.participations VALUES(20,10,'N',12);
INSERT INTO shyeld.participations VALUES(4,10,'N',13);
INSERT INTO shyeld.participations VALUES(6,10,'N',14);
INSERT INTO shyeld.participations VALUES(19,10,'N',15);
INSERT INTO shyeld.participations VALUES(9,10,'N',16);
INSERT INTO shyeld.participations VALUES(3,10,'N',17);
INSERT INTO shyeld.participations VALUES(11,10,'N',18);
COMMIT;


INSERT INTO shyeld.reperages VALUES(DEFAULT,8,1,9,63,'2006/12/19');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,6,6,56,'2007/11/20');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,13,84,82,'2002/1/15');
INSERT INTO shyeld.reperages VALUES(DEFAULT,7,5,88,33,'2009/1/6');
INSERT INTO shyeld.reperages VALUES(DEFAULT,3,16,17,65,'2004/1/6');
INSERT INTO shyeld.reperages VALUES(DEFAULT,2,11,74,32,'2013/10/15');
INSERT INTO shyeld.reperages VALUES(DEFAULT,9,18,61,5,'2008/12/2');
INSERT INTO shyeld.reperages VALUES(DEFAULT,6,3,79,12,'2000/12/6');
INSERT INTO shyeld.reperages VALUES(DEFAULT,5,8,41,77,'2000/2/4');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,2,72,50,'2007/8/3');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,5,98,63,'2014/10/17');
INSERT INTO shyeld.reperages VALUES(DEFAULT,8,4,24,39,'2014/2/5');
INSERT INTO shyeld.reperages VALUES(DEFAULT,4,12,19,34,'2006/2/19');
INSERT INTO shyeld.reperages VALUES(DEFAULT,10,17,56,10,'2005/2/26');
INSERT INTO shyeld.reperages VALUES(DEFAULT,1,13,79,94,'2014/4/16');

/***************************************** APPEL FONCTIONS ***********************************************************************/

SELECT *  FROM shyeld.combats;