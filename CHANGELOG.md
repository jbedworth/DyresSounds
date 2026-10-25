# Changelog

Player-facing changes for each Dyre's Sounds release, newest first. The
release builder copies the section for the TOC version into the GitHub release
notes and the CurseForge changelog, and fails if that section is missing.

## 1.2.0

### Features
- **Dyre's Aggression:** 11 new battle cries and shouts, for Charge, shouts, and other Warrior moves: "Charge!" from a soldier, an orc, a pirate, a crowd, and children, a bugle charge, a rage-filled attack, a raspy angry shout, an angry scream, an angry orc, and an orc spitting fury.
- **Dyre's Gore, Dyre's Smacks, and Dyre's Blades:** 14 crit sounds: a slice, a chop, a bash, a splat, a bloody impact, a wet splat hit and a wet face punch; a wet slap, a swish smack, a kiss and kisses; a sword swipe, a sword cut, and a laser sword swing.

### Fixes
- The Animals, Devices, Impacts, Instruments, Warcraft 2, and Warcraft 3 sounds are out of the menus for now: they played only some of the time, or not at all. Dyre's AddOns play their default sound instead where you had chosen one.
- **Classic Era and Anniversary:** the sound menus list only sounds those clients can play: the Dyre's groups, Interface, and Text to Speech. The Imp and Hellish imp sounds are not in those clients and played nothing.

## 1.1.0

### Features
- 22 new sounds, in four new groups after Dyre's Picks:
  - **Dyre's Speed:** speed boosts, a power-up, engine revs, a car zooming by, and a spaceship slowing down, for travel and sprint spells.
  - **Dyre's Cats:** a kitty meow, an angry cat, a child's tiger grrr, a tiger growl, and a lion roar.
  - **Dyre's Bears:** a little kid's roar, a cartoon bad bear, a bear roar, a monster bear, and a big monster roar.
  - **Dyre's Water:** a dive, a fish splash, a fish swimming by, and a walrus roar.

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
