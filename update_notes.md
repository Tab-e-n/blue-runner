# 2.0.0 SMALL UPDATE ? NO !!! BIG BREAK !!!

<details><summary><h2>GENERAL</h2></summary><p>

 - License moment

</p></details>
<details><summary><h2>SONIC RUNNER</h2></summary><p>

### NEW ADDITIONS

 - The main menu got almost completely redesigned, with every menu that it had originaly either completely overhalled or at least changed in some way.
   There were no escapees. On top of that, there are now also new menus! And also a new inaccesable menu! God damn!
 - Achievements!
 - Cheat Codes!
 - New timer setting, where it will only appear if you had beaten the level you are playing.
 - New outlines option, when turned on the player character and the finish will gain outlines to make them more visible.
 - You can now screenshot the game with F2.
 - You can now save replays while playing the level with F6. This will save a replay without you needing to finish the level.
 - While looking at a replay, you can now pause it by pressing the jump button.

### VISUAL

 - Sonic Runner is no longer in the 4:3 aspect ratio, it is now in the glorious___ 5:3 aspect ratio___!
 - XT9 has new idle animations.
 - When launched very high with a mushroom, you now spin.
 - Fixed XT9's and missing's particles being the wrong color for 1 frame
 - The timer is now outlined for better visibility.
 - User Universe now has a unique BG.
 - Bootup sequence has a new font.
 - Ghosts now appear a solid instead of appearing segmented.

### FIXES & CHANGES

 - The menu now has it's own seperate keys from gameplay.
 - Fixed bug where a level groups completion percentage wouldn't save, leading to messy behaviour.
 - The level timer doesn't start until you start moving.
 - Saw jumps are now consistent.
 - S1's default slide is now a bit slower. Dropslide is staying the same speed, however.
 - Shortend coyote time on S1 and it's derivates.
 - XT9 is unlocked when you have 7 bonuses now. If you already have them unlocked,
   this update wont take it away.
 - Fixed a bug where you could quit to the menu after you've hit an obstacle, making the game not count the death.
 - Fixed a bug where the game didn't record the first frame of a replay.
 - Fixed `--savefile_interaction` console argument working incorrectly.

</p></details>
<details><summary><h2>SONIC RUNNER EDITOR</h2></summary><p>

### NEW ADDITIONS

 - New__ bucket tool__! You can access it by pressing the edit mode key while
   placing down tiles, and with a single left click it will allow you to fill
   in any holes you may have in the ground.
 - Added new shortcuts to temporarely hide layers.
 - In the edit layers panel, there is now a new option:__ Unicolor__! Turning this
   on will make every layer only one color.
 - Added a new objects:
    - __ Boosters__! The act similarly to mushrooms, but just with
      different theming.
    - __ Platforms__! The moving platforms are real!
    - __ External Images__! It's the lite version of mods!
    - __ Invisible Ground__! :)
 - You can now change the font of HoverText.
 - New text formating or something! It allows you show some game data as text.
   This will be explained in the wiki in more detail if you are interested.
 - You can now set `tele_destination` of the portal and finish to `*Level_Next`, which will change the level to the next level in the level group.
 - The Camera's fade in and fade out can be edited. Useful for story levels, but not needed for normal levels.
 - You can now add the name of the author to a level group. You can also make it so it doesn't display in the level select screen, if you don't like how it looks.
 - A new tool to convert pngs to stex has been added. It has no use currently, but may come in handy once i tackle mod support.

### VISUAL

 - Buttons no longer turn blue after pressing them.
 - You can now specify the "ui color" for a level group.
 - There are now more variations of dirt tiles.
 - More Blurees! i love trees trees so cool
 - New stalagmite and stalactite sprites added.
 - The .dat creator has been centralized.

### FIXES & CHANGES

 - When picking items, the original item is nolonger deleted unless you hold shift.
 - After you remove an item, you can press backspace to place the current
   item you have selected in it's place.
 - There is now a shortcut to start playtesting the level.
 - Added a new dropdown menu for selecting a tab.
 - Attachables should no longer have wacky behaviours when you do anything complex with them.
 - Fixed a bug where you could have multiple of the same tile preset in the place panel.
 - You can now edit the order of portals.
 - Portals nolonger break when multiple are placed.
 - Fixed playtested levels not reloading when you die or press reset.
 - Playtested levels no longer save as seperate levels.
 - Upon exiting a level when you are playtesting it, you will also exit SR. You won't need to go through the SR menu to get back to the editor.
 - The "Is official" tag has been altered. Now when a level has the "Is official" tag:
	 - If the level's author matches the level groups author, the level won't have the "Creator:" line, similary to how WaterWay doesn't have it.
	 - If the level's author is different to the level groups author, it will show a thank you message.
 - The "Is official" tag now does nothing in UserUniverse.
 - In the options menu, the keybind for saving with a popup didn't display properly. This is now fixed.

</p></details>
