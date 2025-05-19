fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'hype_banking'
author 'Hype Project'
version '0.0.7'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

client_scripts {
    'bridge/**/client.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/**/server.lua',
    'server/*.lua',
}

ui_page 'web/build/index.html'

-- development ui page
-- ui_page 'http://localhost:5173'

files {
    'web/build/**',
    'locales/*.json'
}