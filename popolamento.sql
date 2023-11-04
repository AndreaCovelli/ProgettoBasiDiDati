DELIMITER //

CREATE PROCEDURE PopolaFilm()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 100 DO
    INSERT INTO Film (Titolo, Descrizione, Genere, AnnoProduzione, Durata, Rating, NumeroVisualizzazioni, NomePaese)
    VALUES ('Titolo' || i, 'Descrizione' || i, 'Genere' || i, 2022, 120, 8.0, 0, 'Paese' || i);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaGenere()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE generi VARCHAR(50);
  SET generi = 'Azione,Commedia,Drammatico,Horror,Fantascienza,Fantasy,Giallo,Romantico,Animazione,Documentario,Thriller,Avventura,Musical,Western,Biografico';
  
  WHILE i <= 15 DO
    INSERT INTO Genere (NomeGenere)
    VALUES (SUBSTRING_INDEX(SUBSTRING_INDEX(generi, ',', i), ',', -1));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaAppartenenza()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE film_generi VARCHAR(500);
  SET film_generi = 
    'Titolo1:Azione,Commedia;Titolo2:Drammatico,Romantico;Titolo3:Fantascienza;Titolo4:Commedia,Thriller;Titolo5:Animazione,Fantasy;Titolo6:Horror,Thriller;Titolo7:Drammatico;Titolo8:Avventura,Azione;Titolo9:Commedia,Romantico;Titolo10:Fantasy;Titolo11:Drammatico,Romantico;Titolo12:Giallo;Titolo13:Commedia,Drammatico;Titolo14:Horror,Fantascienza;Titolo15:Avventura,Romantico';
  
  WHILE i <= 15 DO
    INSERT INTO Appartenenza (Titolo, NomeGenere)
    VALUES (SUBSTRING_INDEX(SUBSTRING_INDEX(film_generi, ';', i), ':', 1), 
            SUBSTRING_INDEX(SUBSTRING_INDEX(film_generi, ';', i), ':', -1));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaArtista()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 36 DO
    INSERT INTO Artista (IDArtista, Nome, Cognome, Popolarità)
    VALUES (i, 'Nome' || i, 'Cognome' || i, FLOOR(RAND() * 100));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaPartecipazione()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 600 DO
    INSERT INTO Partecipazione (Titolo, IDArtista, Ruolo)
    VALUES ('Titolo' || CEIL(RAND() * 100), CEIL(RAND() * 36), 'Ruolo' || i);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaDirezione()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 100 DO
    INSERT INTO Direzione (Titolo, IDArtista)
    VALUES ('Titolo' || CEIL(RAND() * 100), CEIL(RAND() * 36));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaPremio()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 60 DO
    INSERT INTO Premio (CodicePremio, Nome, Importanza, Anno, Regista, Film, Attore)
    VALUES (i, 'Premio' || i, 'Alta', 2022, 'Regista' || i, 'Titolo' || CEIL(RAND() * 100), 'Attore' || i);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaPremioArtista()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE premi_artisti VARCHAR(200);
  SET premi_artisti = 
    '1:1,2;2:3,4;3:5,6;4:7,8;5:9,10;6:11,12;7:13,14;8:15,16;9:17,18;10:19,20';
  
  WHILE i <= 10 DO
    INSERT INTO PremioArtista (CodicePremio, IDArtista)
    VALUES (SUBSTRING_INDEX(SUBSTRING_INDEX(premi_artisti, ';', i), ':', 1), 
            SUBSTRING_INDEX(SUBSTRING_INDEX(premi_artisti, ';', i), ':', -1));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaPremioFilm()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE premi_film VARCHAR(100);
  SET premi_film = '1:1,2;2:3,4;3:5,6;4:7,8;5:9,10;6:11,12;7:13,14;8:15,16;9:17,18;10:19,20';

  WHILE i <= 10 DO
    INSERT INTO PremioFilm (CodicePremio, Titolo)
    VALUES (SUBSTRING_INDEX(SUBSTRING_INDEX(premi_film, ';', i), ':', 1), 
            SUBSTRING_INDEX(SUBSTRING_INDEX(premi_film, ';', i), ':', -1));
    SET i = i + 1;
  END WHILE;

