-- Vincoli intrarelazionali di dominio

/*ALTER TABLE Film
  ADD CONSTRAINT Check_Anno CHECK (Anno >= 1900 AND Anno <= YEAR(CURRENT_DATE));*/

ALTER TABLE Film
  ADD CONSTRAINT Check_Durata CHECK (Durata >= 5 AND Durata <= 360);

ALTER TABLE CartaDiCredito
  ADD CONSTRAINT Check_N_carta CHECK (N_carta >= '0000000000000000' AND N_carta <= '9999999999999999');

ALTER TABLE CartaDiCredito
  ADD CONSTRAINT Check_CVV CHECK (CVV >= 100 AND CVV <= 999);

/*ALTER TABLE CartaDiCredito
  ADD CONSTRAINT Check_MeseScadenza CHECK (MeseScadenza >= 1 AND MeseScadenza <= 12);

ALTER TABLE CartaDiCredito
  ADD CONSTRAINT Check_AnnoScadenza CHECK (AnnoScadenza >= YEAR(CURRENT_DATE));*/

ALTER TABLE Connessione
  ADD CONSTRAINT Check_IP CHECK (IP >= '0.0.0.0' AND IP <= '255.255.255.255');

ALTER TABLE Fattura
  ADD CONSTRAINT Check_N_cartaFattura CHECK (N_carta >= '0000000000000000' AND N_carta <= '9999999999999999');

ALTER TABLE Paese
  ADD CONSTRAINT Check_InizioIP CHECK (InizioIP >= '0.0.0.0' AND InizioIP <= '255.255.255.255');

ALTER TABLE Paese
  ADD CONSTRAINT Check_FineIP CHECK (FineIP >= '0.0.0.0' AND FineIP <= '255.255.255.255');

ALTER TABLE Premio
  ADD CONSTRAINT Check_Importanza CHECK (Importanza >= 0 AND Importanza <= 100);

ALTER TABLE ValutazioneUtente
  ADD CONSTRAINT Check_Stelle CHECK (Stelle >= 1 AND Stelle <= 5);

ALTER TABLE ValutazioneCritico
  ADD CONSTRAINT Check_Punteggio CHECK (Punteggio >= 1 AND Punteggio <= 5);

ALTER TABLE Artista
  ADD CONSTRAINT Check_Popolarità CHECK (Popolarità >= 1 AND Popolarità <= 10);

ALTER TABLE FormatoVideo
  ADD CONSTRAINT Check_FPS CHECK (FPS >= 22 AND FPS <= 60);

ALTER TABLE Abbonamento
  ADD CONSTRAINT Check_N_profili CHECK (N_profili >= 1 AND N_profili <= 10);

ALTER TABLE Abbonamento
  ADD CONSTRAINT Check_N_dispositivi CHECK (N_dispositivi >= 1 AND N_dispositivi <= 5);

-- Vincoli intrarelazionali di n-upla

ALTER TABLE Premio
  ADD CONSTRAINT Check_PremioNotNull CHECK (Attore IS NOT NULL OR Regista IS NOT NULL OR Film IS NOT NULL);

ALTER TABLE Paese
  ADD CONSTRAINT Check_PaeseOrdine CHECK (InizioIP < FineIP);

ALTER TABLE CartaDiCredito
  ADD CONSTRAINT Check_ScadenzaCarta CHECK (CONCAT(AnnoScadenza, LPAD(MeseScadenza, 2, '0')) > DATE_FORMAT(CURRENT_DATE, '%Y%m'));

ALTER TABLE Artista
  ADD CONSTRAINT Check_ArtistaNotNull CHECK (Attore IS NOT NULL OR Regista IS NOT NULL);

ALTER TABLE Connessione
  ADD CONSTRAINT Check_InizioMenoreDiFine CHECK (Inizio < Fine);

ALTER TABLE Visualizzazione
  ADD CONSTRAINT Check_InizioVMenoreDiFineV CHECK (InizioV < FineV);

-- Vincoli interrelazionali di integrità referenziale

