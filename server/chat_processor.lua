local commands = {}

AddEventHandler('chatMessage',
  function(source, n, message)
    if startsWith(message, '/') or startsWith(message, '!') then
      local args = splitBySpace(message)
      local command = args[1]:lower()

      if startsWith(message, '/') then
        command = string.gsub(command, '/', '')
        CancelEvent()
      end

      if startsWith(message, '!') then
        command = string.gsub(command, '!', '')
      end

      if commands[command] then
        local cmd = commands[command]
        local auth = getAuthedAdmin(source)

        if cmd.pre ~= nil then
          cmd.pre(source, auth, args, cmd)
          return
        end

        local allowed = checkIfAllowed(source, cmd)

        if not allowed then
          TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed.')
          return
        end

        if cmd.target ~= nil then
          if cmd.target == true then
            cmd.target = 2
          end

          local targetId = tonumber(args[cmd.target])
          local targetPlayerName = GetPlayerName(targetId)

          if not targetPlayerName then
            TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Player doesn\'t exist.')
            return
          end

          local targetAuth = getAuthedAdmin(targetId)

          if auth and hasFlags(auth.flags, 'z') then
            cmd.callback(source, args, auth, targetAuth)
            return
          end

          if not auth and targetAuth then
            targetAuth.immunity = targetAuth.immunity or 0
            if targetAuth.immunity > 0 then
              TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed to target them.')
              return
            end
          end

          if targetAuth and auth then
            if targetAuth.immunity > auth.immunity then
              TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed to target them.')
              return
            end
          end

          cmd.callback(source, args, auth, targetAuth)
        end

        cmd.callback(source, args, auth)
      end
    end
  end
)

function checkIfAllowed(id, cmd)
  local overridden = false

  local authed = getAuthedAdmin(id)

  if authed and hasFlags(authed.flags, 'z') then
    return true
  end

  local overridden = checkIfOverriden(authed, cmd)

  if overridden ~= nil then
    return overridden
  end

  if cmd.flag == nil or cmd.flag == '*' then
    return true
  end

  return authed and hasFlags(authed.flags, override.flag)
end

function checkIfOverriden(authed, cmd)
  for _, override in getOverrides() do
    if override.type == 'full' and override.commandString == cmd.command then
      if override.flag == nil or override.flag == '*' then
        return true
      end
      return authed and hasFlags(authed.flags, override.flag)
    end

    if override.type == 'prefix' and startswith(cmd.command, override.commandString) then
      if override.flag == nil or override.flag == '*' then
        return true
      end
      return authed and hasFlags(authed.flags, override.flag)
    end
  end
  return nil
end

RegisterServerEvent('bs-perms:addCommand')
AddEventHandler('bs-perms:addCommand', function(command)
  addCommand(command)
end)

function addCommand(command)
  commands[command.command] = command
end

addCommand({
  command = 'perms',
  flag = 'b',
  callback = function(who, args, auth)
    if args[2] == 'reload' then
      refreshAdmins()
    end
  end
})
