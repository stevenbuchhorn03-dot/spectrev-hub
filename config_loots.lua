-- Loot refresh rate, loot list, grid size, prop triggers, static loot points, exports, searching sound.
-- Example prop: [prop-postbox_01a]


LootConfig = LootConfig or {}

-- ============================================================================
-- GENERAL SETTINGS
-- ============================================================================

LootConfig.Enabled = true

-- Target integration:
-- useTarget = true  -> ox_target / qb-target uzerinden etkileşim
-- useTarget = false -> klasik "E" ile etkileşim
LootConfig.UseTarget = true
LootConfig.TargetSystem = "auto" -- "auto" | "ox_target" | "qb-target"
LootConfig.Target = {
    icon = "fas fa-box-open",
    label = "Search Loot",
    distance = 2.0,
}

-- Inspect (hidden loot): when true, items show as '?' until clicked (inspect animation). When false, all items visible when loot panel opens.
LootConfig.EnableInspect = true

-- Global refresh time (seconds). Each region/lootType can override this.
LootConfig.GlobalRefreshSeconds = 900 -- 15 minutes

-- Minimum cooldown (seconds) before the same loot container can be looted again.
LootConfig.MinSearchCooldownSeconds = 3

-- Default loot panel size and roll. Used when LootTypes entry has no grid/rolls.
LootConfig.SearchSound = {
    enabled = true,
    nuiSound = "loot_search",
    frontendSoundset = "",
    soundName = "",
}

-- SFX list played randomly in NUI when inspect (search click) starts (inventory_sound_effects/*.wav)
LootConfig.InspectSfx = { "searching_1", "searching_2", "searching_3", "searching_4", "searching_5" }

-- ============================================================================
-- LOOT TYPES / LISTS
-- ============================================================================

LootConfig.LootTypes = {}
-- ============================================================================
-- PROP TRIGGERS (PROP-BASED LOOT)
-- ============================================================================

-- When player is near the prop and presses E, the associated lootType opens.
LootConfig.PropTriggers = {
    -- Example: postboxes
    ["prop_postbox_01a"] = {
        lootType = "generic_small",
        -- Cooldown (seconds) before same player can loot this prop again
        perPlayerCooldownSeconds = 300,
        -- Override global/type refresh; nil = use lootType.refreshSeconds
        refreshSecondsOverride = nil,
    },

    -- Another prop example:
    ["prop_bin_05a"] = {
        lootType = "generic_small",
        perPlayerCooldownSeconds = 120,
    },
}

-- ============================================================================
-- STATIC LOOT POINTS (COORDS-BASED)
-- ============================================================================

-- When player is within radius of this point, E opens loot.
LootConfig.StaticLootPoints = {
    {
        id = "police_armory_crate_1",
        lootType = "weapon_cache",
        coords = vector3(451.2, -980.3, 30.7),
        radius = 1.5,
        -- Override refresh for this point only
        refreshSecondsOverride = 3600, -- 1 hour
    },
    {
        id = "downtown_trash_cache_1",
        lootType = "generic_small",
        coords = vector3(-681.05, 5828.32, 17.33),
        radius = 1.5,
    },
}

-- Loot Creator export (auto-generated)
LootConfig.LootTypes["lootTest"] = {
    label = "test loot label",
    slots = {
        [1] = {
            items = { {
                    min = 1,
                    name = "cash",
                    info = {
                        rarity = { "common" },
                    },
                    weight = 50,
                    chance = 80,
                    max = 50,
                }, {
                    min = 1,
                    name = "cash_stack_1",
                    info = {
                        rarity = { "common" },
                    },
                    weight = 50,
                    chance = 80,
                    max = 1,
                }, {
                    min = 1,
                    name = "cashroll",
                    info = {
                        rarity = { "common" },
                    },
                    weight = 50,
                    chance = 80,
                    max = 1,
                } },
        },
    },
    refreshSeconds = 900,
}
LootConfig.PropTriggers["prop_bin_08a"] = {
    lootType = "lootTest",
    perPlayerCooldownSeconds = 3,
}
LootConfig.PropTriggers["prop_table_01"] = {
    lootType = "lootTest",
    perPlayerCooldownSeconds = 3,
}
table.insert(LootConfig.StaticLootPoints, { id = "point_1774285276653", lootType = "lootTest", coords = vector3(-681.936, 5822.702, 17.331), radius = 1.50, refreshSecondsOverride = nil })

return LootConfig
