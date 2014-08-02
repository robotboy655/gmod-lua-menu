Garry's Mod Lua Main Menu
=============

A Lua powered ( No HTML ) main menu for Garry's Mod.
It is meant for those who do not have main menu in Garry's Mod by default.
Note that this is a personal project, and it is not going to be included into Garry's Mod.
It does not have some features that I don't use.
Some other features that are not part of the standard menu might be added in the future.

Missing/Broken Features
=============

* Server browser - This menu uses the default Source Engine server browser
* Demos and Saves - I never use those so I didn't bother adding them. Who uses them anyway?
* Good looks
* You can't browse through new/top rated/ect addons in main menu. You should use the Open Workshop button anyway.
* Due to how Material() works, I have to ship a duplicate of all default map icons.
* Gamemode header image thigny is kind of broken - there's no way to get a size of a .png image

New/Fixed Features
=============

* I think it's faster then the default one
* Server settings in "new game" menu are working properly
* Caching - map and workshop icons are cached - you only slowly load them once, and then it's fast
* No HTML

Installing
=============

To install this, download the ZIP and extract it to your ```SteamApps/common/GarrysMod/garrysmod``` folder.

Uninstalling
=============

To uninstall this, open ```lua/menu/menu.lua``` and follow instructions inside.
