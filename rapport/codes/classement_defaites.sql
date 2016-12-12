DROP VIEW IF EXISTS shyeld.classementDefaites;

CREATE VIEW shyeld.classementDefaites AS
SELECT s.nombre_defaites, s.id_superhero, s.nom_superhero
FROM shyeld.superheros s
WHERE s.est_vivant='TRUE'
ORDER BY s.nombre_defaites DESC;