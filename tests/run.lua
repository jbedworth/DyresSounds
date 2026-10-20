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
        end,
    }
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
    equal(names(lib.Groups()), "Dyre's Picks,Interface,Animals,Devices,Impacts,Instruments,"
        .. "Warcraft 2,Warcraft 3,Imp,Hellish imp,Text to Speech")
    equal(#lib.Groups()[1].sounds, 9)
    local seen = {}
    for _, sound in ipairs(lib.List()) do
        equal(seen[sound.key], nil, "unique key " .. sound.key)
        seen[sound.key] = true
    end
    equal(#lib.List(), 9 + 9 + 67 + 13 + 1, "a SOUNDKIT name the client lacks is left out")
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
    lib.Play("impactspopclick")
    equal(state.kits[2].kit, 316434, "the Cooldown Manager's kit IDs")
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
    equal(#lib.List("aura"), 9 + 13)
    equal(names(lib.Groups("aura")), "Dyre's Picks,Imp,Hellish imp")
end)
test("without the sound APIs nothing is offered or played", function()
    local state = fixture({remove = {"PlaySoundFile", "PlaySound", "SOUNDKIT"}})
    equal(#state.lib.List(), 0)
    equal(state.lib.Play("magical"), false)
end)

-- The menu --------------------------------------------------------------------------

test("a dropdown gets the plain list and the nested menu; other dropdowns keep theirs", function()
    local state = fixture()
    local lib = state.lib
    local choices = lib.Choices("aura")()
    equal(#choices, 22)
    equal(choices[1].label, "Dyre's Picks: Fading slow disappear")
    local value = "magical"
    local setting = {GetValue = function() return value end, SetValue = function(_, v) value = v end}
    local initializer = {data = nil}
    function initializer:GetSetting() return setting end
    function initializer:InitFrame(frame) frame.initialized = true end
    lib.SetupMenu(initializer)
    equal(initializer.data.forceSteppersHidden, true, "no steppers through a menu of submenus")
    equal(initializer.getSelectionTextFunc(), "Dyre's Picks: Magical disappear", "the full label shows")
    local blizzard = 0
    local frame = {SetupDropdownMenu = function() blizzard = blizzard + 1 end}
    initializer:InitFrame(frame)
    equal(frame.initialized, true)
    frame.SetupDropdownMenu(nil, "button", setting, nil, nil, {})
    equal(blizzard, 1, "another dropdown on the pooled control keeps Blizzard's menu")
    frame.SetupDropdownMenu(nil, "button", setting, nil, nil, initializer)
    equal(blizzard, 1)
    local root = menuRoot()
    state.inserted.inserter(setting, root)
    equal(names(root.entries), "Dyre's Picks,Interface,Animals,Devices,Impacts,Instruments,"
        .. "Warcraft 2,Warcraft 3,Imp,Hellish imp")
    local picks = root.entries[1]
    equal(picks.entries[5].text, "Magical disappear", "names inside their group")
    equal(picks.entries[5].isSelected("magical"), true)
    picks.entries[1].setSelected(picks.entries[1].data)
    equal(value, "fadingslow")
    initializer:InitFrame(frame)
    frame.SetupDropdownMenu(nil, "button", setting, nil, nil, {})
    equal(blizzard, 2, "wrapped once, even when the frame is reused")
end)
test("a pooled dropdown frame that showed a sound never keeps its label for another dropdown", function()
    local state = fixture()
    local value = "magical"
    local setting = {GetValue = function() return value end, SetValue = function(_, v) value = v end}
    local initializer = {}
    function initializer:GetSetting() return setting end
    function initializer:InitFrame() end
    state.lib.SetupMenu(initializer)
    -- Blizzard's dropdown: it stores the selection text function and never clears it.
    local dropdown = {}
    function dropdown:SetSelectionText(selectionFunc) self.selectionFunc = selectionFunc end
    local frame = {SetupDropdownMenu = function() end}
    initializer:InitFrame(frame)
    frame.SetupDropdownMenu(nil, dropdown, setting, nil, nil, initializer)
    dropdown:SetSelectionText(initializer.getSelectionTextFunc)
    equal(dropdown.selectionFunc(), "Dyre's Picks: Magical disappear", "the sound dropdown shows its full label")
    frame.SetupDropdownMenu(nil, dropdown, {}, nil, nil, {})
    equal(dropdown.selectionFunc, nil, "the next, plain dropdown on that frame does not show the sound's label")
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
end)

-- A checkbox-dropdown row as Blizzard's control builds it: Init initializes the
-- dropdown with the plain list; the dropdown stores its selection text function.
local function checkboxRow(soundSetting)
    local initializer = {data = {dropdownSetting = soundSetting, dropDownLabel = "Sound"}}
    function initializer:InitFrame(frame) frame:Init(self) end
    local dropdown = {}
    function dropdown:SetSelectionText(selectionFunc) self.selectionFunc = selectionFunc end
    function dropdown:GetMenuDescription() return "menu" end
    function dropdown:UpdateToMenuSelections(menu) self.updated = menu end
    local frame = {Control = {Dropdown = dropdown}, inits = 0}
    function frame.Control:SetSteppersShown(shown) self.steppers = shown end
    function frame:Init(row)
        self.inits = self.inits + 1
        if row.getSelectionTextFunc then dropdown:SetSelectionText(row.getSelectionTextFunc) end
        self.Control:SetSteppersShown(true)
    end
    return initializer, frame, dropdown
end

test("a checkbox row gets the nested sound menu, its full label, and no steppers", function()
    local state = fixture()
    local value = "magical"
    local setting = {GetValue = function() return value end, SetValue = function(_, v) value = v end}
    local row, frame, dropdown = checkboxRow(setting)
    state.lib.SetupCheckboxMenu(row, "aura")
    row:InitFrame(frame)
    equal(frame.inits, 1, "Blizzard's Init still runs")
    equal(state.inserted.button, dropdown, "the nested menu is built after Init")
    equal(state.inserted.setting, setting)
    local root = menuRoot()
    state.inserted.inserter(setting, root)
    equal(names(root.entries), "Dyre's Picks,Imp,Hellish imp", "the filter is kept")
    equal(dropdown.selectionFunc(), "Dyre's Picks: Magical disappear")
    equal(dropdown.updated, "menu", "the label is refreshed")
    equal(frame.Control.steppers, false, "no steppers through a menu of submenus")
end)
test("a pooled checkbox row that showed a sound never keeps its label for another row", function()
    local state = fixture()
    local value = "magical"
    local setting = {GetValue = function() return value end, SetValue = function(_, v) value = v end}
    local row, frame, dropdown = checkboxRow(setting)
    state.lib.SetupCheckboxMenu(row)
    row:InitFrame(frame)
    equal(dropdown.selectionFunc(), "Dyre's Picks: Magical disappear")
    local plain = {data = {}}
    frame:Init(plain)
    equal(dropdown.selectionFunc, nil, "another AddOn's checkbox row on that frame shows its own choice")
    row:InitFrame(frame)
    frame:Init(plain)
    equal(frame.inits, 4, "wrapped once, even when the frame is reused")
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
