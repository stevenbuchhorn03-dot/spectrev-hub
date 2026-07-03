fx_version 'cerulean'
version '1.9.01'
description 'devix-inventory'
author 'zhonnz'

game 'gta5'

client_scripts {
    'client/inventory_camera.lua',
    'client/c_main.lua',
    'client/cl_food.lua',
    'client/cl_shops.lua',
    'escrow_ignore/cl_loot_target.lua',
    'client/cl_loot.lua',
    'client/cl_loot_creator.lua',
    'client/weapons.lua',
    'client/weapon_attachment_preview.lua',
    'client/cl_itemback.lua',
    'client/integration/ox_inventory/init.lua',
    'client/integration/qb-inventory/init.lua',
}

server_scripts {
    -- qb-inventory bridge must load first so exports register immediately (avoids "No such export" on first join)
    'server/integration/qb-inventory/init.lua',
    'server/sv_db.lua',          -- Central DB layer (DevixDB)
    'server/main.lua',             -- DevixSrv bridge is populated here; modules must load after
    -- Module files: must load AFTER main.lua (they use the DevixSrv bridge)
    'server/sv_guards.lua',        -- Validation/guard helpers (stub — may move here later)
    'server/sv_grid.lua',          -- Grid cache/DB management (stub)
    'server/sv_transfer.lua',      -- Transfer handlers (stub)
    'server/sv_drops.lua',         -- Drop management (stub + migration target for new handlers)
    'server/sv_clothes.lua',       -- Clothing handlers
    'server/sv_refresh.lua',       -- Light refresh/snapshot helpers
    'server/sv_player.lua',        -- Player lifecycle (stub)
    'server/sv_useitem.lua',       -- Item use (stub)
    'server/sv_search.lua',        -- Player search handlers (moved from main.lua)
    'server/sv_api.lua',           -- Public export API (stub)
    'server/weapons.lua',
    'server/sv_itemback.lua',
    'server/sv_import_items.lua',
    'server/sv_loot.lua',
    'server/sv_loot_creator.lua',
    'escrow_ignore/sv_clothing_skin.lua',
    'server/integration/ox_inventory/init.lua', -- After main + exports (GetItemCount, etc.)
}

ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/*.webp',
    'html/img/*.png',
    'html/img/*.PNG',
    'html/img/*.webp',
    'html/clothe_img/*.png',
    'html/clothe_img/*.webp',
    'sql/*.sql',
    'inventory_sound_effects/*.wav',
    'inventory_sound_effects/*.mp3',
    'import_items/*.lua'
}

exports {
    'GetItemList',
    'ConfiscateInventory',
    'ReturnInventory'
}

server_exports {
    'AddClothingItems',
    'AddItem',
    'RemoveItem',
    'GetInventory',
    'GetItemCount',
    'GetStashItems',
    'AddItemStash',
    'RemoveItemStash',
    'RegisterStash',
    'NormalizeStashId',
    'CanCarryItem',
    'OpenStashInventory',
    'registerHook',
    'RegisterHookCallback',
    'RegisterHookExport',
    'removeHooks',
    'GetSharedItemInfo',
    'GetItemList',
}

shared_scripts {
    'shared/sh_events.lua',
    'config.lua',
    'config_performance.lua',
    'config_items.lua',
    'config_food.lua',
    'config_weapons.lua',
    'config_loots.lua',
    'config_itemback.lua',
    'config_crafting.lua',
    'Locales/locales.lua',
}

escrow_ignore {
    'config.lua',
    'config_performance.lua',
    'config_items.lua',
    'config_food.lua',
    'config_weapons.lua',
    'config_loots.lua',
    'config_itemback.lua',
    'config_crafting.lua',
    'Locales/*.lua',
    'html/*.css',
    'sql/*.sql',
    'README.md',
    'stream/*.ytd',
    'escrow_ignore/*.lua',
    'import_items/*.lua',
}

provide 'qb-inventory'
provide 'ox_inventory'

dependencies {
    '/onesync',
    'devix-core',
}

ui_page_preload 'yes' -- Transparent NUI support

lua54 'yes'

dependency '/assetpacks'