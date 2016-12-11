CREATE TRIGGER trigger_reperageCombat AFTER INSERT ON shyeld.participations
FOR EACH ROW
EXECUTE PROCEDURE shyeld.reperageCombat(); 

--- MAJ champ date apparition et dernieres coordonnees de la table shyeld.superheros ---
CREATE OR REPLACE FUNCTION shyeld.miseAJourDateCoordonneeReperage() RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS (SELECT s.* FROM shyeld.superheros s WHERE s.id_superhero = NEW.superhero) THEN
		RAISE foreign_key_violation;
	END IF;

 	UPDATE shyeld.superheros SET date_derniere_apparition = NEW.date, derniere_coordonneeX = NEW.coord_x,
 	 derniere_coordonneeY = NEW.coord_y WHERE id_superhero = NEW.superhero;
 	 	RETURN NEW;
 
 	 EXCEPTION
 	 	WHEN check_violation THEN RAISE EXCEPTION 'trigger date - coord superhero incorrect';
 END;
 $$LANGUAGE plpgsql;
 
 
 
 CREATE TRIGGER trigger_reperage_coordonnee AFTER INSERT ON shyeld.reperages
 FOR EACH ROW
 EXECUTE PROCEDURE shyeld.miseAJourDateCoordonneeReperage();
