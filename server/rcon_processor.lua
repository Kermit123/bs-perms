AddEventHandler('rconCommand',
  function(commandName, args)
    if commandName:lower() == 'admins' then
      if args[1] == 'reload' then
        refreshAdmins()
      end
      CancelEvent()
    end
  end
)
