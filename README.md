# bs-perms alpha 0.0.1
----------
This is a resource that manages whether people are able to run certain commands via a flag system.  The flag system is inspired by sourcemod.  This requires bs-perms-json or bs-perms-api to have admin, group, and override data fed into it.  It is optional of what you want to use.  Both bs-perms-json and bs-perms-api will work together.  A flag can be any single character.  

----------
## Server Owners
### Requirements
[bs-perms-json](https://github.com/busheezy/bs-perms-json)  
and/or  
[bs-perms-api](https://github.com/busheezy/bs-perms-api)  
### Installation
 - copy/move ``bs-perms`` to ``<server>/resources/``
 - add to ``<server>/citmp-server.yml``
 - install bs-perms-api or bs-perms-json
----------
## Developers  
### API Examples
- Creating commands
```Lua
  TriggerEvent('bs-perms:addCommand', {
  	command = 'example',
  	flag = 'b',
  	callback = function(who, args, auth)
  		...
  	end
  })
```
- Loop through authed users
```Lua
  TriggerEvent('bs-perms:loopThroughAuthed',
  function(authed)
    print(authed.authString .. ' : ' .. authed.flags)
  end)
```
----------
### Related Gits
[bs-admin](https://github.com/busheezy/bs-admin)   
[bs-perms-json](https://github.com/busheezy/bs-perms-json)  
[bs-perms-api](https://github.com/busheezy/bs-perms-api)  
[node-bs-perms-api](https://github.com/busheezy/node-bs-perms-api)
