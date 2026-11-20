local _, ns = ...

-- The sound menu for a settings dropdown: a submenu per group and a
-- top-level entry for a sound with no group, as the Cooldown Manager's sound
-- picker (CooldownViewerUtil.BuildSoundMenus) builds it with the same menu
-- API.
--
-- Taint (1.7.2; a player's error, 2026-11-19: Blizzard's "Status Text"
-- setting failed with "attempt to compare a secret number value (execution
-- tainted by ...)"): the settings list pools its row frames and shares them
-- with Blizzard's own settings. Code here never replaces a method or writes a
-- field on those frames, and never leaves a function of ours on them (no
-- getSelectionTextFunc). It only adds secure hooks (hooksecurefunc): Blizzard's
-- code runs first, untainted, and the hook then rebuilds the menu only when
-- the row being drawn is one of ours. A Blizzard row on the same frame later
-- gets its own menu back from Blizzard's own setup. The dropdown shows the
-- chosen sound's name (the menu's own selection text), without its group.

local DyresSounds = ns.DyresSounds

-- Every sound by its full label: a dropdown's plain list, for
-- Settings.CreateDropdown, used when the nested menu cannot be set up.
function DyresSounds.Choices(filter)
    return function()
        local container = Settings.CreateControlTextContainer()
        for _, sound in ipairs(DyresSounds.List(filter)) do
            container:Add(sound.key, sound.label)
        end
        return container:GetData()
    end
end

local function MenuInserter(filter)
    return function(setting, rootDescription)
        local function IsSelected(key)
            return setting:GetValue() == key
        end
        local function SetSelected(key)
            setting:SetValue(key)
        end
        for _, group in ipairs(DyresSounds.Groups(filter)) do
            if #group.sounds == 1 and not DyresSounds.Parts(group.sounds[1]) then
                rootDescription:CreateRadio(group.sounds[1].label, IsSelected, SetSelected, group.sounds[1].key)
            else
                local submenu = rootDescription:CreateButton(group.name)
                for _, sound in ipairs(group.sounds) do
                    local _, name = DyresSounds.Parts(sound)
                    submenu:CreateRadio(name, IsSelected, SetSelected, sound.key)
                end
            end
        end
    end
end

-- Pooled frames hooked once each; kept here, never as a field on the frame.
local hooked = setmetatable({}, {__mode = "k"})

local function Call(object, method, ...)
    if type(object) == "table" and type(object[method]) == "function" then
        return object[method](object, ...)
    end
end

-- The plain dropdown row's menu, rebuilt as the nested menu when the row
-- drawn on `frame` now is one of ours; any other row is left alone.
local function NestDropdown(frame)
    local initializer = Call(frame, "GetElementData")
    local menu = type(initializer) == "table" and initializer.dyresSoundsMenu
    local dropdown = menu and type(frame.Control) == "table" and frame.Control.Dropdown
    if type(dropdown) ~= "table" then
        return
    end
    local setting = Call(initializer, "GetSetting")
    local initTooltip
    if type(Settings.CreateOptionsInitTooltip) == "function" then
        initTooltip = Settings.CreateOptionsInitTooltip(setting, Call(initializer, "GetName"),
            Call(initializer, "GetTooltip"), Call(initializer, "GetOptions"))
    end
    Settings.InitDropdown(dropdown, setting, MenuInserter(menu.filter), initTooltip)
end

local function CanHook(initializer)
    return type(initializer) == "table" and type(initializer.InitFrame) == "function"
        and type(hooksecurefunc) == "function"
        and type(Settings) == "table" and type(Settings.InitDropdown) == "function"
end

-- Turns a dropdown from Settings.CreateDropdown(..., DyresSounds.Choices(filter))
-- into the nested sound menu. filter "aura" lists only aura sounds. Without the
-- client's menu hooks the plain list stays.
function DyresSounds.SetupMenu(initializer, filter)
    if not CanHook(initializer) then
        return
    end
    initializer.dyresSoundsMenu = {filter = filter}
    initializer.data = initializer.data or {}
    -- A menu of submenus has no single list to step through.
    initializer.data.forceSteppersHidden = true
    hooksecurefunc(initializer, "InitFrame", function(_, frame)
        -- The control sets its menu up again on a value change (InitDropdown):
        -- hook that too, once per pooled frame.
        if type(frame) == "table" and not hooked[frame] and type(frame.InitDropdown) == "function" then
            hooked[frame] = true
            hooksecurefunc(frame, "InitDropdown", NestDropdown)
        end
        NestDropdown(frame)
    end)
end

-- A checkbox and its sound on one row: Blizzard's checkbox-dropdown control
-- (CreateSettingsCheckboxDropdownInitializer, as its Action Bars page uses).
-- That control's Init calls Settings.InitDropdown itself, so the nested menu
-- is built after it, from a secure hook on this row's InitFrame.
function DyresSounds.SetupCheckboxMenu(initializer, filter)
    if not CanHook(initializer)
        or type(initializer.data) ~= "table" or type(initializer.data.dropdownSetting) ~= "table" then
        return
    end
    initializer.dyresSoundsMenu = {filter = filter}
    local setting = initializer.data.dropdownSetting
    hooksecurefunc(initializer, "InitFrame", function(self, frame)
        local control = type(frame) == "table" and frame.Control
        local dropdown = type(control) == "table" and control.Dropdown
        if type(dropdown) ~= "table" then
            return
        end
        local initTooltip
        if type(Settings.CreateOptionsInitTooltip) == "function" then
            initTooltip = Settings.CreateOptionsInitTooltip(setting, self.data.dropDownLabel,
                self.data.dropDownTooltip, self.data.dropdownOptions)
        end
        Settings.InitDropdown(dropdown, setting, MenuInserter(filter), initTooltip)
        -- A menu of submenus has no single list to step through.
        Call(control, "SetSteppersShown", false)
    end)
end
