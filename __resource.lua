server_script 'server/utilities.lua'
server_script 'server/server.lua'
server_script 'server/chat_processor.lua'
server_script 'server/rcon_processor.lua'
server_script 'server/exports.lua'

client_script 'client/client.lua'

export 'playerHasFlag' -- (id, flag) - boolean
export 'addCommand' -- (table {command, callback, flag})
export 'checkIfAllowed' -- (id, flag) - boolean
export 'playerCanTargetPlayer' -- (id, id) - boolean
