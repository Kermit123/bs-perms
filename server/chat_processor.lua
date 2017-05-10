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
        local allowed = false

        local authed = getAuthedAdmin(source)

        if cmd.flag == '*' then
          allowed = true
        else
          if authed then
            if string.match(authed.flags, 'z') or string.match(authed.flags, cmd.flag) then
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

        if not allowed then
          TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed.')
          return
        end

        if cmd.callback ~= nil then
          cmd.callback(args, source)
        end
      end
    end
  end
)

RegisterServerEvent('bs-perms:addCommand')
AddEventHandler('bs-perms:addCommand',
  function(command)
    commands[command.command] = command
  end
)

commands['perms'] = {
  flag = 'z',
  callback = function(args, who)
    if args[2] == 'reload' then
      refreshAdmins()
    end
    if args[2] == 'test' then
      print(json.encode(adminCache))
    end
  end
}
