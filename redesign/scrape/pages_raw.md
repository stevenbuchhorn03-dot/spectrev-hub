# Faktor M — Roh-Scrape (Markdown je Seite)
Quelle: https://faktor-m.net/  | Scrape via Apify rag-web-browser (Headless-Browser) | 2026-06-18
Hinweis: Direkter HTTP-Zugriff (curl/WebFetch) lieferte 403 (Bot-Schutz). Headless-Browser-Rendering war erfolgreich.

---
## STARTSEITE (/)
Title: Faktor M
Splash/Auswahlseite mit Keyvisual und News-Lippe (News-Slider).
H1: Personalberatung für Unternehmer & Bewerber
Auswahl: Unternehmen (/unternehmen) | Bewerber (/bewerber)
News (Auszug):
- 05.Jun.2024 — Krisenkommunikation im HR-Bereich
- 22.May.2024 — Umgang mit Jobabsagen: Feedback einholen und verstehen
- 08.May.2024 — Nutzung von Mitarbeitern zur Förderung der Unternehmensmarke

---
## UNTERNEHMEN (/unternehmen)
Kicker: Sie haben eine Stelle zu besetzen?
H: Wir finden den einen Mitarbeiter, der wirklich passt.
CTAs: Bewerberprofile ansehen (/unternehmen/bewerberprofile), Stellenangebot übermitteln (/kontakt)
"Die Erfolgsformel für passgenaue Personalvermittlung" + Intro-Text.
8 Vorteile + 4-Schritte-Prozess (Bedarfsanalyse, Recruiting, Bewerberprofil, Kandidatenvorstellung).
Siehe content.json -> audience_unternehmen.

---
## BEWERBER (/bewerber)
Kicker: Sie suchen einen neuen Job?
H: Wir finden das Unternehmen, das wirklich zu Ihnen passt.
CTAs: Stellenangebote ansehen (/bewerber/stellenangebote), Bewerbung übermitteln (externes Portal europersonal.com)
8 Vorteile + 4-Schritte-Prozess (Erstgespräch, Matching, Bewerberprofil, Vorstellungsgespräch).
Aktuelle Stellenangebote (Beispiele): Industriemechaniker (Lennestadt), Schweißer (Drolshagen),
Produktionsmitarbeiter (Wilnsdorf), Maschinen- und Anlagenführer (Lennestadt/Herborn).
Siehe content.json -> audience_bewerber.

---
## ÜBER UNS (/ueber-uns)
Intro + Erfolgsformel "EINS PLUS EINS GLEICH M".
Team (9 Personen) mit Rolle, Durchwahl, E-Mail — siehe content.json -> team.

---
## KONTAKT (/kontakt)
H1: Ihr Kontakt zu Faktor M.
Faktor M Consulting GmbH, Trulichstr. 2, 57258 Freudenberg
Tel: 02734 47977-0 | E-Mail: info@faktor-m.net
Routenplaner (Google Maps Link) + Kontaktformular (TYPO3 Form):
Felder: Unternehmer/Bewerber (Radio*), Anrede*, Vorname*, Nachname*, Firma, Ort, E-Mail*, Telefon,
Nachricht, Datenschutz-Checkbox*, Datei-Upload (Stellenangebot/Bewerbung).

---
## IMPRESSUM (/impressum)
Faktor M Consulting GmbH, Trulichstraße 2, 57258 Freudenberg
Handelsregister: HRB 10243 | Registergericht: Amtsgericht Siegen
Geschäftsführer: Eduard Christiani, Jan-Philip Stender, Jan Plaum
Tel: +49 (0) 2734 / 47977-0 | Fax: +49 (0) 2734 / 4797729 | E-Mail: info@faktor-m.net
USt-ID: DE292159969
Aufsichtsbehörde: Regionaldirektion NRW der Bundesagentur für Arbeit
Redaktionell verantwortlich: Faktor M Consulting GmbH, Jan Plaum
