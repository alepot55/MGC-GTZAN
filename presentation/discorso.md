### **Discorso Finale per la Presentazione**

#### **Parte 1 - Speaker: Camilla (Slide 1–14)**


**(Slide 1: Titolo)**

Buongiorno professore. Sono Camilla Sed, e insieme al mio collega Alessandro Potenza, oggi le presentiamo il nostro progetto: uno studio di replicazione sulla classificazione automatica dei generi musicali.

**(Slide 2: Introduzione al problema)**

La classificazione dei generi musicali è un compito centrale nel Music Information Retrieval. In parole semplici, l'obiettivo è insegnare a un sistema ad assegnare il genere corretto – come rock, blues o classica – a un frammento audio. Questo ha applicazioni pratiche evidenti, come nei servizi di raccomandazione o nell'organizzazione di grandi archivi musicali.

Il dominio è interessante anche dal punto di vista metodologico, perché i generi non sono entità rigide; presentano sovrapposizioni, ibridazioni e spesso etichette ambigue. Il punto di partenza del nostro lavoro è stato un risultato pubblicato recentemente da Patil e colleghi, che dichiarano un'eccezionale accuratezza del 99.41% sul dataset GTZAN con un modello basato su U-Net. Un valore quasi perfetto, su un benchmark noto per le sue imperfezioni, ci ha spinto a porci una domanda fondamentale: si tratta di un vero salto architetturale, o c'è una spiegazione metodologica dietro a questo risultato? Da qui è nata l'idea di una replica rigorosa.

**(Slide 3: Obiettivi del progetto)**

Per investigare questa domanda, abbiamo formulato tre obiettivi principali.
Primo, **Replicare e Validare**: abbiamo implementato l'architettura U-Net basandoci sui dettagli disponibili nel paper e l'abbiamo testata all'interno di una nostra pipeline controllata, per verificare la plausibilità di quel 99.41%.
Secondo, **Confrontare e Analizzare**: per contestualizzare la performance dell'U-Net, l'abbiamo confrontata con altre due architetture rappresentative, una più leggera e una più profonda, mantenendo un protocollo di training identico per tutti.
Infine, **Estendere e Generalizzare**: abbiamo testato il modello su dataset molto diversi – per scala, cultura e tipo di task – per misurare la reale robustezza e riusabilità delle feature apprese. Implicitamente, il nostro quarto obiettivo era produrre un benchmark trasparente e riproducibile, per mitigare proprio l'ambiguità che avevamo riscontrato.

**(Slide 4: Dataset)**

Per raggiungere questi obiettivi, abbiamo utilizzato quattro dataset con caratteristiche complementari.
Il **GTZAN** è stato il nostro punto di partenza obbligato per la replicazione, essendo il riferimento storico del paper.
Successivamente, abbiamo introdotto **FMA Small**, un dataset molto più grande e realistico, che ha rappresentato un vero stress-test per la scalabilità dei modelli.
Con l'**Indian Music Genre**, abbiamo testato l'adattabilità a un dominio culturale diverso, per capire se le feature apprese fossero realmente 'musicali' o solo legate allo stile occidentale.
Infine, con **Tabla Taala**, un dataset di soli cicli ritmici, abbiamo verificato se un encoder addestrato su pattern armonici potesse essere riadattato a un compito puramente ritmico.

**(Slide 5: Dalle onde ai Mel-spettrogrammi)**

Le CNN sono nate per lavorare su immagini. Abbiamo quindi trasformato il segnale audio monodimensionale in una rappresentazione 2D: il Mel-spettrogramma. Utilizziamo 128 bande di frequenza Mel, che mimano la percezione uditiva umana, rendendo questa feature molto efficace. Dopo la Trasformata di Fourier a tempo breve (STFT), normalizziamo i dati usando esclusivamente le statistiche del training set, un passo cruciale per evitare data leakage. Questa pipeline ci permette di affrontare il problema come un compito di classificazione di immagini, mantenendo però l'informazione musicale rilevante.

**(Slide 6: Visualizzazione delle feature)**

Qui vediamo l'efficacia di questa trasformazione. Confrontando la forma d'onda con il Mel-spettrogramma per un brano Blues e uno di musica Classica, le differenze nelle texture spettrali diventano evidenti. Sono proprio questi pattern visivi che le nostre CNN imparano a riconoscere.

**(Slide 7: Partizionamento e slicing)**

