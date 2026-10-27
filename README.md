# Casthisthing

App iOS per seguire le fusioni d'argento (cast) dei gioielli: quanto costa ogni fusione, quanto costa ogni pezzo che ne esce e quanto si guadagna quando lo si vende.

## Cosa fa

- **Cast in 4 step** — peso cera → argento puro necessario → costo argento → costo fusione.
- **Lavorazioni** — i pezzi usciti dal cast, numerati `#1`, `#2`, …, con peso argento, foto e prezzo di vendita. Il costo di ogni pezzo è proporzionale al suo peso sul totale del cast.
- **Lettura del peso dalla foto** — fotografando il pezzo sulla bilancia, il peso viene letto dal display tramite Gemini.
- **Cast precedenti** — elenco dei cast completati, con badge "Tutto venduto" quando ogni pezzo è stato venduto.
- **Spese e guadagni** — spesa totale e guadagno su tutti i cast completati, più le spese extra (attrezzatura, spedizioni, …) aggiunte a mano. Toccando i totali si apre una ricevuta con il dettaglio di ogni voce.

Il menu ⋯ della card del cast porta a Spese e guadagni, Cast precedenti e Ricomincia sessione.

## Requisiti

- Xcode con SDK iOS 17 o successivo
- iOS 17.0+ (iPhone)

## Primo avvio su un nuovo Mac

Il file con la chiave API di Gemini **non è nel repository** (è in `.gitignore`). Va ricreato a mano in `Casthisthing/Helpers/Secrets.swift`:

```swift
// Escluso da git (.gitignore). Su un altro Mac va ricreato a mano.
enum Secrets {
    static let geminiAPIKey = "LA_TUA_CHIAVE"
}
```

Senza una chiave valida l'app funziona lo stesso: solo la lettura automatica del peso dalla foto non va, e il peso si inserisce a mano.

Poi apri `Gioielli.xcodeproj`, scegli lo schema **Casthisthing** e avvia.

## Struttura

```
Casthisthing/
├── Models/        Dati salvati con SwiftData (CastingSession, Lavorazione, SpesaExtra)
├── Views/         Schermate dell'app
├── DesignSystem/  Componenti DS* e token (colori, spaziature, font)
├── Helpers/       Tema, formattazione, lettura bilancia, shake
├── Fonts/         Excon Variable
└── Assets.xcassets  Icone esportate da Figma
docs/
├── backlog.md               Cose da fare e già fatte
└── smoke-test-checklist.md  Controlli manuali dopo ogni build
BEST_PRACTICES.md            Regole del progetto e lezioni imparate
```

## Regole del progetto

Prima di modificare il codice leggi [BEST_PRACTICES.md](BEST_PRACTICES.md). In breve:

- solo token del design system (`DS.Color`, `DS.Space`, `DS.Radius`), niente valori scritti a mano;
- icone sempre esportate da Figma, mai disegnate a mano o sostituite con SF Symbols;
- i dati salvati si possono **aggiungere**, ma rinominare o togliere un campo esistente rompe i database già presenti sui telefoni.
