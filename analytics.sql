DROP PROCEDURE IF EXISTS ClassificaVisualizzazioniPerAbbonamento;
DROP PROCEDURE IF EXISTS CalcolaFilmPiùRichiesti;

-- Analytic function n°1: Classifica

DELIMITER //

CREATE PROCEDURE ClassificaVisualizzazioniPerAbbonamento(
    IN InputPaese VARCHAR(255),
    IN InputTipologiaAbbonamento VARCHAR(255)
)
BEGIN
    -- Step 1
    CREATE TEMPORARY TABLE TempVisualizzazioniFile AS
    SELECT IDfile, IDvisualizzazione
    FROM VisualizzazioneFile;

    -- Step 2
    CREATE TEMPORARY TABLE TempFileCodifica AS
    SELECT tf.IDfile, c.Titolo
    FROM TempVisualizzazioniFile tf
    JOIN Codifica c ON tf.IDfile = c.IDfile;

    -- Step 3
    CREATE TEMPORARY TABLE TempVisualizzazioniUtente AS
    SELECT tf.IDfile, v.IDvisualizzazione, a.CodiceUtente
    FROM TempVisualizzazioniFile tf
    JOIN Visualizzazione v ON tf.IDvisualizzazione = v.IDvisualizzazione
    JOIN Fruizione f ON v.IDvisualizzazione = f.IDvisualizzazione
    JOIN Accesso a ON f.CodiceConnessione = a.CodiceConnessione;

    -- Step 4
    CREATE TEMPORARY TABLE TempVisualizzazioniAbbonamento AS
    SELECT tu.IDfile, tu.IDvisualizzazione, tu.CodiceUtente, u.Paese, u.IDultimaFattura
    FROM TempVisualizzazioniUtente tu
    JOIN Utente u ON tu.CodiceUtente = u.CodiceUtente;

    -- Step 5
    CREATE TEMPORARY TABLE TempVisualizzazioniFiltrate AS
    SELECT tva.IDfile, tva.IDvisualizzazione, tva.Paese, s.Tipologia
    FROM TempVisualizzazioniAbbonamento tva
    JOIN Sottoscrizione s ON tva.IDultimaFattura = s.IDfattura
    WHERE tva.Paese = InputPaese AND s.Tipologia = InputTipologiaAbbonamento;

    -- Step 6
    CREATE TEMPORARY TABLE TempConteggioPerFilm AS
    SELECT IDfile, COUNT(*) AS NumeroVisualizzazioni
    FROM TempVisualizzazioniFiltrate
    GROUP BY IDfile;

    -- Step 7
    SELECT tfc.Titolo, tcf.NumeroVisualizzazioni
    FROM TempFileCodifica tfc
    JOIN TempConteggioPerFilm tcf ON tfc.IDfile = tcf.IDfile
    ORDER BY tcf.NumeroVisualizzazioni DESC;

    -- Cleanup: drop temporary tables
    DROP TEMPORARY TABLE IF EXISTS TempVisualizzazioniFile;
    DROP TEMPORARY TABLE IF EXISTS TempFileCodifica;
    DROP TEMPORARY TABLE IF EXISTS TempVisualizzazioniUtente;
    DROP TEMPORARY TABLE IF EXISTS TempVisualizzazioniAbbonamento;
    DROP TEMPORARY TABLE IF EXISTS TempVisualizzazioniFiltrate;
    DROP TEMPORARY TABLE IF EXISTS TempConteggioPerFilm;
    
END//

DELIMITER ;

-- Analytic function n°2: Custom analytic

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