Il dataset GTZAN ha solo 1000 brani, che sono pochi per il deep learning. Per aumentare la quantità di dati, abbiamo segmentato ogni traccia da 30 secondi in dieci clip da 3 secondi.

Qui, però, si nasconde il dettaglio metodologico più importante: **evitare il data leakage**. Se avessimo prima segmentato e poi suddiviso i dati, frammenti della stessa canzone sarebbero finiti sia nel training che nel test set, portando il modello a imparare il 'fingerprint' di una traccia invece delle caratteristiche del genere. Per evitare questo 'imbroglio', abbiamo prima suddiviso i brani interi a livello di file, e solo dopo abbiamo effettuato lo slicing all'interno di ciascun set. Questo rigore metodologico è ciò che garantisce la validità scientifica dei nostri risultati.

**(Slide 8: Architetture di confronto)**

Una volta preparati i dati, per condurre un'analisi rigorosa, abbiamo implementato tre modelli, ciascuno rappresentativo di una diversa filosofia architetturale.

Il primo è l'Efficient-VGG. Lo consideriamo la nostra baseline di efficienza. Ispirato alla classica architettura VGG, è un modello volutamente semplice e leggero, con soli 35mila parametri. Il suo scopo è definire la performance minima attesa e rispondere a una domanda fondamentale: è necessaria una grande complessità per questo task? Questo modello ci fornisce un solido punto di riferimento per valutare il beneficio reale delle architetture più avanzate.

Il secondo modello è il ResSE-AudioCNN, che rappresenta il nostro termine di paragone ad alte prestazioni. È un'architettura moderna e profonda, con circa 1.2 milioni di parametri, che combina due idee potenti. La sua base in stile ResNet gli permette di essere molto profondo senza perdere efficacia nell'addestramento, grazie alle connessioni residue. In più, integra un meccanismo di attenzione (SE), che insegna al modello a "pesare" le feature spettrali più importanti, concentrandosi solo su ciò che è rilevante per la classificazione. È, a tutti gli effetti, il nostro concorrente di riferimento che rappresenta lo stato dell'arte.

**(Slide 9: Il classificatore U-Net)**

E infine, arriviamo al protagonista della nostra indagine: il classificatore basato su U-Net.

L'architettura U-Net nasce per la segmentazione di immagini, un compito in cui è fondamentale analizzare un'immagine a diverse scale di dettaglio. Abbiamo adattato questa potente idea al nostro problema. Anziché utilizzare l'intera struttura a forma di "U", abbiamo impiegato esclusivamente il suo ramo encoder, ovvero la parte di contrazione.

La logica è semplice: questo ramo è un potentissimo estrattore di feature. Man mano che scende in profondità, cattura pattern spettrali sempre più astratti e complessi, proprio ciò che ci serve per distinguere i generi. Abbiamo quindi rimosso la parte di ricostruzione (il decoder) e l'abbiamo sostituita con una "testa" di classificazione composta da due elementi cruciali.

Il primo è il Global Average Pooling. Il suo compito è di riassumere in modo intelligente tutte le feature estratte. In pratica, prende ogni mappa di caratteristiche bidimensionale prodotta dall'encoder e la condensa in un singolo numero, la sua media. Questo trasforma una rappresentazione complessa e spaziale in un vettore di feature compatto e gestibile, rendendo il modello più robusto.

Questo vettore viene poi passato al classificatore finale. È l'ultimo passo, dove il modello prende la decisione vera e propria. Si tratta di un semplice layer denso con un neurone per ogni genere musicale. Riceve le caratteristiche compattate e il suo output è la probabilità che il frammento audio appartenga a ciascuna classe, dicendoci ad esempio: "questo brano è al 95% Classica, al 3% Jazz, e così via".

Con circa 1.18 milioni di parametri, la sua complessità è quasi identica a quella del nostro ResNet. Questo è un punto cruciale, perché ci ha permesso di realizzare un confronto diretto e onesto, non basato sulla dimensione, ma sulla pura efficacia delle rispettive filosofie architetturali.

**(Slide 10: Protocollo di training)**

Per garantire un confronto onesto, abbiamo standardizzato ogni aspetto del training: stesso ottimizzatore Adam, stessa loss, stesse callback come l'Early Stopping. Abbiamo fissato tutti i semi casuali e usato, dove possibile, operazioni deterministiche. Questo approccio minimizza le variabili confondenti e ci permette di attribuire le differenze di performance direttamente alle scelte architetturali.

**(Slide 11: Iperparametri chiave)**

