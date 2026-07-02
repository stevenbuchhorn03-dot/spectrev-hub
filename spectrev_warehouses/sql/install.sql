-- Persistenz für gekaufte / upgradebare Warehouses.
-- Die eigentlichen Item-Inhalte (Einlass / Ausgabe / Lager) speichert ox_inventory
-- selbst in seinen eigenen Stash-Tabellen — hier steht nur Besitz, Level & Fortschritt.

CREATE TABLE IF NOT EXISTS `spectrev_warehouses` (
    `config_id`  VARCHAR(64)  NOT NULL,
    `owner`      VARCHAR(64)  NOT NULL,
    `level`      INT          NOT NULL DEFAULT 1,
    `progress`   FLOAT        NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`config_id`),
    INDEX (`owner`)
);
