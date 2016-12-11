GRANT CONNECT
ON DATABASE dbdmeur15
TO csacre15;

GRANT USAGE
ON SCHEMA shyeld
TO csacre15;

GRANT SELECT ON
shyeld.combats,
shyeld.participations,
shyeld.reperages,
shyeld.superheros,
shyeld.agents
TO csacre15;

GRANT TRIGGER ON
shyeld.combats,
shyeld.participations,
shyeld.superheros,
shyeld.reperages
TO csacre15;

GRANT INSERT ON
shyeld.reperages,
shyeld.combats,
shyeld.participations,
shyeld.superheros
TO csacre15;

GRANT UPDATE ON
shyeld.superheros,
shyeld.combats
TO csacre15;

GRANT EXECUTE ON FUNCTION
shyeld.rechercherSuperHerosParNomSuperHero(VARCHAR),
shyeld.creation_superhero(varchar, varchar, varchar, varchar, varchar, varchar, integer, integer, integer, timestamp,varchar , integer, integer, boolean),
shyeld.creation_reperage(integer, integer, integer, integer, timestamp),
shyeld.creation_combat(timestamp, integer, integer, integer, integer, integer, integer, integer),
shyeld.creation_participation(integer, integer, varchar),
shyeld.supprimerSuperHeros(INTEGER),
shyeld.rechercherSuperHerosParNomSuperHero(varchar),
shyeld.verificationAuthenticiteCombat(),
shyeld.miseAJourDateCoordonneeReperage(),
shyeld.reperageCombat(),
shyeld.miseAJourNombreVictoiresDefaites()
TO csacre15;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA shyeld TO csacre15;
