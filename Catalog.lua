local _, ns = ...

-- The sound catalog: every sound Dyre's AddOns offer, in menu order. Labels
-- are "Group: Name" for the nested menu; a sound without a group (Text to
-- Speech) is a group of its own. Each sound is one of:
--   pick   a file in this AddOn's Sounds/ folder (Dyre's Picks)
--   fileID a game sound file by ID (found in client: IDs play, paths do not)
--   kit    a SOUNDKIT name from the pinned SoundKitConstants
--   id     a sound kit ID (the Cooldown Manager's alert sounds)
--   voice  the game's text-to-speech, saying the caller's text
-- Only pick and fileID sounds can be aura sounds: C_UnitAuras.AddAuraSound
-- takes a sound file, not a sound kit.
ns.CATALOG = {
    -- Dyre's Picks, first (author-approved): shipped in Sounds/, licensed to
    -- Vertiso Corporation from Envato (the author keeps the license files).
    {key = "fadingslow", label = "Dyre's Picks: Fading slow disappear", pick = "FadingSlowDisappear.mp3"},
    {key = "blowswoosh", label = "Dyre's Picks: Disappear blow swoosh", pick = "DisappearBlowSwoosh.mp3"},
    {key = "cartoonvanish", label = "Dyre's Picks: Cartoon vanish", pick = "CartoonVanish.mp3"},
    {key = "disappear", label = "Dyre's Picks: Disappear", pick = "Disappear.mp3"},
    {key = "magical", label = "Dyre's Picks: Magical disappear", pick = "MagicalDisappear.mp3"},
    {key = "disappearshort", label = "Dyre's Picks: Disappear (short)", pick = "DisappearShort.wav"},
    {key = "disappearingswoosh", label = "Dyre's Picks: Disappearing swoosh", pick = "DisappearingSwoosh.wav"},
    {key = "teleportvanish", label = "Dyre's Picks: Teleport warp vanish", pick = "TeleportWarpVanish.wav"},
    {key = "slowswoosh", label = "Dyre's Picks: Slow swoosh", pick = "SlowSwoosh.wav"},
    -- More picks by theme (1.1.0; the same Envato license): speed for travel
    -- and sprint spells, then cats, bears, and water for the Druid's forms.
    {key = "speedboost", label = "Dyre's Speed: Speed boost", pick = "SpeedBoost.wav"},
    {key = "boost", label = "Dyre's Speed: Boost", pick = "Boost.wav"},
    {key = "retroboost", label = "Dyre's Speed: Retro boost", pick = "RetroBoost.wav"},
    {key = "videogamespeed", label = "Dyre's Speed: Video game speed", pick = "VideoGameSpeed.wav"},
    {key = "powerup", label = "Dyre's Speed: Power-up", pick = "PowerUp.wav"},
    {key = "enginerev", label = "Dyre's Speed: Engine rev", pick = "EngineRevDoppler.wav"},
    {key = "cardoppler", label = "Dyre's Speed: Car zooming by", pick = "CarDoppler.wav"},
    {key = "spaceshipslow", label = "Dyre's Speed: Spaceship slowing down", pick = "SpaceshipSlowDown.wav"},
    {key = "kittymeow", label = "Dyre's Cats: Kitty meow", pick = "KittyMeow.wav"},
    {key = "angrycat", label = "Dyre's Cats: Angry cat", pick = "AngryCatMeow.wav"},
    {key = "childtiger", label = "Dyre's Cats: Child's tiger grrr", pick = "ChildTigerGrrr.wav"},
    {key = "tigerroar", label = "Dyre's Cats: Tiger growl", pick = "TigerRoar.wav"},
    {key = "lionroar", label = "Dyre's Cats: Lion roar", pick = "LionRoar.wav"},
    {key = "kidroar", label = "Dyre's Bears: Little kid roar", pick = "LittleKidRoar.wav"},
    {key = "cartoonbear", label = "Dyre's Bears: Cartoon bad bear", pick = "CartoonBadBear.wav"},
    {key = "bearroar", label = "Dyre's Bears: Bear roar", pick = "BearRoar.wav"},
    {key = "monsterbear", label = "Dyre's Bears: Monster bear", pick = "MonsterBear.wav"},
    {key = "bigmonsterroar", label = "Dyre's Bears: Big monster roar", pick = "BigMonsterRoar.wav"},
    {key = "waterdive", label = "Dyre's Water: Dive", pick = "WaterDive.wav"},
    {key = "fishsplash", label = "Dyre's Water: Fish splash", pick = "FishSplash.wav"},
    {key = "fishpassby", label = "Dyre's Water: Fish swimming by", pick = "FishPassBy.wav"},
    {key = "walrusroar", label = "Dyre's Water: Walrus roar", pick = "WalrusRoar.wav"},
    -- Battle cries and shouts (1.2.0; the same Envato license), for Charge,
    -- shouts, and other Warrior cast chimes.
    {key = "militarycharge", label = "Dyre's Aggression: Military: Charge!", pick = "MilitaryCharge.wav"},
    {key = "orccharge", label = "Dyre's Aggression: Orc: Charge!", pick = "OrcCharge.wav"},
    {key = "piratecharge", label = "Dyre's Aggression: Pirate: Charge!", pick = "PirateCharge.wav"},
    {key = "crowdcharge", label = "Dyre's Aggression: Crowd: Charge!", pick = "CrowdCharge.wav"},
    {key = "childrencharge", label = "Dyre's Aggression: Children: Charge!", pick = "ChildrenCharge.wav"},
    {key = "whistlecharge", label = "Dyre's Aggression: Bugle charge", pick = "WhistleCharge.wav"},
    {key = "rageattack", label = "Dyre's Aggression: Rage-filled attack", pick = "RageAttack.wav"},
    {key = "raspyshout", label = "Dyre's Aggression: Raspy angry shout", pick = "RaspyShout.wav"},
    {key = "angryscream", label = "Dyre's Aggression: Angry scream", pick = "AngryScream.wav"},
    {key = "orcangry", label = "Dyre's Aggression: Angry orc", pick = "OrcAngry.wav"},
    {key = "orcfury", label = "Dyre's Aggression: Orc spitting fury", pick = "OrcSpittingFury.wav"},
    -- Crit sounds (1.2.0; the same Envato license), for Dyre's Crit Mayhem's
    -- themes: gore, cartoon smacks and kisses, and blades.
    {key = "goreslice", label = "Dyre's Gore: Slice", pick = "GoreSlice.wav"},
    {key = "gorechop", label = "Dyre's Gore: Chop", pick = "GoreChop.wav"},
    {key = "gorebash", label = "Dyre's Gore: Bash", pick = "GoreBash.wav"},
    {key = "goresplat", label = "Dyre's Gore: Splat", pick = "GoreSplat.wav"},
    {key = "gorebloody", label = "Dyre's Gore: Bloody impact", pick = "GoreBloodyImpact.wav"},
    {key = "wetsplat", label = "Dyre's Gore: Wet splat hit", pick = "WetSplatHit.wav"},
    {key = "wetpunch", label = "Dyre's Gore: Wet face punch", pick = "WetFacePunch.wav"},
    {key = "wetslap", label = "Dyre's Smacks: Wet slap", pick = "WetSlap.wav"},
    {key = "swishsmack", label = "Dyre's Smacks: Swish smack", pick = "SwishSmack.wav"},
    {key = "kiss", label = "Dyre's Smacks: Kiss", pick = "Kiss.wav"},
    {key = "kisses", label = "Dyre's Smacks: Kisses", pick = "Kisses.wav"},
    {key = "swordswipe", label = "Dyre's Blades: Sword swipe", pick = "SwordSwipe.wav"},
    {key = "swordcut", label = "Dyre's Blades: Sword cut", pick = "SwordCut.wav"},
    {key = "laserswing", label = "Dyre's Blades: Laser sword swing", pick = "LaserSwordSwing.wav"},
    -- The client's interface sounds, by SOUNDKIT name, then the Cooldown
    -- Manager's alert sounds by kit ID in its categories, generated from the
    -- pinned Blizzard_CooldownViewer/CooldownViewerSoundAlertData.lua (as in
    -- Mage Tools Forever's and Warlock Tools Forever's chimes).
    {key = "mapping", label = "Interface: Map ping", kit = "MAP_PING"},
    {key = "whisper", label = "Interface: Whisper", kit = "TELL_MESSAGE"},
    {key = "invite", label = "Interface: Group invite", kit = "IG_PLAYER_INVITE"},
    {key = "readycheck", label = "Interface: Ready check", kit = "READY_CHECK"},
    {key = "raidwarning", label = "Interface: Raid warning", kit = "RAID_WARNING"},
    {key = "toast", label = "Interface: Friend toast", kit = "UI_BNET_TOAST"},
    {key = "talent", label = "Interface: Talent ready", kit = "UI_ORDERHALL_TALENT_READY_TOAST"},
    {key = "click", label = "Interface: Soft click", kit = "UI_IG_STORE_PAGE_NAV_BUTTON"},
    {key = "auction", label = "Interface: Auction bell", kit = "AUCTION_WINDOW_OPEN"},
    {key = "alarm", label = "Interface: Alarm clock", kit = "ALARM_CLOCK_WARNING_2"},
    {key = "animalscat", label = "Animals: Cat", id = 316401},
    {key = "animalschicken", label = "Animals: Chicken", id = 316406},
    {key = "animalscow", label = "Animals: Cow", id = 316407},
    {key = "animalsgnoll", label = "Animals: Gnoll", id = 316409},
    {key = "animalsgoat", label = "Animals: Goat", id = 316715},
    {key = "animalslion", label = "Animals: Lion", id = 316411},
    {key = "animalspanther", label = "Animals: Panther", id = 316412},
    {key = "animalsrattlesnake", label = "Animals: Rattlesnake", id = 316413},
    {key = "animalssheep", label = "Animals: Sheep", id = 316414},
    {key = "animalswolf", label = "Animals: Wolf", id = 316415},
    {key = "devicesboathorn", label = "Devices: Boat Horn", id = 316442},
    {key = "devicesairhorn", label = "Devices: Air Horn", id = 316436},
    {key = "devicesbikehorn", label = "Devices: Bike Horn", id = 316713},
    {key = "devicescashregister", label = "Devices: Cash Register", id = 316446},
    {key = "devicesjackpotbell", label = "Devices: Jackpot Bell", id = 316717},
    {key = "devicesjackpotcoins", label = "Devices: Jackpot Coins", id = 316718},
    {key = "devicesjackpotfail", label = "Devices: Jackpot Fail", id = 316719},
    {key = "devicesrotaryphonedial", label = "Devices: Rotary Phone Dial", id = 316433},
    {key = "devicesrotaryphonering", label = "Devices: Rotary Phone Ring", id = 316492},
    {key = "devicesstovepipe", label = "Devices: Stove Pipe", id = 316425},
    {key = "devicestrashcanlid", label = "Devices: Trashcan Lid", id = 316430},
    {key = "impactsanvilstrike", label = "Impacts: Anvil Strike", id = 316528},
    {key = "impactsbubblesmash", label = "Impacts: Bubble Smash", id = 316419},
    {key = "impactslowthud", label = "Impacts: Low Thud", id = 316531},
    {key = "impactsmetalclanks", label = "Impacts: Metal Clanks", id = 316532},
    {key = "impactsmetalrattle", label = "Impacts: Metal Rattle", id = 316486},
    {key = "impactsmetalscrape", label = "Impacts: Metal Scrape", id = 316484},
    {key = "impactsmetalwarble", label = "Impacts: Metal Warble", id = 316536},
    {key = "impactspopclick", label = "Impacts: Pop Click", id = 316434},
    {key = "impactsstrangeclang", label = "Impacts: Strange Clang", id = 316453},
    {key = "impactsswordscrape", label = "Impacts: Sword Scrape", id = 316535},
    {key = "instrumentsbellring", label = "Instruments: Bell Ring", id = 316493},
    {key = "instrumentsbelltrill", label = "Instruments: Bell Trill", id = 316712},
    {key = "instrumentsbrass", label = "Instruments: Brass", id = 316722},
    {key = "instrumentschimeascending", label = "Instruments: Chime Ascending", id = 316447},
    {key = "instrumentsguitarchug", label = "Instruments: Guitar Chug", id = 316477},
    {key = "instrumentsguitarpinch", label = "Instruments: Guitar Pinch", id = 316482},
    {key = "instrumentspitchpipedistressed", label = "Instruments: Pitch Pipe Distressed", id = 316509},
    {key = "instrumentspitchpipenote", label = "Instruments: Pitch Pipe Note", id = 316501},
    {key = "instrumentssynthbig", label = "Instruments: Synth Big", id = 316540},
    {key = "instrumentssynthbuzz", label = "Instruments: Synth Buzz", id = 316476},
    {key = "instrumentssynthhigh", label = "Instruments: Synth High", id = 316460},
    {key = "instrumentswarhorn", label = "Instruments: Warhorn", id = 316723},
    -- No "Short" group: Blizzard's Cooldown Manager lists its sound kits
    -- (353387-353428), but Forever's client has none of them (found in
    -- client: PlaySound(353392) plays nothing; Impacts' 316434 plays).
    -- They were silent there already, so they are dropped (author).
    {key = "war2abstractwhoosh", label = "Warcraft 2: Abstract Whoosh", id = 316731},
    {key = "war2choir", label = "Warcraft 2: Choir", id = 316733},
    {key = "war2construction", label = "Warcraft 2: Construction", id = 316735},
    {key = "war2magicchimes", label = "Warcraft 2: Magic Chimes", id = 316736},
    {key = "war2pigsqueal", label = "Warcraft 2: Pig Squeal", id = 316745},
    {key = "war2saws", label = "Warcraft 2: Saws", id = 316738},
    {key = "war2seal", label = "Warcraft 2: Seal", id = 316746},
    {key = "war2slow", label = "Warcraft 2: Slow", id = 316748},
    {key = "war2smith", label = "Warcraft 2: Smith", id = 316749},
    {key = "war2synthstinger", label = "Warcraft 2: Synth Stinger", id = 316739},
    {key = "war2trumpetrally", label = "Warcraft 2: Trumpet Rally", id = 316740},
    {key = "war2zippymagic", label = "Warcraft 2: Zippy Magic", id = 316737},
    {key = "war3bell", label = "Warcraft 3: Bell", id = 316773},
    {key = "war3crunchybell", label = "Warcraft 3: Crunchy Bell", id = 316774},
    {key = "war3drumsplash", label = "Warcraft 3: Drum Splash", id = 316768},
    {key = "war3error", label = "Warcraft 3: Error", id = 316775},
    {key = "war3fanfare", label = "Warcraft 3: Fanfare", id = 316769},
    {key = "war3gateopen", label = "Warcraft 3: Gate Open", id = 316776},
    {key = "war3gold", label = "Warcraft 3: Gold", id = 316770},
    {key = "war3magicshimmer", label = "Warcraft 3: Magic Shimmer", id = 316778},
    {key = "war3ringout", label = "Warcraft 3: Ringout", id = 316771},
    {key = "war3rooster", label = "Warcraft 3: Rooster", id = 316765},
    {key = "war3shimmerbell", label = "Warcraft 3: Shimmer Bell", id = 316779},
    {key = "war3wolfhowl", label = "Warcraft 3: Wolf Howl", id = 316766},
    -- Demon chirps and laughs by file ID, from the game's sound files as
    -- Leatrix Sounds lists them for this client (as in Warlock Tools Forever's
    -- Nightfall sound).
    {key = "implaugh1", label = "Imp: Laugh 1", fileID = 639142},
    {key = "implaugh2", label = "Imp: Laugh 2", fileID = 639144},
    {key = "implaugh3", label = "Imp: Laugh 3", fileID = 639146},
    {key = "implaugh4", label = "Imp: Laugh 4", fileID = 639148},
    {key = "implaugh5", label = "Imp: Laugh 5", fileID = 639150},
    {key = "implaugh6", label = "Imp: Laugh 6", fileID = 639152},
    {key = "implaugh7", label = "Imp: Laugh 7", fileID = 639154},
    {key = "impfunny", label = "Imp: Chuckle", fileID = 639140},
    {key = "impattack1", label = "Imp: Attack chirp 1", fileID = 639100},
    {key = "impattack2", label = "Imp: Attack chirp 2", fileID = 639104},
    {key = "impspell", label = "Imp: Spell chirp", fileID = 639156},
    {key = "hellishimp1", label = "Hellish imp: Cackle 1", fileID = 1281685},
    {key = "hellishimp2", label = "Hellish imp: Cackle 2", fileID = 1281691},
    -- The game's text-to-speech says the caller's text, last as in the
    -- Cooldown Manager's menu.
    {key = "voice", label = "Text to Speech", voice = true},
}

-- Keys the AddOns saved before this library, mapped to its keys.
ns.ALIASES = {popclick = "impactspopclick"}
ns.ALIASES.effectfadingslow = "fadingslow"
ns.ALIASES.pickfadingslow = "fadingslow"
ns.ALIASES.effectblowswoosh = "blowswoosh"
ns.ALIASES.pickblowswoosh = "blowswoosh"
ns.ALIASES.effectcartoonvanish = "cartoonvanish"
ns.ALIASES.pickcartoonvanish = "cartoonvanish"
ns.ALIASES.effectdisappear = "disappear"
ns.ALIASES.pickdisappear = "disappear"
ns.ALIASES.effectmagical = "magical"
ns.ALIASES.pickmagical = "magical"
ns.ALIASES.effectdisappearshort = "disappearshort"
ns.ALIASES.pickdisappearshort = "disappearshort"
ns.ALIASES.effectdisappearingswoosh = "disappearingswoosh"
ns.ALIASES.pickdisappearingswoosh = "disappearingswoosh"
ns.ALIASES.effectteleportvanish = "teleportvanish"
ns.ALIASES.pickteleportvanish = "teleportvanish"
ns.ALIASES.effectslowswoosh = "slowswoosh"
ns.ALIASES.pickslowswoosh = "slowswoosh"
