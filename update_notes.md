# 2.0.0 SMALL UPDATE ? NO !!! BIG BREAK !!!

<details><summary><h2>GENERAL</h2></summary><p>

 - License moment

</p></details>
<details><summary><h2>SONIC RUNNER</h2></summary><p>

### NEW ADDITIONS

 - The main menu got almost completely redesigned, with every menu that it had originaly either completely overhalled or at least changed in some way.
   There were no escapees. On top of that, there are now also new menus! And also a new inaccesable menu! God damn!
 - New timer setting, where it will only appear if you had beaten the level you are playing.
 - You can now screenshot the game with F2.
 - You can now save replays while playing the level with F6. This will save a replay without you needing to finish the level.
 - You can now unlock "missing" legitimately.

### VISUAL

 - Sonic Runner is no longer in the 4:3 aspect ratio, it is now in the glorious___ 5:3 aspect ratio___!
 - XT9 has new idle animations.
 - When launched very high with a mushroom, you now spin.
 - Fixed XT9's and missing's particles being the wrong color for 1 frame
 - The timer is now outlined for better visibility.
 - User Universe now has a unique BG.
 - Bootup sequence has a new font.

### FIXES & CHANGES

 - The menu now has it's own seperate keys from gameplay.
 - Fixed bug where a level groups completion percentage wouldn't save, leading to messy behaviour.
 - The level timer doesn't start until you start moving.
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
 - New text interpreter or something!
	 - When typing text into HoverText, you can type some commands
	   inbetween %% and they will be replaced by game info.
	 - `%left%`, `%right%`, `%up%`, `%down%`, `%jump%`, `%special%`,
	   `%reset%`, `%return%`, `%menu_left%`, `%menu_right%`, `%menu_up%`,
           `%menu_down%`, `%accept%`, `%deny%`, `%save_replay%`, `%screenshot%`
	   will be replaced by the users keybinds for those actions.
	 - `%unlock [unlock]%` will be replaced by a YES or NO depending on if
	   `[unlock]` is unlocked.
	 - `%level [level_data]%` will be replaced by info from the level .dat file.
	   possible options for [level_data]:
		 - creator - Who made the level.
		 - level_name - Name of the level.
		 - level_icon - What icon the level has.
		 - level_base - What base the level has.
	 - If you wanna type % or any of the commands without them being replaced, put them between \`\`,
	   and the interpreter will ignore them.
	 - %\`% will put a \`, since otherwise it will be removed.
 - You can now set `tele_destination` of the portal and finish to `*Level_Next`, which will change the level to the next level in the level group.
 - There is now a shortcut to start playtesting the level
 - You can now add the name of the author to a level group. You can also make it so it doesn't display in the level select screen, if you don't like how it looks.
 - A new tool to convert pngs to stex has been added. It has no use currently, but may come in handy once i tackle mod support.

### VISUAL

 - You can now specify the "ui color" for a level group.
 - There are now more variations of dirt tiles.
 - More Blurees! i love trees trees so cool
 - New stalagmite and stalactite sprites added.
 - The .dat creator has been centralized.

### FIXES & CHANGES

 - Attachables should no longer have wacky behaviours when you do anything complex with them.
 - Fixed a bug where you could have multiple of the same tile preset in the place panel.
 - You can now edit the order of portals.
 - Fixed playtested levels not reloading when you die or press reset.
 - Playtested levels no longer save as seperate levels.
 - Upon exiting a level when you are playtesting it, you will also exit SR. You won't need to go through the SR menu to get back to the editor.
 - The "Is official" tag has been altered. Now when a level has the "Is official" tag:
	 - If the level's author matches the level groups author, the level won't have the "Creator:" line, similary to how WaterWay doesn't have it.
	 - If the level's author is different to the level groups author, it will show a thank you message.
 - The "Is official" tag now does nothing in UserUniverse.
 - In the options menu, the keybind for saving with a popup didn't display properly. This is now fixed.

</p></details>