Questa tabella riassume gli iperparametri principali. L'aspetto importante qui non sono i valori assoluti, ma la loro coerenza attraverso tutti gli esperimenti. Questo rigore ci permette di trarre conclusioni affidabili.

**(Slide 12: Risultati GTZAN - overview)**

Passiamo ora ai risultati su GTZAN. La conclusione principale è che l'architettura U-Net è emersa come il modello più performante nel nostro setup, superando chiaramente le altre due.

**(Slide 13: Metriche GTZAN)**

Analizzando le metriche, vediamo che l'U-Net raggiunge l'82.3% di accuratezza sul test set, circa tre punti percentuali sopra il ResNet. È interessante notare che ottiene questo vantaggio con una capacità simile in termini di parametri e, come vedremo, con una latenza leggermente inferiore, rendendolo un'opzione molto efficiente.

**(Slide 14: Accuratezza vs Efficienza)**

Questo grafico visualizza il trade-off tra prestazioni ed efficienza. L'obiettivo è essere in alto a sinistra. Il punto blu, il nostro U-Net, si posiziona chiaramente come la scelta migliore, offrendo l'accuratezza più alta senza un costo computazionale superiore a quello del ResNet. Il trade-off è dunque nettamente favorevole all'architettura U-Net.

**(Passaggio ad Alessandro)**


---

#### **Parte 2 - Speaker: Alessandro (Slide 15–29)**


**(Slide 15: Ablation - SpecAugment)**

Successivamente, abbiamo valutato l'impatto della data augmentation (SpecAugment). La domanda era: questa tecnica aiuta sempre? La nostra analisi ha mostrato che la risposta è 'no'. Solo l'architettura U-Net, la più capiente, ha tratto un beneficio netto. I modelli più piccoli hanno subito un lieve degrado. Questo indica una forte interazione tra la capacità del modello e la sua abilità di sfruttare tecniche di regolarizzazione aggressive.

**(Slide 16: Risultati SpecAugment)**

Il grafico conferma questo risultato in modo visivo: un guadagno modesto ma consistente per l'U-Net e un lieve peggioramento per gli altri due.

**(Slide 17: Robustezza - 5-Fold Cross-Validation)**

Per essere sicuri che i nostri risultati non fossero dovuti a una singola suddivisione fortunata dei dati, abbiamo eseguito una cross-validation a 5-fold sull'U-Net. Qui abbiamo ottenuto il nostro risultato più solido su GTZAN: un'accuratezza media di validazione del **90.44%**. È importante notare che questa è un'accuratezza di *validazione* media, ed è più alta del nostro test set perché ad ogni fold il modello viene addestrato sull'80% dei dati. Il dato cruciale è la deviazione standard bassissima, sotto l'1%, che conferma l'eccezionale stabilità e robustezza del modello.

**(Slide 18: Analisi qualitativa del modello)**

Ma oltre ai numeri, volevamo capire *dove* il nostro modello campione eccelle e dove fallisce.

**(Slide 19: Classification report)**

Il classification report ci mostra che il modello è quasi perfetto su generi con una firma acustica netta, come la Classica (F1-score di 0.98) e il Jazz (0.93). La sua debolezza principale è sul genere Rock, con un F1-score di appena 0.61.

**(Slide 20: Confusion matrix - visualizzazione)**

E la matrice di confusione ci spiega visivamente il perché.

**(Slide 21: Analisi della confusion matrix)**

La diagonale marcata conferma l'alta accuratezza generale. Gli errori non sono casuali: il 'rock' viene spesso confuso con 'country' e 'disco', e il 'reggae' con l' 'hiphop'. Si tratta di confusioni musicalmente coerenti, che riflettono la prossimità spettrale di questi generi e la difficoltà intrinseca di distinguerli basandosi solo su frammenti di 3 secondi.

**(Slide 22: Oltre GTZAN - generalizzazione cross-dataset)**

Una volta validata la nostra architettura su GTZAN, abbiamo voluto testarne la reale robustezza. Per farlo, abbiamo seguito due strategie complementari: la prima, addestrare il modello da zero sul complesso dataset FMA, per valutarne le capacità di apprendimento generali. La seconda, usare il transfer learning sui domini specializzati Indian e Tabla, per misurare quanto fossero realmente generalizzabili le feature già apprese.

**(Slide 23: Risultati di generalizzazione)**

