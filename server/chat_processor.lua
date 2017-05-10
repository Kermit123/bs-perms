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
        local allowed = checkIfAllowed(source, cmd.flag)

        if not allowed then
          TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed.')
          return
        end

        if cmd.target ~= nil then
          if cmd.target == true then
            cmd.target = 2
          end
          local targetAuth = getAuthedAdmin(tonumber(args[cmd.target]))
          if targetAuth then
            if targetAuth.immunity > auth.immunity then
              TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed to target them.')
              return
            end
          end
        end

        if cmd.callback ~= nil then
          cmd.callback(source, args, getAuthedAdmin(source))
        end
      end
    end
  end
)

function checkIfAllowed(id, flag)
  local allowed = false

  local authed = getAuthedAdmin(id)

  if flag == '*' then
    allowed = true
  else
    if authed then
      if string.match(authed.flags, 'z') or string.match(authed.flags, flag) then
        allowed = true
      end
    end
  end

  if authed and not string.match(authed.flags, 'z') then
    for _, override in getOverrides() do
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

  return allowed
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
