## Discorso per la Presentazione
Durata stimata: ~20 minuti

---
### Slide 1 – Titolo
Camilla: Buongiorno professore. Sono Camilla Sed, insieme al mio collega Alessandro Potenza. Oggi presentiamo il nostro progetto: uno studio di replicazione sulla classificazione automatica dei generi musicali.

### Slide 2 – Introduzione al problema
Camilla: La classificazione dei generi musicali (Music Genre Classification) è un compito centrale nel Music Information Retrieval. In sostanza vogliamo addestrare un sistema che assegni automaticamente un brano al suo genere – rock, blues, classica, ecc. Le applicazioni sono molteplici: sistemi di raccomandazione, organizzazione intelligente di cataloghi, analisi su larga scala. Il nostro lavoro nasce da un risultato molto ambizioso pubblicato da Patil e colleghi: un modello basato su U‑Net che dichiara il 99.41% di accuratezza sul dataset standard GTZAN. Un valore così vicino alla perfezione ci ha spinti a verificarlo con rigore.

### Slide 3 – Obiettivi del progetto
Camilla: Gli obiettivi sono stati tre:
1. Replicare e validare: implementare l'architettura U‑Net descritta e testarla rigorosamente su GTZAN per verificare il risultato dichiarato.
2. Confrontare e analizzare: affiancare alla U‑Net altre due architetture convoluzionali significative, per capirne punti di forza e limiti relativi.
3. Estendere e generalizzare: valutare la robustezza su dataset più complessi e culturalmente differenti, verificando la reale capacità di generalizzazione del modello.

### Slide 4 – Dataset (introduzione)
Camilla: Abbiamo utilizzato quattro dataset con caratteristiche complementari. Lascio ora la parola ad Alessandro per la descrizione dettagliata.

### Slide 4 (continua) – Dataset
Alessandro: La scelta dei dati è stata strategica. GTZAN è il riferimento storico, indispensabile per la replicazione. FMA Small introduce maggiore scala e complessità ed è noto per la sua difficoltà. Il dataset Indian Music Genre ci permette di testare il trasferimento verso musica non occidentale. Infine Tabla Taala, focalizzato su cicli ritmici, ci consente di misurare la capacità del modello di specializzarsi su pattern temporali molto fini.

### Slide 5 – Dalle onde ai Mel‑spettrogrammi
Alessandro: Le CNN lavorano su immagini; trasformiamo quindi l'audio in rappresentazioni 2D: i Mel‑spettrogrammi. Rispetto a uno spettrogramma lineare, la scala Mel approssima la percezione uditiva umana. Otteniamo così una rappresentazione più informativa per la classificazione. Il flusso: campionamento, finestratura, trasformata di Fourier, proiezione su scala Mel, log‑compressione.

### Slide 6 – Visualizzazione delle feature
Alessandro: Qui vediamo la differenza tra forma d'onda e Mel‑spettrogramma per due brani (Blues e Classica). Le differenze strutturali e di tessitura spettrale evidenziano perché questa trasformazione renda il problema trattabile per una CNN.

### Slide 7 – Partizionamento e slicing
Alessandro: GTZAN contiene solo 1000 tracce: pochino per il deep learning. Segmentiamo ogni brano di 30 secondi in dieci clip da 3 secondi, ampliando il training set di un ordine di grandezza. Il punto critico è evitare il data leakage: se segmentassimo prima e dividessimo poi in modo casuale, clip provenienti dallo stesso brano finirebbero sia nel training sia nel test. Il modello imparerebbe l'impronta specifica del brano (audio fingerprinting implicito), non il genere. Per evitare questo imbroglio, prima suddividiamo a livello di brano in training / validation / test, poi effettuiamo lo slicing all'interno di ciascun split. Questo rigore metodologico distingue il nostro lavoro e rende i risultati scientificamente solidi.

