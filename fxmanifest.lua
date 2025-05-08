fx_version 'cerulean'
game 'gta5'

author 'YourName'
description 'QBCore Sports Betting System'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
