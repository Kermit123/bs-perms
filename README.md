# bs-perms alpha 0.0.1

## About  
This is a resource that manages whether people are able to run certain commands via a flag system.  The flag system is inspired by sourcemod.  This requires bs-perms-json or bs-perms-api to have admin, group, and override data fed into it.  It is optional of what you want to use.  Both bs-perms-json and bs-perms-api will work together.  A flag can be any single character.  

## Server Owners

### Requirements
[bs-perms-json](https://github.com/busheezy/bs-perms-json)  
and/or  
[bs-perms-api](https://github.com/busheezy/bs-perms-api)  

### Installation
 - copy/move ``bs-perms`` to ``<server>/resources/``
 - add to ``<server>/citmp-server.yml``
 - install bs-perms-api or bs-perms-json

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

### Flags
These flags are either already used by bs-perms plugins or will be soon.

A - Reserved Slot  
B - Generic Admin  
C - Kick  
D - Ban  
E - Unban  
F - Slay  
G - Change Map  
H - Change Gametype  
I - Chat Perms  
J - Start Votes  
K - Set a password  
L - RCON  
M - No Clip  

Z - ALL FLAGS

### Immunity (copy/pasted from sourcemod docs)
Immunity is a flexible system based on immunity levels. Every admin can have an arbitrary immunity value assigned to them. Whether an admin can target another admin depends on who has a higher immunity value.

For example, say Admin #1 has an immunity level of "3" and Admin #2 has an immunity level of "10." Admin #2 can target Admin #1, but Admin #1 cannot target Admin #2. The numbers are completely arbitrary, and they can be any number equal to or higher than 0. Note that 0 always implies no immunity.

Admins with the same immunity value can target each other.

Admins with the z flag are not subject to immunity checks. This means they can always target anyone.

### Related Gits
[bs-admin](https://github.com/busheezy/bs-admin)   
[bs-perms-json](https://github.com/busheezy/bs-perms-json)  
[bs-perms-api](https://github.com/busheezy/bs-perms-api)  
[node-bs-perms-api](https://github.com/busheezy/node-bs-perms-api)
