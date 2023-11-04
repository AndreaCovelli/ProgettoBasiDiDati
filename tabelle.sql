-- Creazione del database
CREATE DATABASE IF NOT EXISTS FilmSphere;

-- Utilizzo del database
USE FilmSphere;

-- Tabella "Area contenuti"

CREATE TABLE Film (
    Titolo VARCHAR(255) PRIMARY KEY,
    Descrizione TEXT,
    Genere VARCHAR(255),
    AnnoProduzione INT,
    Durata INT,
    Rating DECIMAL(3, 1),
    NumeroVisualizzazioni BIGINT,
    NomePaese VARCHAR(255)
);

CREATE TABLE Genere (
    NomeGenere VARCHAR(255) PRIMARY KEY
);

CREATE TABLE Appartenenza (
    Titolo VARCHAR(255),
    NomeGenere VARCHAR(255),
    PRIMARY KEY (Titolo, NomeGenere)
);

CREATE TABLE Partecipazione (
    Titolo VARCHAR(255),
    IDArtista INT,
    Ruolo VARCHAR(255),
    PRIMARY KEY (Titolo, IDArtista)
);

CREATE TABLE Direzione (
    Titolo VARCHAR(255),
    IDArtista INT,
    PRIMARY KEY (Titolo, IDArtista)
);

CREATE TABLE Artista (
    IDArtista INT auto_increment PRIMARY KEY,
    Nome VARCHAR(255),
    Cognome VARCHAR(255),
    Popolarità DECIMAL(3, 1)
);

CREATE TABLE PremioArtista (
    CodicePremio INT PRIMARY KEY,
    IDArtista INT
);

CREATE TABLE PremioFilm (
    CodicePremio INT PRIMARY KEY,
    Titolo VARCHAR(255)
);

CREATE TABLE Premio (
    CodicePremio INT auto_increment PRIMARY KEY,
    Nome VARCHAR(255),
    Importanza VARCHAR(255),
    Anno INT,
    Regista VARCHAR(255),
    Film VARCHAR(255),
    Attore VARCHAR(255)
);

CREATE TABLE ValutazioneCritico (
    IDcritico INT,
    Titolo VARCHAR(255),
    Testo TEXT,
    Data_ DATE,
    Punteggio DECIMAL(3, 1),
	PRIMARY KEY(IDCritico, Titolo)
);

CREATE TABLE Critico (
    IDcritico INT auto_increment PRIMARY KEY,
    Nome VARCHAR(255),
    Cognome VARCHAR(255)
);

CREATE TABLE Sottotitolo (
    NomeLingua VARCHAR(255),
    IDfile INT,
    PRIMARY KEY (NomeLingua, IDfile)
);

CREATE TABLE Doppiaggio (
    NomeLingua VARCHAR(255),
    IDfile INT,
    PRIMARY KEY (NomeLingua, IDfile)
);

CREATE TABLE Lingua (
    NomeLingua VARCHAR(255) PRIMARY KEY,
    NumeroFilm BIGINT
);

CREATE TABLE Paese (
    NomePaese VARCHAR(255) PRIMARY KEY,
    InizioIP VARCHAR(255),
    FineIP VARCHAR(255)
);

CREATE TABLE RestrizionePaese (
    NomePaese VARCHAR(255),
    IDfile INT,
    PRIMARY KEY (NomePaese, IDfile)
);

-- Tabella "Area formati"
CREATE TABLE File_(
    IDfile VARCHAR(255) PRIMARY KEY,
    Dimensione DECIMAL(10, 2),
    DataRilascio DATE,
    Titolo VARCHAR(255)
);

CREATE TABLE EstensioneAudio (
    CodiceAudio VARCHAR(255) PRIMARY KEY,
    IDfile VARCHAR(255)
);

CREATE TABLE EstensioneVideo (
    CodiceVideo VARCHAR(255) PRIMARY KEY,
    IDfile VARCHAR(255)
);

CREATE TABLE FormatoAudio (
    CodiceAudio VARCHAR(255) PRIMARY KEY,
    BitRateAudio INT,
    BitDepth INT
);

CREATE TABLE FormatoVideo (
    CodiceVideo VARCHAR(255) PRIMARY KEY,
    FPS DECIMAL(4, 2),
    Risoluzione VARCHAR(255),
    BitRateVideo INT,
    RapportoAspetto VARCHAR(255)
);

-- Tabella "Area clienti"
CREATE TABLE Utente (
    CodiceUtente INT auto_increment PRIMARY KEY,
    Nome VARCHAR(255),
    Cognome VARCHAR(255),
    EMail VARCHAR(255),
    Paese VARCHAR(255),
    Password_ VARCHAR(255),
    IDultimaFattura BIGINT,
    N_carta VARCHAR(255)
);

CREATE TABLE ValutazioneUtente (
    CodiceUtente INT,
    Titolo VARCHAR(255),
    Stelle INT,
    Data_ DATE,
    Feedback TEXT,
    PRIMARY KEY (CodiceUtente, Titolo)
);

CREATE TABLE Fattura (
    CodiceFattura INT auto_increment PRIMARY KEY,
    DataPagamento DATE,
    Importo DECIMAL(10, 2),
    Tipologia VARCHAR(255),
    CodiceUtente INT
);

CREATE TABLE Pagamento (
    IDfattura INT,
    DataPagamento DATE,
    N_carta VARCHAR(255),
    PRIMARY KEY(IDfattura,DataPagamento)
);

CREATE TABLE CartaDiCredito (
    N_carta VARCHAR(255) PRIMARY KEY,
    DataScadenza DATE,
    Intestatario VARCHAR(255),
    CVV VARCHAR(255)
);

CREATE TABLE Connessione (
    IP VARCHAR(255) PRIMARY KEY,
    RisoluzioneSchermoDispositivo VARCHAR(255),
    TipoDispositivo VARCHAR(255),
    MAC VARCHAR(255),
    Inizio DATETIME,
    Fine DATETIME,
    CodiceUtente INT
);

CREATE TABLE Abbonamento (
    Tipologia VARCHAR(255) PRIMARY KEY,
    Tariffa DECIMAL(10, 2),
    N_profili INT,
    Pubblicità VARCHAR(255),
    N_dispositivi INT,
    Download VARCHAR(255),
    N_max_ore INT
);

CREATE TABLE RestrizioneAbbonamento (
    NomePaese VARCHAR(255),
    Tipologia VARCHAR(255),
    PRIMARY KEY (NomePaese, Tipologia)
);

CREATE TABLE Libreria (
    IDfile INT PRIMARY KEY,
    Tipologia VARCHAR(255)
);

-- Tabella "Area streaming"
CREATE TABLE Visualizzazione (
    IDvisualizzazione INT auto_increment PRIMARY KEY,
    InizioV DATETIME,
    FineV DATETIME,
    IP VARCHAR(255),
    IDserver INT,
    IDfile INT
);

CREATE TABLE Server_(
    IDserver INT auto_increment PRIMARY KEY,
    Storage_ DECIMAL(12, 2),
    RegioneGeografica VARCHAR(255),
    On_Off BOOL,
    DisponibilitàBanda DECIMAL(12, 2),
    CapacitàMassima DECIMAL(12, 2),
    LarghezzaBanda DECIMAL(12, 2)
);

CREATE TABLE Memorizzazione (
    IDfile INT,
    IDserver INT,
    PRIMARY KEY (IDfile, IDserver)
);

