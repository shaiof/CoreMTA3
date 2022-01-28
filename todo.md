# Core structure
- /core - Core loader files
- /globals - Global resources (for adding custom funcs)
- /modules - Framework resources
- /resources - Main resources

# commands
| command     | args     | function              |
|-------------|----------|-----------------------|
| /startres   | name     | Starts a resource     |
| /stopres    | name     | Stops a resource      |
| /restartres | name     | Restarts a resource   |

# custom globals
| function    | args     | function               |
|-------------|----------|------------------------|
| import      | -        | Import modules/globals |


# todo / issues (not in any specific order)
- [x] import optimizations: when resources[name] is restarted, resources that have imported resources[name], don't have access to it anymore. we gotta return a function or something, then maybe use a metatable to trigger (re-import) automatically when a variable is accessed.
- [x] cancel fetchremote/callremote requests on resStop/unload (abortRemoteRequest)
- [x] put more functions in shared
- [ ] put even more functions in shared (from res)
- [ ] create auto updater
- [ ] add external loading
- [ ] optimize code /shorten code
- [ ] stress test core / security tests
- [ ] change scriptbuffer events to latent events, and use: https://wiki.multitheftauto.com/wiki/GetLatentEventStatus (see core gui)
- [ ] modules should be imported via import func (rn import imports res globals)
- [ ] add support for .map files (map resources)
- [ ] add support for gamemodes (multiple gamemodes ?)
- [ ] rethink core modules (require, global res or per script?, loadstring?). 3 options: global to core, global to res (we use scriptloader and load it before res scripts) or global per script only.
- [ ] fix import function from utils resource that's loaded in w/ loadstring, it overrides core import func. we need to prevent scripts overriding Core functions
- [ ] parse meta.xml settings?

  # priority
  - [x] CEGUI is not being destroyed!, we are storing gui elements inside serverroot/clientroot, destroying the root does not destroy the gui elements. we must store them in a table instead.
  - [ ] make sure scripts cannot access/modify or replace main Core functions and break it

  # Core GUI / Master Panel
  - [ ] make advanced resource panel (Core master panel?). shows resource information, script events, cmds, binds, timers, elements,
uptime, cpu usage, mem usage, filelist, scriptlist, autostart, stop/start button etc. etc.
  - [ ] config manager, logs

  # File function / res rootdir
  - [ ] create file class, and rewrite file funcs & playSound etc change rootdir to resroot and add in file decryption
  - [ ] add file encryption (optional in meta), rewrite filefuncs/sound/etc to decrypt files
  https://wiki.multitheftauto.com/wiki/GetResourceOrganizationalPath

  # critical
  - [x] server scripts not unloading (res.server contains both index and filename as key!)
  - [x] server elements not being destroyed? (see MTA Class elements, they're not destroyed atm)
  - [x] res w/ tempResource won't start sometimes after it's been stopped once.
  - [x] /restartres screws up file downloads (starts too fast after stop, need to use stop/start events for temp res?) in general resources with tempres screw up badly, need to properly wait for it to start/stop (thru start/stop events?) before doign anything with it or running client scripts.
  - [x] onClientResourceStart is broken, onResourceStart too?
  - [ ] onClientResourceStart root/resourceRoot, if resourceRoot should only trigger for that resource, if root, it should trigger ALL resourceStart events in EVERY script in EVERY resource.
  - [ ] some files need to be unloaded like fonts before they can be deleted.
  - [ ] onClientReady isn't used.

  # error handling (FIXED partially)
  - [x] script error checking is only done on script load (scriptLoader). if there's an error that's inside, say a cmd handler, a timer or event, then it's not going through the error checking process that's happening in the scriptLoader.
    - we could separate the error checking from the buffer and feed any callbacks from other functions through it.
    - If we do that, how are we gonna get the correct line the error occurred at? the first line would be the first line in the callback function.
    - we ned to somehow go through every argument of a global function and check if it's a function although this wouldn't work for private local functions and anonymous functions
  - [ ] error checking is still messing up often, for instance when resource name is too long?
  - [ ] make warnings messages prettier

# ideas
- ability to set script or entire res to private so other resources can't mess with it (only get name, root etc.)
- ability to set script to read only (to prevent other resources and/or scripts to change it).

# questions

