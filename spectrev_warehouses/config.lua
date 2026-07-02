Config = {}

-- ═══════════════════════════════════════════════════════════════════════════
--  ALLGEMEIN
-- ═══════════════════════════════════════════════════════════════════════════

-- Name der Inventar-Resource. Devix basiert auf ox_inventory und teilt sich
-- (laut deiner Angabe) dieselben Exports. Falls dein Devix-Inventar unter einem
-- anderen Resourcennamen läuft, trage ihn hier ein (z.B. 'devix_inventory').
-- Die im Script genutzten Exports sind: RegisterStash, AddItem, RemoveItem,
-- GetItem, CanCarryItem, openInventory. Sollten diese bei Devix anders heißen,
-- musst du nur die Wrapper-Funktionen in server/main.lua (Inv.*) anpassen.
Config.InventoryResource = 'ox_inventory'

-- Von welchem ESX-Konto Kauf & Upgrades abgebucht werden: 'bank' oder 'money'.
Config.PaymentAccount = 'bank'

-- Routing-Bucket Basis. Jedes Warehouse bekommt bucketBase + index, damit sich
-- Spieler in verschiedenen Warehouses (und die gleiche Shell) nicht sehen.
Config.BucketBase = 8000

-- ═══════════════════════════════════════════════════════════════════════════
--  VERARBEITUNG (läuft server-seitig, auch wenn der Besitzer offline ist)
-- ═══════════════════════════════════════════════════════════════════════════

Config.Processing = {
    -- Wie oft (in Sekunden) der Server einen Verarbeitungs-Tick rechnet.
    -- 60 = jede Minute. Kleiner = flüssiger, größer = weniger Last.
    tickSeconds = 60,
}

-- Rezepte: Rohstoff(e) -> verarbeitete Resource. Wird automatisch abgearbeitet,
-- sobald passende Rohstoffe im "Rohstoff-Einlass" liegen. Mehrere Rezepte werden
-- in Reihenfolge geprüft; das erste, für das genug Input + Ausgabe-Platz da ist,
-- wird ausgeführt.
--
-- >>> PLATZHALTER-REZEPTE <<< — ersetze die Item-Namen durch deine echten Items.
Config.Recipes = {
    {
        label  = 'Eisenerz -> Eisenbarren',
        input  = { { name = 'iron_ore', count = 2 } },
        output = { { name = 'iron_bar', count = 1 } },
    },
    {
        label  = 'Holz -> Bretter',
        input  = { { name = 'wood_log', count = 1 } },
        output = { { name = 'wood_plank', count = 2 } },
    },
    {
        label  = 'Rohgold -> Goldbarren',
        input  = { { name = 'raw_gold', count = 3 } },
        output = { { name = 'gold_bar', count = 1 } },
    },
}

-- ═══════════════════════════════════════════════════════════════════════════
--  LEVEL / UPGRADES
-- ═══════════════════════════════════════════════════════════════════════════
--
-- craftsPerHour = wie viele Verarbeitungs-Vorgänge (ein "Craft" = ein Durchlauf
-- eines Rezepts) pro Stunde erledigt werden. Zusammen mit der Einlass-Kapazität
-- ergibt das die "24h für maximale Menge"-Regel:
--
--   Level 1: 10 Crafts/Std -> 240 Crafts in 24h. Wenn der Einlass so viel fasst
--   wie ~240 Crafts an Rohstoffen, ist ein voller Einlass in genau 24h leer
--   verarbeitet. Höhere Level = schneller UND mehr Kapazität.
--
-- inputSlots/inputWeight  = Größe des Rohstoff-Einlasses
-- outputSlots/outputWeight = Größe der Ausgabe
-- storeSlots/storeWeight   = Größe des allgemeinen Lagers
-- upgradePrice = Kosten um AUF dieses Level zu upgraden (Level 1 = nil = Startlevel)
Config.Levels = {
    [1] = {
        label        = 'Basis',
        craftsPerHour = 10,
        inputSlots   = 50,  inputWeight  = 200000,
        outputSlots  = 50,  outputWeight = 200000,
        storeSlots   = 30,  storeWeight  = 150000,
        upgradePrice = nil,
    },
    [2] = {
        label        = 'Ausgebaut',
        craftsPerHour = 20,
        inputSlots   = 80,  inputWeight  = 350000,
        outputSlots  = 80,  outputWeight = 350000,
        storeSlots   = 60,  storeWeight  = 300000,
        upgradePrice = 250000,
    },
    [3] = {
        label        = 'Industriell',
        craftsPerHour = 40,
        inputSlots   = 120, inputWeight  = 600000,
        outputSlots  = 120, outputWeight = 600000,
        storeSlots   = 100, storeWeight  = 500000,
        upgradePrice = 750000,
    },
}

