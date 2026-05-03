# Casthisthing — Best Practices & Lessons Learned

## Keyboard

### Blocca il layout con `GeometryReader` — non fidarti di `.ignoresSafeArea(.keyboard)` da solo
`.ignoresSafeArea(.keyboard)` non è sufficiente su `VStack` con contenuto dinamico (es. `Spacer`, `frame(maxHeight:.infinity)`). La soluzione definitiva: misurare l'altezza con `GeometryReader` e fissare frame espliciti. La keyboard non può spostare niente perché le altezze sono hardcoded.

```swift
GeometryReader { geo in
    VStack(spacing: 0) {
        header.frame(height: 72)
        content.frame(height: geo.size.height - 72)
    }
    .frame(width: geo.size.width, height: geo.size.height)
}
.ignoresSafeArea(.keyboard) // ← sul GeometryReader, non sul VStack
```

```swift
// ✅ Corretto — sul VStack root
VStack { ... }
    .ignoresSafeArea(.keyboard)

// ❌ Sbagliato — si perde se rimuovi lo ScrollView
ScrollView { ... }
    .ignoresSafeArea(.keyboard)
```

### Commit il valore solo su `focused = false`, non su `onChange(of: text)`
Aggiornare il binding ad ogni keystroke causa avanzamento prematuro degli step. Usare sempre `onChange(of: focused)`:

```swift
// ✅ Corretto
.onChange(of: focused) { isFocused in
    guard !isFocused else { return }
    value = parse(text)
}

// ❌ Sbagliato — avanza lo step al primo carattere digitato
.onChange(of: text) { value = parse($0) }
```

---

## Design System

### Mai ricostruire le icone a mano — sempre esportare da Figma
Le icone vanno esportate come SVG da Figma via MCP, patchate (`fill="var(...)"` → `fill="currentColor"`) e inserite come template imageset in Assets.xcassets. Aggiungerle poi a `DSIcon.swift`.

### Usare sempre token DS — mai hardcodare colori, spaziature o radii
```swift
// ✅
DS.Color.primary / DS.Color.borderGeneral / DS.Radius.xl / DS.Space.md

// ❌
Color(hex: "#FF006E") / cornerRadius: 28 / padding: 16
```

### Usare `borderPrimary` per i bordi degli elementi interattivi selezionati
Non usare `DS.Color.primary` direttamente per i bordi — usare `DS.Color.borderPrimary` (stesso valore, ma semanticamente corretto).

---

## Font

### Il nome del font è `"Excon Variable"` (con spazio), non `"Excon-Variable"`
Il nome della famiglia nel TTF è diverso dal nome del file.

### Nei `#Preview` serve sempre `.registerFonts()`
L'`init()` dell'App non viene eseguito nei preview. Ogni `#Preview` deve chiamare `.registerFonts()` per vedere il font corretto.

```swift
#Preview {
    MyView()
        .registerFonts()
}
```

---

## SVG / Icone

### Patch obbligatoria per le icone Figma
Figma esporta SVG con CSS variables (`fill="var(--fill-0, #FF006E)"`). Xcode non le risolve. Prima di aggiungere un asset:

```bash
sed -i '' 's/fill="var([^)]*,\s*\([^)]*\))"/fill="currentColor"/g' icon.svg
sed -i '' 's/stroke="var([^)]*,\s*\([^)]*\))"/stroke="currentColor"/g' icon.svg
```

### `Contents.json` imageset deve avere template rendering
```json
{
  "properties": {
    "preserves-vector-representation": true,
    "template-rendering-intent": "template"
  }
}
```

---

## Layout

### Card a full height: `Spacer()` + `.frame(maxHeight: .infinity)`
Per far occupare una card tutta l'altezza disponibile senza modificare le altezze dei componenti interni:

```swift
// In CastCardView
VStack {
    // contenuto fisso
    Spacer() // espande il wrapper
    // button ancorato in fondo
}
.frame(maxHeight: .infinity)

// In HomeView — niente ScrollView, solo padding
CastCardView(session: session)
    .padding(24)
```

### Altezze button garantite con `frame(minHeight:)`, non con padding verticale
Il padding verticale dipende dalla line-height del font e può variare. Usare sempre `frame(minHeight:)` nei ButtonStyle.

```swift
// ✅
.frame(maxWidth: .infinity, minHeight: 48)

// ❌ — altezza imprevedibile
.padding(.vertical, 16)
```

---

## SwiftData / Logica

### `currentStep` deve includere tutti i campi per sbloccare gli step in cascata
Se aggiungi un nuovo step, aggiornare **sempre** `CastingSession.currentStep`:

```swift
var currentStep: Int {
    if silverCost != nil   { return 4 }
    if silverNeeded != nil { return 3 }
    if waxWeight != nil    { return 2 }
    return 1
}
```

---

## Build / Xcode

### La build non serve ad ogni modifica
- **Build necessaria**: prima di un render preview, dopo refactoring grossi, quando ci sono dubbi sulla compilazione
- **Build non necessaria**: modifiche di token, colori, layout semplici — il preview si aggiorna live

### Il preview non ha dati SwiftData — serve un container in-memory
```swift
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CastingSession.self, Lavorazione.self, configurations: config)
    let session = CastingSession(title: "Cast in corso", date: .now)
    session.waxWeight = 12.5
    container.mainContext.insert(session)
    return HomeView()
        .modelContainer(container)
        .registerFonts()
}
```
