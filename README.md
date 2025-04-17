# NoteSkin Selector Remastered
NoteSkin Selector Remastered; new layout, new code, and more customizability.

## About
This is a completely remastered one of my old mods "NoteSkin Selector", created in 2022. This mod heavily improves and enhances everything from the old mod. It includes a new friendlier GUI layout for selecting skins more easily, a better optimized and organized code. Basically, a more improved version of the current built-in noteskin system in the engine, because that one sucks ass ngl.

NoteSkin Selector Remastered © 2024 by Meme0179 is licensed under CC BY-NC-ND 4.0

## Installation Requirements
1. Computer
     - Windows, MacOS, and Linux are only supported when playing this mod. 
     - Android, Switch, Consoles and other devices are not supported due to controller issues. 
          - Never ask a FUCKING port of this, especially Android I ain't doin' that shit.
2. Psych Engine & P-Slice
     - Some specific version of Psych Engine are only supported when playing this mod:
          - 1.0.3
          - 0.7.3

## Features
- A brand new user-friendly graphical user interface (GUI)
     - A `4x4` display grid to select multiple skins
     - A scroll bar to scroll through multiple pages of skin
     - A search bar to easily find the certain skin you want to select
- A brand new user-friendly implementation of skins
- Previews of the skins and its animations associated with it
- ~~Preview-editor for offsetings the skin's animation preview~~
- Customizable background music
- Saves the data

***

## Version 2.0.0
### Additions/Changes
- Overhual the main GUI with a new redesign, cuz it looks cool. _(inspired by OreUI from Minecraft)_
- Overhual the main source-code of the mod for organization and an ability to soft-code new skin states.
     - Classes to create custom states for different skins by using inheritance and polymorphism stuff.
     - Loads separated chunks of object sprites of the skins when switching pages.
- Additions/Changes on the NoteSkin Selector State.
     - Added a functional slider for switching skin pages.
          - It automatically snaps to its nearest page index.
          - It also automatically disables itself if there's only currently `1` page index.
     - Added an implementation for custom skin packs
          - Subfolders for the textures of skins within the skin packs (images folder)
          - Subfolders for certain metadata JSON files within the skin packs (json folder)
     - Added a functional search bar for finding certain skins.
          - Automatically filters to the closest skin it can find.
     - Added an `inOutExpo` easing tween to the color changing background.
     - Increase the skin grid selections from `3x4` to `4x4`, cuz it's better.
- Additions/Changes on the preview animation selection.
     - Added a new GUI for the preview animation selection.
          - Allowing for selecting other preview animations by clicking a button
- Organized file locations.
     - Added an `api` folder to group: `classes`, `libraries`, and `modules` for convenient sake.
     
> [!NOTE]
> The Noteskin Debug State is temporarily removed for reasons. Because I wanna rush it out becuase it has been almost a year without an update. And making an editor is the most hardest part, so cut me some slack here. This will be re-added back in the version 3.0.0.

***

# Stuff Used Here
## Noteskins
- Majin - [Vs. Sonic.EXE 2.0](https://gamebanana.com/mods/316022)
- Arrow Funk - [Arrow Funk](https://gamebanana.com/mods/370234)
- Bad - [FNF, but bad (REMAKE)](https://gamebanana.com/wips/79374)
- Creepy - [Vs. Flippy](https://gamebanana.com/mods/300838)
- DokiDoki - [FNF: Doki Doki Takeover Plus!](https://gamebanana.com/mods/47364)
- M1KU - [Hatsune Miku - Project Funkin'](https://gamebanana.com/mods/485992)
- MM, MM Luigi - [FNF: Mario's Madness](https://gamebanana.com/mods/359554)
- Ourple - [Vs Ourple Guy](https://ourpleguy.neocities.org/)
- Rush - [RUSHSHOT](https://gamebanana.com/mods/523534)
- TGT - [Tails Gets Trolled](https://gamebanana.com/mods/320596)

## Music
- File Select - Sonic 3 & Knuckles
- Extras Menu - Sonic Mega Collection
- Palmtree Panic (P mix) - Sonic CD
- Artistic Expression - [Friday Night Funkin' (Kawaisprite)](https://www.youtube.com/watch?v=yFHbQFH09Io)
- Monkey - Original: [Mario Paint (Hirokazu Tanaka)](https://www.youtube.com/watch?v=gMRFXrbfKEo); Remix: [Mario's Madness (FriedFrick)](https://www.youtube.com/watch?v=x0AMU2nelAw)

## Lua Libraries
- [MathParser](https://github.com/bytexenon/MathParser.lua) - bytexenon
- [Lua Pretty JSON](https://github.com/xiedacon/lua-pretty-json) - xiedaco
- [Lua Easing Library](https://github.com/EmmanuelOga/easing) - EmmanuelOga

## Other
- Cursor - [Sonic Legacy](https://gamebanana.com/mods/496733)
- FridayNight Font - [Due Debts (BF Mix)](https://gamebanana.com/mods/575991); Creator: [LeGooey](https://gamebanana.com/members/2322712)