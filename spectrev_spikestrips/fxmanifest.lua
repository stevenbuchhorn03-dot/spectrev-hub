fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'spectrev-hub'
description 'Police Nagelbänder (Spike Strips) für devix-core / devix-inventory – Item-basiert, job-restricted, ox_target'
version '2.0.0'

shared_script 'config.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
    'devix-core',
    'devix-inventory',
    'ox_target',
}
