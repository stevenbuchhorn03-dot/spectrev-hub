# Faktor M Consulting GmbH — Website (Neugestaltung)

Modernisierte, voll responsive Website auf Basis der echten Inhalte und Kontaktdaten
der **Faktor M Consulting GmbH** (Personalberatung, Freudenberg).

## Lokal öffnen

Reines HTML/CSS/JS – kein Build, kein Server nötig.

```bash
# Variante 1: Datei direkt im Browser öffnen
open redesign/site/index.html        # macOS
xdg-open redesign/site/index.html    # Linux
start redesign\site\index.html       # Windows

# Variante 2 (empfohlen, für korrektes Laden von Karte/Assets): lokaler Server
cd redesign/site
python3 -m http.server 8080
# → http://localhost:8080
```

## Projektstruktur

```
redesign/
├── AUDIT.md              # Ehrliche Schwachstellen-Analyse der alten Seite
├── README.md            # Diese Datei
├── scrape/              # Roh-Scrape & strukturierte Inhalte
│   ├── content.json     # Alle extrahierten Inhalte + Kontaktdaten (Quelle der Wahrheit)
│   ├── pages_raw.md     # Roh-Inhalt je Seite
│   ├── home.html        # Gerendertes HTML der Startseite (gekürzt)
│   └── impressum.html   # Roh-HTML Impressum (Kontakt/Recht verbatim)
├── assets/              # Markenassets (SVG-Logo nachgebaut, Favicon)
└── site/                # ► Fertige Website
    ├── index.html
    ├── impressum.html
    ├── style.css
    ├── script.js
    └── assets/          # logo.svg, favicon.svg
```

## Inhalte / Datenherkunft

Alle Texte, Leistungen, das Team und sämtliche Kontakt- und Impressumsdaten stammen
1:1 von der bestehenden Seite (`https://faktor-m.net/`) und sind in
`scrape/content.json` dokumentiert. Es wurden **keine** Werbe-/Pitch-Texte und keine
Lorem-Ipsum-Platzhalter eingefügt.

> Hinweis zu Bildern: Die Original-Fotos (Team, Keyvisuals) liegen unter
> `faktor-m.net/fileadmin/…`. Der Binärdownload war in der Build-Umgebung durch die
> Netzwerk-Egress-Policy blockiert; die Pfade sind in `content.json` dokumentiert.
> Im Redesign sind sie durch markenkonforme, eigenständige SVG-Grafiken (Logo,
> Erfolgsformel-Motiv, Team-Initialen-Avatare) ersetzt – jederzeit gegen die echten
> Fotos austauschbar.

## Wichtigste Änderungen gegenüber dem Original

1. **Eine durchgehende Startseite** statt vorgeschalteter „Unternehmen/Bewerber"-Splash-Seite
   – Inhalte und Einstiegspfade sofort sichtbar.
2. **Sticky-Navigation** mit jederzeit erreichbarem Kontakt-CTA, Telefon und E-Mail
   (Click-to-Call / Click-to-Mail).
3. **Klare Typo-Hierarchie & großzügiger Weißraum**; je Seite genau eine H1.
4. **Konsistentes grünes Farbsystem** (aus der Markenfarbe abgeleitet) mit definierten
   Abstufungen und ausreichenden Kontrasten.
5. **Leistungen als Card-Grid + 4-Schritte-Prozess**, umschaltbar zwischen Unternehmen
   und Bewerber (Tabs).
6. **Echtes Team** als ansprechendes Personen-Grid mit Rolle, Durchwahl und E-Mail.
7. **Prominente Kontaktsektion** mit funktionalem Formular (inkl. Unternehmer/Bewerber-Auswahl,
   Datei-Upload, Datenschutz-Hinweis) und eingebetteter Karte des Standorts.
8. **Mobile-first & voll responsive** (Breakpoints 600/900/1100 px), semantisches HTML,
   Alt-Texte, Skip-Link, Fokuszustände, `prefers-reduced-motion`.
9. **Vollständiges Impressum** mit allen Rechtsdaten (HRB, USt-ID, Geschäftsführer,
   Aufsichtsbehörde) als eigene, verlinkte Seite.

## Hinweis zum Kontaktformular

Das Formular ist vollständig ausgezeichnet und client-seitig validiert. Für den
Produktiveinsatz muss es an ein Backend / einen Mailversand angebunden werden
(aktuell zeigt es nach erfolgreicher Validierung eine Bestätigung an).
