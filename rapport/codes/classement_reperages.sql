CREATE VIEW shyeld.classementReperages AS

SELECT a.nom, a.prenom, count(r.id_reperage) as "reperages"
FROM shyeld.agents a, shyeld.reperages r 
WHERE a.id_agent = r.agent 
AND a.est_actif = TRUE 
GROUP BY a.id_agent
ORDER BY count(r.id_reperage) DESC;