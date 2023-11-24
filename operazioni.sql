-- Drop stored procedure 1 RegistraUtente
DROP PROCEDURE IF EXISTS RegistraUtente;

-- Drop stored procedure 2 Pagamento fattura
DROP PROCEDURE IF EXISTS PagamentoFattura;

-- Drop stored procedure 3 InserisciFileInFilmSphere
DROP PROCEDURE IF EXISTS InserisciFileInFilmSphere;

-- Drop stored procedure 4 Inserimento di una valutazione utente
DROP PROCEDURE IF EXISTS InserisciValutazioneUtente;

-- Drop stored procedure 5 Numero di fatture in un paese
DROP PROCEDURE IF EXISTS CalcolaNumeroFatturePaese;

-- Drop stored procedure 6 Stampa stato Server
DROP PROCEDURE IF EXISTS StampaStatoServer;

-- Drop stored procedure 7 Elencare n° film disponibili in una lingua
DROP PROCEDURE IF EXISTS NumeroFilmDisponibiliPerAbbonamento;

-- Drop stored procedure 8 Numero di visualizzazioni di un film
DROP PROCEDURE IF EXISTS CalcolaNumeroVisualizzazioniFilm;

-- Drop stored procedure funzionalità n°1
DROP PROCEDURE IF EXISTS CalcolaRatingAssoluto;

-- Drop stored procedure funzionalità n°2
DROP PROCEDURE IF EXISTS ScegliServer;

-- Drop stored procedure funzionalità n°3
DROP PROCEDURE IF EXISTS CalcolaProbabilitàCaching;


-- Operazione n°1: Registrazione di un utente

DELIMITER //

CREATE PROCEDURE RegistraUtente(
    IN Nome VARCHAR(255),
    IN Cognome VARCHAR(255),
    IN Email VARCHAR(255),
    IN Password_ VARCHAR(255),
    IN TipologiaAbbonamento VARCHAR(255),
    IN NumeroCarta VARCHAR(16),
    IN ScadenzaCarta DATE,
    IN IntestatarioCarta VARCHAR(255),
    IN CVV INT
)
BEGIN
    DECLARE UtenteEsistente INT;
    DECLARE CodiceUtente INT;
    DECLARE CodiceFattura INT;

    -- Verifica se l'utente esiste già
    SELECT COUNT(*) INTO UtenteEsistente
    FROM Utente
    WHERE EMail = Email;

    IF UtenteEsistente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L''utente con questo indirizzo e-mail è già registrato.';
    ELSE
        -- Crea una nuova istanza dell'utente
        INSERT INTO Utente (Nome, Cognome, EMail, Password, TipologiaAbbonamento)
        VALUES (Nome, Cognome, Email, Password, TipologiaAbbonamento);

        -- Ottieni il CodiceUtente appena creato
        SELECT LAST_INSERT_ID() INTO CodiceUtente;

        -- Associa il pagamento alla carta di credito inserita
        INSERT INTO FormaDiPagamento (Tipo, NumeroCarta, ScadenzaCarta, Intestatario, CVV)
        VALUES ('Carta di Credito', NumeroCarta, ScadenzaCarta, IntestatarioCarta, CVV);

        -- Ottieni il CodiceFattura appena creato
        SELECT LAST_INSERT_ID() INTO CodiceFattura;

        -- Associa la carta di credito all'utente
        UPDATE Utente
        SET NCarta = CodiceFattura
        WHERE CodiceUtente = CodiceUtente;

        -- Associa i dati dell'utente alla fattura
        INSERT INTO Intestazione (CodiceUtente, CodiceFattura)
        VALUES (CodiceUtente, CodiceFattura);

        -- Crea una nuova istanza di fattura
        INSERT INTO Fattura (DataPagamento, Importo, Tipologia, CodiceUtente)
        VALUES (CURRENT_DATE(), 0, TipologiaAbbonamento, CodiceUtente);

        -- Associa i dati del pagamento alla fattura
        INSERT INTO Transazione (IDFattura, DataPagamento, NumeroCarta)
        VALUES (LAST_INSERT_ID(), CURRENT_DATE(), NumeroCarta);
    END IF;
END//

DELIMITER ;

-- Operazione n°2: PagamentoFattura

DELIMITER //

