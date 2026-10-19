local _, ns = ...

-- The sound menu for a settings dropdown: a submenu per group and a
-- top-level entry for a sound with no group, as the Cooldown Manager's sound
-- picker (CooldownViewerUtil.BuildSoundMenus) builds it with the same menu
-- API. Blizzard's settings dropdown builds its menu in its control's
-- SetupDropdownMenu; the control frames are pooled and shared with other
-- settings and AddOns (Mage Tools Forever and Warlock Tools Forever wrap them
-- too), so the replacement builds the nested menu only for a dropdown set up
-- here and hands every other one on.

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

local function NestedSetupDropdownMenu(original)
    return function(control, button, setting, options, initTooltip, initializer)
        local menu = initializer and initializer.dyresSoundsMenu
        if not menu then
            -- The frame is pooled: Blizzard sets a dropdown's selection text only
            -- when the initializer has getSelectionTextFunc and never clears it
            -- (SettingsDropdownControlMixin:InitDropdown), so a frame that once
            -- showed a sound would keep showing that sound's label (found in
            -- client). Blizzard sets it again after this for a dropdown that has one.
            if type(button) == "table" and type(button.SetSelectionText) == "function" then
                button:SetSelectionText(nil)
            end
            return original(control, button, setting, options, initTooltip, initializer)
        end
        Settings.InitDropdown(button, setting, MenuInserter(menu.filter), initTooltip)
    end
end

-- Turns a dropdown from Settings.CreateDropdown(..., DyresSounds.Choices(filter))
-- into the nested sound menu. filter "aura" lists only aura sounds. Without the
-- client's menu hooks the plain list stays.
function DyresSounds.SetupMenu(initializer, filter)
    if type(initializer) ~= "table" or type(initializer.InitFrame) ~= "function"
        or type(Settings) ~= "table" or type(Settings.InitDropdown) ~= "function" then
        return
    end
    initializer.dyresSoundsMenu = {filter = filter}
    initializer.data = initializer.data or {}
    -- A menu of submenus has no single list to step through.
    initializer.data.forceSteppersHidden = true
    -- The dropdown shows the full label, "Short: Bell Strike".
    initializer.getSelectionTextFunc = function()
        return DyresSounds.Label(initializer:GetSetting():GetValue()) or ""
    end
    local initFrame = initializer.InitFrame
    function initializer:InitFrame(frame)
        if type(frame.SetupDropdownMenu) == "function" and not frame.dyresSoundsNestedMenu then
            frame.dyresSoundsNestedMenu = true
            frame.SetupDropdownMenu = NestedSetupDropdownMenu(frame.SetupDropdownMenu)
        end
        return initFrame(self, frame)
    end
end
