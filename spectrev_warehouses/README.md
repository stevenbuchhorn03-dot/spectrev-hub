# spectrev_warehouses

Automatischer Rohstoff-Verarbeiter für FiveM mit **kaufbaren, upgradebaren Warehouses** und einer **Shell mit Autoplatz**, in die man mit dem Fahrzeug einfahren kann.

**Ablauf:** Rohstoffe auf dem Feld sammeln → zum eigenen Warehouse fahren → mit dem Auto per `ox_target` durchs Tor einfahren → Rohstoffe in den Einlass legen → die Verarbeitung läuft **automatisch über Zeit weiter (auch offline)** → fertige Resource an der Ausgabe abholen.

## Abhängigkeiten
- [es_extended](https://github.com/esx-framework/esx_core) (ESX Legacy)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_target](https://github.com/overextended/ox_target)
- **ox_inventory** bzw. dein **Devix Grid Inventory** (siehe `Config.InventoryResource`)

## Installation
1. Ordner `spectrev_warehouses` in deine `resources/` legen.
2. SQL importieren: `sql/install.sql`.
3. In der `server.cfg` **nach** den Abhängigkeiten starten: `ensure spectrev_warehouses`.
4. `config.lua` anpassen (siehe unten).

## ESX + Devix richtig verdrahten (wichtig!)
Damit ESX-Geldoperationen (Kauf/Upgrade) nicht crashen, muss ESX auf Devix statt auf
ox konfiguriert sein (sonst greift ESX' ox_inventory-Override, dessen `Inventory`-Variable
bei Devix nie gesetzt wird → Crash in `removeAccountMoney`):

- `es_extended/shared/config/main.lua` → `Config.CustomInventory = 'devix'`
- `es_extended/server/bridge/inventory` → die von Devix bereitgestellte Bridge-Datei einsetzen
  (siehe Devix-Doku „ESX - es_extended“).

Das Script bucht Geld zusätzlich defensiv ab (pcall + Kontostand-Verifikation), läuft also
auch dann, wenn die ESX-Config noch nicht sauber ist — der obige Fix ist aber die richtige
serverweite Lösung.

## Inventar-Backend
Devix hat für Stashes eine **eigene API** (`AddItemStash`/`RemoveItemStash`/`GetStashItems`/
`OpenStashInventory`); der ox_inventory-Bridge-`AddItem(source,…)` funktioniert für Stashes
NICHT. Deshalb erkennt das Script das Backend und routet Stash-Operationen passend:
- `Config.InventoryBackend = 'auto'` erkennt `devix-inventory` automatisch (sonst `'devix'`/`'ox'` erzwingen).
- `Config.DevixResource` nur ändern, falls dein Devix-Inventar anders heißt.

Die Warehouse-Kisten werden **owner-los** registriert; die Zugriffskontrolle macht das Script
server-seitig über den Warehouse-Besitz (`spectrev_wh:requestOpen` prüft, bevor geöffnet wird).

## Wichtige Config-Punkte (must-do)
| Punkt | Wo | Bedeutung |
|---|---|---|
| `Config.InventoryBackend` | oben | `'auto'` erkennt Devix. Bei Bedarf `'devix'` oder `'ox'` erzwingen. |
| `Config.Recipes` | Mitte | **Platzhalter-Items** (`iron_ore` usw.) durch deine echten Item-Namen ersetzen. |
| `Config.Interior.shellModel` | Interior | **Model-Name deiner Shell** eintragen. Oder `spawnShell = false` + `anchor` auf die Koordinaten deiner bestehenden Shell-Resource legen. |
| `Config.Interior.*Spawn` / `points` | Interior | Auto-/Ped-Spawn und die Interaktionspunkte an deine Shell anpassen (Offsets zum `anchor`). |
| `Config.Warehouses` | unten | Kauf-Punkt, Garagentor und Preis je Standort. |

## Verarbeitung & die „24h“-Regel
Die Verarbeitung läuft server-seitig als Tick (`Config.Processing.tickSeconds`).
`craftsPerHour` je Level bestimmt das Tempo:

- **Level 1:** 10 Crafts/Std → 240 Crafts in 24 h. Passt du die Einlass-Größe so an, dass ein voller Einlass ≈ 240 Crafts an Rohstoffen fasst, ist ein voller Einlass bei Basislevel in genau **24 h** verarbeitet.
- **Level 2:** 20 Crafts/Std (2×) + größere Stashes.
- **Level 3:** 40 Crafts/Std (4×) + noch größere Stashes.

Läuft komplett automatisch: sobald passende Rohstoffe im Einlass liegen und in der Ausgabe Platz ist, werden sie nach Rezept umgewandelt — unabhängig davon, ob der Besitzer online ist.

## Upgrades
3 Level (`Config.Levels`). Jedes Upgrade erhöht **Geschwindigkeit + Einlass-/Ausgabe-Kapazität + Lagergröße**. Gekauft wird am **Terminal** im Warehouse. Preise & Werte frei in der Config einstellbar.

## Instanzierung
Jedes Warehouse nutzt einen eigenen **Routing-Bucket** (`Config.BucketBase + index`), sodass sich mehrere Besitzer dieselbe Shell-Position teilen können, ohne sich zu sehen.

## Admin
`/resetwarehouse <config_id>` (ace `group.admin`) setzt den Besitz eines Warehouses zurück.

## Offene Punkte / abstimmbar
- **Shell-Model:** aktuell Platzhalter (`placeholder_shell`) — sag mir den echten Model-Namen, dann trage ich Spawn/Offsets passend ein.
- **Rezepte:** aktuell Beispiele — nenn mir deine echten Input→Output-Items + Mengen.
- Optionale Erweiterungen möglich: Yield-Chance pro Level, mehrere Verarbeitungs-„Slots“, Warehouse-Verkauf durch Spieler, Mitarbeiter-Keys.