END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaPaese()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE regione VARCHAR(255);
  
  WHILE i <= 80 DO
    SET regione = 'Regione' || CEIL(RAND() * 10);
    INSERT INTO Paese (NomePaese, InizioIP, FineIP, RegioneGeografica)
    VALUES ('Paese' || i, '192.168.' || CEIL(RAND() * 255) || '.' || CEIL(RAND() * 255), '192.168.' || CEIL(RAND() * 255) || '.' || CEIL(RAND() * 255), regione);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaCritico()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 20 DO
    INSERT INTO Critico (IDcritico, Nome, Cognome)
    VALUES (i, 'NomeCritico' || i, 'CognomeCritico' || i);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaValutazioneCritico()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 50 DO
    INSERT INTO ValutazioneCritico (IDcritico, Titolo, Testo, Data, Punteggio)
    VALUES (CEIL(RAND() * 20), 'Titolo' || CEIL(RAND() * 100), 'TestoCritico' || i, CURDATE(), CEIL(RAND() * 5));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaLingua()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE lingue VARCHAR(100);
  SET lingue = 'Inglese;Spagnolo;Francese;Italiano;Tedesco;Portoghese;Olandese;Svedese;Norvegese;Danese';

  WHILE i <= 10 DO
    INSERT INTO Lingua (NomeLingua, NumeroFilm)
    VALUES (SUBSTRING_INDEX(lingue, ';', i), FLOOR(RAND() * 1000) + 1);
    SET i = i + 1;
  END WHILE;

END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaSottotitolo()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 300 DO
    INSERT INTO Sottotitolo (NomeLingua, IDfile)
    VALUES ('Lingua' || i, CEIL(RAND() * 400));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaDoppiaggio()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 200 DO
    INSERT INTO Doppiaggio (NomeLingua, IDfile)
    VALUES ('Lingua' || i, CEIL(RAND() * 400));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaRestrizionePaese()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 20 DO
    INSERT INTO RestrizionePaese (NomePaese, IDfile)
    VALUES ('Paese' || i, CEIL(RAND() * 400));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaUtente()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 1000 DO
    INSERT INTO Utente (CodiceUtente, Nome, Cognome, Email, Paese, Password, IDultimaFattura, N°carta)
    VALUES (i, 'NomeUtente' || i, 'CognomeUtente' || i, 'utente' || i || '@esempio.com', 'Paese' || CEIL(RAND() * 80), 'Password' || i, CEIL(RAND() * 2500), 'Carta' || i);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaValutazioneUtente()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 3000 DO
    INSERT INTO ValutazioneUtente (CodiceUtente, Titolo, Stelle, Data, Feedback)
    VALUES (CEIL(RAND() * 1000), 'Titolo' || CEIL(RAND() * 100), CEIL(RAND() * 5), CURDATE(), 'FeedbackUtente' || i);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaFattura()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 2500 DO
    INSERT INTO Fattura (CodiceFattura, DataPagamento, Importo, Tipologia, CodiceUtente)
    VALUES (i, DATE_SUB(CURDATE(), INTERVAL CEIL(RAND() * 30) DAY), CEIL(RAND() * 100), 'Tipologia' || CEIL(RAND() * 5), CEIL(RAND() * 1000));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaAbbonamento()
BEGIN
  INSERT INTO Abbonamento (Tipologia, Tariffa, N_profili, Pubblicità, N_dispositivi, Download, N_max_ore)
  VALUES ('Tipo1', 10.99, 2, 'Sì', 1, 'Sì', 24),
         ('Tipo2', 14.99, 4, 'No', 2, 'Sì', 48),
         ('Tipo3', 19.99, 6, 'No', 3, 'No', 72),
         ('Tipo4', 24.99, 8, 'Sì', 4, 'Sì', 96),
         ('Tipo5', 29.99, 10, 'No', 5, 'No', 120);
 
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaPagamento()
BEGIN
  DECLARE i INT DEFAULT 1;

  WHILE i <= 2500 DO
    INSERT INTO Pagamento (IDfattura, DataPagamento, N°carta)
    VALUES (FLOOR(RAND() * 2500) + 1, NOW() - INTERVAL FLOOR(RAND() * 365) DAY, LPAD(FLOOR(RAND() * 10000), 4, '0'));
    SET i = i + 1;
  END WHILE;

