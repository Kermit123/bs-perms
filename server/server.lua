local adminCache = {}
local groupCache = {}
local overrideCache = {}

local authedAdmins = {}

RegisterServerEvent('bs-perms:connected')
AddEventHandler('bs-perms:connected',
  function()
    local ip = GetPlayerEP(source)
    local steam = getSteamFromId(source)

    for _, admin in pairs(adminCache) do
      if admin.authString == ip or admin.authString == steam then
        authedAdmins[source] = getFlatAdmin(admin, source)
        break
      end
    end
  end
)

AddEventHandler('playerDropped',
  function()
    authedAdmins[source] = nil
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
        adminCache[existingAdmin].immunity = highestOfTwo(adminCache[existingAdmin].immunity, admin.immunity)
      else
        adminCache[#adminCache + 1] = admin
      end
    end

    for _, group in pairs(cache.groups) do
      local existingGroup = getGroupIdByNameFromGroupCache(group.name)
      if existingGroup ~= nil then
        groupCache[existingGroup].flags = mergeFlags(groupCache[existingGroup].flags, group.flags)
        groupCache[existingGroup].immunity = highestOfTwo(groupCache[existingGroup].immunity, group.immunity)
      else
        groupCache[#groupCache + 1] = group
      end
    end

    for _, override in pairs(cache.overrides) do
      overrideCache[#overrideCache + 1] = override
    end
  end
)

RegisterServerEvent('bs-perms:loopThroughAuthed')
AddEventHandler('bs-perms:loopThroughAuthed',
  function(cb)
    for _, admin in pairs(authedAdmins) do
      cb(admin)
    end
  end
)

RegisterServerEvent('bs-perms:getUtils')
AddEventHandler('bs-perms:getUtils',
  function(cb)
    cb(gatherUtils)
  end
)

function gatherUtils()
  return {
    getAdmins = getAdmins,
    getGroups = getGroups,
    getOverrides = getOverrides,
    getSteamFromId = getSteamFromId,
    hasFlag = hasFlag,
    getAuthedAdmin = getAuthedAdmin,
    playerHasFlag = playerHasFlag,
    playerCanTargetPlayer = playerCanTargetPlayer,
    loopThroughAuthed = loopThroughAuthed
  }
end

function getFlatAdmin(admin, source)
  admin.pid = source
  if admin.Group ~= nil then
      local groupId = getGroupIdByNameFromGroupCache(admin.Group)
      if groupId then
        local group = groupCache[groupId]
        admin.flags = mergeFlags(admin.flags, group.flags)
        admin.immunity = highestOfTwo(admin.immunity, group.immunity)
      end
      return admin
  else
    return admin
  end
end

function loopThroughAuthed(cb)
  for _, admin in pairs(authedAdmins) do
    cb(admin)
  end
end

function getAdmins()
  return overrideCache
end

function getGroups()
  return overrideCache
end

function getOverrides()
  return overrideCache
end

function getAuthedAdmins()
  return authedAdmins
end

function getSteamFromId(playerId)
  for _, v in pairs(GetPlayerIdentifiers(playerId)) do
    if string.sub(v, 1, 6) == 'steam:' then
      return tostring(tonumber(string.sub(v, 7), 16))
    end
  end
  return nil
end

function hasFlag(flags, flag)
  return string.match(flags, flag)
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
  flags1 = flags1 or ''
  flags2 = flags2 or ''
  return flags1 .. flags2
end

function getAdminIdByTableFromAdminCache(adminToCheck)
  for i, admin in ipairs(adminCache) do
    if admin.authString == adminToCheck.authString then
      return i
    end
  end
  return nil
end

function getGroupIdByNameFromGroupCache(name)
  for i, group in ipairs(groupCache) do
    if group.name == name then
      return i
    end
  end
  return nil
end

function playerHasFlag(id, flag)
  local authed = getAuthedAdmin(source)
  if not authed then
    return false
  end
  if hasFlag(authed.flags, flag) then
    return true
  end
  return false
end

function playerCanTargetPlayer(id, targetId)
  local auth = getAuthedAdmin(id)
  local targetAuth = getAuthedAdmin(targetId)

  if auth == nil then
    if targetAuth == nil then
      return true
    else
      return false
    end
  end

  if targetAuth == nil then
    return true
  end

  if auth.immunity >= targetAuth.immunity then
    return true
  end

  return false
end
