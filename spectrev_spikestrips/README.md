# spectrev_spikestrips

Polizei-Nagelbänder (Spike Strips) für **FiveM** mit **devix-core / devix-inventory**.
Item-basiert, auf den Job `police` beschränkt, mit **ox_target** zum Einsammeln.

## Features

- **Nagelband als Item** (`nagelband`) – wird über devix-inventory benutzt und legt das Band aus.
- **Job-restricted**: Nur Spieler mit dem Job `police` (ab konfigurierbarem Dienstgrad) können Bänder benutzen und einsammeln. Serverseitig gegen Cheating abgesichert.
- **Admin-Command** `/spikestrip`: Legt ohne Item ein Nagelband ab (ACE-geschützt).
- **Realistische Erkennung**: Nur die Reifen, die tatsächlich über das Band fahren, platzen (rad-genau via Bone-Position). Reifen platzen erst ab einer Mindestgeschwindigkeit.
- **Wiederverwendbar**: Beim Auslegen wird 1 Item entfernt, beim Einsammeln 1 Item zurückgegeben.
- **Einsammeln via ox_target**: Auf das Band zielen → „Nagelband einsammeln".
- **Sync**: Bänder werden auf allen Clients als lokale Objekte gespawnt (keine Ownership-/Despawn-Probleme). Neu verbundene Spieler bekommen alle aktiven Bänder nachgeladen.

## Abhängigkeiten

- [devix-core](https://devix.gitbook.io/devix/devix-core)
- [devix-inventory](https://devix.gitbook.io/devix/devix-inventory)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Ordner `spectrev_spikestrips` in deinen `resources`-Ordner kopieren.
2. In der `server.cfg` **nach** `devix-core`, `devix-inventory` und `ox_target` starten:

   ```cfg
   ensure spectrev_spikestrips
   ```

3. Item in devix anlegen (siehe unten).
4. ACE-Recht für den Admin-Command vergeben (siehe unten).
5. `config.lua` nach Bedarf anpassen (Job, Limit, Geschwindigkeit, etc.).

## Item in devix anlegen

In deiner devix-Item-Config (`config_items.lua` bzw. shared items) folgenden Eintrag ergänzen.
Wichtig ist der **`server.useExport`** – so ruft devix beim Benutzen unseren Export auf
(siehe [Item: Use, Add, Remove](https://devix.gitbook.io/devix/devix-inventory/item-use-add-remove)):

```lua
['nagelband'] = {
    name        = 'nagelband',
    label       = 'Nagelband',
    weight      = 3500,
    stack       = true,
    close       = true,
    description = 'Ein Nagelband zum Stoppen flüchtender Fahrzeuge.',
    server = {
        useExport = 'spectrev_spikestrips.useNagelband',
    },
},
```

> **Wichtig:** Der Item-Name (`nagelband`) muss mit `Config.Item` in `config.lua` übereinstimmen.
> Das Bild `nagelband.png` im entsprechenden Item-Bilderordner ablegen, damit das Item im Inventar
> mit Grafik angezeigt wird.

### Item geben / verkaufen

- Zum Testen z.B. über deinen Admin-/Giveitem-Weg das Item `nagelband` vergeben.
- Für Läden/Job-Shops einfach `nagelband` als kaufbares Item hinterlegen.

## Admin-Command `/spikestrip`

Der Command ist als **restricted command** registriert. Vergib das Recht in der `server.cfg`
(oder per ACE-Konfiguration):

```cfg
add_ace group.admin command.spikestrip allow
```

Damit kann jeder Spieler der ACE-Gruppe `admin` mit `/spikestrip` ein Nagelband ablegen –
ohne ein Item zu verbrauchen. Der Command-Name ist über `Config.AdminCommand` anpassbar.

## Konfiguration (`config.lua`)

| Option | Beschreibung |
| --- | --- |
| `Config.Job` | Erlaubter Job (Standard `police`). |
| `Config.MinGrade` | Mindest-Dienstgrad zum Auslegen. |
| `Config.Item` | Item-Name in devix-inventory. |
| `Config.ReturnItem` | Item beim Einsammeln zurückgeben (Standard `true`). |
| `Config.MaxPerPlayer` | Max. gleichzeitig ausgelegte Bänder pro Beamtem. |
| `Config.AdminCommand` | Name des Admin-Commands (Standard `spikestrip`). |
| `Config.BurstSpeed` | Mindestgeschwindigkeit in m/s, damit Reifen platzen (5.0 ≈ 18 km/h). |
| `Config.WheelHitDistance` | Abstand Rad ↔ Band, ab dem der Reifen platzt. |
| `Config.DetectRadius` | Prüfradius für Fahrzeuge um ein Band. |

## Funktionsweise (kurz)

1. Beamter benutzt das Item `nagelband` → devix ruft `exports.spectrev_spikestrips:useNagelband(src, itemData)` → Server prüft Job/Limit → Client legt das Band vor dem Beamten ab (mit Animation).
2. Client bestätigt die Position → Server verbraucht 1 Item, registriert das Band und lässt es auf allen Clients spawnen.
3. Fährt ein Fahrzeug schnell genug über das Band, platzen die berührten Reifen (rad-genau).
4. Ein Beamter zielt via ox_target auf das Band → Server prüft Nähe/Job, entfernt das Band überall und gibt (bei `ReturnItem = true`) 1 Item zurück.

## Genutzte Exports / Natives

**devix-core** (`local DEVIX = exports['devix-core']:getObjects()`)
- `DEVIX.GetPlayer(src)`, `DEVIX.GetPlayerJob(player)`
- `DEVIX.AddItem(player, item, amount)`, `DEVIX.RemoveItem(player, item, amount)`
- `DEVIX.Notify(src, msg, type)` (Server) / `DEVIX.Notify(msg, type)` (Client)

**devix-inventory**
- `exports['devix-inventory']:GetItemCount(src, item)`
- `exports['devix-inventory']:CanCarryItem(src, item, amount)`
- Item-Nutzung über `server.useExport` in der Item-Config

**ox_target**
- `exports.ox_target:addLocalEntity` / `removeLocalEntity`

**FiveM-Natives**
- Prop `p_ld_stinger_s`
- `SetVehicleTyreBurst`, `IsVehicleTyreBurst`, `GetWorldPositionOfEntityBone`, `GetEntityBoneIndexByName`, `GetEntitySpeed`, `GetGamePool('CVehicle')`
- `IsPlayerAceAllowed` (Admin-Command-Absicherung)
