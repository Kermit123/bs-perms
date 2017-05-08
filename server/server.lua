local adminCache = {}
local overrides = {}

local authedAdmins = {}

local commands = {}

AddEventHandler('playerConnecting', function(playerName, setKickReason)
  local ip = GetPlayerEP(source)
  local steam = getSteamFromId(source)

  for _, admin in pairs(adminCache) do
    if admin.authString == ip or admin.authString == steam then
      authedAdmins[source] = admin
      break
    end
  end
end)

function getSteamFromId(playerId)
  for _, v in pairs(GetPlayerIdentifiers(playerId)) do
    if string.sub(v, 1, 6) == 'steam:' then
      return tostring(tonumber(string.sub(v, 7), 16))
    end
  end
  return false
end

AddEventHandler('onResourceStart',
  function(resource)
    if resource == 'bs-perms' then
      SetTimeout(
        1 * 1000,
        refreshAdmins
      )
    end
  end
)

function stringsplit(self, delimiter)
  local a = self:Split(delimiter)
  local t = {}

  for i = 0, #a - 1 do
     table.insert(t, a[i])
  end

  return t
end

function startswith(theString, start)
   return string.sub(theString, 1, string.len(start)) == start
end

AddEventHandler('chatMessage', function(source, n, message)
  message = tostring(message)
  if startswith(message, '/') or startswith(message, '!') then
    local args = stringsplit(message, ' ')
    local command = args[1]:lower()

    if startswith(message, '/') then
      command = string.gsub(command, '/', '')
      CancelEvent()
    end

    if startswith(message, '!') then
      command = string.gsub(command, '!', '')
    end

    if commands[command] then
      local cmd = commands[command]
      local allowed = false

      local authed = authedAdmins[source]

      if cmd.flag == '*' then
        allowed = true
      else
        if authed then
          if string.match(authed.flags, 'z') then
            allowed = true
          else
            if string.match(authed.flags, cmd.flag) then
              allowed = true
            end
          end
        end
      end

      if authed and not string.match(authed.flags, 'z') then
        for _, override in overrides do
          if override.type == 'full' then
            if override.commandString == command and hasFlags(authed.flags, override.flags) then
              allowed = override.access
              break
            end
          end
          if override.type == 'prefix' then
            if startswith(command, override.commandString) and hasFlags(authed.flags, override.flags) then
              allowed = override.access
              break
            end
          end
        end
      end

      if not allowed then
        TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed.')
        return
      end
      print('here???')
      if cmd.callback ~= nil then
        cmd.callback(args, source)
      end
    end
  end
end)

function hasFlags(flags1, flags2)
  for char in flags2:gmatch('.') do
    if string.match(flags1, char) then
      return true
    end
  end
  return false
end

RegisterServerEvent('bs-perms:addCommand')
AddEventHandler('bs-perms:addCommand', function(command)
	commands[command.command] = command
end)

commands['perms'] = {
  flag = 'z',
  callback = function(args, who)
    if args[2] == 'reload' then
      refreshAdmins()
    end
  end
}

function refreshAdmins()
  TriggerEvent('bs-perms:reloadAdminCache')
  TriggerClientEvent('chatMessage', -1, 'BS-PERMS', {255, 0, 0}, 'Reloading admins.')
end

RegisterServerEvent('bs-perms:gotCache')
AddEventHandler('bs-perms:gotCache',
  function(cache)
    for _, admin in pairs(cache.admins) do
      local existingAdmin = getExistingAdminInCache(admin, adminCache)
      if existingAdmin then
        adminCache[existingAdmin].flags = mergeFlags(adminCache[existingAdmin].flags, admin.flags)
        if admin.immunity > adminCache[existingAdmin].immunity then
          adminCache[existingAdmin].immunity = admin.immunity
        end
      else
        adminCache[#adminCache + 1] = admin
      end
    end
  end
)

function mergeFlags(flags1, flags2)
  if flags1 == '' or flags2 == '' then
    return flags1 .. flags2
  end
  for char in flags2:gmatch('.') do
    if not string.match(flags1, char) then
      flags1 = flags1 .. char
    end
  end
  return flags1
end

function getExistingAdminInCache(adminToCheck, table)
  for i, admin in ipairs(table) do
    if admin.authString == adminToCheck.authString then
      return i
    end
  end
  return false
end

AddEventHandler('rconCommand', function(commandName, args)
  if commandName:lower() == 'admins' then
    if args[1] == 'reload' then
      adminCache = {}
      overrides = {}

      refreshAdmins()
    end
    CancelEvent()
  end
end)
