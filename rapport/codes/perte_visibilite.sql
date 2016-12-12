DROP VIEW IF EXISTS shyeld.perte_visibilite;

CREATE VIEW shyeld.perte_visibilite AS
SELECT DISTINCT sh.id_superhero, sh.nom_superhero, sh.date_derniere_apparition, sh.derniere_coordonneeX, sh.derniere_coordonneeY
FROM shyeld.superheros sh
WHERE (date_part('year', age(sh.date_derniere_apparition)) >= 1
	OR date_part('month', age(sh.date_derniere_apparition)) >= 1
	OR date_part('day', age(sh.date_derniere_apparition)) > 15)
	AND sh.est_vivant = TRUE
ORDER BY sh.nom_superhero;