CREATE PROCEDURE PagamentoFattura(IN p_CodiceUtente INT)
BEGIN
  DECLARE idFattura INT;
  DECLARE idCartaCredito INT;
  DECLARE tipoAbbonamento VARCHAR(255);

  -- Si seleziona l'IDfattura più recente per l'utente specificato
  SELECT IDfattura INTO idFattura
  FROM Utente
  WHERE CodiceUtente = p_CodiceUtente;

  -- Si seleziona la carta di credito associata all'utente
  SELECT IDcarta INTO idCartaCredito
  FROM FormaPagamento
  WHERE CodiceUtente = p_CodiceUtente
  LIMIT 1;

  -- Si effettua il pagamento della fattura
  INSERT INTO Pagamento (IDfattura, DataPagamento, N°carta)
  VALUES (idFattura, NOW(), idCartaCredito);

  -- Si associa la carta di credito al nuovo pagamento
  INSERT INTO DettagliPagamento (IDfattura, IDcarta)
  VALUES (idFattura, idCartaCredito);

  -- Si associa il pagamento alla relativa fattura
  INSERT INTO Transazione (IDfattura, IDpagamento)
  VALUES (idFattura, LAST_INSERT_ID());

  -- Si cerca la tipologia di abbonamento della fattura appena pagata
  SELECT Tipologia INTO tipoAbbonamento
  FROM Sottoscrizione
  WHERE IDfattura = idFattura;

  -- Si emette una nuova fattura intestata all'utente
  INSERT INTO Fattura (IDfattura, DataPagamento, Importo, Tipologia, CodiceUtente)
  VALUES (NULL, NOW(), FLOOR(RAND() * 100), tipoAbbonamento, p_CodiceUtente);

  -- Si associa la nuova fattura alla stessa tipologia di abbonamento della precedente
  SET @nuovaFatturaID = LAST_INSERT_ID();
  INSERT INTO Sottoscrizione (IDfattura, Tipologia)
  VALUES (@nuovaFatturaID, tipoAbbonamento);

  -- Si aggiorna la ridondanza IDultimaFattura nell'entità Utente
  UPDATE Utente
  SET IDultimaFattura = @nuovaFatturaID
  WHERE CodiceUtente = p_CodiceUtente;

END//

DELIMITER ;

-- Operazione n°3: Inserimento di un file in FilmSphere

DELIMITER //

CREATE PROCEDURE InserisciFileInFilmSphere(
    IN FileID VARCHAR(255),
    IN Dimensione INT,
    IN DataRilascio DATE,
	IN Titolo VARCHAR(255),
    IN NomeLingua VARCHAR(255),
    IN LinguaSottotitolo VARCHAR(255),
    IN CodiceAudio INT,
    IN CodiceVideo INT,
    IN RegioneGeografica VARCHAR(255)
)
label1: BEGIN
    DECLARE LinguaID INT;
    DECLARE FormatoAudioID INT;
    DECLARE FormatoVideoID INT;
    DECLARE ServerID INT;

    -- Controlla se la lingua esiste nella base di dati
    SELECT LinguaID FROM Lingua WHERE NomeLingua = NomeLingua INTO LinguaID;

    IF LinguaID IS NULL THEN
        -- La lingua non esiste, inseriscila
        INSERT INTO Lingua (NomeLingua) VALUES (NomeLingua);
        SET LinguaID = LAST_INSERT_ID();
    END IF;
    
    -- Controlla se il formato audio esiste nella base di dati
    SELECT FormatoAudioID FROM FormatoAudio WHERE CodiceAudio = CodiceAudio INTO FormatoAudioID;

    IF FormatoAudioID IS NULL THEN
        -- Il formato audio non esiste, inseriscilo
        INSERT INTO FormatoAudio (CodiceAudio) VALUES (CodiceAudio);
        SET FormatoAudioID = LAST_INSERT_ID();
    END IF;

    -- Controlla se il formato video esiste nella base di dati
    SELECT FormatoVideoID FROM FormatoVideo WHERE CodiceVideo = CodiceVideo INTO FormatoVideoID;

    IF FormatoVideoID IS NULL THEN
        -- Il formato video non esiste, inseriscilo
        INSERT INTO FormatoVideo (CodiceVideo) VALUES (CodiceVideo);
        SET FormatoVideoID = LAST_INSERT_ID();
    END IF;

    -- Trova un Server_ disponibile nella regione geografica specificata
    SELECT IDServer INTO ServerID
    FROM Server_
    WHERE RegioneGeografica = RegioneGeografica
    AND (SELECT COUNT(*) FROM Memorizzazione WHERE ServerID = IDServer) < 5000
    LIMIT 1;

    -- Se nessun Server_ disponibile nella regione, esci
    IF ServerID IS NULL THEN
        LEAVE label1;
    END IF;

    -- Inserisci i dati del file nella base di dati
    INSERT INTO File (Titolo, NomeFile, Dimensione, DataRilascio)
    VALUES (Titolo, IDfile, NomeFile, Dimensione, DataRilascio, LinguaID, CodiceAudio, CodiceVideo);

    -- Associa il file a un film specifico (Codifica)
    INSERT INTO Codifica (FilmID, FileID) VALUES (NULL, IDfile);

    -- Associa il file alla sua estensione audio
    INSERT INTO EstensioneAudio (FileID, FormatoAudioID) VALUES (IDfile, FormatoAudioID);

    -- Associa il file alla sua estensione video
    INSERT INTO EstensioneVideo (FileID, FormatoVideoID) VALUES (IDfile, FormatoVideoID);
    
     -- Associa il file alla sua lingua
    INSERT INTO Doppiaggio (FileID, NomeLingua) VALUES (IDfile, Lingua);
    
     -- Associa il file ai suoi sottotitoli
    INSERT INTO Sottotitolo (FileID, Lingua) VALUES (IDfile, LinguaSottotitolo);

    -- Associa il file al Server_ nella regione geografica specificata
    INSERT INTO Memorizzazione (ServerID, FileID) VALUES (ServerID, IDfile);
    
