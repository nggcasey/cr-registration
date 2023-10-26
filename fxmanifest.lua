fx_version 'cerulean'
game 'gta5'

author 'Casey Reed'
description 'QB Registration'
version '1.0.0'

client_scripts {
    'client/*'
}

server_scripts {
    'server/*',
    '@oxmysql/lib/MySQL.lua'
}

shared_scripts {
    'config.lua'
}