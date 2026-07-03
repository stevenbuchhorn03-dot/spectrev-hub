# spectrev_spikestrips

Polizei-Nagelbänder (Spike Strips) für **FiveM ESX Legacy**.
Item-basiert, auf den Job `police` beschränkt, mit **ox_inventory** und **ox_target**.

## Features

- **Nagelband als Item** (`nagelband`) – wird über ox_inventory benutzt und legt das Band aus.
- **Job-restricted**: Nur Spieler mit dem Job `police` (ab konfigurierbarem Dienstgrad) können Bänder benutzen und einsammeln. Zusätzlich serverseitig gegen Cheating abgesichert.
- **Realistische Erkennung**: Nur die Reifen, die tatsächlich über das Band fahren, platzen (rad-genau via Bone-Position). Reifen platzen erst ab einer Mindestgeschwindigkeit.
- **Wiederverwendbar**: Beim Auslegen wird 1 Item entfernt, beim Einsammeln 1 Item zurückgegeben.
- **Einsammeln via ox_target**: Auf das Band zielen → „Nagelband einsammeln".
- **Sync**: Bänder werden auf allen Clients als lokale Objekte gespawnt (keine Ownership-/Despawn-Probleme). Neu verbundene Spieler bekommen alle aktiven Bänder nachgeladen.
- **Limit pro Beamtem** und Auslege-Animation konfigurierbar in `config.lua`.

## Abhängigkeiten

- [es_extended](https://github.com/esx-framework/esx_core) (ESX Legacy 1.9+)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Ordner `spectrev_spikestrips` in deinen `resources`-Ordner kopieren.
2. In der `server.cfg` **nach** `es_extended`, `ox_inventory` und `ox_target` starten:

   ```cfg
   ensure spectrev_spikestrips
   ```

3. Item in ox_inventory anlegen (siehe unten).
4. `config.lua` nach Bedarf anpassen (Job, Limit, Geschwindigkeit, etc.).

## Item in ox_inventory anlegen

In `ox_inventory/data/items.lua` folgenden Eintrag ergänzen:

```lua
['nagelband'] = {
    label = 'Nagelband',
    weight = 3500,
    stack = true,
    close = true,
    description = 'Ein Nagelband zum Stoppen flüchtender Fahrzeuge.',
},
```

> **Wichtig:** Der Item-Name (`nagelband`) muss mit `Config.Item` in `config.lua` übereinstimmen.
> Es ist **kein** eigener `client.export`/`server.export` nötig – die Nutzung wird über
> `ESX.RegisterUsableItem` (server/main.lua) registriert. `close = true` schließt beim Benutzen das Inventar.

### Item-Bild (optional)

Ein Bild `nagelband.png` in `ox_inventory/web/images/` ablegen, damit das Item im Inventar
mit Grafik angezeigt wird.

### Item geben / verkaufen

- Zum Testen: `/giveitem <id> nagelband 1` (ESX-Admin-Command).
- Für Läden/Job-Shops einfach `nagelband` als kaufbares Item hinterlegen.

## Konfiguration (`config.lua`)

| Option | Beschreibung |
| --- | --- |
| `Config.Job` | Erlaubter Job (Standard `police`). |
| `Config.MinGrade` | Mindest-Dienstgrad zum Auslegen. |
| `Config.Item` | Item-Name in ox_inventory. |
| `Config.ReturnItem` | Item beim Einsammeln zurückgeben (Standard `true`). |
| `Config.MaxPerPlayer` | Max. gleichzeitig ausgelegte Bänder pro Beamtem. |
| `Config.BurstSpeed` | Mindestgeschwindigkeit in m/s, damit Reifen platzen (5.0 ≈ 18 km/h). |
| `Config.WheelHitDistance` | Abstand Rad ↔ Band, ab dem der Reifen platzt. |
| `Config.DetectRadius` | Prüfradius für Fahrzeuge um ein Band. |

## Funktionsweise (kurz)

1. Beamter benutzt das Item `nagelband` → Server prüft Job/Limit → Client legt das Band vor dem Beamten ab (mit Animation).
2. Client bestätigt die Position → Server verbraucht 1 Item, registriert das Band und lässt es auf allen Clients spawnen.
3. Fährt ein Fahrzeug schnell genug über das Band, platzen die berührten Reifen (rad-genau).
4. Ein Beamter zielt via ox_target auf das Band → Server prüft Nähe/Job, entfernt das Band überall und gibt (bei `ReturnItem = true`) 1 Item zurück.

## Genutzte FiveM-Natives / ESX-Exports

- `exports['es_extended']:getSharedObject()` – ESX-Objekt (Legacy 1.9+)
- `ESX.RegisterUsableItem` / `xPlayer.removeInventoryItem` / `xPlayer.addInventoryItem` / `xPlayer.canCarryItem`
- `exports.ox_target:addLocalEntity` / `removeLocalEntity`
- Prop `p_ld_stinger_s`
- `SetVehicleTyreBurst`, `IsVehicleTyreBurst`, `GetWorldPositionOfEntityBone`, `GetEntityBoneIndexByName`, `GetEntitySpeed`, `GetGamePool('CVehicle')`
