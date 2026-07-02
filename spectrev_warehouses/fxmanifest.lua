fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'spectrev-hub'
description 'Automatischer Rohstoff-Verarbeiter mit kaufbaren, upgradebaren Warehouses (ESX / ox_inventory / ox_target)'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql',
    'ox_target',
    -- 'ox_inventory'  -- bzw. dein Devix-Inventar (siehe Config.InventoryResource)
}
