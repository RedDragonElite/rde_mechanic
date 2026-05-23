-- ╔═══════════════════════════════════════════════════════════╗
-- ║  RDE | Core | 🔺 Next-Gen Vehicle Mechanic & Tuner        ║
-- ║  by ᛋᛅᚱᛒᛅᚾᛁᛋ ᛒᛁᛞᛅ (SerpentsByte)                            ║
-- ║  FXManifest – v2.1 | Camera · Preview · Multiplayer Sync  ║
-- ╚═══════════════════════════════════════════════════════════╝

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'rde_mechanic'
author      'RDE | SerpentsByte'
version     '2.1.0'
description 'Next-Gen Vehicle Mechanic & Tuner — Camera, Preview, GlobalState/StateBag Multiplayer Sync'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

-- FIX: ox_core was wrongly listed as optional — it is actively used for admin checks
dependencies {
    'ox_lib',
    'ox_core',
    'ox_inventory',
    'ox_target',
    'oxmysql'
}

files {}