END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaCartaDiCredito()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 1000 DO
    INSERT INTO CartaDiCredito (N_carta, DataScadenza, Intestatario, CVV)
    VALUES ('Carta' || i, DATE_ADD(CURDATE(), INTERVAL CEIL(RAND() * 5) YEAR), 'Intestatario' || i, LPAD(CEIL(RAND() * 999), 3, '0'));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaRestrizioneAbbonamento()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 50 DO
    INSERT INTO RestrizioneAbbonamento (NomePaese, Tipologia)
    VALUES ('Paese' || i, 'Tipo' || CEIL(RAND() * 5));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaLibreria()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 1500 DO
    INSERT INTO Libreria (IDfile, Tipologia)
    VALUES (CEIL(RAND() * 400), 'Tipo' || CEIL(RAND() * 5));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaConnessione()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 5000 DO
    INSERT INTO Connessione (IP, RisoluzioneSchermoDispositivo, TipoDispositivo, MAC, Inizio, Fine, CodiceUtente)
    VALUES (CONCAT('192.168.', CEIL(RAND() * 255), '.', CEIL(RAND() * 255)),
            CONCAT(CEIL(RAND() * 1920), 'x', CEIL(RAND() * 1080)),
            'Tipo' || CEIL(RAND() * 5), CONCAT(UCASE(HEX(FLOOR(RAND() * 1000))),
            '-', UCASE(HEX(FLOOR(RAND() * 1000))),
            '-', UCASE(HEX(FLOOR(RAND() * 1000)))), NOW() - INTERVAL CEIL(RAND() * 30) DAY,
            NOW(), CEIL(RAND() * 1000));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaServer()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 80 DO
    INSERT INTO Server (IDserver, Storage_, RegioneGeografica, On_Off, DisponibilitàBanda, CapacitàMassima, LunghezzaBanda)
    VALUES (i, CONCAT(CEIL(RAND() * 2000), ' GB'), 'Regione' || CEIL(RAND() * 5),
            'Sì', CEIL(RAND() * 1000), CONCAT(CEIL(RAND() * 2000), ' GB'),
            CONCAT(CEIL(RAND() * 200), ' Mbps'));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaMemorizzazione()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 4800 DO
    INSERT INTO Memorizzazione (IDfile, IDserver)
    VALUES (CEIL(RAND() * 6000), CEIL(RAND() * 80));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaVisualizzazione()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 5000 DO
    INSERT INTO Visualizzazione (IDvisualizzazione, InizioV, FineV, IP, IDserver, IDfile)
    VALUES (i, NOW() - INTERVAL CEIL(RAND() * 30) DAY, NOW(), CONCAT('192.168.', CEIL(RAND() * 255), '.', CEIL(RAND() * 255)),
            CEIL(RAND() * 80), CEIL(RAND() * 6000));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaFile()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 400 DO
    INSERT INTO File_(IDfile, Dimensione, DataRilascio, Titolo)
    VALUES (i, 'File' || i, CONCAT(CEIL(RAND() * 2000), ' MB'),
            DATE_SUB(NOW(), INTERVAL CEIL(RAND() * 365) DAY), 'Titolo' || CEIL(RAND() * 100));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaFormatoAudio()
BEGIN
  INSERT INTO FormatoAudio (CodiceAudio, BitRateAudio, BitDepth)
  VALUES ('Codec1', '128 kbps', '16 bit'),
         ('Codec2', '192 kbps', '16 bit'),
         ('Codec3', '256 kbps', '24 bit'),
         ('Codec4', '320 kbps', '16 bit'),
         ('Codec5', '192 kbps', '24 bit'),
         ('Codec6', '256 kbps', '16 bit'),
         ('Codec7', '320 kbps', '24 bit'),
         ('Codec8', '128 kbps', '24 bit');
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaEstensioneAudio()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 400 DO
    INSERT INTO EstensioneAudio (CodiceAudio, IDfile)
    VALUES ('Codec' || CEIL(RAND() * 8), CEIL(RAND() * 6000));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaFormatoVideo()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 10 DO
    INSERT INTO FormatoVideo (CodiceVideo, FPS, Risoluzione, BitRateVideo, RapportoAspetto)
    VALUES ('Formato' || i, FLOOR(RAND() * 30) + 10, 'Risoluzione' || i, FLOOR(RAND() * 5000) + 1000, 'Rapporto' || i);
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE PopolaEstensioneVideo()
BEGIN
  DECLARE i INT DEFAULT 1;
  
  WHILE i <= 400 DO
    INSERT INTO EstensioneVideo (CodiceVideo, IDfile)
    VALUES ('Codec' || CEIL(RAND() * 10), CEIL(RAND() * 6000));
    SET i = i + 1;
  END WHILE;
  
END//

DELIMITER ;

