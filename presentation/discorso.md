## Discorso per la Presentazione
Durata stimata: ~24–25 minuti

---
### Slide 1 – Titolo
Camilla: Buongiorno professore. Sono Camilla Sed, insieme al mio collega Alessandro Potenza. Oggi presentiamo il nostro progetto: uno studio di replicazione sulla classificazione automatica dei generi musicali.

### Slide 2 – Introduzione al problema
Camilla: La classificazione dei generi musicali (Music Genre Classification) è un compito centrale nel Music Information Retrieval. In termini molto concreti: date alcune decine di secondi di audio, vogliamo che un sistema assegni il genere corretto – rock, blues, classica, ecc. Questo abilita servizi di raccomandazione più intelligenti, organizzazione automatica delle librerie, estrazione di metadati in archivi di grandi dimensioni. Il dominio è anche metodologicamente interessante perché i generi non sono entità rigidamente definite: esiste sovrapposizione timbrica, ibridazione stilistica, e rumore etichettativo nei dataset.
Un punto di partenza del nostro lavoro è stato un risultato pubblicato recentemente da Patil e colleghi: un modello basato su U‑Net che dichiara il 99.41% di accuratezza sul dataset GTZAN. Un valore quasi perfetto su un benchmark notoriamente imperfetto e rumoroso. Questo scarto rispetto alla fascia tipica (90–95% nei migliori lavori) ci ha spinto a chiederci: è davvero un salto architetturale, oppure c’è una spiegazione metodologica? Da qui nasce l'idea di una replica rigorosa, con estensioni controllate.

### Slide 3 – Obiettivi del progetto
Camilla: Gli obiettivi sono stati tre, formulati per isolare cause e valutare robustezza.
1. Replicare e validare: implementare l'architettura U‑Net descritta (o ricostruibile dai dettagli disponibili) e testarla in una pipeline controllata su GTZAN per verificare la plausibilità del 99.41%.
2. Confrontare e analizzare: includere due architetture rappresentative (una leggera e una più profonda) con identico protocollo, in modo da attribuire differenze a scelte strutturali e non a iperparametri.
3. Estendere e generalizzare: spingere il modello oltre il dominio originale, testando trasferibilità su dataset più ampi (FMA), culturalmente diversi (Indian) e ritmicamente specializzati (Tabla). L'obiettivo è misurare se le feature apprese siano riusabili o se collassino fuori dal dominio.
In filigrana c'è anche un quarto obiettivo implicito: produrre un benchmark trasparente, con codice riproducibile e scelte motivate, proprio per mitigare l'ambiguità che abbiamo riscontrato nel lavoro di partenza.

### Slide 4 – Dataset (introduzione)
Camilla: Abbiamo utilizzato quattro dataset con caratteristiche complementari. Lascio ora la parola ad Alessandro per la descrizione dettagliata.

### Slide 4 (continua) – Dataset
Camilla: La scelta dei dati è stata strategica. GTZAN è il riferimento storico (10 generi × 100 tracce), indispensabile per la replicazione. Sappiamo che contiene alcune problematiche note (duplicati, clip potenzialmente corrotti in alcune distribuzioni); abbiamo utilizzato una versione pulita e documentato l'elenco dei file usati per garantire tracciabilità.
FMA Small introduce maggiore scala (8k tracce) e diversità reale: più rumore etichettativo e maggiore eterogeneità di produzione audio. È un banco di prova per la scalabilità delle feature.
Il dataset Indian Music Genre ci permette di valutare un cambio culturale: cambiamenti nelle scale, strumenti, strutture timbriche. Qui testiamo quanto le feature apprese siano realmente “musicali” e non sovra‑specializzate su stile occidentale.
Infine Tabla Taala, focalizzato su cicli ritmici con strutture metriche ripetitive, ci permette di verificare se un encoder addestrato prevalentemente su pattern armonico‑melodici possa essere ri‑adattato a un compito dominato da micro‑pattern ritmici.

