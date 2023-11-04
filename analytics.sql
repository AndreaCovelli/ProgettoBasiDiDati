-- Rating assoluto

DELIMITER //

CREATE PROCEDURE CalcolaRatingAssoluto()
BEGIN
    DECLARE mu_rating_utenti DECIMAL(4, 2);
    DECLARE mu_rating_critici DECIMAL(4, 2);
    DECLARE delta_regista DECIMAL(4, 2);
    DECLARE delta_attore DECIMAL(4, 2);
    DECLARE lambda_premi_film DECIMAL(4, 2);
    DECLARE lambda_premi_attori_film DECIMAL(4, 2);
    DECLARE gamma DECIMAL(4, 2);
    DECLARE Rating_assoluto DECIMAL(4, 2);
    
    -- Calcolo di mu_rating_utenti
    SET mu_rating_utenti = (SELECT AVG(Rating) * 0.4 FROM Film);
    
    -- Calcolo di mu_rating_critici
    SET mu_rating_critici = (SELECT AVG(Rating) * 0.3 FROM Film);
    
    -- Calcolo di delta_regista
    SET delta_regista = CASE
        WHEN NumeroPremiRegista BETWEEN 0 AND 19 THEN 1 * 0.2
        WHEN NumeroPremiRegista BETWEEN 20 AND 39 THEN 2 * 0.2
        WHEN NumeroPremiRegista BETWEEN 40 AND 59 THEN 3 * 0.2
        WHEN NumeroPremiRegista BETWEEN 60 AND 79 THEN 4 * 0.2
        WHEN NumeroPremiRegista >= 80 THEN 5 * 0.2
        ELSE 0
    END;
    
    -- Calcolo di delta_attore
    SET delta_attore = CASE
        WHEN NumeroPremiAttore BETWEEN 0 AND 9 THEN 1 * 0.3
        WHEN NumeroPremiAttore BETWEEN 10 AND 19 THEN 2 * 0.3
        WHEN NumeroPremiAttore BETWEEN 20 AND 29 THEN 3 * 0.3
        WHEN NumeroPremiAttore BETWEEN 30 AND 39 THEN 4 * 0.3
        WHEN NumeroPremiAttore >= 40 THEN 5 * 0.3
        ELSE 0
    END;
    
    -- Calcolo di lambda_premi_film
    SET lambda_premi_film = CASE
        WHEN NumeroPremiFilm BETWEEN 0 AND 4 THEN 1 * 0.3
        WHEN NumeroPremiFilm BETWEEN 5 AND 9 THEN 2 * 0.3
        WHEN NumeroPremiFilm BETWEEN 10 AND 14 THEN 3 * 0.3
        WHEN NumeroPremiFilm BETWEEN 15 AND 19 THEN 4 * 0.3
        WHEN NumeroPremiFilm >= 20 THEN 5 * 0.3
        ELSE 0
    END;
    
    -- Calcolo di lambda_premi_attori_film
    SET lambda_premi_attori_film = CASE
        WHEN NumeroPremiAttoriFilm BETWEEN 0 AND 4 THEN 1 * 0.2
        WHEN NumeroPremiAttoriFilm BETWEEN 5 AND 9 THEN 2 * 0.2
        WHEN NumeroPremiAttoriFilm BETWEEN 10 AND 14 THEN 3 * 0.2
        WHEN NumeroPremiAttoriFilm BETWEEN 15 AND 19 THEN 4 * 0.2
        WHEN NumeroPremiAttoriFilm >= 20 THEN 5 * 0.2
        ELSE 0
    END;
    
    -- Calcolo di gamma
    SET gamma = CASE
        WHEN NumeroVisualizzazioni BETWEEN 0 AND 999999 THEN 1 * 0.3
        WHEN NumeroVisualizzazioni BETWEEN 1000000 AND 2999999 THEN 2 * 0.3
        WHEN NumeroVisualizzazioni BETWEEN 3000000 AND 5999999 THEN 3 * 0.3
        WHEN NumeroVisualizzazioni BETWEEN 6000000 AND 9999999 THEN 4 * 0.3
        WHEN NumeroVisualizzazioni >= 10000000 THEN 5 * 0.3
        ELSE 0
    END;
    
    -- Calcolo del Rating assoluto
    SET Rating_assoluto = mu_rating_utenti + mu_rating_critici + delta_regista + delta_attore + lambda_premi_film + lambda_premi_attori_film + gamma;
    
    -- Aggiorna il Rating assoluto per ciascun film
    UPDATE Film
    SET RatingAssoluto = Rating_assoluto;
END//

DELIMITER ;

-- Custom analytic

DELIMITER //

CREATE PROCEDURE CalcolaFilmPiùRichiesti()
BEGIN
    DECLARE chi_rating DECIMAL(4, 2);
    DECLARE coeff_num_visual DECIMAL(4, 2);
    DECLARE Popolaritàfilm DECIMAL(4, 2);
    
    -- Calcolo di chi_rating
    SET chi_rating = (SELECT (Rating * 1.50) FROM Film WHERE NumeroVisualizzazioni >= 100000);
    
    -- Calcolo di coeff_num_visual
    SET coeff_num_visual = CASE
        WHEN NumeroVisualizzazioni BETWEEN 100000 AND 199999 THEN 1.5
        WHEN NumeroVisualizzazioni BETWEEN 200000 AND 499999 THEN 2.5
        WHEN NumeroVisualizzazioni BETWEEN 500000 AND 699999 THEN 3.5
        WHEN NumeroVisualizzazioni BETWEEN 700000 AND 999999 THEN 4
        WHEN NumeroVisualizzazioni >= 1000000 THEN 5
        ELSE 0
    END;
    
    -- Calcolo di Popolaritàfilm
    SET Popolaritàfilm = chi_rating + (coeff_num_visual * 0.50);
    
    -- Seleziona i 10 film con la maggiore Popolaritàfilm
    SELECT Titolo, Popolaritàfilm
    FROM Film
    WHERE NumeroVisualizzazioni >= 100000
    ORDER BY Popolaritàfilm DESC
    LIMIT 10;
END//

DELIMITER ;