ALTER TABLE Film add constraint fk_Film FOREIGN KEY (NomePaese) REFERENCES Paese(NomePaese);
ALTER TABLE Appartenenza add constraint fk_Appartenza1 FOREIGN KEY (Titolo) REFERENCES Film(Titolo);
ALTER TABLE Appartenenza add constraint fk_Appartenza2 FOREIGN KEY (NomeGenere) REFERENCES Genere(NomeGenere);
ALTER TABLE Partecipazione add constraint fk_Partecipazione1 FOREIGN KEY (Titolo) REFERENCES Film(Titolo);
ALTER TABLE Partecipazione add constraint fk_Partecipazione2 FOREIGN KEY (IDArtista) REFERENCES Artista(IDArtista);
ALTER TABLE Direzione add constraint fk_Direzione1 FOREIGN KEY (Titolo) REFERENCES Film(Titolo);
ALTER TABLE Direzione add constraint fk_Direzione2 FOREIGN KEY (IDArtista) REFERENCES Artista(IDArtista);
ALTER TABLE PremioArtista add constraint fk_PremioArtista1 FOREIGN KEY (CodicePremio) REFERENCES Premio(CodicePremio);
ALTER TABLE PremioArtista add constraint fk_PremioArtista2 FOREIGN KEY (IDArtista) REFERENCES Artista(IDArtista);
ALTER TABLE ValutazioneCritico add constraint fk_ValutazioneCritico1 FOREIGN KEY (IDcritico) REFERENCES Critico(IDcritico);
ALTER TABLE ValutazioneCritico add constraint fk_ValutazioneCritico2 FOREIGN KEY (Titolo) REFERENCES Film(Titolo);
ALTER TABLE PremioFilm add constraint fk_PremioFilm1 FOREIGN KEY (CodicePremio) REFERENCES Premio(CodicePremio);
ALTER TABLE PremioFilm add constraint fk_PremioFilm2 FOREIGN KEY (Titolo) REFERENCES Film(Titolo);
ALTER TABLE Sottotitolo add constraint fk_Sottotitolo1 FOREIGN KEY (NomeLingua) REFERENCES Lingua(NomeLingua);
ALTER TABLE Sottotitolo add constraint fk_Sottotitolo2 FOREIGN KEY (IDfile) REFERENCES File_(IDfile);
ALTER TABLE Doppiaggio add constraint fk_Doppiaggio1 FOREIGN KEY (NomeLingua) REFERENCES Lingua(NomeLingua);
ALTER TABLE Doppiaggio add constraint fk_Doppiaggio2 FOREIGN KEY (IDfile) REFERENCES File_(IDfile);
ALTER TABLE RestrizionePaese add constraint fk_RestrizionePaese1 FOREIGN KEY (NomePaese) REFERENCES Paese(NomePaese);
ALTER TABLE ValutazioneUtente add constraint fk_ValutazioneUtente1 FOREIGN KEY (CodiceUtente) REFERENCES Utente(CodiceUtente);
ALTER TABLE ValutazioneUtente add constraint fk_ValutazioneUtent2 FOREIGN KEY (Titolo) REFERENCES Film(Titolo);
ALTER TABLE Fattura add constraint fk_Fattura1 FOREIGN KEY (Tipologia) REFERENCES Abbonamento(Tipologia);
ALTER TABLE Fattura add constraint fk_Fattura2 FOREIGN KEY (CodiceUtente) REFERENCES Utente(CodiceUtente);
ALTER TABLE File_ add constraint fk_File_ FOREIGN KEY (Titolo) references Film(Titolo);
ALTER TABLE EstensioneAudio add constraint fk_EstensioneAudio1 FOREIGN KEY (CodiceAudio) REFERENCES FormatoAudio(CodiceAudio);
ALTER TABLE EstensioneAudio add constraint fk_EstensioneAudio2 FOREIGN KEY (IDfile) REFERENCES File_(IDfile);
ALTER TABLE EstensioneVideo add constraint fk_EstensioneVideo1 FOREIGN KEY (CodiceVideo) REFERENCES FormatoVideo(CodiceVideo);
ALTER TABLE EstensioneVideo add constraint fk_EstensioneVideo2 FOREIGN KEY (IDfile) REFERENCES File_(IDfile);
ALTER TABLE Pagamento add constraint fk_Pagamento1 FOREIGN KEY (IDfattura) REFERENCES Fattura(CodiceFattura);
ALTER TABLE Pagamento add constraint fk_Pagamento2 FOREIGN KEY (N_carta) REFERENCES CartaDiCredito(N_carta);
ALTER TABLE Connessione add constraint fk_Connessione FOREIGN KEY (CodiceUtente) REFERENCES Utente(CodiceUtente);
ALTER TABLE RestrizioneAbbonamento add constraint fk_RestrizioneAbbonamento1 FOREIGN KEY (NomePaese) REFERENCES Paese(NomePaese);
ALTER TABLE RestrizioneAbbonamento add constraint fk_RestrizioneAbbonamento2 FOREIGN KEY (Tipologia) REFERENCES Abbonamento(Tipologia);
ALTER TABLE Libreria add constraint fk_Libreria1 FOREIGN KEY (IDfile) REFERENCES File_(IDfile);
ALTER TABLE Libreria add constraint fk_Libreria2 FOREIGN KEY (Tipologia) REFERENCES Abbonamento(Tipologia);
ALTER TABLE Visualizzazione add constraint fk_Visualizzazione1 FOREIGN KEY (IP) REFERENCES Connessione(IP);
ALTER TABLE Visualizzazione add constraint fk_Visualizzazione2 FOREIGN KEY (IDserver) REFERENCES Server_(IDserver);
ALTER TABLE Visualizzazione add constraint fk_Visualizzazione3 FOREIGN KEY (IDfile) REFERENCES File_(IDfile);
ALTER TABLE Memorizzazione add constraint fk_Memorizzazione1 FOREIGN KEY (IDfile) REFERENCES File_(IDfile);
ALTER TABLE Memorizzazione add constraint fk_Memorizzazione2 FOREIGN KEY (IDserver) REFERENCES Server_(IDserver);
