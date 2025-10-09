fx_version 'cerulean'
lua54 'on'
game 'gta5'

name 'intraTab'
description 'IntraRP FiveM Tablet Integration'
author 'intraRP & NoName.cs <kontakt@intrarp.de>'
version '1.2.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
    'server/emd_sync.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js'
}