END//

DELIMITER ;

-- Operazione n°4: Inserimento di una valutazione utente

DELIMITER //

CREATE PROCEDURE InserisciValutazioneUtente(
    IN CodiceUtente INT,
    IN Titolo VARCHAR(255),
    IN Stelle INT,
    IN Data_ DATE,
    IN Feedback TEXT
)
label2: BEGIN
    -- Controlla se l'utente esiste nella base di dati
    DECLARE UtenteID INT;
	DECLARE FilmID INT;
    SELECT IDUtente FROM Utente WHERE CodiceUtente = CodiceUtente INTO UtenteID;

    IF UtenteID IS NULL THEN
        -- L'utente non esiste, esci
        LEAVE label2;
    END IF;

    -- Controlla se il film esiste nella base di dati
    SELECT IDFilm FROM Film WHERE Titolo = Titolo INTO FilmID;

    IF FilmID IS NULL THEN
        -- Il film non esiste, esci
        LEAVE label2;
    END IF;

    -- Inserisci la valutazione dell'utente nella base di dati
    INSERT INTO ValutazioneUtente (UtenteID, FilmID, Stelle, Data_, Feedback)
    VALUES (UtenteID, FilmID, Stelle, Data_, Feedback);

END//

DELIMITER ;

-- Operazione n°5: Numero di fatture emesse in un paese in quel mese 

DELIMITER //

CREATE PROCEDURE CalcolaNumeroFatturePaese(IN MeseAnno DATE, IN NomePaese VARCHAR(255), OUT NumeroFatture INT)
BEGIN
    DECLARE TotaleFatture INT;

    -- Inizializza il totale delle fatture a zero
    SET TotaleFatture = 0;

    -- Trova tutte le fatture emesse nel mese specificato
    SELECT NumeroFatture INTO TotaleFatture
    FROM Paese
    WHERE Paese.NomePaese=NomePaese;

    -- Aggiungi il numero di fatture associate agli utenti del paese specificato
    SELECT COUNT(*) INTO NumeroFatture
    FROM Utente
    WHERE Paese = NomePaese;

    -- Restituisci il numero totale di fatture nel paese specificato
    SET NumeroFatture = TotaleFatture;
END//

DELIMITER ;

-- Operazione n°6: Stampa stato di un Server_

DELIMITER //

CREATE PROCEDURE StampaStatoServer(
    IN ServerID INT,
    OUT ServerRegioneGeografica VARCHAR(255),
    OUT ServerStorage INT,
    OUT ServerOnOff ENUM('On', 'Off'),
    OUT ServerLarghezzaBanda INT,
    OUT ServerCapacitaMassima INT,
    OUT ServerDisponibilitaBanda INT
)
BEGIN
    -- Recupera lo stato del Server_ specificato dal suo ID
    SELECT RegioneGeografica, Storage_, OnOff, LarghezzaBanda, CapacitaMassima, DisponibilitaBanda
    INTO ServerRegioneGeografica, ServerStorage, ServerOnOff, ServerLarghezzaBanda, ServerCapacitaMassima, ServerDisponibilitaBanda
    FROM Server_
    WHERE IDServer = ServerID;
END//

DELIMITER ;

-- Operazione n°7: Elencare n° film disponibili in un abbonamento
DELIMITER //

