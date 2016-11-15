DROP SCHEMA shyeld CASCADE;
DROP TYPE type_clan;
DROP TYPE type_issue;

CREATE SCHEMA shyeld;

CREATE TYPE type_clan AS ENUM('M','D');
CREATE TYPE type_issue AS ENUM('G','P','N');

CREATE TABLE shyeld.superheros(
	id_superhero bigserial PRIMARY KEY,
	nom_civil varchar(255) CHECK (nom_civil != '' AND nom_civil SIMILAR TO ('%[a-zA-Z0-9]%')),
	prenom_civil varchar(255) CHECK	(prenom_civil != '' AND prenom_civil SIMILAR TO ('%[a-zA-Z0-9]%')),
	nom_superhero varchar(255) NOT NULL CHECK (nom_superhero != '' AND nom_superhero SIMILAR TO ('%[a-zA-Z0-9]%')),
	adresse_privee varchar(255) CHECK (adresse_privee != '' AND adresse_privee SIMILAR TO ('%[a-zA-Z0-9]%')),
	origine varchar(255) CHECK (origine != '' AND origine SIMILAR TO ('%[a-zA-Z0-9]%')),
	type_super_pouvoir varchar(255) NOT NULL CHECK (type_super_pouvoir != '' AND type_super_pouvoir SIMILAR TO ('%[a-zA-Z0-9]%')),
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

CREATE TABLE shyeld.agents(
	id_agent bigserial primary key,
	prenom varchar(255) NOT NULL CHECK(prenom <>'' AND prenom SIMILAR TO ('%[a-zA-Z0-9]%')),
	nom varchar(255) NOT NULL CHECK (nom<> ''  AND nom SIMILAR TO ('%[a-zA-Z0-9]%')),
	date_mise_en_service TIMESTAMP NOT NULL CHECK(date_mise_en_service <= now()),
	est_actif boolean NOT NULL
);

CREATE TABLE shyeld.combats(
	id_combat bigserial PRIMARY KEY,
	date_combat timestamp NOT NULL CHECK (date_combat <= now()),
	coord_combatX integer NOT NULL CHECK (coord_combatX >= 0 AND coord_combatX <= 100),
	coord_combatY integer NOT NULL CHECK (coord_combatY >= 0 AND coord_combatY <= 100),
	agent bigserial NOT NULL REFERENCES shyeld.agents(id_agent)
);

CREATE TABLE shyeld.participations(
	superhero bigserial NOT NULL REFERENCES shyeld.superheros(id_superhero),
	combat bigserial NOT NULL REFERENCES shyeld.combats(id_combat),
	issue type_issue NOT NULL DEFAULT 'N',
	PRIMARY KEY (superhero, combat)                                                                                                                                     
);

CREATE TABLE shyeld.reperages(
	id_reperage bigserial primary key,
	agent bigserial NOT NULL references shyeld.agents(id_agent),
	superhero bigserial NOT NULL references shyeld.superheros(id_superhero),
	coord_x integer NOT NULL CHECK (coord_x>=0 AND coord_x<=100),
	coord_y integer NOT NULL CHECK (coord_y >=0 AND coord_y <=100)
	
);