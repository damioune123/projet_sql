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
	est_vivant boolean NOT NULL,
	unique(nom_superhero)
);
INSERT INTO shyeld.superheros (id_superhero, nom_superhero, type_super_pouvoir, puissance_super_pouvoir, date_derniere_apparition, clan, nombre_victoires, nombre_defaites, est_vivant) 
	VALUES (1, 'captain america', 'feu', 2, now()::timestamp, 'M', 0,0, 'true');

CREATE TABLE shyeld.agents(
	id_agent serial primary key,
	prenom varchar(255) NOT NULL CHECK(prenom <>''),
	nom varchar(255) NOT NULL CHECK (nom<> ''),
	date_mise_en_service TIMESTAMP NOT NULL CHECK(date_mise_en_service <= now()),
	est_actif boolean NOT NULL
);
INSERT INTO shyeld.agents (id_agent, prenom, nom, date_mise_en_service, est_actif) VALUES (1, 'dams', 'lamif', now()::timestamp, 'true');

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
INSERT INTO shyeld.reperages (agent, superhero, coord_x, coord_y ,date) VALUES (1, 1, 5, 10, now()::TIMESTAMP);
INSERT INTO shyeld.reperages (agent, superhero, coord_x, coord_y ,date) VALUES (1, 1, 19, 20, now()::TIMESTAMP);
--partie 1 inscription agent

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
				AND (SELECT count(DISTINCT s1.clan) 
					FROM shyeld.reperages r1, shyeld.superheros s1
					WHERE r1.superhero = s1.id_superhero) LOOP
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
CREATE OR REPLACE FUNCTION shyeld.historiqueAgent(INTEGER, TIMESTAMP, TIMESTAMP) RETURNS SETOF
shyeld.listesReperagesAgent as $$
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
SELECT * FROM shyeld.historiqueAgent(1, now()::timestamp- interval '200 min', now()::timestamp);


