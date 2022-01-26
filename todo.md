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
- [x] starting res too soon causes tempResource to fail to start. a timer of 1ms on Res.start in (Res.restart)
- [x] put more functions in shared
- [ ] put even more functions in shared (from res)
- [ ] create auto updater
- [ ] add external loading
- [ ] optimize code /shorten code
- [ ] stress test core / security tests
- [ ] change scriptbuffer events to latent events, also use: https://wiki.multitheftauto.com/wiki/GetLatentEventStatus

  # priority
  - [x] CEGUI is not being destroyed!, we are storing gui elements inside serverroot/clientroot, destroying the root does not destroy the gui elements. we must store them in a table instead.

  # Core GUI
  - [ ] make advanced resource panel (Core master panel?), show resource information, script events, cmds, binds, timers, number of elements,
uptime, cpu usage, mem usage, filelist, script list, stop/start button etc. etc.

  # File function / res rootdir
  - [ ] create file class, and rewrite file funcs & playSound etc change rootdir to resroot and add in file decryption
  - [ ] add file encryption (optional in meta), rewrite filefuncs/sound/etc to decrypt files

  https://wiki.multitheftauto.com/wiki/GetResourceOrganizationalPath

  # critical
  - [x] server scripts not unloading (res.server contains both index and filename as key!)
  - [x] server elements not being destroyed? (see MTA Class elements, they're not destroyed atm)
  - [ ] onClientResourceStart is broken, onResourceStart too?
  - [ ] make sure scripts cannot access/modify main Core functions and break it!

  # error handling (FIXED)
  - [x] script error checking is only done on script load (scriptLoader). if there's an error that's inside, say a cmd handler, a timer or event, then it's not going through the error checking process that's happening in the scriptLoader.
    - we could separate the error checking from the buffer and feed any callbacks from other functions through it.
    - If we do that, how are we gonna get the correct line the error occurred at? the first line would be the first line in the callback function.
    - we ned to somehow go through every argument of a global function and check if it's a function although this wouldn't work for private local functions and anonymous functions

# ideas
- ability to set script or entire res to private so other resources can't mess with it (only get name, root etc.)
- ability to set script to read only (to prevent other resources and/or scripts to change it).

# questions

