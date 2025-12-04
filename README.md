# A barotrauma mod, a big one at that.

This contains a script to automate the installation of Workshop mods into the Megamod (or your version of it).
To use it:
1. Create a local copy of the Megamod, if you haven't already.
2. Make sure that /Lua/utils/automation/auto.lua, /steamcmd/steamcmd.exe, /temp/, /Workshop/, and /Lua/workshop/ are present and that the first line in /Lua/Autorun/mega init.lua *is* commented out.
3. Make your changes to /Lua/utils/automation/auto.lua and make sure that in the file, Auto.Step = 0 before you move on.
auto.lua has documentation for making changes. Be very careful however, one incorrect XML override will botch the whole thing and force you to go digging for treasure (finding the singular invalid XML override, as it is not detected.)
4. Start a Barotrauma server (with the Lua executable, of course) running your local Megamod. Preferably, make it private and passworded, so that people don't mistakenly join.
5. In mega init.lua, uncomment the first line. In auto.lua, set Auto.Step = 1.
6. Reload Lua by typing "reloadlua" into the console.
7. The script will write an auto.bat to the root directory. Execute it to invoke SteamCMD to download the mods defined in auto.lua, placing them in /temp/.
Sometimes SteamCMD will fail to download a mod, indicated by an empty folder structure with no files. If this happens, download that mod manually. I prefer to subscribe to the mod on Steam temporarily, and copy-paste it into /temp/ while renaming it.
8. Copy everything in /temp/ to /Workshop/, replacing anything that was in /Workshop/. Make sure that no mods were not downloaded correctly before moving on, or you will get an error upon integrating the mods and will have to redo this step.
9. In auto.lua, set Auto.Step = 2.
10. Reload Lua again. This time, it will take much longer. Wait for it to finish, shown by the Lua startup in the console.
During this step, it will create three text files in Lua/utils/automation/. Two of them are lists of items that should be added to your Performance Fix config (if you're running PF) on the server- and client- side respectively. This makes projectiles in-game act much more consistently, and makes some animations (particularly on doors) smoother. The third file is a list of item variants, as the script can't yet detect if variants should be included in the aforementioned lists of items.
11. The script will rewrite auto.bat. Execute it again to copy all Lua files to /Lua/workshop/.
This is important so that the Lua function require() will work, as it, well, requires files to be in the /Lua/ folder. This is a limitation of the Barotrauma Lua extension.
12. Make sure to re-comment the first line in mega init.lua, and optionally for next time, set Auto.Step = 0.
If you are forking the Megamod, make sure to delete everything in /temp/, before using your fork on your server or uploading it to the Workshop. Not doing so will nearly double the file size. You can also delete other backend things like steamcmd and auto.bat to save a little more space.