-- ═══════════════════════════════════════════════════════════════════════════
--  INTERIOR / SHELL
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Alle Innenraum-Punkte sind RELATIV zum anchor definiert (offset). So kannst du
-- die ganze Shell verschieben, indem du nur den anchor änderst, ohne die einzelnen
-- Punkte neu setzen zu müssen. Dank Routing-Buckets nutzen ALLE Warehouses denselben
-- anchor gleichzeitig, ohne sich zu überschneiden.
Config.Interior = {
    -- Ein abgelegener, leerer Ort auf der Map (Standard: über der Wüste, hoch oben).
    anchor = vector3(1800.0, 3300.0, 500.0),

    -- >>> Trage hier das Model deiner Shell ein <<<
    -- Wenn du eine separate Shell-RESOURCE hast, die den Innenraum bereits an
    -- fixen Koordinaten spawnt, setze spawnShell = false und lege den anchor auf
    -- die Koordinaten deiner bestehenden Shell.
    spawnShell  = true,
    shellModel  = 'placeholder_shell',   -- <-- z.B. 'imp_prop_warehouse_shell' o.ä.
    shellHeading = 0.0,

    -- Wo Auto / Spieler beim Betreten landen (offset zum anchor). w = Heading.
    vehicleSpawn = vector4(4.5, 0.0, 0.0, 90.0),
    pedSpawn     = vector4(-2.0, 0.0, 0.0, 90.0),

    -- Interaktionspunkte im Inneren (offset zum anchor).
    points = {
        input    = { offset = vector3(-4.0,  3.0, 0.0), size = vector3(1.5, 1.5, 2.0) }, -- Rohstoff-Einlass
        output   = { offset = vector3(-4.0, -3.0, 0.0), size = vector3(1.5, 1.5, 2.0) }, -- Ausgabe
        store    = { offset = vector3(-6.0,  0.0, 0.0), size = vector3(1.5, 1.5, 2.0) }, -- Lager
        terminal = { offset = vector3(-4.0,  0.0, 0.0), size = vector3(1.0, 1.0, 2.0) }, -- Terminal (Status/Upgrade)
        exit     = { offset = vector3( 6.0,  0.0, 0.0), size = vector3(2.0, 2.0, 2.0) }, -- Ausgang
    },
}

-- ═══════════════════════════════════════════════════════════════════════════
--  WAREHOUSE-STANDORTE (kaufbare Objekte auf der Map)
-- ═══════════════════════════════════════════════════════════════════════════
--
-- id       = eindeutiger Schlüssel (nicht ändern, wird in der DB gespeichert!)
-- price    = Kaufpreis
-- purchase = Punkt an dem man das Warehouse KAUFT (Schild / Makler-Punkt)
-- garage   = Garagentor: hier "Einfahren" (mit Auto) bzw. "Betreten" (zu Fuß)
-- exit     = wohin man beim Verlassen zurück teleportiert wird (meist vor's Tor)
-- blip     = optionaler Map-Blip
Config.Warehouses = {
    {
        id       = 'wh_cypress',
        label    = 'Lagerhalle Cypress Flats',
        price    = 500000,
        purchase = vector3(717.5, -1088.5, 22.2),
        garage   = vector4(709.0, -1075.0, 22.2, 180.0),
        exit     = vector4(709.0, -1078.5, 22.2, 0.0),
        blip     = { sprite = 473, color = 5, scale = 0.8 },
    },
    {
        id       = 'wh_larsa',
        label    = 'Lagerhalle LSIA',
        price    = 650000,
        purchase = vector3(-1067.0, -2560.0, 13.5),
        garage   = vector4(-1075.0, -2565.0, 13.5, 240.0),
        exit     = vector4(-1072.0, -2568.0, 13.5, 60.0),
        blip     = { sprite = 473, color = 5, scale = 0.8 },
    },
}
