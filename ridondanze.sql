-- Aggiornamento ridondanza NumeroFatture

DELIMITER //

CREATE PROCEDURE InserisciRidondanzaIDUltimaFattura(IN CodiceUtente INT)
BEGIN
    DECLARE TipoAbbonamento INT;
    DECLARE IDNuovaFattura INT;

    -- Controlla se l'utente ha il rinnovo automatico attivo
    SELECT AbbonamentoID INTO TipoAbbonamento
    FROM Sottoscrizione
    WHERE UtenteID = CodiceUtente;

    -- Esce se l'utente non ha il rinnovo automatico attivo
    IF TipoAbbonamento IS NULL THEN
        LEAVE InserisciRidondanzaIDUltimaFattura;
    END IF;

    -- Genera una nuova fattura
    INSERT INTO Fattura (DataEmissione, Importo, StatoPagamento)
    VALUES (CURDATE(), (SELECT ImportoAbbonamento FROM Abbonamento WHERE IDAbbonamento = TipoAbbonamento), 'Non Pagata');

    -- Ottiene l'ID della nuova fattura
    SELECT LAST_INSERT_ID() INTO IDNuovaFattura;

    -- Associa la nuova fattura al tipo di abbonamento
    INSERT INTO Sottoscrizione (UtenteID, AbbonamentoID, IDUltimaFattura)
    VALUES (CodiceUtente, TipoAbbonamento, IDNuovaFattura);

    -- Intesta la nuova fattura all'utente
    INSERT INTO Intestazione (IDfattura, CodiceUtente)
    VALUES (IDNuovaFattura, CodiceUtente);

    -- Aggiorna l'IDUltimaFattura dell'utente con il valore della nuova fattura
    UPDATE Utente
    SET IDUltimaFattura = IDNuovaFattura
    WHERE CodiceUtente = CodiceUtente;
END//

DELIMITER ;

-- Aggiornamento ridondanza NumeroFilm per ciascuna lingua di FilmSphere

DELIMITER //

-- Creazione della stored procedure per l'introduzione della ridondanza NumeroFilm
CREATE PROCEDURE IntroduciRidondanzaNumeroFilm()
BEGIN
    -- Dichiarazione delle variabili
    DECLARE LinguaCorrente VARCHAR(255);
    DECLARE NumeroFilm INT;
    
    -- Crea un cursore per ottenere tutte le lingue
    DECLARE cur CURSOR FOR
        SELECT DISTINCT Lingua
        FROM Audio;
    
    -- Loop attraverso tutte le lingue
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO LinguaCorrente;
        
        -- Conta il numero di film per la lingua corrente
        SELECT COUNT(DISTINCT Film.TitoloFilm)
        INTO NumeroFilm
        FROM Codifica
        WHERE Codifica.CodiceAudio IN (SELECT CodiceAudio FROM Audio WHERE Lingua = LinguaCorrente);
        
        -- Aggiorna il valore NumeroFilm nella tabella Lingua
        UPDATE Lingua
        SET Lingua.NumeroFilm = NumeroFilm
        WHERE Lingua.Lingua = LinguaCorrente;
        
    END LOOP;
    CLOSE cur;
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
DO CALL InserisciRidondanzaIDUltimaFattura(123456789);

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
