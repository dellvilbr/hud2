fx_version 'cerulean'
game 'gta5'

client_scripts {
    "@vrp/config/Native.lua",
	  "@vrp/lib/Utils.lua",
    "client-side/*"
}

server_scripts {
  "@vrp/config/Global.lua",
	"@vrp/config/Item.lua",
	"@vrp/lib/Utils.lua",
  "server-side/*"
}


ui_page 'web/index.html'

files {
  'web/*',
  'web/**/*',
  "stream/*"
}

