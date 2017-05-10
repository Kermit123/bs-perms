local adminCache = {}
local groupCache = {}
local overrideCache = {}

local authedAdmins = {}

RegisterServerEvent('bs-perms:connected')
AddEventHandler('bs-perms:connected',
  function()
    local ip = GetPlayerEP(source)
    local steam = getSteamFromId(source)

    print('connected source: '..tostring(source))

    for _, admin in pairs(adminCache) do
      if admin.authString == ip or admin.authString == steam then
        authedAdmins[source] = getFlatAdmin(admin)
        break
      end
    end
  end
)

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

RegisterServerEvent('bs-perms:gotCache')
AddEventHandler('bs-perms:gotCache',
  function(cache)
    for _, admin in pairs(cache.admins) do
      local existingAdmin = getAdminIdByTableFromAdminCache(admin)
      if existingAdmin then
        adminCache[existingAdmin].flags = mergeFlags(adminCache[existingAdmin].flags, admin.flags)
        if admin.immunity > adminCache[existingAdmin].immunity then
          adminCache[existingAdmin].immunity = admin.immunity
        end
      else
        adminCache[#adminCache + 1] = admin
      end
    end

    for _, group in pairs(cache.groups) do
      local existingGroup = getGroupIdByNameFromGroupCache(group.name, groupCache)
      if existingGroup then
        groupCache[existingGroup].flags = mergeFlags(groupCache[existingGroup].flags, admin.flags)
        groupCache[existingGroup].immunity = highestOfTwo(groupCache[existingGroup].immunity, admin.immunity)
      else
        groupCache[#groupCache + 1] = admin
      end
    end
  end
)

function getFlatAdmin(admin)
  if admin.Group ~= nil then
      local groupId = getGroupIdByNameFromGroupCache(admin.Group)
      if groupId then
        local group = adminCache[groupId]
        admin.flags = mergeFlags(admin.flags, group.flags)
        admin.immunity = highestOfTwo(admin.immunity, group.immunity)
      end
      return admin
  else
    return admin
  end
end

function getOverrides()
  return overrideCache
end

function getSteamFromId(playerId)
  for _, v in pairs(GetPlayerIdentifiers(playerId)) do
    if string.sub(v, 1, 6) == 'steam:' then
      return tostring(tonumber(string.sub(v, 7), 16))
    end
  end
  return false
end

function hasFlags(flags1, flags2)
  for char in flags2:gmatch('.') do
    if string.match(flags1, char) then
      return true
    end
  end
  return false
end

function refreshAdmins()
  adminCache = {}
  groupCache = {}
  overrideCache = {}

  TriggerEvent('bs-perms:reloadAdminCache')
  TriggerClientEvent('chatMessage', - 1, 'BS-PERMS', {255, 0, 0}, 'Reloading admins.')
end

function getAuthedAdmin(id)
  return authedAdmins[id]
end

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

function getAdminIdByTableFromAdminCache(adminToCheck)
  for i, admin in ipairs(adminCache) do
    if admin.authString == adminToCheck.authString then
      return i
    end
  end
  return false
end

function getGroupIdByNameFromGroupCache(name)
  for i, group in ipairs(groupCache) do
    if group.name == name then
      return i
    end
  end
  return false
end