### Slide 8 – Architetture di confronto
Camilla: Abbiamo implementato tre modelli. Efficient‑VGG: leggero (≈35k parametri), baseline efficiente. ResSE‑AudioCNN: architettura più profonda in stile ResNet (≈1.2M parametri) con skip connection e maggiore capacità. Servono come termini di paragone equilibrati per prestazioni e complessità.

### Slide 9 – Il classificatore U‑Net
Camilla: La nostra implementazione dell'idea del paper utilizza solo il ramo encoder della U‑Net, sfruttando la progressiva astrazione gerarchica delle feature. In coda applichiamo Global Average Pooling e un denso finale per la classificazione. Con circa 1.18M parametri, la complessità è comparabile al modello ResNet, ma l'organizzazione multi‑scala dell'encoder facilita la cattura di pattern sia locali sia contestuali.

### Slide 10 – Protocollo di training
Camilla: Standardizziamo ogni aspetto: ottimizzatore Adam, cross‑entropy, early stopping, gestione dei semi per piena riproducibilità, stessi callback e scheduling. Questo minimizza le variabili confondenti nel confronto fra architetture.

### Slide 11 – Iperparametri chiave
Camilla: La tabella riporta i principali iperparametri. L'enfasi non è sui valori assoluti, ma sulla loro coerenza attraverso tutti gli esperimenti: condizione necessaria per un confronto equo e riproducibile.

### Slide 12 – Risultati GTZAN (overview)
Alessandro: La U‑Net risulta il modello più performante nel nostro setup, emergendo chiaramente sugli altri due in termini di accuratezza mantenendo efficienza parametrica.

### Slide 13 – Metriche GTZAN
Alessandro: Sul test set l'U‑Net raggiunge l'82.3%, circa tre punti sopra il modello ResNet‑like. Interessante il fatto che ottenga questo vantaggio con una leggera riduzione della latenza e una capacità simile in termini di parametri.

### Slide 14 – Accuratezza vs Efficienza
Alessandro: Il grafico posiziona i modelli nello spazio prestazioni/efficienza. La U‑Net occupa la regione desiderata: accurata e relativamente leggera. Il trade‑off è dunque favorevole.

### Slide 15 – Ablation: SpecAugment
Alessandro: Abbiamo valutato l'effetto di SpecAugment (mascheramento di bande di frequenza e intervalli temporali). Solo la U‑Net trae un beneficio netto; i modelli più piccoli subiscono un lieve degrado, probabilmente perché l'augmentation riduce segnali informativi oltre la loro capacità di compensazione. Indica che la complessità del modello condiziona l'utilità di certe tecniche di robustificazione.

### Slide 16 – Risultati SpecAugment
Alessandro: Il grafico conferma: guadagno moderato ma consistente per U‑Net, lieve peggioramento per gli altri due modelli.

### Slide 17 – Robustezza: 5‑Fold Cross‑Validation
Alessandro: Per ridurre la dipendenza da un singolo split abbiamo eseguito una 5‑fold cross‑validation su GTZAN con U‑Net. Otteniamo una media di validazione del 90.44%. È superiore all'82.3% sul test finale perché ogni fold usa una frazione maggiore di dati per il training. Il punto chiave è la deviazione standard estremamente bassa: indica stabilità e supporta la generalità del modello, non un risultato fortunato.

### Slide 18 – Analisi qualitativa del modello
Alessandro: Oltre alla metrica aggregata, analizziamo dove il modello eccelle e dove mostra fragilità, per orientare possibili estensioni future.

### Slide 19 – Classification report
Alessandro: Generi con firme acustiche nette (Classica, Jazz) raggiungono F1 molto elevati (Classica 0.98). Rock scende a 0.61, penalizzato dal recall. Evidenzia interferenze spettrali e sovrapposizioni timbriche tra generi contigui.

### Slide 20 – Confusion matrix (visualizzazione)
Alessandro: La matrice fornisce la mappa degli errori e prepara l'interpretazione dettagliata.

