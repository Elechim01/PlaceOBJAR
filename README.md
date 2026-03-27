# 🧊 PlaceOBJAR

**PlaceOBJAR** è un'applicazione sperimentale in Realtà Aumentata (AR) progettata per l'inserimento, la visualizzazione e la manipolazione di modelli 3D (.obj / .usdz) nel mondo reale. Sfrutta la potenza di ARKit per il tracciamento delle superfici e SceneKit per il rendering degli oggetti.

---

## 🚀 Funzionalità Principali

### 🔍 Rilevamento Superfici
* **Plane Detection**: Identificazione automatica di piani orizzontali (pavimenti, tavoli) e verticali (pareti) per il posizionamento degli oggetti.
* **Visual Feedback**: Indicatori visivi per confermare il punto esatto di ancoraggio nel mondo reale.

### 📦 Gestione Modelli 3D
* **Importazione OBJ/USDZ**: Supporto per il caricamento di modelli 3D complessi con texture integrate.
* **Posizionamento Dinamico**: Tocca lo schermo per "spawnare" l'oggetto nel punto rilevato dalla telecamera.

### 🔄 Manipolazione Real-Time
* **Gesture Control**: Utilizzo di pinch-to-zoom per scalare l'oggetto e rotazione a due dita per orientarlo.
* **Physics Engine**: Integrazione di base con le leggi fisiche per un'interazione più realistica tra gli oggetti virtuali e l'ambiente.

---

## 🏗 Architettura Tecnica

Il progetto è costruito seguendo i principi di modularità di Elechim:

1. **AR Manager**: Gestisce la sessione `ARSession` e la configurazione del tracciamento.
2. **Object Loader**: Utility per convertire file sorgente in `SCNNode` pronti per la scena.
3. **ElechimCore Integration**: Utilizzo del sistema di logging e gestione errori per il debug delle sessioni AR.

---

## 💻 Requisiti Tecnici
* **Dispositivo**: iPhone o iPad con chip A12 Bionic o superiore (richiesto ARKit).
* **OS**: iOS 17.0+ / iPadOS 17.0+
* **Linguaggio**: Swift 6.0
* **Framework**: ARKit, SceneKit, RealityKit (opzionale).

---

## 🛠 Setup Rapido

1. **Clona il repository**:
   ```bash
   git clone [https://github.com/Elechim01/PlaceOBJAR.git](https://github.com/Elechim01/PlaceOBJAR.git)