### Slide 5 – Dalle onde ai Mel‑spettrogrammi
Camilla: Le CNN lavorano su immagini; trasformiamo quindi l'audio in rappresentazioni 2D: i Mel‑spettrogrammi. Usiamo tipicamente 128 mel bins, una finestra (FFT window) di 2048 campioni e un hop di 512 (75% overlap). Questo compromesso offre sufficiente risoluzione in frequenza per distinguere timbri e un numero gestibile di frame temporali nei 3 secondi. Dopo la STFT applichiamo il banco di filtri Mel, il log scaling e normalizziamo solo usando statistiche del training set (per evitare leakage). Questa pipeline rende il problema vicino all'image classification mantenendo informazione rilevante per genere e ritmo.

### Slide 6 – Visualizzazione delle feature
Camilla: Qui vediamo la differenza tra forma d'onda e Mel‑spettrogramma per due brani (Blues e Classica). Le differenze strutturali e di tessitura spettrale evidenziano perché questa trasformazione renda il problema trattabile per una CNN.

### Slide 7 – Partizionamento e slicing
Camilla: GTZAN contiene solo 1000 tracce: pochino per il deep learning. Segmentiamo ogni brano di 30 secondi in dieci clip da 3 secondi, ampliando il training set di un ordine di grandezza. Perché 3 secondi? È un compromesso: abbastanza lunghi da includere frammenti ritmici e intervalli armonici, abbastanza corti da moltiplicare i campioni e ridurre overfitting. Abbiamo testato anche 2 e 5 secondi in analisi preliminari: 2 secondi aumentavano il rumore, 5 riducevano la variabilità di batch.
Il punto critico è evitare il data leakage: se segmentassimo prima e dividessimo poi casualmente, clip dello stesso brano apparirebbero in train e test e il modello imparerebbe l'impronta specifica (fingerprinting) invece delle invarianti di genere. Per evitare questo imbroglio, prima suddividiamo a livello di brano (train / validation / test) mantenendo stratificazione, poi effettuiamo lo slicing dentro ciascuno split. Questo rigore metodologico distingue il nostro lavoro e rende i risultati scientificamente solidi. In aggiunta, generiamo i batch mescolando clip di brani diversi per evitare correlazione sequenziale.

### Slide 8 – Architetture di confronto
Camilla: Abbiamo implementato tre modelli. Efficient‑VGG: leggero (≈35k parametri), baseline efficiente. ResSE‑AudioCNN: architettura più profonda in stile ResNet (≈1.2M parametri) con skip connection e maggiore capacità. Servono come termini di paragone equilibrati per prestazioni e complessità.

### Slide 9 – Il classificatore U‑Net
Camilla: La nostra implementazione dell'idea del paper utilizza solo il ramo encoder della U‑Net, sfruttando la progressiva astrazione gerarchica delle feature. In coda applichiamo Global Average Pooling e un denso finale per la classificazione. Con circa 1.18M parametri, la complessità è comparabile al modello ResNet, ma l'organizzazione multi‑scala dell'encoder facilita la cattura di pattern sia locali sia contestuali.

### Slide 10 – Protocollo di training
Camilla: Standardizziamo ogni aspetto: ottimizzatore Adam (lr iniziale 1e-3 con riduzione on plateau), cross‑entropy categoriale, early stopping con pazienza di 12 epoch sulla validation accuracy, restore dei pesi migliori, gradient clipping dove necessario per stabilità. Fissiamo tutti i semi (Python, NumPy, TensorFlow) e usiamo deterministic ops dove possibile. Stesso scheduler, stessa dimensione batch (32), stessa normalizzazione per tutti. Questo minimizza le variabili confondenti nel confronto fra architetture. L'hardware principale: GPU Nvidia serie RTX; riportiamo i tempi di epoca e la latenza media di inferenza su batch di 1 per trasparenza sperimentale.

