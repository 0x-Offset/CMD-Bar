Please report any bugs in an issue and ill try to fix it.

note: i mainly focused on the ui not being shit this time, but that does mean that i didnt focus that much on functionality; unlike legacy, reloading commands is not possible and you'll have to reload CMD Bar completely. a plus tho: reloading CMD Bar is as easy as just loading the ui lib again, since it automatically destroys old instances, so most of the time ur script can just be re-executed to reload it, additionally you could also create ur own wrapper to replace the Loader.luau script that allows u to reload the ui easier. (i might do this myself at some point, but probably not.)

example of how to use:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/0x-Offset/CMD-Bar/refs/heads/main/New/Loader.luau", true))()
repeat task.wait() until shared.RegisterCMD ~= nil

shared.RegisterCMD("FuckYou", {"Name"}, "Says fuck you.", function(Arguments, Issuer)
    print("Hey "..Issuer.Name..", why u trying to be mean to "..Arguments[1].."?? fuck you "..Issuer.Name)
end)
```
