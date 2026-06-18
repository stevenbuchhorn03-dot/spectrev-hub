# Schwachstellen-Report — faktor-m.net (Stand 18.06.2026)

Ehrliche, sachliche Bewertung der bestehenden Website der **Faktor M Consulting GmbH**
als Grundlage für das Redesign. Bewertung auf Basis der gescrapten Seiten
(Start, Unternehmen, Bewerber, Über uns, Kontakt, Impressum).

---

## 1. Design / Layout

- **Splash-/Auswahlseite als Einstieg.** Die Startseite zwingt Besucher zu einer
  Vorabentscheidung („Unternehmen" oder „Bewerber"), bevor überhaupt Inhalte sichtbar
  sind. Das ist ein zusätzlicher Klick-Schritt, kostet Reichweite und liefert
  Suchmaschinen kaum indexierbaren Text auf der wichtigsten URL.
- **Schwache visuelle Hierarchie.** Headlines werden in mehrere gleichrangige
  Überschriften zerlegt (z. B. „Die Erfolgsformel" / „für passgenaue
  Personalvermittlung" als zwei H1/H2). Dadurch fehlt eine klare Leseführung.
- **Bildlastiges, statisches Keyvisual** ohne erkennbares modernes Grid-System;
  Inhalte wirken eher zusammengesetzt als aus einem durchgängigen Designsystem.
- **Markenfarbe (Grün) wird nur punktuell** eingesetzt (CSS-Klassen `FontGruen`,
  `green-bg`), ohne konsistentes, abgestuftes Farbsystem.

## 2. UX / Nutzerführung

- **Call-to-Actions verteilt und uneinheitlich** benannt („Stellenangebot
  übermitteln", „Bewerbung übermitteln", „ansehen", „alle Stellen ansehen") — kein
  klarer, durchgängiger Primär-CTA.
- **Kontakt schwer zu scannen.** Die zentralen Kontaktdaten erscheinen erst auf der
  Unterseite /kontakt; auf den Inhaltsseiten fehlt eine durchgängige, sichtbare
  Kontaktmöglichkeit (Telefon/E-Mail) z. B. in einer Sticky-Navigation.
- **News als „Lippe"/Slider** am Rand ist ein veraltetes Pattern und auf Mobilgeräten
  schlecht bedienbar.
- **Externe Brüche im Bewerber-Flow:** „Bewerbung übermitteln" führt auf eine
  fremde Domain (europersonal.com) — Stilbruch und Vertrauensverlust ohne klare
  Erwartungssteuerung.

## 3. Technik / Mobile / Performance

- **Bot-/Direktzugriff liefert 403** (Server blockt einfache Clients). Für echte
  Nutzer unkritisch, deutet aber auf eine ältere, restriktive Server-/CMS-Konfiguration
  (TYPO3) hin.
- **Bildgewicht.** Große PNG-Keyvisuals (z. B. 1920×800, 1320×981) ohne erkennbares
  modernes Format (WebP/AVIF) → längere Ladezeiten, besonders mobil.
- **Mobile-First nicht erkennbar.** Layout basiert auf großflächigen Desktop-Keyvisuals;
  das Splash-Konzept (zwei nebeneinander liegende Hälften) ist auf kleinen Displays
  umständlich.
- **Formular** ist funktional (TYPO3 Form), aber optisch unauffällig und ohne moderne
  Validierungs-/Feedback-Anmutung.

## 4. Inhalt / SEO

- **Wenig indexierbarer Text auf der Startseite** durch das Splash-Konzept.
- **Doppelte/aufgespaltene Überschriften** verwässern die semantische Struktur
  (mehrere H1 pro Seite).
- **Starke, vorhandene Inhalte werden unter Wert verkauft:** klare Erfolgsformel
  (1 + 1 = M), 4-Schritte-Prozesse, konkrete Vorteilslisten, echtes Team mit
  Durchwahlen, Branchenexpertise (Automotive, Maschinen-/Anlagenbau, Bauwesen).
  Diese Substanz ist da — sie ist nur nicht prägnant inszeniert.

---

## Konkrete Verbesserungen im Redesign

1. **Eine durchgängige Startseite** statt Splash: Hero mit klarer Headline + zwei
   gleichwertigen Pfaden (Unternehmen / Bewerber) als Karten — ohne den Inhalt zu
   verstecken.
2. **Klare Typo-Hierarchie**: eine H1 pro Seite, Kicker + Headline + Subline-Muster,
   großzügiger Weißraum.
3. **Sticky-Navigation** mit jederzeit sichtbarem Primär-CTA „Kontakt" und
   Telefonnummer (Click-to-Call).
4. **Abgestimmtes grünes Farbsystem** (abgeleitet aus der Markenfarbe) mit
   definierten Abstufungen, ausreichenden Kontrasten und konsistentem Akzent.
5. **Leistungen als sauberes Card-Grid** (Vorteile + 4-Schritte-Prozess) statt
   loser Aufzählungen.
6. **Echtes Team** als ansprechendes Personen-Grid (Name, Rolle, Durchwahl, E-Mail).
7. **Prominente Kontaktsektion** mit funktionalem Formular-Markup (inkl.
   Unternehmer/Bewerber-Auswahl, Datenschutz-Hinweis, Datei-Upload) und Karten-Einbettung
   der Adresse.
8. **Performance & Mobile-First**: schlankes reines HTML/CSS/JS, responsives Grid,
   CSS-/SVG-Grafiken statt schwerer Bitmaps, semantisches HTML, Alt-Texte, lazy-fähig.
9. **SEO-/A11y-Basics**: ein klarer H1, beschreibende Meta-Daten, sinnvolle
   Landmarks, Fokuszustände, Skip-Link.

> Hinweis: Identität, Texte und Kontaktdaten bleiben 1:1 erhalten — verbessert wird
> ausschließlich Design, Struktur und Technik, nicht die Marke.