Questo grafico mette a confronto diretto le nostre performance. La barra blu rappresenta il nostro modello U-Net, mentre la barra rossa indica una baseline di riferimento pubblicata in letteratura per ciascun dataset. Questo ci permette di contestualizzare i nostri risultati in modo onesto. 

Come si può vedere, su GTZAN e FMA otteniamo risultati solidi e riproducibili. Ma il dato più interessante emerge con il transfer learning: non solo otteniamo ottimi risultati su Indian Music, ma sul dataset Tabla Taala riusciamo a superare la baseline esistente.

**(Slide 24: Interpretazione dei risultati)**

Analizzando i numeri che abbiamo appena visto: su FMA Small, il nostro 41.1% di accuratezza conferma la nota difficoltà del benchmark, dove la letteratura per CNN simili si attesta tipicamente tra il 50 e il 65%. Il nostro risultato, pur essendo inferiore, è quindi un'onesta misura della sfida.

Il vero potenziale della nostra architettura, però, emerge con il transfer learning. Abbiamo raggiunto il 72.2% sul dataset di musica indiana, confermando che le feature apprese sono in gran parte universali. Ma il risultato più notevole è stato il 96.5% sul dataset Tabla Taala, dove abbiamo superato la baseline. 

Questo dimostra che il nostro modello ha imparato a riconoscere pattern così fondamentali da poterli riadattare con successo, passando dalla classificazione di generi al riconoscimento di strutture ritmiche finissime con alta precisione.

**(Slide 25: Matrici di confusione cross-dataset)**

Questa slide visualizza la differenza: le matrici per GTZAN e Tabla sono 'pulite', con diagonali forti. Quella per FMA è molto più 'diffusa', riflettendo la maggiore complessità e sovrapposizione tra le classi di quel dataset.

**(Slide 26: Discrepanza con il paper originale)**

Arriviamo quindi alla domanda finale. Perché non raggiungiamo il 99.41% riportato nel paper di riferimento? Una differenza di 9 punti percentuali è troppo ampia per essere spiegata solo da piccoli dettagli implementativi.

**(Slide 27: Possibili cause della discrepanza)**

La nostra analisi indica che la causa di questo divario di 9 punti non sia architetturale, ma metodologica. Abbiamo individuato tre prove a sostegno di questa tesi.

Primo, e più importante, il rischio di data leakage. Il paper non chiarisce il suo protocollo di split. Sospettiamo fortemente che abbiano effettuato lo slicing prima della suddivisione, una pratica errata che trasforma il problema in 'audio fingerprinting' e gonfia i risultati. Il nostro protocollo a livello di traccia, invece, previene questo errore.

Secondo, l'ambiguità del loro modello. La descrizione del loro 'modello matematico' è troppo vaga per permettere una replica fedele, impedendo una verifica diretta delle loro affermazioni.

Terzo, il loro risultato è un outlier. Un'accuratezza del 99.41% è statisticamente anomala rispetto a decenni di ricerca su GTZAN, dove i risultati più solidi e affidabili si attestano tra il 90 e il 95%.

In sintesi, tutti gli indizi ci portano a concludere che la differenza sia dovuta al loro setup sperimentale, non a una superiorità del loro modello.

**(Slide 28: Conferma dell'efficienza architetturale)**

Tuttavia, pur non replicando l'accuratezza, il nostro lavoro **conferma un punto sostanziale del paper**: l'encoder U-Net offre davvero un equilibrio superiore tra prestazioni e costo computazionale rispetto a una ResNet standard. Su questo, le nostre conclusioni sono allineate.

**(Slide 29: Conclusioni e contributi principali)**

Riassumendo, i nostri contributi principali sono quattro:
1.  Abbiamo stabilito che l'**encoder U-Net è un'architettura efficace**, definendo un benchmark trasparente e riproducibile del 90.44% (media CV) su GTZAN.
2.  Abbiamo concluso che il **gap di performance** con il paper di riferimento è molto probabilmente dovuto a **fattori metodologici**, non a una superiorità architetturale.
3.  Abbiamo dimostrato la **forte adattabilità** del modello tramite transfer learning, raggiungendo fino al 96.5% su un compito diverso.
4.  Infine, questo lavoro si trasforma in un caso di studio sulla **rilevanza del rigore metodologico**, mostrando come il controllo del leakage e la standardizzazione siano decisivi per interpretare correttamente i risultati. Crediamo che questo, al di là dei numeri, sia il contributo più duraturo del nostro progetto.

**(Fine)**


Fine. Grazie per l'attenzione. Siamo a disposizione per qualsiasi domanda.