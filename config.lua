
Config = {}

-- =============================================================================
-- DEBUG & DEVELOPERS
-- =============================================================================

-- NUI / default language (first launch; player override in settings → localStorage).
-- Any key defined in Locales/locales.lua (e.g. "en", "tr", "zh"). Restart resource after adding a locale.
Config.DefaultLocale = "en"


Config.Debug = false     
Config.DebugGridLayout = false -- Grid çakışma / ResolveGridOverlaps — sadece layout debug (Debug'dan ayrı).
Config.DebugWeaponDrop = false    -- Weapon drop / remove logs (F8 + server console)
Config.DebugWeaponDurabilityShoot = false
Config.DebugWeaponTint = false    -- Weapon tint logs (server + client console)
Config.DebugQuickSlot = false     -- Quickslot load/save and NUI flow
Config.DebugVerboseUseItem = false -- Verbose per-useItem logs (can be expensive under spam).
Config.DebugVerboseRemoveItem = false -- Verbose RemoveItem grid-name logs (string concat + large output).
Config.DebugBag = false           -- Bag slot, drawable/texture (F8 client console)
Config.DebugDragGive = false      -- Drag->give: raycast print + DrawLine/DrawMarker (F8 client; disable when done)
Config.DropDebug = false          -- Drop / GetDrop / SQL iz — sadece drop sorunu ararken açın
Config.DebugTransferPerf = false
-- Server: tüm DevixInvPerfStart/End ölçümleri (transfer, getInventory, BuildInventoryResponse…)
Config.DebugPerf = false
-- useItem + kıyafet slotları toplam/aşama süreleri ([use-clothes] prefix). DebugPerf false iken sadece bunu açabilirsin.
-- F8 resmon çoğunlukla client; mermi sunucuda wall~0ms normal — client [perf][cl][AddAmmo] satırlarına bak.
Config.DebugUseItemClothesPerf = false
-- useItem akışı resmon korelasyonu: `config_performance.lua` içinde `Config.DebugResmonUseItemPrint` veya `setr devix_inv_resmon_useitem 1` (prefix `[devix-inv][resmon][useitem]`).
-- Server: envanter açılışı [devix-inv-open]; BuildInventoryResponse iç adımlar [devix-inv-open][br] (resmon bunları ayırmaz).
Config.DebugOpenInventoryPerf = false
-- getInventory tek [perf] satırı: toplam süre bu ms altındaysa yazdırma (CACHE_HIT spamını keser). 0 = her zaman yaz.
Config.DebugPerfGetInventoryMinMs = 5
-- Drag->give: target ped highlight (marker + soft light at marker position)
Config.GiveTargetHighlight = {
    ground = { r = 0, g = 255, b = 120, a = 220 },
    -- Point light (DrawLightWithRange): range = spread, intensity = brightness
    light = { r = 0, g = 255, b = 200, range = 0.8, intensity = 1.0 },
}
-- Max distance (meters) when giving an item to a player (drag & drop). Players farther than this cannot receive items.
Config.GiveTargetMaxDistance = 3.0

-- After a successful player→player give (context Give, drag-drop, batch give, ox giveItemToTarget):
-- short give/receive anim on both giver and receiver clients (fired after server confirms).
Config.GiveItemAnim = {
    enabled = true,
    dict = "mp_common",
    giverClip = "givetake1_a",
    receiverClip = "givetake1_b",
    durationMs = 2000,
    blendIn = 8.0,
    blendOut = -8.0,
    -- TaskPlayAnim flags; try 49 if inventory is open and you want upper-body only (e.g. 48 upper + control variants)
    flag = 0,
}

--[[
  NUI Settings (gear): server defaults, full lock, or per-row rules when players may open settings.
  lockAndHideSettings = true  → gear hidden; `preferences` enforced; localStorage ignored (client+NUI).
  lockAndHideSettings = false → player can open settings; NUI: `preferences` = varsayılan; oyuncunun LS'te kaydettiği değer, playerCanChange≠false iken preferences üstündedir (ör. inventoryCamera).
  playerCanChange:
    • true / omitted = player can change that option in Settings.
    • false = player cannot change it: row is hidden if hideNonChangeableRows (default), else row visible but controls disabled.
  hideNonChangeableRows = false → locked rows (playerCanChange false) stay visible but greyed/disabled.
]]
Config.InventoryPlayerPreferences = {
    lockAndHideSettings = false,
    -- If true (default): playerCanChange = false rows are not shown. If false: shown but disabled.
    hideNonChangeableRows = true,
    preferences = {
        language = "en", -- optional; uses Config.DefaultLocale when omitted
        blur = true,
        showHint = true,
        showItemRarity = true,
        inventoryCamera = true,
        accent = "#35e0c4",          -- Storyline mint — matches --accent in styles.css
        durabilityHigh = "#63d38c",
        durabilityLow = "#e36a6a",
        gridBorder = "#ffffff",
        gridBorderOpacity = 5,
        invBg = "#0a0f0f",           -- Storyline dark teal-black panel base
        invBgOpacity = 60,           -- matches the settings default in index.html
    },
    playerCanChange = {
        language = false,
        blur = false,
        showHint = false,
        showItemRarity = false,
        inventoryCamera = true,
        invBg = true,
        invBgOpacity = true,
        accent = true,
        durabilityHigh = true,
        durabilityLow = true,
        gridBorder = true,
        gridBorderOpacity = false,
        reset = true,
    },
}

-- Discord webhook URLs — one per action type (leave empty to disable logging)
Config.Webhooks = {
    -- Item transfer: player ↔ stash/trunk/glovebox/drop/bag/searched_player (drag-drop, move)
    transfer = "",
    -- Shop purchase
    purchase = "",
    -- Drop create: single item dropped on ground
    drop_create = "",
    -- Add to existing drop (addToDrop): items added from player to drop
    drop_add = "",
    -- Drop update (setDrop): reorder/split inside drop panel
    drop_update = "",
    -- Take all: drop/trunk/stash/glovebox/bag → player (takeAllToPlayer)
    take_all = "",
    -- Give item: player to player (giveItem)
    give_item = "",
    -- Search: take from searched player clothes slot to searcher inventory
    search_take_clothes = "",
    -- Search: move from searched player clothes to their grid inventory
    search_move_clothes_to_inv = "",
    -- Search: add item to searched player clothes slot (addItemToSearchedPlayerClothes)
    search_add_clothes = "",
    -- Grid transfer involving searched_player (transferBetweenInventories fromType/toType)
    search_transfer = "",
    -- Fold item
    fold = "",
    -- Unfold item
    unfold = "",
    -- Move from clothes slot to drop (moveClothesItemToDrop)
    clothes_to_drop = "",
    -- Move from drop to clothes slot (moveDropItemToClothes)
    drop_to_clothes = "",
    -- Move from clothes slot to player grid (moveClothesItemToPlayer)
    clothes_to_player = "",
    -- Crafting: recipe completed, item added to player
    crafting = "",
    -- Item used (consumed or used via useItem)
    use_item = "",
    -- Inventory grid → clothes slot (setClothes: player equipped item to clothes)
    inventory_to_clothes = "",
}
-- Grid UI (NUI): slot size and spacing (sent to script.js)
-- primaryFrameMaxRows/Cols: default frame max; each inventory can override with its own primaryFrameMaxRows/Cols in Config.Inventories
Config.GridUI = {
    cellSize = 72,    -- px per slot — Storyline scale; keep in sync with --cell-size in styles.css
    gridGap = 2,       -- px between slots
    gridPadding = 2,   -- px around grid
    primaryFrameMaxRows = 10,   -- default (used when not defined for player or inventories); 10 × 72px ≈ 740px
    primaryFrameMaxCols = 10,   -- default (used when not defined for player or inventories)
    -- Drag-drop / transfer throttle (ms). Lower = snappier but more server load; higher = fewer duplicate posts.
    transferLockMs = 220,       -- after a transfer, block new drag-start for this many ms (prevents double-fires)
    transferDebounceMs = 620,   -- minimum delay between two transferBetweenInventories posts (debounce)
}

-- If bag visuals are overridden by another script (skin/appearance), periodically reapply
Config.BagPersistenceSeconds = 4   -- Duration (seconds). 0 = disabled
Config.BagPersistenceIntervalMs = 250

-- =============================================================================
-- DATABASE & SOUND
-- =============================================================================

Config.Mysql = "oxmysql"   -- "oxmysql" | "mysql-async" | "ghmattimysql"

Config.Sound3D = {
    enabled = true,
    maxDistance = 15.0,   -- meters
}

Config.MaxItemAmount = 999999999 -- Max stackable amount (enough for transfer payload)
-- Latent event BPS for large payloads (inventory, drop) during transfer/sync
Config.SyncPayloadBps = 500000 -- 500KB/s — increased for high player count (500+) burst payloads

-- Stack metadata: only these info keys are compared for identity. Craft/shop/source/loot keys are ignored.
-- If two items differ on any key listed here (or one has it and the other does not), they do not stack.
-- Keys not listed here do not block stacking unless StackStrictUnknownMetadata is true.
Config.StackDistinguishingInfoKeys = {
    ["serie"] = true,
    ["serial"] = true,
    ["serial_number"] = true,
    ["serialnumber"] = true,
    ["citizenid"] = true,
}
-- true: any info key other than quality/durability/unitDurabilities and not in StackDistinguishingInfoKeys blocks stacking (legacy-like).
-- false: only distinguishing keys + condition checks matter (craft/market/unknown metadata can stack).
Config.StackStrictUnknownMetadata = false

-- Only items listed here + items in config_food and weapons use durability.
-- Value forms (per item key, lowercase):
--   true  → lose 10 condition per use; removeWhenBroken defaults to Config.DurabilityItemRemove
--   N>0   → lose N per use; removeWhenBroken defaults to Config.DurabilityItemRemove
--   table → { enabled = true|false, decreasePerUse = 10, removeWhenBroken = true|false }
--           omit removeWhenBroken to inherit Config.DurabilityItemRemove; omit decreasePerUse for 10
-- Adding food/drink here ensures the durability bar appears; consumption-based decrease is controlled by config_food.lua (durabilityDecrease).
Config.DurabilityItems = {
    -- Food items (works together with config_food.lua; shows durability bar)
    ["sandwich"] = true,
    ["burger"] = true,
    ["hamburger"] = true,
    ["donut"] = true,
    ["taco"] = true,
    ["hotdog"] = true,
    ["pizza"] = true,
    ["chips"] = true,
    ["candy"] = true,
    ["bread"] = true,
    -- Drinks
    ["water_bottle"] = true,
    ["water"] = true, 
    ["ecola"] = true,
    ["sprunk"] = true,
    ["coffee"] = true,
    ["juice"] = true,
    ["energy_drink"] = true,
    -- ["phone"] = true,
    ["beer"] = true,
    -- Vest: grants armor when equipped; durability drops on damage; when 0 the slot is emptied and a "vest destroyed" notify is shown
    ["clothe_vest"] = true,
    -- Other (optional): per-use wear; when condition hits 0, one stack unit is removed (last unit removes the grid item)
    ["pcb"] = {
        enabled = true,
        decreasePerUse = 10,
        removeWhenBroken = true,
    },
    -- ["tool_wrench"] = true,
    -- ["tool_wrench"] = 5,
}
-- Default removeWhenBroken for DurabilityItems entries that are true or a number (not overridden in a table).
Config.DurabilityItemRemove = true

-- Vest (clothe_vest): armor granted when equipped (0-100), and durability lost per armor damage
Config.VestArmorMax = 100
Config.VestDurabilityPerArmorLost = 1  -- How much vest durability decreases when player loses 1 armor
Config.VestDamageGraceMs = 1000  -- Spawn/apply sonrası bu süre (ms) boyunca zırh kaybı sayılmaz (yanlış "destroyed" engelleme)

-- Weapon durability / jam are configured in config_weapons.lua (WeaponsConfig) and bridged below.

-- Item rarities — used for UI glow and tooltip line
-- Key: item name (lowercase), Value: "common" | "uncommon" | "rare" | "epic" | "legendary"
Config.ItemRarity = {
    ["water_bottle"]   = "common",
    ["sandwich"]       = "common",
    ["radio"]          = "uncommon",
    ["phone"]          = "rare",
    ["weapon_pistol"]  = "epic",
    ["repairkit"]      = "uncommon",
}

-- =============================================================================
-- GRID & ITEM SIZES
-- =============================================================================

Config.GridCellSize = 72          -- Size of each grid cell in pixels (UI) — matches Config.GridUI.cellSize
Config.DefaultItemWidth = 1       -- Default item width (in grid cells) if undefined — Storyline: 1 item = 1 big slot
Config.DefaultItemHeight = 1      -- Default item height (in grid cells) if undefined

-- =============================================================================
-- USER INTERFACE
-- =============================================================================

Config.DraggableInventory = true -- çalışmıyor 
-- true: When inventory opens the camera smoothly pulls back from current position and FOV widens; closing restores previous camera.
-- Can be disabled by the player in Settings.
Config.InventoryCamera = true
-- Transfer progress bar (used for drop, bag, trunk, glovebox, etc.)
Config.ProgressBar = false
Config.ProgressBarWeightCalculation = true   -- Use item weight to calculate duration
Config.ProgressBarBaseDuration = 800         -- Base ms duration
Config.ProgressBarWeightMultiplier =10      -- Extra ms per weight unit
Config.ProgressBarLabel = "Moving..."
Config.TransferQueueBatchDelayMs = 200        -- Batch delay for grouped transfers (take-all)
Config.ProgressBarCancelKey = "X"

Config.ProgressBarAnimation = {
    animDict = "anim@heists@ornate_bank@grab_cash",
    anim = "intro",
    flags = 1,
}

-- =============================================================================
-- PROGRESS BAR (ammo reload, etc.) — optional custom implementation
-- =============================================================================
-- If your server does not use qb-core, set Config.ProgressBarFunction to your own function.
-- Signature: function(durationMs, label, onComplete, onCancel)
--   durationMs: number (e.g. 5000)
--   label: string (e.g. "Loading...")
--   onComplete: function() — call when progress finishes successfully
--   onCancel: function() — call when the user cancels (e.g. X key)
-- When nil, the script tries qb-core Progressbar, then falls back to a simple timer (no UI).
--
-- Example (ox_lib): returns true when done, false when cancelled.
--   Config.ProgressBarFunction = function(durationMs, label, onComplete, onCancel)
--     CreateThread(function()
--       local ok = lib and lib.progressBar and lib.progressBar({ duration = durationMs, label = label, useWhileDead = false, canCancel = true, disable = { move = false, car = false, mouse = false, combat = true } })
--       if ok then onComplete() else onCancel() end
--     end)
--   end
--
-- Example (ESX / custom): run your progress UI, then call onComplete() or onCancel() when done.
Config.ProgressBarFunction = nil


-- Config.ProgressBarFunction = function(durationMs, label, onComplete, onCancel)
--     CreateThread(function()
--         local ok = lib and lib.progressBar and lib.progressBar({
--             duration = durationMs,
--             label = label,
--             useWhileDead = false,
--             canCancel = true,
--             disable = { move = false, car = false, mouse = false, combat = true }
--         })
--         if ok then onComplete() else onCancel() end
--     end)
-- end

-- =============================================================================
-- HUNGER / THIRST HUD INTEGRATION
-- =============================================================================
-- Configure how the inventory should notify external HUDs when hunger/thirst change.
-- By default the QB-Core compatible event "hud:client:UpdateNeeds" is used.
-- You can change to your own event or use an export from another resource.
--
-- Example (use event):
-- Config.HungerThirst = {
--     useExport = false,
--     clientEvent = "hud:client:UpdateNeeds", -- TriggerClientEvent(clientEvent, src, hunger, thirst)
-- }
--
-- Example (use export):
-- Config.HungerThirst = {
--     useExport = true,
--     exportName = "esx_status",            -- resource providing an export
--     exportFunction = "set",               -- function name to call via exports[exportName]:exportFunction(src, data)
--     exportWrapper = function(src, h, t)   -- optional wrapper for custom signatures (server-side)
--         local ok, _ = pcall(function() exports['esx_status']:set(src, { hunger = h, thirst = t }) end)
--     end,
-- }
--
-- If both useExport and clientEvent are provided, export is preferred.
Config.HungerThirst = {
    useExport = false,
    clientEvent = "hud:client:UpdateNeeds",
    exportName = "",
    exportFunction = "",
    exportWrapper = nil,
}

-- =============================================================================
-- KEYBINDS
-- =============================================================================

Config.Keybinds = {
    Open = "F2",
    ShowQuickSlot = "TAB",
    EatAndDrink = "E",
    CancelFood = "X",
    RotateItem = "R",
    -- Numpad (right block)
    QuickSlot1 = "NUMPAD1",
    QuickSlot2 = "NUMPAD2",
    QuickSlot3 = "NUMPAD3",
    QuickSlot4 = "NUMPAD4",
    QuickSlot5 = "NUMPAD5",
    QuickSlot6 = "NUMPAD6",
    QuickSlot7 = "NUMPAD7",
    QuickSlot8 = "NUMPAD8",
    QuickSlot9 = "NUMPAD9",
    -- Top row numbers (1–9): same slots, both work
    QuickSlot1Row = "1",
    QuickSlot2Row = "2",
    QuickSlot3Row = "3",
    QuickSlot4Row = "4",
    QuickSlot5Row = "5",
    QuickSlot6Row = "6",
    QuickSlot7Row = "7",
    QuickSlot8Row = "8",
    QuickSlot9Row = "9",
}

-- =============================================================================
-- VEHICLE INVENTORY
-- =============================================================================

Config.VehicleInventory = {
    enabled = true,
    gloveboxInVehicle = true,
    trunkDistance = 1.9,
    checkLockState = true,
    useVehiclePlate = true,
    -- Per-vehicle trunk/glovebox config (model name string or hash number)
    -- Priority: vehicle > class > Config.Inventories.trunk/glovebox
    -- Set trunk = false or glovebox = false to disable that inventory for the vehicle
    vehicles = {
        ["issi2"] = { trunk = { rows = 3, cols = 6, maxWeight = 150000 }, glovebox = { rows = 2, cols = 3, maxWeight = 30000 } },
        -- ["faggio"] = { trunk = false, glovebox = false }, -- Motorcycle: no trunk/glovebox
    },
    -- Per-class trunk/glovebox config (GetVehicleClass IDs 0-21)
    -- Set trunk = false or glovebox = false to disable for entire class
    classes = {
        -- Storyline coarse slots (72px, 1 item = 1 slot, long weapons 2x1):
        -- trunks tiered 15-64 slots, gloveboxes 3x2 / 4x2. maxWeight unchanged.
        [0] = { trunk = { rows = 3, cols = 6, maxWeight = 120000 }, glovebox = { rows = 2, cols = 3, maxWeight = 40000 } },   -- Compacts (18)
        [1] = { trunk = { rows = 4, cols = 6, maxWeight = 180000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },   -- Sedans (24)
        [2] = { trunk = { rows = 4, cols = 7, maxWeight = 250000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },   -- SUVs (28)
        [3] = { trunk = { rows = 3, cols = 6, maxWeight = 140000 }, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },   -- Coupes (18)
        [4] = { trunk = { rows = 4, cols = 6, maxWeight = 160000 }, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },   -- Muscle (24)
        [5] = { trunk = { rows = 3, cols = 6, maxWeight = 140000 }, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },   -- Sports Classics (18)
        [6] = { trunk = { rows = 3, cols = 6, maxWeight = 140000 }, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },   -- Sports (18)
        [7] = { trunk = { rows = 3, cols = 5, maxWeight = 120000 }, glovebox = { rows = 2, cols = 3, maxWeight = 30000 } },   -- Super (15)
        [8] = { trunk = false, glovebox = false },                                                                            -- Motorcycles (no trunk/glovebox)
        [9] = { trunk = { rows = 4, cols = 7, maxWeight = 180000 }, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },   -- Off-road (28)
        [10] = { trunk = { rows = 6, cols = 8, maxWeight = 280000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },  -- Industrial (48)
        [11] = { trunk = { rows = 5, cols = 8, maxWeight = 200000 }, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },  -- Utility (40)
        [12] = { trunk = { rows = 6, cols = 8, maxWeight = 300000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },  -- Vans (48)
        [13] = { trunk = false, glovebox = false },                                                                           -- Cycles (bicycles)
        [14] = { trunk = { rows = 5, cols = 8, maxWeight = 200000 }, glovebox = false },                                      -- Boats (40, no glovebox)
        [15] = { trunk = false, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },                                       -- Helicopters (no trunk)
        [16] = { trunk = false, glovebox = { rows = 2, cols = 4, maxWeight = 40000 } },                                       -- Planes (no trunk)
        [17] = { trunk = { rows = 5, cols = 8, maxWeight = 220000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },  -- Service (40)
        [18] = { trunk = { rows = 5, cols = 8, maxWeight = 250000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },  -- Emergency (40)
        [19] = { trunk = { rows = 6, cols = 8, maxWeight = 280000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },  -- Military (48)
        [20] = { trunk = { rows = 8, cols = 8, maxWeight = 350000 }, glovebox = { rows = 2, cols = 4, maxWeight = 50000 } },  -- Commercial (64)
        [21] = { trunk = false, glovebox = false },                                                                           -- Trains
    },
}

-- =============================================================================
-- INVENTORY TYPES (grid: rows x cols)
-- =============================================================================

Config.Inventories = {
    player = {
        rows = 6,
        cols = 8,
        label = "Inventar",
        maxWeight = 120000,
    },
    glovebox = {
        rows = 2,
        cols = 4,
        label = "Glovebox",
        maxWeight = 50000,
        -- primaryFrameMaxRows/Cols = max visible rows/columns for this inventory on screen (otherwise Config.GridUI values are used)
        primaryFrameMaxRows = 5,
        primaryFrameMaxCols = 5,
    },
    trunk = {
        rows = 4,
        cols = 7,
        label = "Trunk",
        maxWeight = 200000,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    -- scrollable = true → panel shows a scroll bar if row count exceeds visible area (useful for police/EMS/mechanic stashes)
    -- scrollMaxRows = maximum visible rows before overflow
    stash = {
        rows = 8,
        cols = 8,
        label = "Stash",
        maxWeight = 200000,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    -- Loot (EFT-style): panel boyutu config_loots.lua'dan (DefaultGrid / LootTypes[].grid). Buradaki rows/cols sadece fallback.
    loot = {
        rows = 5,
        cols = 6,
        label = "Loot",
        maxWeight = 1000000,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    -- Police/EMS/Mechanic stash: same "stash" config is used. Open with:
    -- Server: exports[GetCurrentResourceName()]:OpenStashInventory(source, "police_stash", "Police Stash")
    --         exports[GetCurrentResourceName()]:OpenStashInventory(source, "ems_stash", "EMS Stash")
    --         exports[GetCurrentResourceName()]:OpenStashInventory(source, "mechanic_stash", "Mechanic Stash")
    -- identifier (e.g. "police_stash") must be unique per stash; same ID opens the same stash.
    bag = {
        rows = 3,
        cols = 5,
        label = "Bag",
        maxWeight = 30000,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    drop = {
        rows = 6,
        cols = 8,
        label = "Searched Player",
        maxWeight = 99999999999999999,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    crafting = {
        rows = 8,
        cols = 8,
        label = "Crafting",
        maxWeight = 50000,
    },
    -- Shop: grid size is auto-calculated based on item count (rows increase until items fit).
    -- rows = upper limit (max rows), cols = number of columns.
    shop = {
        rows = 20,
        cols = 8,
        label = "Shop",
        maxWeight = 0,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    -- Searched player inventory (second-player-inventory: hands-up search / admin search)
    -- primaryFrameMaxRows/Cols: max visible rows/cols before scroll. Can be 23+; NUI caps panel to viewport so it never overflows.
    searched_player = {
        rows = 6,
        cols = 8,
        label = "Searched Player",
        maxWeight = 120000,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    jacket = {
        rows = 2,
        cols = 4,
        label = "Jacket",
        maxWeight = 120000,
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
    wallet = {
        rows = 2,
        cols = 3,
        label = "Wallet",
        primaryFrameMaxRows = 10,
        primaryFrameMaxCols = 10,
    },
}

-- Player search: open a nearby player's inventory as a second panel (same idea as trunk — two panels). Used by the inventory keybind and the SearchPlayer export.
-- Checks run in order: target animation (RequireHandsUp / AllowSearchWhenAnim), then searcher weapon (RequireWeapon). Both keybind and export respect these. Only /inv [id] bypasses them (admin).
Config.SearchPlayer = {
    enabled = true,
    MaxDistance = 2.5,
    -- If true, the target must have their hands up (or be in one of AllowSearchWhenAnim) before the search can start. If false, we don't check animation (RequireWeapon still applies).
    RequireHandsUp = true,
    -- Must match whatever your hands-up script uses (e.g. qb-smallresources). We only look at this anim; it should have been playing for at least ~0.15s.
    HandsUpDict = "missminuteman_1ig_2",
    HandsUpAnim = "handsup_base",
    -- If the target is in any of these anims (e.g. dead or laststand), they can be searched without hands up. Tune these to match your death/laststand script (e.g. qb-ambulancejob).
    AllowSearchWhenAnim = {
        { dict = "dead", anim = "dead_a" },
        { dict = "combat@damage@writhe", anim = "writhe_loop" },
        { dict = "veh@low@front_ps@idle_duck", anim = "sit" },
    },
    SearchAce = "devix.inventory.searchPlayer",
    -- If true, the searcher must have a weapon in hand (e.g. for police). This is checked after the target is approved. Only /inv [id] skips this.
    RequireWeapon = true,
    -- Set to true to log the search flow in F8 (client) and server console (searcher, target, server).
    Debug = false,
}

-- =============================================================================
-- ITEM-BAG INVENTORIES
-- =============================================================================

-- These items have their own internal inventory; they cannot be moved to stash/trunk/drop.
-- Can be opened with right-click while in stash/trunk/glovebox/locker; when the bag is moved, the open panel closes automatically.
-- Value: "bag" (all items allowed) or table: { type = "bag", allowedItems = {...}, blacklistItems = {...} }
-- allowedItems: whitelist. If provided and non-empty, ONLY these items can be put inside. Empty {} / nil = allow all (except blacklist).
-- blacklistItems: blacklist. These items cannot be put inside (even if allowedItems is empty / allows all).
Config.ItemInventories = {
    ["veh_toolbox"] = {
        type = "bag",
        allowedItems = { "repairkit", "weapon_wrench", "weapon_hammer", "weapon_crowbar", "screwdriver", "duct_tape" },
        blacklistItems = {},
    },
    ["empty_evidence_bag"] = {
        type = "bag",
        allowedItems = { "phone", "empty_evidence_bag", "drug_small_bag", "drug_large_bag" },
        blacklistItems = {},
    },
    ["clothe_bag"] = {
        type = "bag",
        allowedItems = {},   -- empty = no whitelist; all items allowed (except blacklist)
        blacklistItems = { "veh_toolbox", "empty_evidence_bag" },
    },
    ["clothe_torso2"] = {
        type = "jacket",
        allowedItems = {},   -- empty = no whitelist; all items allowed (except blacklist)
        blacklistItems = { "veh_toolbox", "empty_evidence_bag" },
    },
    ["wallet"] = {
        type = "wallet",
        allowedItems = { "money", "money", "black_money", "markedbills", "driver_license", "weaponlicense", "lawyerpass", "id_card", "condom", "fightpass", "bottle_cap", "auction_invitation" },   -- empty = no whitelist; all items allowed (except blacklist)
        blacklistItems = {},
    },
}

-- Bags that can only be opened when equipped in the corresponding clothing slot
Config.ItemInventoriesOnlyWhenEquipped = {
    ["clothe_bag"] = "bag",
    ["clothe_torso2"] = "jacket",
}

Config.BagContentsWeightMultiplier = 0.5   -- How much bag contents contribute to weight (0–1)

-- =============================================================================
-- ITEM GRID SIZES & FOLDING
-- =============================================================================

-- Storyline coarse slots: most items take 1 big slot (default 1x1);
-- only long/bulky items span multiple slots (e.g. shotgun = 2 slots wide).
Config.Items = {
    ["weapon_briefcase"] = { width = 2, height = 1 },
    ["weapon_carbinerifle"] = { width = 2, height = 1 },
    ["weapon_pumpshotgun"] = { width = 2, height = 1 },
    ["weapon_assaultrifle"] = { width = 2, height = 1 },
    ["veh_toolbox"] = { width = 2, height = 1 },
    ["clothe_bag"] = { width = 2, height = 2 },
}

-- Coarse Storyline slots: folding only matters for multi-slot items
-- (1x1 items cannot shrink further; bag 2x2 folds down to 1x1).
Config.FoldedItems = {
    ["clothe_bag"] = { width = 1, height = 1 },
}

-- Stack limits: true = never stacks (each is unique in its own slot). Number = max stack size per slot.
-- Example: ["id_card"] = true (never stacks), ["repair_kit"] = 12 (max 12 per slot)
-- When true, the item becomes unique.
Config.ItemLimits = {
    ["repairkit"] = 12,
    ["pistol_ammo"] = 20,
}

-- =============================================================================
-- DROP (DROPPED ITEMS)
-- =============================================================================

Config.Drop = {
    Object = `prop_cs_heist_bag_02`,
    CleanupMinutes = 15,
    CleanupCheckMinutes = 1,
    -- Pickup when near thrown/dropped item: E adds to inventory (item info/amount preserved)
    PickupKey = "E",
    PickupDistance = 2.0,
    PickupSound = false,  -- Ring sound disabled when approaching drop
}

-- Throw (context menu): right-click aim, release to throw with physics (snowball-style)
Config.Throw = {
    --! atma kısmını true false  olarak ayarlama eklenecek 
    CancelKey = 73,            -- Control index: 73 = X (cancel throw)
    BagObject = "prop_paper_bag_small",
    -- Hand attachment: bone (57005 = right hand SKEL_R_Hand, 18905 = left hand SKEL_L_Hand). Offset/rot in bone-local space (meters / degrees).
    HandBone = 57005,          -- Right hand for throwing
    BagAttachOffset = { 0.1066464031328, 0.059750356355977, -0.087529510466521 },
    BagAttachRot = { -48.690251950654, -28.054602209437, -6.3637301635597 },
    -- Weapon in hand: when throwing a weapon, it is attached as prop (CreateWeaponObject) instead of GiveWeaponToPed. Same offset/rot as bag.
    WeaponAttachOffset = { 0.1066464031328, 0.059750356355977, -0.087529510466521 },
    WeaponAttachRot = { -48.690251950654, -28.054602209437, -6.3637301635597 },
    ThrowVelocity = 22.0,
    ThrowLandTimeout = 5000,
    -- Baseball-style animations (weapons@projectile@)
    AnimAimDict = "weapons@projectile@",
    AnimAimName = "aim_m",             -- Pose while right-click held (aim)
    AnimThrowDict = "weapons@projectile@",
    AnimThrowName = "throw_m_fb_stand", -- Throw animation on release
    AnimThrowReleaseMs = 380,           -- Ms into throw anim when prop is released (hand opens)
    -- Trajectory preview: shows where the throw will land while aiming
    DrawTrajectory = true,
    TrajectoryStartFromLeftHand = true,
    TrajectoryGravity = 9.8,
    TrajectoryDuration = 2.2,
    TrajectorySegments = 64,       -- Smoother curve
    -- Trajectory: green-to-red gradient, square segments
    TrajectoryLineColor = { r = 40, g = 255, b = 80, a = 255 },   -- Start: green (hand)
    TrajectoryLineColorEnd = { r = 255, g = 40, b = 40, a = 255 }, -- End: red (landing)
    TrajectoryLineThickness = 0.045,  -- Square segment width (rectangle frame)
    TrajectorySegmentGap = 0.08,      -- Gap between segments (0 = adjacent, >0 = spaced)
    -- Glow: soft glow behind the line
    TrajectoryGlow = true,
    TrajectoryGlowColor = { r = 100, g = 200, b = 120, a = 255 },
    TrajectoryGlowPasses = 2,
    -- Style: "line" = straight line, "squares" = square frames (green→red)
    TrajectoryStyle = "squares",
    -- Wall check: raycast; trajectory stops at wall hit, hit segment turns red
    TrajectoryCheckWalls = true,
    TrajectoryWallHitColor = { r = 255, g = 50, b = 50, a = 255 },
    -- Start/end markers (hand + landing spot); start = green ellipse (around weapon in hand) — disabled
    TrajectoryShowStartMarker = false,
    TrajectoryStartMarkerScale = 0.12,
    TrajectoryShowEndMarker = true,
    TrajectoryEndMarkerScale = 0.14,
    TrajectoryEndMarkerColor = { r = 255, g = 30, b = 30, a = 200 },
    -- Dropped item marker: arrow above thrown drop when nearby
    DropMarker = true,
    DropMarkerHeight = 0.55,       -- Arrow height above drop
    DropMarkerScale = 0.28,        -- Arrow size (cone tip down)
    DropMarkerColor = { r = 255, g = 200, b = 80, a = 200 },
}

-- =============================================================================
-- ADMIN & LIMITS
-- =============================================================================

Config.ClearInvAce = "devix-inventory.clearinv"   -- add_ace group.admin devix-inventory.clearinv allow
-- Number of hotbar/quick slots (TAB bar). Default 6; 0 = disabled. NUI shows this many slots (max 12 in UI).
Config.QuickSlots = 9
Config.MaxSecondPanels = nil   -- Max number of open second panels at the same time (nil = unlimited)

-- Admin command names (server owner can change these)
Config.AdminCommands = {
    clearinv = "clearinv", -- Clear inventory command
    inv = "inv",           -- Open target inventory command
    giveitem = "giveitem", -- Give item to player command
    invtest = "invtest",   -- Stabilizasyon/guvenlik dry-run testleri (admin)
}

-- =============================================================================
-- CLOTHING SYSTEM
-- =============================================================================
-- If enabled = false the clothing panel on the left of the inventory is hidden; wear/unequip, setClothes, bag slot etc. are disabled.
Config.Clothing = {
    enabled = true,
}

-- =============================================================================
-- CLOTHING SLOTS
-- =============================================================================

Config.ClothingSlotCount = nil   -- nil = all; number = first N slots

Config.ClothingSlots = {
    { id = "hat",       label = "Şapka",      item = "clothe_hat",       maxItems = 1 },
    { id = "glasses",   label = "Gözlük",     item = "clothe_glasses",   maxItems = 1 },
    { id = "mask",      label = "Maske",      item = "clothe_mask",      maxItems = 1 },
    { id = "arms",      label = "Kollar",     item = "clothe_arms",      maxItems = 1 },
    { id = "pants",     label = "Pantolon",   item = "clothe_pants",     maxItems = 1 },
    { id = "shoes",     label = "Ayakkabı",   item = "clothe_shoes",     maxItems = 1 },
    { id = "vest",      label = "Yelek",      item = "clothe_vest",      maxItems = 1 },
    { id = "bag",       label = "Çanta",      item = "clothe_bag",       maxItems = 1 },
    { id = "accessory", label = "Aksesuar",   item = "clothe_accessory", maxItems = 1 },
    { id = "decals",    label = "Decals",     item = "clothe_decals",    maxItems = 1 },
    { id = "tshirt",    label = "Tişört",     item = "clothe_tshirt",    maxItems = 1 },
    { id = "torso2",    label = "Ceket",      item = "clothe_torso2",    maxItems = 1 },
    { id = "watch",     label = "Saat",       item = "clothe_watch",    maxItems = 1 },
    { id = "bracelet",  label = "Bilezik",    item = "clothe_bracelet", maxItems = 1 },
}

Config.ClothingSlotToAppearanceKey = {
    hat = "hat",
    glasses = "glass",
    mask = "mask",
    arms = "arms",
    pants = "pants",
    shoes = "shoes",
    vest = "vest",
    bag = "bag",
    accessory = "accessory",
    decals = "decals",
    tshirt = "t-shirt",
    torso2 = "torso2",
    watch = "watch",
    bracelet = "bracelet",
}

Config.ClothingApplyOrder = { "hat", "glasses", "mask", "arms", "pants", "shoes", "vest", "torso2", "tshirt", "bag", "accessory", "decals", "watch", "bracelet" }

-- Default drawable/texture to use when clothing item.info.drawable/texture is missing
Config.ClothingItemDefaults = {
    ["clothe_bag"] = { item = 44, texture = 0 },
    ["bag"] = { item = 1, texture = 0 },
}

-- Default clothing when slot is empty (prevent nudity). item -1 = remove prop
Config.DefaultClothing = {
    hat      = { item = -1, texture = 0 },
    glass    = { item = -1, texture = 0 },
    ear      = { item = -1, texture = 0 },
    watch    = { item = -1, texture = 0 },
    bracelet = { item = -1, texture = 0 },
    mask     = { item = 0, texture = 0 },
    arms     = { male = { item = 15, texture = 0 }, female = { item = 15, texture = 0 } },
    ["t-shirt"] = { male = { item = 15, texture = 0 }, female = { item = 15, texture = 0 } },
    torso2   = { male = { item = 252, texture = 0 }, female = { item = 74, texture = 0 } },
    pants    = { male = { item = 61, texture = 0 }, female = { item = 14, texture = 0 } },
    vest     = { item = 0, texture = 0 },
    shoes    = { male = { item = 34, texture = 0 }, female = { item = 35, texture = 0 } },
    bag      = { item = 0, texture = 0 },
    decals   = { item = 0, texture = 0 },
    accessory = { item = 0, texture = 0 },
}

Config.ClothingChangeAnims = {
    hat      = { dict = "mp_masks@standard_car@ds@", name = "put_on_mask", duration = 600 },
    glasses  = { dict = "clothingspecs", name = "take_off", duration = 1400 },
    mask     = { dict = "mp_masks@standard_car@ds@", name = "put_on_mask", duration = 800 },
    arms     = { dict = "nmt_3_rcm-10", name = "cs_nigel_dual-10", duration = 1200 },
    tshirt   = { dict = "clothingtie", name = "try_tie_negative_a", duration = 1200 },
    torso2   = { dict = "missmic4", name = "michael_tux_fidget", duration = 1500 },
    vest     = { dict = "clothingtie", name = "try_tie_negative_a", duration = 1200 },
    pants    = { dict = "re@construction", name = "out_of_breath", duration = 1300 },
    shoes    = { dict = "random@domestic", name = "pickup_low", duration = 1200 },
    bag      = { dict = "anim@heists@ornate_bank@grab_cash", name = "intro", duration = 1600 },
    accessory = { dict = "clothingtie", name = "try_tie_positive_a", duration = 2100 },
    decals   = { dict = "clothingtie", name = "try_tie_negative_a", duration = 1200 },
    ear      = { dict = "mp_cp_stolen_tut", name = "b_think", duration = 900 },
    watch    = { dict = "nmt_3_rcm-10", name = "cs_nigel_dual-10", duration = 1200 },
    bracelet = { dict = "nmt_3_rcm-10", name = "cs_nigel_dual-10", duration = 1200 },
}

-- =============================================================================
-- ANIMATIONS (inventory / trunk / glovebox)
-- =============================================================================

Config.InventoryOpenAnim = { dict = "random@domestic", name = "pickup_low", duration = 800 }
Config.TrunkOpenAnim = { dict = "mini@repair", name = "fixing_a_player", duration = 1200 }
Config.GloveboxOpenAnim = { dict = "veh@std@ds@base", name = "hotwire", duration = 1200 }

-- =============================================================================
-- SHOPS (opened as second inventory; bag/crafting cannot be open at the same time)
-- =============================================================================
-- E = open shop (when nearby). Price: price = number (cash) or price = { cash = 100, bank = 95 }
Config.ShopOpenKey = 38
Config.ShopUseDistance = 3.0
Config.ShopShowMarker = true           -- Draw a cylinder marker at coords (visible)
Config.ShopMarkerDrawDist = 30.0       -- Draw marker up to this distance
Config.ShopMarkerType = 1              -- 1 = cylinder, 2 = ring, 27 = money bag
Config.ShopMarkerScale = vector3(1.2, 1.2, 0.5)
Config.ShopMarkerColor = { r = 72, g = 187, b = 120, a = 180 }
Config.ShopDefaultMoneyType = "cash"   -- default money type used when price is a number
-- When true, "cash" payments use inventory item. Item name comes from devix-core Config.CashItemName (server/main.lua). Works QB + ESX.
Config.ShopCashAsItem = true
-- Config.ShopCashItemName: read from devix-core (DEVIX.CashItemName), not defined in config
Config.ShopSellMultiplier = 0.5       -- Multiplier applied when selling to shop

-- Each shop: coords, label; optionally blip, ped, job, grade. Products: items (flat) or categories (tabbed)
Config.Shops = {
    -- Example: Radio shop (single page)
    -- {
    --     coords = vector3(31.59, -1347.65, 29.4),
    --     heading = 270.0,
    --     radius = 2.5,
    --     label = "Radio Shop",
    --     blip = { sprite = 52, color = 2, scale = 0.8, label = "Radio" },
    --     -- ped = { model = "a_m_m_eastsa_01", coords = vector3(0.0, 0.0, 0.0), heading = 0.0 },
    --     -- job = nil,      -- Only this job (e.g. "mechanic")
    --     -- grade = nil,    -- Minimum rank (0+)
    --     items = {
    --         { name = "radio", price = 100, amount = 1, info = {}, type = "item" },
    --         { name = "repairkit", price = 250, amount = 1, info = {}, type = "item" },
    --     },
    -- },
    -- Example: 24/7 (with categories)
    {
        coords = vector3(19.68, -1353.85, 29.33),
        heading = 270.0,
        radius = 2.5,
        label = "24/7",
        blip = { sprite = 52, color = 2, scale = 0.8, label = "24/7" },
        categories = {
            { name = "Drinks", items = {
                { name = "water_bottle", price = 10, amount = 1, info = {}, type = "item" },
            }},
            { name = "Snacks", items = {
                { name = "sandwich", price = 15, amount = 1, info = {}, type = "item" },
            }},
            { name = "Iteeems", items = {
                { name = "radio", price = 100, amount = 1, info = {}, type = "item" },
                { name = "phone", price = 500, amount = 1, info = {}, type = "item" },
                { name = "metalscrap", price = 500, amount = 1, info = {}, type = "item" },
                { name = "plastic", price = 500, amount = 1, info = {}, type = "item" },
                { name = "tablet", price = 500, amount = 1, info = {}, type = "item" },
                { name = "tirerepairkit", price = 500, amount = 1, info = {}, type = "item" },
                { name = "weapon_pistol", price = 500, amount = 1, info = {rarity = "legendary"}, type = "weapon" },
                { name = "weapon_pistol", price = 500, amount = 1, info = {rarity = "epic"}, type = "weapon" },
                { name = "weapon_assaultrifle", price = 500, amount = 1, info = {rarity = "epic"}, type = "weapon" },
                { name = "aluminumoxide", price = 500, amount = 1, info = {}, type = "item" },
                -- { name = "hotdog", price = 500, amount = 1, info = {}, type = "item" },
                { name = "clip_attachment", price = 500, amount = 1, info = {}, type = "item" },
                { name = "suppressor_attachment", price = 500, amount = 1, info = {}, type = "item" },
                { name = "holoscope_attachment", price = 500, amount = 1, info = {}, type = "item" },
                { name = "smallscope_attachment", price = 500, amount = 1, info = {}, type = "item" },
                
                { name = "grip_attachment", price = 500, amount = 1, info = {}, type = "item" },
                { name = "barrel_attachment", price = 500, amount = 1, info = {}, type = "item" },
                { name = "weapontint_5", price = 500, amount = 1, info = {}, type = "item", sellPrice = 50 },
                { name = "clothe_pants", price = 500, amount = 1, info = { drawable = 87, img = "male_4_87", texture = 0 }, type = "item", sellPrice = 50 },            }},
        },
        sellItems = {
            {name = "grip_attachment", price = 50, 1, type = "item"}
        }
    },
    -- Example: Mechanic (job only)
    {
        coords = vector3(0.0, 0.0, 0.0),
        label = "Mekanik Deposu",
        job = "mechanic",
        grade = 0,
        items = {
            { name = "repairkit", price = 50, amount = 1, info = {}, type = "item" },
            { name = "advancedrepairkit", price = 200, amount = 1, info = {}, type = "item" },
            { name = "tirerepairkit", price = 75, amount = 1, info = {}, type = "item" },
        },
    },
}
