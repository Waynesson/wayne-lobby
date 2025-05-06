fx_version 'cerulean'
game 'gta5'

author 'Waynesson'
description 'Waynes Lobby Script'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'ox_lib'
}

lua54 'yes'