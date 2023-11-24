-- Aggiornamento ridondanza NumeroFatture

DELIMITER //

-- Stored procedure per il mantenimento della ridondanza
CREATE PROCEDURE InserisciRidondanzaIDUltimaFattura()
BEGIN
  DECLARE idFattura INT;
  DECLARE codiceUtente INT;
  
  -- Si seleziona l'IDfattura più recente per ciascun utente
  DECLARE cur CURSOR FOR
    SELECT IDfattura, CodiceUtente
    FROM Fattura NATURAL JOIN Utente
    ORDER BY CodiceUtente, DataPagamento DESC;

  OPEN cur;

  -- Si scorre il cursore e si aggiorna la ridondanza
  read_loop: LOOP
    FETCH cur INTO idFattura, codiceUtente;
    IF idFattura IS NULL THEN
      LEAVE read_loop;
    END IF;
    
    UPDATE Utente
    SET IDultimaFattura = idFattura
    WHERE CodiceUtente = codiceUtente;
  END LOOP;

  CLOSE cur;

END//

DELIMITER ;

DELIMITER //

  -- Inserimento della ridondanza NumeroFilm 

CREATE PROCEDURE IntroduciRidondanzaNumeroFilm()
BEGIN
  -- Introduzione della ridondanza NumeroFilm
  ALTER TABLE Abbonamento ADD COLUMN NumeroFilm INT;

  -- Popolamento della ridondanza
  UPDATE Abbonamento
  SET NumeroFilm = (
    SELECT COUNT(DISTINCT f.Titolo)
    FROM Libreria l
    JOIN File_ fi ON l.IDfile = fi.IDfile
    JOIN Film f ON fi.Titolo = f.Titolo
    WHERE l.Tipologia = Abbonamento.Tipologia
  );

END//

-- Aggiornamento della ridondanza Numerofilm

CREATE PROCEDURE AggiornaRidondanzaNumeroFilm()
BEGIN
  -- Aggiornamento della ridondanza NumeroFilm
  UPDATE Abbonamento
  SET NumeroFilm = (
    SELECT COUNT(DISTINCT f.Titolo)
    FROM Libreria l
    JOIN File_ fi ON l.IDfile = fi.IDfile
    JOIN Film f ON fi.Titolo = f.Titolo
    WHERE l.Tipologia = Abbonamento.Tipologia
  );

END//

DELIMITER ;

-- Aggiornamento della ridondanza NumeroVisualizzazioniFilm una volta al mese

DELIMITER //

-- Creazione della stored procedure per l'introduzione della ridondanza NumeroVisualizzazioni in Film
CREATE PROCEDURE AggiornaRidondanzaNumeroVisualizzazioniFilm()
BEGIN
    DECLARE FilmID INT;
    DECLARE VisualizzazioniGiornaliere INT;
    
    -- Dichiarare un cursore per ottenere l'elenco dei film
    DECLARE film_cursor CURSOR FOR
    SELECT Film.ID
    FROM Film;
    
    -- Aprire il cursore
    OPEN film_cursor;
    
    -- Inizializzare il valore delle visualizzazioni giornaliere a 0
    SET VisualizzazioniGiornaliere = 0;
    
    -- Ciclare attraverso l'elenco dei film
    film_loop: LOOP
        FETCH film_cursor INTO FilmID;
        
        -- Uscire dal ciclo se non ci sono più film da elaborare
        IF done THEN
            LEAVE film_loop;
        END IF;
        
        -- Calcolare il numero di visualizzazioni giornaliere per il film
        SELECT COUNT(*) INTO VisualizzazioniGiornaliere
        FROM VisualizzazioneFile
        WHERE VisualizzazioneFile.Codifica IN (SELECT Codifica.ID FROM Codifica WHERE Codifica.FilmID = FilmID)
        AND VisualizzazioneFile.DataVisualizzazione >= DATE_SUB(NOW(), INTERVAL 1 DAY);
        
        -- Aggiornare la ridondanza NumeroVisualizzazioni nel film
        UPDATE Film
        SET Film.NumeroVisualizzazioni = VisualizzazioniGiornaliere
        WHERE Film.ID = FilmID;
    END LOOP;
    
    -- Chiudere il cursore
    CLOSE film_cursor;
    
END//

DELIMITER ;

CREATE EVENT RidIDUltimaFattura
ON SCHEDULE
EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '00:00:00')
COMMENT 'Aggiornamento ridondanza NumeroFatture'
DO CALL InserisciRidondanzaIDUltimaFattura();

CREATE EVENT RidNumFilmPerLingua
ON SCHEDULE
EVERY 1 MONTH
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '00:00:00')
COMMENT 'Aggiornamento ridondanza NumeroFatture'
DO CALL IntroduciRidondanzaNumeroFilm();

CREATE EVENT RidondanzaNumeroVisualizzazioniFilm
ON SCHEDULE
EVERY 1 MONTH
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '00:00:00')
COMMENT 'Aggiornamento ridondanza NumeroFatture'
DO CALL AggiornaRidondanzaNumeroVisualizzazioniFilm();

SET GLOBAL event_scheduler = ON;