### Slide 21 – Analisi della confusion matrix
Alessandro: La diagonale marcata conferma l'accuratezza globale. Le confusioni Rock→Country/Disco e Reggae→Hiphop non sono casuali ma riflettono prossimità spettrale e strutturale. Su clip di soli 3 secondi il contesto armonico e ritmico è limitato; distinguere generi così simili potrebbe richiedere finestre temporali più lunghe.

### Slide 22 – Oltre GTZAN: generalizzazione cross‑dataset
Camilla: Esploriamo ora la trasferibilità: addestramento da zero su un dataset complesso (FMA) e transfer learning verso domini diversi (Indian, Tabla). Due strategie complementari per valutare robustezza e riuso delle feature.

### Slide 23 – Risultati di generalizzazione
Camilla: Il grafico sintetizza il quadro. Training da zero su FMA Small: 41.1% (coerente con la difficoltà del benchmark). Fine‑tuning del modello pre‑addestrato su GTZAN: salti al 72.2% su Indian Music Genre e al 96.5% su Tabla Taala. Figure: The U-Net's performance across all datasets. Transfer learning (Indian, Tabla) yields significantly better results than training from scratch on a complex dataset (FMA), highlighting the adaptability of the learned features.

### Slide 24 – Interpretazione dei risultati
Camilla: Il 41.1% su FMA, pur non elevato, supera di molto il caso e conferma la natura impegnativa del dataset. Il 72.2% su musica non occidentale mostra che molte feature timbriche e ritmiche apprese su GTZAN sono riutilizzabili. Il 96.5% su Tabla indica una forte capacità di adattamento a un compito diverso (pattern ritmici ciclici) partendo da feature più generali.

### Slide 25 – Matrici di confusione cross‑dataset
Camilla: Le matrici per GTZAN e Tabla mostrano diagonali pulite; quella per FMA appare più diffusa, coerente con l'elevata sovrapposizione tra classi e la maggiore variabilità interna.

### Slide 26 – Discrepanza con il paper originale
Alessandro: Rimane la domanda: perché non raggiungiamo il 99.41% riportato da Patil et al.? Una differenza di circa 9 punti percentuali è troppo ampia per attribuirla a meri dettagli implementativi.

### Slide 27 – Possibili cause della discrepanza
Alessandro: L'ipotesi principale è metodologica: data splitting potenzialmente effettuato dopo lo slicing, generando leakage (clip sorelle in train e test) e di fatto trasformando il problema in audio fingerprinting, più semplice e meno rappresentativo della generalizzazione reale. A questo si aggiungono ambiguità nella descrizione del loro "modello matematico" e l'eccezionalità statistica del 99.41% rispetto al tipico intervallo 90–95% della letteratura.

### Slide 28 – Conferma dell'efficienza architetturale
Alessandro: Pur non replicando l'accuratezza dichiarata, confermiamo un punto sostanziale del paper: l'encoder U‑Net offre un eccellente equilibrio fra costo computazionale e prestazioni rispetto a una ResNet standard di capacità simile.

### Slide 29 – Conclusioni e contributi principali
Alessandro: Riassumendo:
1. L'encoder U‑Net è un'architettura efficace: otteniamo un benchmark trasparente e riproducibile del 90.44% (media CV) su GTZAN.
2. Il 99.41% del paper di riferimento è molto probabilmente influenzato da fattori metodologici (verosimile data leakage) più che da superiorità architetturale.
3. Il modello mostra forte adattabilità tramite transfer learning (fino al 96.5% su Tabla Taala) anche in domini culturalmente e strutturalmente differenti.
4. Rilevanza del rigore: il progetto evolve da semplice replicazione a caso di studio sulla trasparenza e sulle pratiche sperimentali corrette. In definitiva, questo lavoro diventa soprattutto un contributo metodologico: evidenzia quanto un protocollo accurato sia determinante per attribuire valore scientifico ai risultati.

---
Fine.