### Slide 11 – Iperparametri chiave
Camilla: La tabella riporta i principali iperparametri (lr iniziale, scheduler, batch size, numero massimo di epoch, pazienza dell'early stopping, dropout, specaugment mask parametri). L'enfasi non è sui valori assoluti, ma sulla loro coerenza: mantenerli invariati ci permette di attribuire differenze di performance a scelte architetturali e non a fine‑tuning opportunistico.

### Slide 12 – Risultati GTZAN (overview)
Camilla: La U‑Net risulta il modello più performante nel nostro setup, emergendo chiaramente sugli altri due in termini di accuratezza mantenendo efficienza parametrica.

### Slide 13 – Metriche GTZAN
Camilla: Sul test set l'U‑Net raggiunge l'82.3%, circa tre punti sopra il modello ResNet‑like. Interessante il fatto che ottenga questo vantaggio con una leggera riduzione della latenza e una capacità simile in termini di parametri. La latenza è misurata come media di 100 forward pass su singolo clip (warm‑up escluso). Questo fornisce un indicatore pratico per eventuale deploy.

### Slide 14 – Accuratezza vs Efficienza
Camilla: Il grafico posiziona i modelli nello spazio prestazioni/efficienza. La U‑Net occupa la regione desiderata: accurata e relativamente leggera. Il trade‑off è dunque favorevole.

### Slide 15 – Ablation: SpecAugment
Camilla: Abbiamo valutato l'effetto di SpecAugment (mascheramento di bande di frequenza e intervalli temporali). Solo la U‑Net trae un beneficio netto; i modelli più piccoli subiscono un lieve degrado, probabilmente perché l'augmentation rimuove porzioni di informazione discriminante oltre la loro capacità di ricostruzione interna. Questo indica un'interazione architettura–regularizzazione: tecniche aggressive richiedono capacità sufficiente a sfruttarle.

### Slide 16 – Risultati SpecAugment
Alessandro: Il grafico conferma: guadagno moderato ma consistente per U‑Net, lieve peggioramento per gli altri due modelli.

### Slide 17 – Robustezza: 5‑Fold Cross‑Validation
Alessandro: Per ridurre la dipendenza da un singolo split abbiamo eseguito una 5‑fold cross‑validation su GTZAN con U‑Net (split a livello di traccia, folds stratificati). Media di validazione: 90.44% con deviazione standard sotto 0.7 p.p. È superiore all'82.3% del test finale perché in ciascun fold il modello vede l'80% dei brani (non solo il 60% usato nel training dello split principale). Il valore aggiunto della CV è la bassa varianza: riduce la probabilità che il test set sia stato particolarmente favorevole o sfavorevole.

### Slide 18 – Analisi qualitativa del modello
Alessandro: Oltre alla metrica aggregata, analizziamo dove il modello eccelle e dove mostra fragilità, per orientare possibili estensioni future.

### Slide 19 – Classification report
Alessandro: Generi con firme acustiche nette (Classica, Jazz) raggiungono F1 molto elevati (Classica 0.98). Rock scende a 0.61, penalizzato dal recall; molte tracce rock condividono pattern ritmici e strumenti con country e disco rendendo ambigua la decisione su frammenti corti. Questo suggerisce due possibili direzioni future: (1) incorporare segmenti più lunghi per catturare progressioni armoniche; (2) usare modelli con attenzione temporale per integrare contesto multi‑scala.

### Slide 20 – Confusion matrix (visualizzazione)
Alessandro: La matrice fornisce la mappa degli errori e prepara l'interpretazione dettagliata.

### Slide 21 – Analisi della confusion matrix
Alessandro: La diagonale marcata conferma l'accuratezza globale. Le confusioni Rock→Country/Disco e Reggae→Hiphop riflettono prossimità spettrale (pattern di chitarra ritmica simili, uso di batteria quantizzata). Con soli 3 secondi il contesto strutturale (transizioni, dinamiche più lente) non entra. Per distinguere generi così simili potrebbe essere necessario aggregare informazioni su scale temporali più lunghe o integrare feature ritmiche derivate (tempo, onset pattern).

### Slide 22 – Oltre GTZAN: generalizzazione cross‑dataset
Alessandro: Esploriamo ora la trasferibilità: addestramento da zero su un dataset complesso (FMA) e transfer learning verso domini diversi (Indian, Tabla). Due strategie complementari per valutare robustezza e riuso delle feature.

### Slide 23 – Risultati di generalizzazione
Alessandro: Il grafico sintetizza il quadro. Training da zero su FMA Small: 41.1% (coerente con la difficoltà del benchmark, etichette rumorose e generi sovrapposti). Fine‑tuning del modello pre‑addestrato su GTZAN: salti al 72.2% su Indian Music Genre e al 96.5% su Tabla Taala. In fase di transfer congeliamo gli strati iniziali (feature generiche) e ri‑addestriamo i blocchi superiori e il classificatore; su Tabla basta ri‑adattare soprattutto il classifier head. Figure: The U-Net's performance across all datasets. Transfer learning (Indian, Tabla) yields significantly better results than training from scratch on a complex dataset (FMA), highlighting the adaptability of the learned features.

### Slide 24 – Interpretazione dei risultati
Alessandro: Il 41.1% su FMA, pur non elevato, supera di molto il caso e conferma la natura impegnativa del dataset. Il 72.2% su musica non occidentale mostra che molte feature timbriche e ritmiche apprese su GTZAN sono riutilizzabili. Il 96.5% su Tabla indica una forte capacità di adattamento a un compito diverso (pattern ritmici ciclici) partendo da feature più generali.

### Slide 25 – Matrici di confusione cross‑dataset
Alessandro: Le matrici per GTZAN e Tabla mostrano diagonali pulite; quella per FMA appare più diffusa, coerente con l'elevata sovrapposizione tra classi e la maggiore variabilità interna.

### Slide 26 – Discrepanza con il paper originale
Alessandro: Rimane la domanda: perché non raggiungiamo il 99.41% riportato da Patil et al.? Una differenza di circa 9 punti percentuali è troppo ampia per attribuirla a meri dettagli implementativi.

### Slide 27 – Possibili cause della discrepanza
Alessandro: L'ipotesi principale è metodologica: data splitting potenzialmente effettuato dopo lo slicing, generando leakage (clip sorelle in train e test) e trasformando il problema in audio fingerprinting, più semplice e meno rappresentativo della generalizzazione. A questo si sommano (1) ambiguità nella descrizione del loro "modello matematico" che impedisce replica bit‑a‑bit, (2) mancanza di indicazione esplicita su come sia stata gestita la standardizzazione, (3) assenza di cross‑validation o statistica di dispersione. Il 99.41% risulta quindi un outlier non corroborato da elementi metodologici sufficienti.

### Slide 28 – Conferma dell'efficienza architetturale
Alessandro: Pur non replicando l'accuratezza dichiarata, confermiamo un punto sostanziale del paper: l'encoder U‑Net offre un eccellente equilibrio fra costo computazionale e prestazioni rispetto a una ResNet standard di capacità simile.

### Slide 29 – Conclusioni e contributi principali
Alessandro: Riassumendo:
1. L'encoder U‑Net è un'architettura efficace: benchmark trasparente e riproducibile del 90.44% (media CV) / 82.3% (test) su GTZAN.
2. Il 99.41% del paper di riferimento è molto probabilmente influenzato da fattori metodologici (verosimile data leakage) più che da superiorità architetturale.
3. Forte adattabilità tramite transfer learning (fino al 96.5% su Tabla Taala) anche in domini culturalmente e strutturalmente differenti.
4. Rilevanza del rigore: il progetto evolve da semplice replicazione a caso di studio sulla trasparenza e sulle pratiche sperimentali corrette. In definitiva, questo lavoro si trasforma soprattutto in un contributo metodologico: mostra come il controllo del leakage e la standardizzazione siano decisivi per interpretare correttamente risultati elevati.
Chiudo sottolineando che tutto il codice è strutturato per riproduzione: script di preprocessing, configurazioni esplicite e fissaggio dei semi. Questo, a nostro avviso, è il contributo duraturo oltre ai numeri specifici.

---
Fine.