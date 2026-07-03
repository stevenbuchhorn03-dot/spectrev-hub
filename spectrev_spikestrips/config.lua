Config = {}

-- ─── Job / Berechtigung ───────────────────────────────────────────────
Config.Job          = 'police'        -- Job, der Nagelbänder nutzen & einsammeln darf
Config.MinGrade     = 0               -- Mindest-Dienstgrad zum Auslegen (0 = jeder Polizist)

-- ─── Item ─────────────────────────────────────────────────────────────
Config.Item         = 'nagelband'     -- Item-Name in devix-inventory (siehe README)
Config.ReturnItem   = true            -- Item beim Einsammeln zurückgeben (wiederverwendbar)
Config.MaxPerPlayer = 5               -- Max. gleichzeitig ausgelegte Nagelbänder pro Beamtem

-- ─── Admin-Command ────────────────────────────────────────────────────
-- Legt ohne Item ein Nagelband ab. Zugriff über ACE-Rechte (siehe README):
--   add_ace group.admin command.spikestrip allow
Config.AdminCommand = 'spikestrip'

-- ─── Prop ─────────────────────────────────────────────────────────────
Config.Prop         = 'p_ld_stinger_s' -- Standard-GTA-Nagelband-Prop
Config.PlaceForward = 1.2             -- Abstand (m) vor dem Beamten, an dem ausgelegt wird

-- ─── Auslege-Animation ────────────────────────────────────────────────
Config.DeployAnim = {
    dict = 'anim@narcotics@trash',
    name = 'drop_front',
    time = 1200,                      -- Dauer der Animation in ms
}

-- ─── Erkennung / Reifen platzen ───────────────────────────────────────
Config.BurstSpeed        = 5.0        -- Mindestgeschwindigkeit in m/s (~18 km/h), damit Reifen platzen
Config.DetectRadius      = 7.0        -- Fahrzeuge in diesem Radius um ein Band werden geprüft
Config.WheelHitDistance  = 1.7        -- Abstand (m) eines Rades zum Band, ab dem der Reifen platzt
Config.NearStripDistance = 60.0       -- Erst ab dieser Nähe zu einem Band läuft die Erkennung pro Frame

-- ─── ox_target (Einsammeln) ───────────────────────────────────────────
Config.Target = {
    distance = 2.0,
    icon     = 'fa-solid fa-screwdriver-wrench',
    label    = 'Nagelband einsammeln',
}

-- ─── Anti-Cheat Toleranzen ────────────────────────────────────────────
Config.MaxDeployDistance = 8.0        -- Max. Abstand Server-Pos ↔ gemeldete Auslege-Pos
Config.MaxPickupDistance = 5.0        -- Max. Abstand des Beamten zum Band beim Einsammeln
