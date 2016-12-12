DROP VIEW IF EXISTS shyeld.classementVictoires;

CREATE VIEW shyeld.classementVictoires AS
SELECT s.nombre_victoires, s.id_superhero, s.nom_superhero
FROM shyeld.superheros s
WHERE s.est_vivant='TRUE'
ORDER BY s.nombre_victoires DESC;