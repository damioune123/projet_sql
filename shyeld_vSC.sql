DROP SCHEMA shyeld CASCADE;
DROP TYPE type_clan;
DROP TYPE type_issue;
DROP TYPE listesReperagesAgent;

CREATE SCHEMA shyeld;

CREATE TYPE type_clan AS ENUM('M','D');
CREATE TYPE type_issue AS ENUM('G','P','N');
CREATE TYPE listesReperagesAgent AS (id_superhero INTEGER, nom_superhero varchar(255), coord_x  INTEGER, coord_y  INTEGER, date timestamp);

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
	clan type_clan NOT NULL,
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
	clan_vainqueur type_clan NOT NULL
);

CREATE TABLE shyeld.participations(
	superhero integer NOT NULL REFERENCES shyeld.superheros(id_superhero),
	combat integer NOT NULL REFERENCES shyeld.combats(id_combat),
	issue type_issue NOT NULL DEFAULT 'N',
	PRIMARY KEY (superhero, combat)                                                                                                                                     
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

-- PARTIE 6 Historique d'un agent
CREATE OR REPLACE FUNCTION shyeld.historiqueAgent(INTEGER, TIMESTAMP, TIMESTAMP) RETURNS SETOF
listesReperagesAgent as $$
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