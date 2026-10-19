# Testing

## Method

1. **Pinned source review.** Client behavior is read from Blizzard's FrameXML
   and generated API documentation at Gethe/wow-ui-source commit
   `943764493e6b16d63ded3ab304150d1f05e58b57` (`1.60.1.70338`).
2. **Automated mock tests.** `tests/run.lua` exercises the catalog, the
   contract, playing each kind of sound, aura sound fields, and the sound menu
   against a minimal mock of the client. `tests/test_release.py` checks that
   the catalog's Dyre's Picks match the packaged sound files.
3. **In-client checks.** The checklist below covers what mocks cannot.

```sh
.tools/luarocks-3.13.0-win32/win32/lua5.1/bin/lua5.1.exe tests/run.lua
.tools/luarocks-3.13.0-win32/win32/lua5.1/bin/luac5.1.exe -p Catalog.lua Sounds.lua Menu.lua tests/run.lua
.tools/python-3.13.7/python.exe -m unittest discover -s tests -p 'test_*.py'
```

## Source findings

- `C_UnitAuras.AddAuraSound` takes `UnitAuraSoundInfo` with `soundFileName`
  or `soundFileID` only, not sound kits (pinned UnitConstantsDocumentation).
- The pinned Blizzard UI plays no sound by file; it uses sound kits.

## Found in client

Found with Dyre's Shields Up, Mage Tools Forever, and Warlock Tools Forever,
which shipped the same sounds:

- A game sound by path (`Sound\Interface\RaidWarning.ogg`) does not play.
- An AddOn's own MP3 and WAV files play, also through `AddAuraSound` when a
  buff runs out.
- Game sounds by file ID (the imp sounds) play.
- The interface sound kits play from a timer, also in combat (the cooldown
  chimes).

## In-client checklist

- [ ] `/run print(DyresSounds.RequireContract(1) ~= nil)` prints `true`.
- [ ] `/run DyresSounds.Play("magical")` plays Magical disappear.
- [ ] A dependent AddOn's sound dropdown shows Dyre's Picks first, plays a
      sound when chosen, and shows the full label.
- [ ] A dependent's checkbox-and-sound row (Dyre's Buff Reminders' chimes)
      shows the checkbox and the sound on one line, with the nested menu, the
      full label, and no arrows; turning the checkbox off greys the sound.
