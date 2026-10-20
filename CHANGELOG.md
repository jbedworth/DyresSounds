# Changelog

Player-facing changes for each Dyre's Sounds release, newest first. The
release builder copies the section for the TOC version into the GitHub release
notes and the CurseForge changelog, and fails if that section is missing.

## 1.0.0

The first full release for WoW: Forever, no longer marked beta: it was play tested on the Forever beta client 1.60.1, build 70450. CurseForge now offers it as a release, so the app updates it and installs what it needs for every player.

- The CurseForge app now installs Dyre's Sounds with the Dyre's AddOns that need it.

## 0.1.3-beta

- Listed under Dyre's Toolkit in the in-game AddOn list, with the other Dyre's AddOns.
- Removed the "Short" sounds: WoW Forever does not have them, so they never played.

## 0.1.2-beta

- For AddOn authors: a checkbox and its sound can share one settings row (`SetupCheckboxMenu`), with the nested sound menu.

## 0.1.1-beta

- Fixed: other AddOns' settings dropdowns could show a Dyre's Sounds label (such as "Dyre's Picks: Disappear") instead of their own choice.

## 0.1.0-beta

- First release: the sounds and sound picker that Dyre's AddOns share. Dyre's Picks (nine effect sounds), the game's interface sounds, the Cooldown Manager's alert sounds, imp sounds, and Text to Speech, in a menu grouped like the Cooldown Manager's.
- A library: it does nothing on its own. Install it when one of Dyre's AddOns asks for it.
