-- Lua 5.1 mock suite for Dyre's Sounds. Run from the repository root:
--   lua5.1 tests/run.lua
-- Mocks cannot prove what the client plays; TESTING.md lists in-client checks.

if _VERSION ~= "Lua 5.1" then
    io.stderr:write("This suite requires Lua 5.1; found " .. tostring(_VERSION) .. "\n")
    os.exit(1)
end

local ADDON = "DyresSounds"
local tests = {}

local function test(name, body)
    tests[#tests + 1] = {name = name, body = body}
end

local function equal(actual, expected, context)
    if actual ~= expected then
        error((context and context .. ": " or "") .. "expected " .. tostring(expected) .. ", got "
            .. tostring(actual), 2)
    end
end

local function tocFiles()
    local files = {}
    for line in io.lines(ADDON .. ".toc") do
        if line:match("%S") and not line:match("^#") then
            files[#files + 1] = line
        end
    end
    return files
end

-- A fresh client mock and a fresh load of the AddOn. options.voice gives the
-- client a text-to-speech voice; options.remove drops globals.
local function fixture(options)
    options = options or {}
    local state = {played = {}, kits = {}, spoken = {}}
    local env = setmetatable({}, {__index = _G})
    env._G = env
    env.SOUNDKIT = {MAP_PING = 3175, TELL_MESSAGE = 3081, IG_PLAYER_INVITE = 880, READY_CHECK = 8960,
        RAID_WARNING = 8959, UI_BNET_TOAST = 18019, UI_ORDERHALL_TALENT_READY_TOAST = 73280,
        AUCTION_WINDOW_OPEN = 5274, ALARM_CLOCK_WARNING_2 = 12867}
    env.PlaySoundFile = function(file, channel) state.played[#state.played + 1] = {file = file, channel = channel} end
    env.PlaySound = function(kit, channel) state.kits[#state.kits + 1] = {kit = kit, channel = channel} end
    if options.voice then
        env.C_VoiceChat = {
            SpeakText = function(voiceID, text) state.spoken[#state.spoken + 1] = {voice = voiceID, text = text} end,
            GetTtsVoices = function() return {{voiceID = 7}} end,
        }
    end
    -- Settings: a dropdown initializer whose InitFrame the menu wraps.
    env.Settings = {
        CreateControlTextContainer = function()
            local container = {data = {}}
            function container:Add(value, label) self.data[#self.data + 1] = {value = value, label = label} end
            function container:GetData() return self.data end
            return container
        end,
        InitDropdown = function(button, setting, inserter)
            state.inserted = {button = button, setting = setting, inserter = inserter}
            state.inits = (state.inits or 0) + 1
        end,
    }
    -- The client's secure hook: the original runs first, then the hook.
    env.hooksecurefunc = function(object, name, hook)
        local original = object[name]
        object[name] = function(...)
            local results = {original(...)}
            hook(...)
            return unpack(results)
        end
        state.hooks = (state.hooks or 0) + 1
    end
    env.WOW_PROJECT_CLASSIC, env.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 2, 5
    env.WOW_PROJECT_ID = options.project or 1
    for _, name in ipairs(options.remove or {}) do env[name] = nil end
    local ns = {}
    for _, path in ipairs(tocFiles()) do
        local chunk = assert(loadfile(path))
        setfenv(chunk, env)
        chunk(ADDON, ns)
    end
    state.env, state.lib = env, env.DyresSounds
    return state
end

-- A menu description as the client's menu API builds it.
local function menuRoot()
    local function node(text)
        local item = {text = text, entries = {}}
        function item:CreateButton(label)
            local child = node(label)
            self.entries[#self.entries + 1] = child
            return child
        end
        function item:CreateRadio(label, isSelected, setSelected, data)
            self.entries[#self.entries + 1] = {text = label, isSelected = isSelected, setSelected = setSelected,
                data = data}
        end
        return item
    end
    return node("root")
end

local function names(list)
    local out = {}
    for _, item in ipairs(list) do out[#out + 1] = item.name or item.text or item.label end
    return table.concat(out, ",")
end

-- The catalog ---------------------------------------------------------------------

test("the library is the global DyresSounds behind a contract", function()
    local lib = fixture().lib
    equal(lib.RequireContract(1), lib)
    equal(lib.RequireContract(2), nil, "a newer contract than this library offers")
    equal(lib.RequireContract("1"), nil)
end)
test("Dyre's Picks come first, then the game's groups; keys are unique", function()
    local lib = fixture({voice = true}).lib
    equal(names(lib.Groups()), "Dyre's Picks,Dyre's Speed,Dyre's Cats,Dyre's Bears,Dyre's Water,Dyre's Aggression,Dyre's Gore,Dyre's Smacks,Dyre's Blades,Dyre's Sax,Dyre's Bassoon,Dyre's Fel Sounds,Dyre's Alerts,Dyre's Frosty,Interface,"
        .. "Imp,Hellish imp,Text to Speech")
    equal(#lib.Groups()[1].sounds, 9)
    equal(#lib.Groups()[2].sounds, 8, "Dyre's Speed")
    equal(#lib.Groups()[3].sounds, 5, "Dyre's Cats")
    equal(#lib.Groups()[4].sounds, 5, "Dyre's Bears")
    equal(#lib.Groups()[5].sounds, 4, "Dyre's Water")
    equal(#lib.Groups()[6].sounds, 25, "Dyre's Aggression: 11 shouts, 10 roars, 4 screams (1.6.0)")
    equal(#lib.Groups()[7].sounds, 7, "Dyre's Gore")
    equal(#lib.Groups()[8].sounds, 4, "Dyre's Smacks")
    equal(#lib.Groups()[9].sounds, 3, "Dyre's Blades")
    equal(#lib.Groups()[10].sounds, 8, "Dyre's Sax")
    equal(#lib.Groups()[11].sounds, 8, "Dyre's Bassoon")
    equal(#lib.Groups()[12].sounds, 4, "Dyre's Fel Sounds")
    equal(#lib.Groups()[13].sounds, 15, "Dyre's Alerts")
    equal(#lib.Groups()[14].sounds, 14, "Dyre's Frosty")
    local seen = {}
    for _, sound in ipairs(lib.List()) do
        equal(seen[sound.key], nil, "unique key " .. sound.key)
        seen[sound.key] = true
    end
    equal(#lib.List(), 76 + 15 + 9 + 13 + 1 + 14 + 14, "a SOUNDKIT name the client lacks, and the kit IDs (off for now), are left out")
end)
test("without a voice there is no Text to Speech", function()
    local lib = fixture().lib
    equal(lib.Find("voice").label, "Text to Speech")
    for _, group in ipairs(lib.Groups()) do
        equal(group.name ~= "Text to Speech", true)
    end
end)
test("keys saved before the library still find their sound", function()
    local lib = fixture().lib
    equal(lib.Resolve("effectmagical"), "magical", "MTF's and WTF's chime keys")
    equal(lib.Resolve("pickslowswoosh"), "slowswoosh", "WTF's Nightfall keys")
    equal(lib.Resolve("popclick"), "impactspopclick")
    equal(lib.Resolve("talent"), "talent")
    equal(lib.Resolve("kazoo"), nil)
    equal(lib.Resolve(nil), nil)
    equal(lib.Label("magical"), "Dyre's Picks: Magical disappear")
end)
test("the Short sounds (missing on Forever) are gone", function()
    local lib = fixture().lib
    equal(lib.Find("shortbellstrike"), nil)
    equal(lib.Resolve("shortbellstrike"), nil, "a saved Short key no longer resolves")
    for _, sound in ipairs(lib.List()) do
        equal(sound.label:find("^Short:") == nil, true, "no Short sound is offered")
    end
end)

-- Playing ---------------------------------------------------------------------------

test("each kind of sound plays the way the client accepts it", function()
    local state = fixture({voice = true})
    local lib = state.lib
    equal(lib.Play("magical"), true)
    equal(state.played[1].file, "Interface\\AddOns\\DyresSounds\\Sounds\\MagicalDisappear.mp3",
        "Dyre's Picks by this AddOn's path")
    equal(state.played[1].channel, "Master")
    lib.Play("impspell")
    equal(state.played[2].file, 639156, "imp sounds by file ID")
    lib.Play("talent", nil, "SFX")
    equal(state.kits[1].kit, 73280, "SOUNDKIT names")
    equal(state.kits[1].channel, "SFX")
    equal(lib.Play("impactspopclick"), false, "the Cooldown Manager's kit IDs: off for now")
    equal(#state.kits, 1)
    equal(lib.Play("voice", "Blink ready"), true)
    equal(state.spoken[1].text, "Blink ready")
    equal(lib.Play("voice"), false, "text-to-speech needs something to say")
    equal(lib.Play("kazoo"), false)
end)
test("aura sounds are files only: names for Dyre's Picks, IDs for game files", function()
    local lib = fixture().lib
    equal(lib.AuraSound("fadingslow").soundFileName, "Interface\\AddOns\\DyresSounds\\Sounds\\FadingSlowDisappear.mp3")
    equal(lib.AuraSound("hellishimp1").soundFileID, 1281685)
    equal(lib.AuraSound("talent"), nil, "a sound kit cannot be an aura sound")
    equal(lib.AuraSound("voice"), nil)
    equal(#lib.List("aura"), 76 + 13 + 15 + 14 + 14)
    equal(names(lib.Groups("aura")), "Dyre's Picks,Dyre's Speed,Dyre's Cats,Dyre's Bears,Dyre's Water,Dyre's Aggression,Dyre's Gore,Dyre's Smacks,Dyre's Blades,Dyre's Sax,Dyre's Bassoon,Dyre's Fel Sounds,Dyre's Alerts,Dyre's Frosty,Imp,Hellish imp")
end)
test("on Classic Era and Anniversary, only sounds the client plays are offered", function()
    for _, project in ipairs({2, 5}) do
        local state = fixture({project = project, voice = true})
        local lib = state.lib
        for _, sound in ipairs(lib.List()) do
            equal(sound.id == nil and sound.fileID == nil, true, "offered on " .. project .. ": " .. sound.key)
        end
        local groups = {}
        for _, group in ipairs(lib.Groups()) do groups[#groups + 1] = group.name end
        groups = table.concat(groups, ",")
        equal(groups:find("Impacts", 1, true), nil, "no Impacts group")
        equal(groups:find("Imp,", 1, true), nil, "no Imp group")
        equal(groups:find("Interface", 1, true) ~= nil, true, "the interface sounds stay")
        equal(groups:find("Dyre's Gore", 1, true) ~= nil, true, "Dyre's sounds stay")
        equal(lib.Playable("impactspopclick"), false)
        equal(lib.Playable("implaugh1"), false)
        equal(lib.Playable("talent"), true)
        equal(lib.Playable("goreslice"), true)
        equal(lib.Play("impactspopclick"), false, "a saved kit ID plays nothing and says so")
        equal(lib.Play("implaugh1"), false)
        equal(#state.kits + #state.played, 0)
        equal(lib.Play("talent"), true)
        equal(lib.Label("impactspopclick"), "Impacts: Pop Click", "still found, for its label")
    end
    local forever = fixture()
    equal(forever.lib.Playable("implaugh1"), true, "elsewhere the imp sounds stay")
    equal(forever.lib.Play("implaugh1"), true)
end)

test("the Cooldown Manager's kit-ID sounds are off everywhere for now", function()
    local state = fixture()
    local lib = state.lib
    for _, sound in ipairs(lib.List()) do
        equal(sound.id, nil, "offered: " .. sound.key)
    end
    local groups = {}
    for _, group in ipairs(lib.Groups()) do groups[#groups + 1] = group.name end
    groups = "," .. table.concat(groups, ",") .. ","
    for _, gone in ipairs({"Animals", "Devices", "Impacts", "Instruments", "Warcraft 2", "Warcraft 3"}) do
        equal(groups:find("," .. gone .. ",", 1, true), nil, gone)
    end
    equal(groups:find(",Imp,", 1, true) ~= nil, true, "the imp files stay")
    equal(lib.Playable("impactspopclick"), false)
    equal(lib.Play("war2choir"), false)
    equal(#state.kits, 0)
    equal(lib.Label("impactspopclick"), "Impacts: Pop Click", "a saved key keeps its label")
    equal(lib.Resolve("popclick"), "impactspopclick", "and its alias")
end)

test("without the sound APIs nothing is offered or played", function()
    local state = fixture({remove = {"PlaySoundFile", "PlaySound", "SOUNDKIT"}})
    equal(#state.lib.List(), 0)
    equal(state.lib.Play("magical"), false)
end)

-- The menu --------------------------------------------------------------------------

-- A pooled settings row frame as Blizzard's dropdown control builds it: its
-- InitDropdown sets up the plain list (Settings.InitDropdown) for the row it
-- draws now (GetElementData).
local function dropdownFrame(state)
    local frame = {Control = {Dropdown = {}}, blizzard = 0}
    function frame:GetElementData() return self.row end
    function frame:InitDropdown()
        self.blizzard = self.blizzard + 1
        state.env.Settings.InitDropdown(self.Control.Dropdown, nil, "plain")
    end
    return frame
end

-- A dropdown row's initializer: Blizzard's InitFrame draws it on a frame.
local function dropdownRow(setting)
    local initializer = {}
    function initializer:GetSetting() return setting end
    function initializer:InitFrame(frame)
        frame.row = self
        frame:InitDropdown()
    end
    return initializer
end

test("a dropdown gets the plain list and the nested menu, through secure hooks only", function()
    local state = fixture()
    local lib = state.lib
    local choices = lib.Choices("aura")()
    equal(#choices, 89 + 15 + 14 + 14)
    equal(choices[1].label, "Dyre's Picks: Fading slow disappear")
    local value = "magical"
    local setting = {GetValue = function() return value end, SetValue = function(_, v) value = v end}
    local initializer = dropdownRow(setting)
    local blizzardInitFrame = initializer.InitFrame
    lib.SetupMenu(initializer)
    equal(initializer.data.forceSteppersHidden, true, "no steppers through a menu of submenus")
    equal(initializer.getSelectionTextFunc, nil, "no function of ours is left on a pooled dropdown")
    local frame = dropdownFrame(state)
    local blizzardInitDropdown = frame.InitDropdown
    initializer:InitFrame(frame)
    equal(frame.blizzard, 1, "Blizzard's own setup still runs, first")
    equal(state.inserted.button, frame.Control.Dropdown)
    equal(type(state.inserted.inserter), "function", "then the nested menu replaces the plain list")
    local root = menuRoot()
    state.inserted.inserter(setting, root)
    equal(names(root.entries), "Dyre's Picks,Dyre's Speed,Dyre's Cats,Dyre's Bears,Dyre's Water,Dyre's Aggression,Dyre's Gore,Dyre's Smacks,Dyre's Blades,Dyre's Sax,Dyre's Bassoon,Dyre's Fel Sounds,Dyre's Alerts,Dyre's Frosty,Interface,"
        .. "Imp,Hellish imp")
    local picks = root.entries[1]
    equal(picks.entries[5].text, "Magical disappear", "names inside their group")
    equal(picks.entries[5].isSelected("magical"), true)
    picks.entries[1].setSelected(picks.entries[1].data)
    equal(value, "fadingslow")
    -- A value change sets the menu up again: the nested menu comes back.
    frame:InitDropdown()
    equal(type(state.inserted.inserter), "function")
    -- Blizzard's own row on the same pooled frame keeps Blizzard's plain list.
    frame.row = {}
    frame:InitDropdown()
    equal(state.inserted.inserter, "plain", "another row on the pooled frame keeps its own menu")
    -- Drawn again on the same frame: hooked once, not twice.
    local hooks = state.hooks
    initializer:InitFrame(frame)
    equal(state.hooks, hooks + 0, "the frame is hooked once")
    -- Nothing of ours is written on the pooled frame but the secure hook.
    for key in pairs(frame) do
        assert(key == "Control" or key == "blizzard" or key == "row" or key == "GetElementData"
            or key == "InitDropdown", "unexpected field on the pooled frame: " .. tostring(key))
    end
    assert(frame.InitDropdown ~= blizzardInitDropdown, "InitDropdown is the secure hook's wrapper")
    assert(initializer.InitFrame ~= blizzardInitFrame, "InitFrame is the secure hook's wrapper")
end)

test("without the client's menu hooks the plain list stays", function()
    local state = fixture()
    state.env.Settings.InitDropdown = nil
    local initializer = {InitFrame = function() end}
    state.lib.SetupMenu(initializer)
    equal(initializer.dyresSoundsMenu, nil)
    state.lib.SetupMenu(nil)
    local row = {InitFrame = function() end, data = {dropdownSetting = {}}}
    state.lib.SetupCheckboxMenu(row)
    equal(row.dyresSoundsMenu, nil, "a checkbox row keeps its plain list too")
    local noHooks = fixture()
    noHooks.env.hooksecurefunc = nil
    local plain = {InitFrame = function() end}
    noHooks.lib.SetupMenu(plain)
    equal(plain.dyresSoundsMenu, nil, "no hooksecurefunc: the plain list")
end)

-- A checkbox-dropdown row as Blizzard's control builds it: Init initializes the
-- dropdown with the plain list.
local function checkboxRow(soundSetting)
    local initializer = {data = {dropdownSetting = soundSetting, dropDownLabel = "Sound"}}
    function initializer:InitFrame(frame) frame:Init(self) end
    local dropdown = {}
    function dropdown:SetSelectionText(selectionFunc) self.selectionFunc = selectionFunc end
    local frame = {Control = {Dropdown = dropdown}, inits = 0}
    function frame.Control:SetSteppersShown(shown) self.steppers = shown end
    function frame:Init(row)
        self.inits = self.inits + 1
        self.Control:SetSteppersShown(true)
    end
    return initializer, frame, dropdown
end

test("a checkbox row gets the nested sound menu and no steppers, through a secure hook", function()
    local state = fixture()
    local value = "magical"
    local setting = {GetValue = function() return value end, SetValue = function(_, v) value = v end}
    local row, frame, dropdown = checkboxRow(setting)
    local blizzardInit = frame.Init
    state.lib.SetupCheckboxMenu(row, "aura")
    equal(row.getSelectionTextFunc, nil, "no function of ours is left on a pooled dropdown")
    row:InitFrame(frame)
    equal(frame.inits, 1, "Blizzard's Init still runs")
    equal(state.inserted.button, dropdown, "the nested menu is built after Init")
    equal(state.inserted.setting, setting)
    local root = menuRoot()
    state.inserted.inserter(setting, root)
    equal(names(root.entries), "Dyre's Picks,Dyre's Speed,Dyre's Cats,Dyre's Bears,Dyre's Water,Dyre's Aggression,Dyre's Gore,Dyre's Smacks,Dyre's Blades,Dyre's Sax,Dyre's Bassoon,Dyre's Fel Sounds,Dyre's Alerts,Dyre's Frosty,Imp,Hellish imp", "the filter is kept")
    equal(frame.Control.steppers, false, "no steppers through a menu of submenus")
    equal(dropdown.selectionFunc, nil, "no selection text function of ours")
    equal(frame.Init, blizzardInit, "the pooled frame's Init is never replaced")
end)

local failed = 0
for index, entry in ipairs(tests) do
    local ok, message = xpcall(entry.body, debug.traceback)
    if ok then
        print("ok " .. index .. " - " .. entry.name)
    else
        failed = failed + 1
        print("not ok " .. index .. " - " .. entry.name)
        print(message)
    end
end
print("")
print(#tests .. " tests: " .. (#tests - failed) .. " passed, " .. failed .. " failed")
print("Mock results do not establish in-client compatibility.")
if failed > 0 then
    os.exit(1)
end
