DROP VIEW IF EXISTS shyeld.affichageCombats;

CREATE VIEW shyeld.affichageCombats AS

SELECT c.*
FROM shyeld.combats c;