CREATE PROCEDURE NumeroFilmDisponibiliPerAbbonamento(IN TipoAbbonamento VARCHAR(255), OUT NumeroFilmDisponibili INT)
BEGIN
  -- Utilizzo della ridondanza NumeroFilm
  SELECT NumeroFilm INTO NumeroFilmDisponibili
  FROM Abbonamento
  WHERE Tipologia = TipoAbbonamento;

END//

DELIMITER ;

-- Operazione n°8: Numero di visualizzazioni di un film

DELIMITER //

-- Creazione della stored procedure per il calcolo del numero di visualizzazioni di un film
CREATE PROCEDURE CalcolaNumeroVisualizzazioniFilm(IN TitoloFilm VARCHAR(255), OUT NumeroVisualizzazioni INT)
BEGIN
    SELECT Film.NumeroVisualizzazioni INTO NumeroVisualizzazioni 
    FROM film
    WHERE Film.Titolo=TitoloFilm;
    
END//

DELIMITER ;

-- Funzionalità n°1: Rating assoluto

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
        WHEN NumeroVisualizzazioni BETWEEN 0 AND 99999 THEN 1 * 0.3
        WHEN NumeroVisualizzazioni BETWEEN 100000 AND 299999 THEN 2 * 0.3
        WHEN NumeroVisualizzazioni BETWEEN 300000 AND 599999 THEN 3 * 0.3
        WHEN NumeroVisualizzazioni BETWEEN 600000 AND 999999 THEN 4 * 0.3
        WHEN NumeroVisualizzazioni >= 1000000 THEN 5 * 0.3
        ELSE 0
    END;
    
    -- Calcolo del Rating assoluto
    SET Rating_assoluto = mu_rating_utenti + mu_rating_critici + delta_regista + delta_attore + lambda_premi_film + lambda_premi_attori_film + gamma;
    
    -- Aggiorna il Rating assoluto per ciascun film
    UPDATE Film
    SET RatingAssoluto = Rating_assoluto;
END//

DELIMITER ;

-- Funzionalità n°2: Scelta del Server

DELIMITER //

CREATE PROCEDURE ScegliServer(IN Titolo VARCHAR(255), IN Utente VARCHAR(15), OUT IDServer INT)
BEGIN
    DECLARE PaeseUtente VARCHAR(255);
    DECLARE ServerNelPaese INT;
    DECLARE ServerNellaRegione INT;
    DECLARE ServerAltriPaesi INT;
    DECLARE IndirizzoIP VARCHAR(255);
    
    SELECT IP INTO IndirizzoIP
    FROM Connessione C
    WHERE C.Utente=Utente;

    -- Ottieni il Paese dell'utente basato sull'Indirizzo IP
    SELECT NomePaese INTO PaeseUtente
    FROM Paese
    WHERE INET_ATON(IndirizzoIP) BETWEEN INizioIP AND FineIP;

    -- Controlla se ci sono Server_ nel Paese dell'utente
    SELECT COUNT(*) INTO ServerNelPaese
    FROM Server_
    WHERE RegioneGeografica = PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0;

    -- Controlla se ci sono Server nella stessa regione geografica dell'utente
    SELECT COUNT(*) INTO ServerNellaRegione
    FROM Server_
    WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0;

    -- Controlla se ci sono Server in altre regioni geografiche con disponibilità
    SELECT COUNT(*) INTO ServerAltriPaesi
    FROM Server_
    WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0;

    -- Scegli il Server in base alle condizioni
    IF ServerNelPaese > 0 THEN
        -- Ci sono Server disponibili nel Paese dell'utente
        SELECT IDserver INTO IDServer
        FROM Server_
        WHERE RegioneGeografica = PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0
        LIMIT 1;
    ELSEIF ServerNellaRegione > 0 THEN
        -- Non ci sono Server nel Paese, ma ci sono Server_ nella stessa regione geografica
        SELECT IDserver INTO IDServer
        FROM Server_
        WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0
        LIMIT 1;
    ELSE
        -- Non ci sono Server disponibili nella stessa regione geografica, quindi scegli un'altra regione con Server_ disponibili
        SELECT IDserver INTO IDServer
        FROM Server_
        WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0
        LIMIT 1;
    END IF;
END//

DELIMITER ;

-- Funzionalità n°3: Caching

DELIMITER //

