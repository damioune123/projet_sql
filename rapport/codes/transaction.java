public int ajouterCombat(Combat combat, ArrayList<Participation> participations) {
		int id = -1;
		try {
			connexionDb.setAutoCommit(false);
			System.out.println(combat.getAgent());
			try {
				tableStatement.get("ajoutComb").setDate(1, combat.getDateCombat());
				tableStatement.get("ajoutComb").setInt(2, combat.getCoordCombatX());
				tableStatement.get("ajoutComb").setInt(3, combat.getCoordCombatY());
				tableStatement.get("ajoutComb").setInt(4, combat.getAgent());
				tableStatement.get("ajoutComb").setInt(5, combat.getNombreParticipants());
				tableStatement.get("ajoutComb").setInt(6, combat.getNombreGagnants());
				tableStatement.get("ajoutComb").setInt(7, combat.getNombrePerdants());
				tableStatement.get("ajoutComb").setInt(8, combat.getNombreNeutres());
				try(ResultSet rs = tableStatement.get("ajoutComb").executeQuery()) {
					while(rs.next()) {
						id = Integer.valueOf(rs.getString(1));
					}
					for(Participation participation : participations){
						participation.setCombat(id);
						ajouterParticipation(participation);
					}
				}
				connexionDb.commit();
			} catch (SQLException se) {
				System.out.println("Le combat n'a pas pu etre ajoute");
				if(!participations.isEmpty()){
					System.out.println("Les partcipations ont tout de meme ete rajoutee en tant que reperages");
					for(Participation participation : participations){
						ajouterReperage(new Reperage(combat.getAgent(), participation.getSuperhero(), combat.getCoordCombatX(), combat.getCoordCombatY(), combat.getDateCombat()));
					}
					id = -2;
				}
			}
		} catch (SQLException se) {
			try {
				connexionDb.rollback();
			} catch (SQLException e) {
				System.out.println("Le retour en arriere n'a pas pu etre effectue");
				id = -1;
			}
		} finally {
			try {
				connexionDb.setAutoCommit(true);
				return id;
			} catch (SQLException e) {
				System.out.println("La fermeture de la connexion n'a pas pu etre effectue");
				return -1;
			}
		}
	}

	public int ajouterParticipation(Participation participation) {
		try {
			tableStatement.get("ajoutPa").setInt(1, participation.getSuperhero());
			tableStatement.get("ajoutPa").setInt(2, participation.getCombat());
			tableStatement.get("ajoutPa").setString(3, String.valueOf(participation.getIssue()));
			try(ResultSet rs = tableStatement.get("ajoutPa").executeQuery()) {
				while(rs.next()) {
					return Integer.valueOf(rs.getString(1));
				}
				return -1;
			}
		} catch (SQLException se) {
			se.printStackTrace();
			System.out.println("La participation n'a pas pu etre ajoutee");
			return -1;
		}
	}