fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'spectrev-hub'
description 'Police Nagelbänder (Spike Strips) für ESX Legacy – Item-basiert, job-restricted, ox_inventory + ox_target'
version '1.0.0'

-- Stellt das globale ESX-Objekt bereit (ESX Legacy 1.9+)
shared_script '@es_extended/imports.lua'
shared_script 'config.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
    'es_extended',
    'ox_inventory',
    'ox_target',
}
