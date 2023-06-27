# 1.2.0 SMALL UPDATE ? NO !!!!

<details><summary><h2>GENERAL</h2></summary><p>

 - License moment

</p></details>
<details><summary><h2>SONIC RUNNER</h2></summary><p>

### VISUAL

 - Sonic Runner is no longer in the 4:3 aspect ratio, it is now in the glorious___ 5:3 aspect ratio___!
 - XT9 has new idle animations.
 - When launched very high with a mushroom, you now spin.
 - The timer is now outlined for better visibility.
 - User Universe now has a unique BG.
 - Bootup sequence has a new font.
 - Spikes' inner glowing circle thing is now purple because they are the things behind the slaughter.

### FIXES & CHANGES

 - The menu now has it's own seperate keys from gameplay.
 - The level timer doesn't start until you start moving.
 - S1's dash is now a bit slower.
 - Shortend coyote time on S1 and it's derivates.
 - XT9 is unlocked when you have 7 bonuses now. If you already have them unlocked,
   this update wont take it away.
 - Fixed `savefile_interaction` argument working incorrectly.

</p></details>
<details><summary><h2>SONIC RUNNER EDITOR</h2></summary><p>

### NEW ADDITIONS

 - Added new shortcuts to temporarely hide layers.
 - In the edit layers panel, there is now a new option:__ Unicolor__! Turning this
   on will make every layer only one color.
 - Added a new object:__ Boosters__! The act similarly to mushrooms, but just with
   different theming.
 - Added a new object:__ Platforms__! The moving platforms are real!
 - You can now change the font of HoverText.
 - New text interpreter or something!
	 - When typing text into HoverText, you can type some commands
	   inbetween %% and they will be replaced by game info.
	 - `%left%`, `%right%`, `%up%`, `%down%`, `%jump%`, `%special%`,
	   `%reset%`, `%return%` will be replaced by the users keybinds for
	   those actions.
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
 - You can now add the name of the author to a level group.

### VISUAL

 - There are now more variations of dirt tiles.
 - The .dat creator has been centralized.

### FIXES & CHANGES

 - Attachables should no longer have wacky behaviours when you do anything complex with them.
 - Fixed a bug where you could have multiple of the same tile in the place panel.
 - Fixed playtested levels not reloading when you die or press reset.
 - Playtested levels no longer save as seperate levels.
 - The official tag has been altered. Now when a level has the official tag:
	 - If the level's author matches the level groups author, the level won't have the "Creator:" line, similary to how WaterWay doesn't have it.
	 - If the level's author is different to the level groups author, it will show a thank you message.
 - The official tag now does nothing in UserUniverse.
 - The keybind for saving with a popup is now shown in full.

</p></details>