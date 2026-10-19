# Agent Guidelines

## Project purpose and scope

Dyre's Sounds is a World of Warcraft: Forever library AddOn: the sounds and
the sound menu that Dyre's AddOns share (author-approved, like QuestieDB). It
has no slash command, no settings, and no saved variables; it does nothing on
its own. Keep this feature set; do not add speculative features or frameworks
without agreement.

Naming (author-approved): the title starts with "Dyre's", so players can find
all of the author's AddOns by searching for it. The apostrophe is only in the
title: the folder, TOC, repository, and global use `DyresSounds`.

### Shared AddOns (author-approved)

- Features duplicated between Mage Tools Forever (MTF), Warlock Tools Forever
  (WTF), and other classes move into their own AddOns: Dyre's Sounds (this
  library), Dyre's Shields Up (DSU), Dyre's Buff Reminders, and Dyre's
  Cooldown Chimes. Layout (magnetic frames) stays copied, with a copy test.
- Dependents list Dyre's Sounds as `## OptionalDeps` in their TOC (never
  `## Dependencies`, which stops an AddOn loading when it is missing) and as a
  required dependency on CurseForge. Without the library, a dependent says once
  in chat what to install and plays no sound.
- The move is in two steps (author-approved): first the new AddOns ship while
  MTF and WTF keep their own copies and stand aside for them; later MTF and
  WTF drop their copies, with a CHANGELOG note and a chat message.

### The interface (contract 1)

- The global `DyresSounds`, reached with `DyresSounds.RequireContract(1)`,
  which returns nil for a newer contract than the library offers. Raise
  `CONTRACT` only for a change a dependent must know about.
- `Find`, `Resolve` (a saved key to the library's own; old MTF, WTF, and DSU
  keys are aliases), `Label`, `Parts`, `List(filter)`, `Groups(filter)`,
  `Play(key, speech, channel)`, `AuraSound(key)` (the `UnitAuraSoundInfo` file
  fields), `Choices(filter)`, `SetupMenu(initializer, filter)`, and
  `SetupCheckboxMenu(initializer, filter)` (0.1.2: a row from Blizzard's
  `CreateSettingsCheckboxDropdownInitializer`, whose Init sets up its own
  dropdown, so the nested menu is built after it; pooled frames clear a stale
  sound label as plain dropdowns do; additive, so contract 1 stays). The filter
  "aura" keeps only file sounds, the only ones `C_UnitAuras.AddAuraSound` takes.

### The catalog

- Catalog.lua, in menu order: Dyre's Picks (files in Sounds/, first), the
  client's interface sounds by SOUNDKIT name, the Cooldown Manager's alert
  sounds by kit ID in its categories, imp sounds by file ID, and Text to
  Speech last. A sound the client lacks is left out of the menu.
- Found in client: the client plays a game sound by file ID or an AddOn's own
  file, never a game sound by path (RaidWarning.ogg stayed silent).
- Dyre's Picks are licensed to Vertiso Corporation from Envato (Elements and
  AudioJungle); the author's license allows every project. The license files
  stay local in docs/licenses/ (ignored by Git). New sounds join Dyre's Picks over time: add the file, its
  catalog line, and its MEDIA_FILES entry (a test checks they match).

## Project structure

- Runtime files: DyresSounds.toc, Catalog.lua, Sounds.lua, Menu.lua, loaded in
  that order, plus Sounds/. tests/run.lua holds the Lua 5.1 mock suite;
  tests/test_*.py cover the release helpers in scripts/.
- README.md is the user-facing overview, TESTING.md the verification method,
  docs/RELEASE_PLAN.md the release process, docs/CURSEFORGE_LISTING.md the
  CurseForge form text, and CHANGELOG.md the per-release change list.
- All Rights Reserved (author-approved, as the author sees boss mods do, to protect the
  sounds; the author's other AddOns are MIT): LICENSE grants only download and
  use, and the release builder requires its exact text. The public author name
  is `Dyre`; LICENSE keeps the legal name, John Bedworth.
- The TOC uses `## Category: Libraries`; keep it identical to the CurseForge
  main category.
- Git origin: git@github.com:jbedworth/DyresSounds.git (public).

## Client and API verification

- Target: Forever beta 1.60.1, build 70338, Interface 16001, Lua 5.1. Pin
  source review to Gethe/wow-ui-source commit
  `943764493e6b16d63ded3ab304150d1f05e58b57`.
- Gate only on required APIs, never on client version, build, or class.
- The target client has Midnight's secret values and AddOn restrictions. This
  library reads no combat values.

## Clean coding

- Lua 5.1 only. Four-space indentation. Share state through the AddOn
  namespace; the only global is `DyresSounds`.
- Comment sparingly: non-obvious intent, API constraints, or tradeoffs.
- Event-driven work only; no polling or idle `OnUpdate` handlers.

## Testing and documentation

- Run `.tools/luarocks-3.13.0-win32/win32/lua5.1/bin/lua5.1.exe tests/run.lua`,
  the bundled `luac5.1.exe -p` on every Lua file,
  `.tools/python-3.13.7/python.exe -m unittest discover -s tests -p 'test_*.py'`,
  and actionlint on workflow changes. Report actual results.
- Add focused tests alongside behavior changes.

## Releases and collaboration

- Read docs/RELEASE_PLAN.md before packaging or changing release automation.
- Do not create commits, tags, uploads, or releases unless asked.
- Every release needs a `## <version>` section in CHANGELOG.md.
- Package only DyresSounds.toc, Catalog.lua, Sounds.lua, Menu.lua, LICENSE,
  and the sounds in Sounds/ under the top-level `DyresSounds/` folder, named
  `DyresSounds-<version>-forever.zip`, with the builder's `release.json`.
- Publishing uses the same repository variables, `release` environment, and
  approval gate as the author's other AddOns. Action pins are full commit SHAs.
- Commit messages: imperative, capitalized subject, at most about 50
  characters, no ending punctuation.
