<!-- ## Version 2.0.0 (Pre-Release)
### Additions/Changes
- Overhual the main source-code of the mod for organization and an ability to soft-code new states.
- Organized some file locations.
- Additions/Changes on the NoteSkin State.
     - Added a display icon background to make it easier to see.
     - Change the highlight icon to match the newer display icon.
     - Change the NoteSkin State title format.
- Added the support for splash skins.
     - Added a display offsets for x, y, and size of the icon to modify the `display.json` for splash skins.
- Added a new setting "Disable Display Animation", which is self-explanatory in its name.
- Added an at-selector for the `preview.json`; just look at the `AT-SELECTOR DOCS.md` in the json folder.
- Added some new sounds.

> [!NOTE]
> The Noteskin Debug State is temporarily removed becuase. I wanna rush it out becuase it has been 4 months without an update, so cut me some slack. This will be re-added back in the version `2.0.0 (Release)`. -->

## Version 2.0.0
### Additions/Changes
- Overhual the main source-code of the mod for organization and an ability to soft-code new states.
- Organized file locations.
- Additions/Changes to the GUI 
     - Completely redesign a new GUI (inspired by OreUI from Minecraft)
     - New textures
     - Added a slider for selecting skins, cuz its cool!


## Version 1.5.0
### Additions/Changes
- Additions/Changes on the NoteSkin Debug State.
     - Added an ability to erase all data offset files for clearing stuff, just pressed <kbd>SHIFT + B</kbd>.
     - Added a delay when saving and deleting data offset files.
     - Added an easter egg. _(You will never find this)_
- Added support for animated noteskins for note preview animations.
- The "Enable Double-Tapping Safe" setting will now work for when pressing <kbd>SHIFT</kbd> key.
- Remove any external scripts for better performace and to avoid conflicts with other scripts.
- Organized the files inside the modules folder, for coders like me.

### Bug Fixes
- Fixed a bug, when deleting a noteskin file in-game, it will crash the moment the countdown finished.
- Fixed a bug on the note preview animations, when holding the <kbd>LEFT-BRACKET</kbd> key then changing the type of animation, it will display the last note animation that was playing.
- Fixed a bug on the NoteSkin Debug State.
     - When attempting to move the idle note offset animations, it will actually move it.
     - When saving the offset positions, the positions will swap confirm and pressed positions, causing bugs.

## Version 1.0.0
- Initial Release