resource 'bs-perms'

author 'BuSheeZy <https://github.com/busheezy>'
maintainer 'BuSheeZy <https://github.com/busheezy>'

version '1.0.2'

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_script 'server/utilities.lua'
server_script 'server/server.lua'
server_script 'server/chat_processor.lua'
server_script 'server/rcon_processor.lua'

client_script 'client/client.lua'
