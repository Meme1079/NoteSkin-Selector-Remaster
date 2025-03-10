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
     - Increase the skin grid selections from `3x4` to `4x4`, cuz it's better.
- Organized file locations.
     - Added an `api` folder to group: `classes`, `libraries`, and `modules` for convenient sake.
     
> [!NOTE]
> The Noteskin Debug State is temporarily removed for reasons. Because I wanna rush it out becuase it has been almost a year without an update. And making an editor is the most hardest part, so cut me some slack here. This will be re-added back in v3.0.0.

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