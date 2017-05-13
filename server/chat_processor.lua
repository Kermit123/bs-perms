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

      local commands = getCommands()

      if commands[command] then
        local cmd = commands[command]
        local auth = getAuthedAdmin(source)

        if cmd.pre ~= nil then
          function getCallback()
            function ready(pass)
              cmd.callback(source, args, auth, pass)
            end
            return ready
          end
          cmd.pre(source, auth, args, cmd, getCallback())
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

          if auth and not hasFlag(auth.flags, 'z') then
            cmd.callback(source, args, auth, targetAuth)
            return
          end

          local whoImmunity = 0
          local targetImmunity = 0

          if auth then
            whoImmunity = auth.immunity or 0
          end

          if targetAuth then
            targetImmunity = targetAuth.immunity or 0
          end

          if targetImmunity > whoImmunity then
            TriggerClientEvent('chatMessage', source, 'BS-PERMS', {255, 0, 0}, 'Not allowed to target them.')
            return
          end

          cmd.callback(source, args, auth, targetAuth)
        end

        cmd.callback(source, args, auth)
      end
    end
  end
)
