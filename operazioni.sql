-- Operazione n°1: Registrazione di un utente

DELIMITER //

CREATE PROCEDURE RegistraUtente(
    IN Nome VARCHAR(255),
    IN Cognome VARCHAR(255),
    IN Email VARCHAR(255),
    IN Password VARCHAR(255),
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

-- Operazione n°2: Rinnovo mensile automatico dell’abbonamento

DELIMITER //

CREATE PROCEDURE RinnovoMensileAbbonamento(IN CodiceUtente INT)
BEGIN
    DECLARE DataOdierna DATE;
    DECLARE UltimaFattura INT;
    DECLARE CartaCredito INT;
    DECLARE Pagamento INT;

    -- Trova la data odierna
    SET DataOdierna = CURDATE();

    -- Trova l'ultima fattura non pagata per l'utente
    SELECT MAX(IDfattura) INTO UltimaFattura
    FROM Utente
    WHERE Utente.CodiceUtente = CodiceUtente;

    -- Esci se non ci sono fatture non pagate
    IF UltimaFattura IS NULL THEN
        LEAVE RinnovoMensileAbbonamento;
    END IF;

    -- Cerca una carta di credito dell'utente
    SELECT IDcarta INTO CartaCredito
    FROM CartaDiCredito
    WHERE CodiceUtente = CodiceUtente;

    -- Esci se non ci sono carte di credito
    IF CartaCredito IS NULL THEN
        LEAVE RinnovoMensileAbbonamento;
    END IF;

    -- Crea un nuovo pagamento
    INSERT INTO Pagamento (DataPagamento, Importo, IDcarta, CodiceUtente, IDfattura)
    VALUES (DataOdierna, (SELECT Importo FROM Fattura WHERE IDfattura = UltimaFattura), CartaCredito, CodiceUtente, UltimaFattura);

    -- Aggiorna lo stato di pagamento della fattura
    UPDATE Fattura
    SET StatoPagamento = 'Pagata'
    WHERE IDfattura = UltimaFattura;

    -- Aggiungi il pagamento alla transazione
    INSERT INTO Transazione (IDpagamento, IDfattura)
    VALUES (LAST_INSERT_ID(), UltimaFattura);
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
BEGIN
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

    -- Trova un server disponibile nella regione geografica specificata
    SELECT IDServer INTO ServerID
    FROM Server
    WHERE RegioneGeografica = RegioneGeografica
    AND (SELECT COUNT(*) FROM Memorizzazione WHERE ServerID = IDServer) < 5000
    LIMIT 1;

    -- Se nessun server disponibile nella regione, esci
    IF ServerID IS NULL THEN
        LEAVE InserisciFileInFilmSphere;
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

    -- Associa il file al server nella regione geografica specificata
    INSERT INTO Memorizzazione (ServerID, FileID) VALUES (ServerID, IDfile);
    
END//

DELIMITER ;

-- Operazione n°4: Inserimento di una valutazione utente

DELIMITER //

CREATE PROCEDURE InserisciValutazioneUtente(
    IN CodiceUtente INT,
    IN Titolo VARCHAR(255),
    IN Stelle INT,
    IN Data DATE,
    IN Feedback TEXT
)
BEGIN
    -- Controlla se l'utente esiste nella base di dati
    DECLARE UtenteID INT;
	DECLARE FilmID INT;
    SELECT IDUtente FROM Utente WHERE CodiceUtente = CodiceUtente INTO UtenteID;

    IF UtenteID IS NULL THEN
        -- L'utente non esiste, esci
        LEAVE InserisciValutazioneUtente;
    END IF;

    -- Controlla se il film esiste nella base di dati
    SELECT IDFilm FROM Film WHERE Titolo = Titolo INTO FilmID;

    IF FilmID IS NULL THEN
        -- Il film non esiste, esci
        LEAVE InserisciValutazioneUtente;
    END IF;

    -- Inserisci la valutazione dell'utente nella base di dati
    INSERT INTO ValutazioneUtente (UtenteID, FilmID, Stelle, Data, Feedback)
    VALUES (UtenteID, FilmID, Stelle, Data, Feedback);

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

-- Operazione n°6: Stampa stato di un server

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
    -- Recupera lo stato del server specificato dal suo ID
    SELECT RegioneGeografica, Storage, OnOff, LarghezzaBanda, CapacitaMassima, DisponibilitaBanda
    INTO ServerRegioneGeografica, ServerStorage, ServerOnOff, ServerLarghezzaBanda, ServerCapacitaMassima, ServerDisponibilitaBanda
    FROM Server
    WHERE IDServer = ServerID;
END//

DELIMITER ;

-- Operazione n°7: Elencare n° film disponibili in una lingua
DELIMITER //

CREATE PROCEDURE ElencoFilmPerLingua(
    IN LinguaCercata VARCHAR(255),
    OUT NumeroFilm INT
)
BEGIN
    -- Conta il numero di film disponibili nella lingua specificata
    SELECT Lingua.NumeroFilm INTO NumeroFilm
    FROM Lingua
    WHERE Lingua.NomeLingua=LinguaCercata;
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

-- Operazione n°9: Scelta del server

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

    -- Controlla se ci sono server nel Paese dell'utente
    SELECT COUNT(*) INTO ServerNelPaese
    FROM Server
    WHERE RegioneGeografica = PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0;

    -- Controlla se ci sono server nella stessa regione geografica dell'utente
    SELECT COUNT(*) INTO ServerNellaRegione
    FROM Server
    WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0;

    -- Controlla se ci sono server in altre regioni geografiche con disponibilità
    SELECT COUNT(*) INTO ServerAltriPaesi
    FROM Server
    WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0;

    -- Scegli il server in base alle condizioni
    IF ServerNelPaese > 0 THEN
        -- Ci sono server disponibili nel Paese dell'utente
        SELECT IDserver INTO IDServer
        FROM Server
        WHERE RegioneGeografica = PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0
        LIMIT 1;
    ELSEIF ServerNellaRegione > 0 THEN
        -- Non ci sono server nel Paese, ma ci sono server nella stessa regione geografica
        SELECT IDserver INTO IDServer
        FROM Server
        WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0
        LIMIT 1;
    ELSE
        -- Non ci sono server disponibili nella stessa regione geografica, quindi scegli un'altra regione con server disponibili
        SELECT IDserver INTO IDServer
        FROM Server
        WHERE RegioneGeografica != PaeseUtente AND OnOff = 1 AND DisponibilitaBanda > 0
        LIMIT 1;
    END IF;
END//

DELIMITER ;

-- Operazione n°10: Caching

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
                WHEN EXISTS (SELECT * FROM Visualizzazione WHERE IDfilm = film_id AND IDfile NOT IN (SELECT IDfile FROM File WHERE NomeLingua IN (SELECT NomeLingua FROM LinguaUtente ORDER BY DataVisualizzazione DESC LIMIT 5)) AND IDfile NOT IN (SELECT IDfile FROM File WHERE NomeLingua IN (SELECT NomeLingua FROM SottotitoliUtente ORDER BY DataVisualizzazione DESC LIMIT 5))) THEN 0.01
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
                WHEN Durata <= (SELECT AVG(Durata) FROM Film WHERE IDfilm IN (SELECT IDfilm FROM Visualizzazione WHERE IDutente = 1 ORDER BY DataVisualizzazione DESC LIMIT 10)) THEN 0.01
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

CALL RegistraUtente('Paolo', 'Rossi', 'paolorossi@email.com', '123456789', 'Base', '7125235678451475', '09/2026', 'Paolo Rossi', '200');

CALL RinnovoMensileAbbonamento(123456789);

CALL InserisciFileInFilmSphere('TheHunt.avi', 1024, '2023-11-05', 'TheHunt', 'Italiano', 'Inglese', 'mp3', 'avi', 'Europa');

CALL InserisciValutazioneUtente(123456789, 'TheHunt', 4, '2023-11-05', 'Ottimo film, lo consiglio!');

CALL CalcolaNumeroFatturePaese('2023-10-01', 'Italia', @NumeroFatture);
SELECT @NumeroFatture;

CALL StampaStatoServer(123, @Regione, @Storage_, @OnOff, @LarghezzaBanda, @CapacitaMassima, @DisponibilitaBanda);
SELECT @Regione, @Storage_, @OnOff, @LarghezzaBanda, @CapacitaMassima, @DisponibilitaBanda;

CALL ElencoFilmPerLingua('Italiano', @NumeroFilm);
SELECT @NumeroFilm;

CALL CalcolaNumeroVisualizzazioniFilm('TheHunt', @NumeroVisualizzazioni);
SELECT @NumeroVisualizzazioni AS NumeroVisualizzazioni;

CALL ScegliServer(Titolo, IndirizzoIPUtente, @IDServer);

CALL CalcolaProbabilitàCaching(Utente);


