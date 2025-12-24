fx_version 'cerulean'
lua54 'on'
game 'gta5'

name 'intraTab'
description 'intraTab + NOTFpad + FireTab'
author 'EmergencyForge.de'
version '2.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/asu_client.lua'
}

server_scripts {
    'server/main.lua',
    'server/emd_sync.lua',
    'server/asu_server.lua'
}

-- Master UI Page (contains eNOTF, FireTab, and ASU)
ui_page 'html/master.html'

files {
    'html/master.html',
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/asueberwachung.html',
    'html/css/asueberwachung.css',
    'html/js/asueberwachung.js',
    'html/firetab.html',
    'html/css/firetab.css',
    'html/js/firetab.js',
    'html/js/master.js'
}

data_file 'DLC_ITYP_REQUEST' 'stream/notfpad.ytyp'