CREATE PROCEDURE CalcolaProbabilitàCaching(IN IPutente VARCHAR(255))
BEGIN
    DECLARE alpha DECIMAL(4, 2);
    DECLARE film_id INT;
    DECLARE genere_prob DECIMAL(4, 2);
    DECLARE vis_prob DECIMAL(4, 2);
    DECLARE rating_prob DECIMAL(4, 2);
    DECLARE durata_prob DECIMAL(4, 2);
    DECLARE caching_prob DECIMAL(4, 2);

    -- Per gli ultimi 10 film visualizzati dall'utente
    DECLARE cur CURSOR FOR
        SELECT Film
        FROM File_
		INNER JOIN visualizzazione
        ON File_.IDfile=visualizzazione.IDfile
        INNER JOIN Connessione ON visualizzazione.IDvisualizzazione
        WHERE Connessione.IP=IPutente
        ORDER BY visualizzazione.FineV DESC
        LIMIT 10; 
    
    -- Calcola la probabilità di caching per ciascun film
    OPEN cur;
    FETCH cur INTO film_id;
    
    WHILE film_id IS NOT NULL DO
        -- Inizializza i fattori di probabilità
        SET genere_prob = 0;
        SET vis_prob = 0;
        SET rating_prob = 0;
        SET durata_prob = 0;

        -- Calcola il fattore di probabilità del genere
        SET genere_prob = (SELECT
            CASE
                WHEN EXISTS (SELECT * FROM Visualizzazione WHERE IDfilm = film_id AND IDfile NOT IN (SELECT IDfile FROM File WHERE NomeLingua IN (SELECT NomeLingua FROM LinguaUtente ORDER BY DataVisualizzazione DESC)) AND IDfile NOT IN (SELECT IDfile FROM File WHERE NomeLingua IN (SELECT NomeLingua FROM SottotitoliUtente ORDER BY DataVisualizzazione DESC))) THEN 0.01
                ELSE 0.1
            END);

        -- Calcola il fattore di probabilità delle visualizzazioni
        SET vis_prob = (SELECT
            CASE
                WHEN NumeroVisualizzazioni >= 500000 THEN 0.1
                ELSE 0.5
            END FROM Film WHERE IDfilm = film_id);

        -- Calcola il fattore di probabilità del rating
        SET rating_prob = (SELECT
            CASE
                WHEN RatingAssoluto >= 6 THEN 0.05
                ELSE 0.15
            END FROM Film WHERE IDfilm = film_id);

        -- Calcola il fattore di probabilità della durata
        SET durata_prob = (SELECT
            CASE
                WHEN Durata <= (SELECT AVG(Durata) FROM Film WHERE IDfilm IN (SELECT IDfilm FROM Visualizzazione WHERE IDutente = 1 ORDER BY DataVisualizzazione DESC)) THEN 0.01
                ELSE 0.05
            END FROM Film WHERE IDfilm = film_id);

        -- Calcola la probabilità finale (alpha)
        SET alpha = genere_prob + vis_prob + rating_prob + durata_prob;

        -- Limita la probabilità massima a 0.8 (80%)
        IF alpha > 0.8 THEN
            SET alpha = 0.8;
        END IF;

        -- Aggiorna la probabilità di caching per il film
        UPDATE Film
        SET ProbabilitàCaching = alpha
        WHERE IDfilm = film_id;
        
        FETCH cur INTO film_id;
    END WHILE;

    CLOSE cur;
END//

DELIMITER ;

CALL RegistraUtente('Paolo', 'Rossi', 'paolorossi@gmail.com', '123456789', 'Base', '7125235678451475', "2026-09-31", 'Paolo Rossi', '200');

CALL RinnovoMensileAbbonamento(123456789);

CALL InserisciFileInFilmSphere('TheRace.avi', 1024, '20231105', 'Italiano', 'Inglese', 'mp3', 'avi', 'Europa');

CALL InserisciValutazioneUtente(123456789, 'TheRace', 4, '2023/11/05', 'Ottimo film, lo consiglio!');

CALL CalcolaNumeroFatturePaese('2023-10-01', 'Italia', @NumeroFatture);
SELECT @NumeroFatture;

CALL StampaStatoServer(123, @Regione, @Storage_, @OnOff, @LarghezzaBanda, @CapacitaMassima, @DisponibilitaBanda);
SELECT @Regione, @Storage_, @OnOff, @LarghezzaBanda, @CapacitaMassima, @DisponibilitaBanda;

CALL NumeroFilmDisponibiliPerAbbonamento('Tipologia1', @NumeroFilm);
SELECT @NumeroFilm;

CALL CalcolaNumeroVisualizzazioniFilm('TheRace', @NumeroVisualizzazioni);
SELECT @NumeroVisualizzazioni AS NumeroVisualizzazioni;

CALL ScegliServer(Titolo, IndirizzoIPUtente, @IDServer);

CALL CalcolaProbabilitàCaching(Utente);


