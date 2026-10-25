local addonName, ns = ...

-- Dyre's Sounds: the sounds and the sound menu that Dyre's AddOns share, as a
-- library AddOn they list as an optional dependency (author-approved, like
-- QuestieDB). Its whole interface is the global DyresSounds, reached through
-- RequireContract, so a dependent AddOn can tell an older library apart.

-- Raised when the interface changes in a way a dependent must know about.
local CONTRACT = 1
local SOUND_FOLDER = "Interface\\AddOns\\" .. addonName .. "\\Sounds\\"
local DEFAULT_CHANNEL = "Master"
-- Text-to-speech volume when the player's setting cannot be read.
local DEFAULT_SPEECH_VOLUME = 100

local DyresSounds = {CONTRACT = CONTRACT}
ns.DyresSounds = DyresSounds

local byKey = {}
for _, sound in ipairs(ns.CATALOG) do
    byKey[sound.key] = sound
end

-- The library's interface when it offers at least this contract, else nil.
function DyresSounds.RequireContract(minimum)
    if type(minimum) == "number" and minimum <= CONTRACT then
        return DyresSounds
    end
    return nil
end

-- A sound by key, also by a key an AddOn saved before this library.
function DyresSounds.Find(key)
    if type(key) ~= "string" then
        return nil
    end
    return byKey[ns.ALIASES[key] or key]
end

-- A saved key mapped to the library's own, so callers save one spelling.
function DyresSounds.Resolve(key)
    local sound = DyresSounds.Find(key)
    return sound and sound.key
end

function DyresSounds.Label(key)
    local sound = DyresSounds.Find(key)
    return sound and sound.label
end

-- A sound's group and its name within it, from its label "Group: Name"; a
-- sound without a group returns nil and its label.
function DyresSounds.Parts(sound)
    local group, name = sound.label:match("^(.-): (.+)$")
    return group, name or sound.label
end

local function SoundKit(sound)
    if sound.id then
        return sound.id
    end
    if sound.kit and type(SOUNDKIT) == "table" and type(SOUNDKIT[sound.kit]) == "number" then
        return SOUNDKIT[sound.kit]
    end
end

local function SoundFile(sound)
    if sound.pick then
        return SOUND_FOLDER .. sound.pick
    end
    return sound.fileID
end

-- The game's text-to-speech voice the player chose, else the first one.
local function SpeechVoice()
    if type(C_VoiceChat) ~= "table" or type(C_VoiceChat.SpeakText) ~= "function" then
        return nil
    end
    if type(C_TTSSettings) == "table" and type(C_TTSSettings.GetVoiceOptionID) == "function"
        and type(Enum) == "table" and type(Enum.TtsVoiceType) == "table" then
        local voiceID = C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard)
        if type(voiceID) == "number" then
            return voiceID
        end
    end
    local voices = type(C_VoiceChat.GetTtsVoices) == "function" and C_VoiceChat.GetTtsVoices()
    local first = type(voices) == "table" and voices[1]
    return type(first) == "table" and first.voiceID or nil
end

-- Classic Era and Anniversary play neither the Cooldown Manager's sound kits
-- (id) nor the creature sound files (fileID), though the code naming them is
-- in their UI (found in client, author: every Animals through Hellish imp
-- sound is silent on Era, also in previews). Their own sounds, the interface
-- kits and the Dyre's sound files, play. Read once at load: the project
-- never changes in a session.
local CLASSIC = type(WOW_PROJECT_ID) == "number"
    and (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)

-- The Cooldown Manager's kit-ID sounds are off on every client for now
-- (author, 1.2.0: on Forever they "played intermittently or not at all";
-- "drop them on forever until we can test/debug further"). They stay in the
-- catalog, so a saved key keeps its label; set this to true to offer them.
local KIT_ID_SOUNDS = false

-- Whether this client can play the sound at all.
local function Silent(sound)
    return (sound.id and (CLASSIC or not KIT_ID_SOUNDS)) or (CLASSIC and sound.fileID) or false
end

local function Available(sound)
    if Silent(sound) then
        return false
    end
    if sound.voice then
        return SpeechVoice() ~= nil
    end
    if SoundFile(sound) then
        return type(PlaySoundFile) == "function"
    end
    return type(PlaySound) == "function" and SoundKit(sound) ~= nil
end

-- filter "aura": only sounds C_UnitAuras.AddAuraSound can play (files).
local function Matches(sound, filter)
    return filter ~= "aura" or SoundFile(sound) ~= nil
end

-- The sounds this client can play, in menu order.
function DyresSounds.List(filter)
    local list = {}
    for _, sound in ipairs(ns.CATALOG) do
        if Matches(sound, filter) and Available(sound) then
            list[#list + 1] = sound
        end
    end
    return list
end

-- The sounds as ordered groups for a nested menu: {{name, sounds}, ...}.
function DyresSounds.Groups(filter)
    local groups, byName = {}, {}
    for _, sound in ipairs(DyresSounds.List(filter)) do
        local group = DyresSounds.Parts(sound) or sound.label
        if not byName[group] then
            byName[group] = {name = group, sounds = {}}
            groups[#groups + 1] = byName[group]
        end
        local sounds = byName[group].sounds
        sounds[#sounds + 1] = sound
    end
    return groups
end

-- Whether this client can play the sound: one a saved key names may be in
-- the catalog but silent here (Classic), so a caller can choose another.
function DyresSounds.Playable(key)
    local sound = DyresSounds.Find(key)
    return sound ~= nil and Available(sound)
end

-- Plays a sound once. speech is what a text-to-speech sound says. Returns
-- true when the client was asked to play it; false for a sound this client
-- cannot play.
function DyresSounds.Play(key, speech, channel)
    local sound = DyresSounds.Find(key)
    if not sound or Silent(sound) then
        return false
    end
    channel = channel or DEFAULT_CHANNEL
    if sound.voice then
        local voiceID = SpeechVoice()
        if not voiceID or type(speech) ~= "string" then
            return false
        end
        local settings = type(C_TTSSettings) == "table" and C_TTSSettings
        local rate = settings and type(settings.GetSpeechRate) == "function" and settings.GetSpeechRate() or 0
        local volume = settings and type(settings.GetSpeechVolume) == "function" and settings.GetSpeechVolume()
            or DEFAULT_SPEECH_VOLUME
        C_VoiceChat.SpeakText(voiceID, speech, rate, volume, true)
        return true
    end
    local file = SoundFile(sound)
    if file then
        if type(PlaySoundFile) ~= "function" then
            return false
        end
        PlaySoundFile(file, channel)
        return true
    end
    local kit = SoundKit(sound)
    if kit and type(PlaySound) == "function" then
        PlaySound(kit, channel)
        return true
    end
    return false
end

-- The sound fields for C_UnitAuras.AddAuraSound's UnitAuraSoundInfo, or nil
-- for a sound that is not a file (a sound kit or text-to-speech).
function DyresSounds.AuraSound(key)
    local sound = DyresSounds.Find(key)
    local file = sound and SoundFile(sound)
    if type(file) == "number" then
        return {soundFileID = file}
    elseif file then
        return {soundFileName = file}
    end
    return nil
end

_G.DyresSounds = DyresSounds
