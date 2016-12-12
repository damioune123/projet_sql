
CREATE OR REPLACE FUNCTION shyeld.verificationAuthenticiteCombat()  RETURNS TRIGGER AS $$
DECLARE
	_participation RECORD;
	_superhero RECORD;
	_compteurMarvelle integer := 0;
	_compteurDece integer := 0;

BEGIN
	IF NOT EXISTS (SELECT * FROM shyeld.participations p WHERE p.combat = NEW.id_combat) THEN RAISE foreign_key_violation;
	END IF;
	FOR _participation IN SELECT p.*  FROM shyeld.participations p WHERE p.combat = NEW.id_combat LOOP
		IF 'M' = (SELECT s.clan FROM shyeld.superheros s WHERE s.id_superhero = _participation.superhero) THEN
			_compteurMarvelle := _compteurMarvelle + 1;
		ELSE
			_compteurDece := _compteurDece +1;
		END IF;
		UPDATE shyeld.combats SET nombre_participants = nombre_participants + 1 WHERE id_combat = _participation.combat;
		IF 'G' = _participation.issue THEN
			UPDATE shyeld.combats SET nombre_gagnants = nombre_gagnants + 1 WHERE id_combat = _participation.combat;
		ELSIF 'P' = _participation.issue THEN
			UPDATE shyeld.combats SET nombre_perdants = nombre_perdants + 1 WHERE id_combat = _participation.combat;
		ELSE
			UPDATE shyeld.combats SET nombre_neutres = nombre_neutres + 1 WHERE id_combat = _participation.combat;
		END IF;
	END LOOP;
	IF (_compteurDece <= 0 OR _compteurMarvelle <= 0) THEN
		RAISE 'Deux clans adverses sont requis pour le meme combat';
	END IF;
	RETURN NEW;
		
END;
$$  LANGUAGE plpgsql; 

CREATE CONSTRAINT TRIGGER trigger_authenticiteCombat AFTER INSERT ON shyeld.combats
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE shyeld.verificationAuthenticiteCombat(); 
