DROP VIEW IF EXISTS shyeld.zone_conflit;

CREATE VIEW shyeld.zone_conflit AS
SELECT DISTINCT s.derniere_coordonneeX, s.derniere_coordonneeY
FROM shyeld.superheros s, shyeld.superheros s1
WHERE s.clan <> s1.clan
AND ((s.derniere_coordonneeX = s1.derniere_coordonneeX AND s.derniere_coordonneeY = s1.derniere_coordonneeY)
	OR (s.derniere_coordonneeX = s1.derniere_coordonneeX + 1 AND s.derniere_coordonneeY = s1.derniere_coordonneeY)
	OR (s.derniere_coordonneeX = s1.derniere_coordonneeX - 1 AND s.derniere_coordonneeY = s1.derniere_coordonneeY)
	OR (s.derniere_coordonneeX = s1.derniere_coordonneeX AND s.derniere_coordonneeY = s1.derniere_coordonneeY + 1)
	OR (s.derniere_coordonneeX = s1.derniere_coordonneeX AND s.derniere_coordonneeY = s1.derniere_coordonneeY - 1))
AND EXTRACT(DAY FROM NOW() - s.date_derniere_apparition) <= 10
AND EXTRACT(DAY FROM NOW() - s1.date_derniere_apparition) <= 10
ORDER BY s.derniere_coordonneeX;