require "Window"
require "Apollo"

local Mod = {}
local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Encounter = "PyrobaneHydroflux"

local Locales = {
    ["enUS"] = {
        -- Unit names
        ["unit.boss_fire"] = "Pyrobane",
        ["unit.boss_water"] = "Hydroflux",
        ["unit.ice_tomb"] = "Ice Tomb",
        ["unit.flame_wave"] = "Flame Wave",
        -- Texts
        ["text.next_bombs"] = "Next bombs",
        ["text.next_ice_tomb"] = "Next ice tomb",
        -- Labels
        ["label.bombs"] = "Bombs",
        ["label.ice_tomb"] = "Ice Tomb",
        ["label.flame_waves"] = "Flame Waves",
    },
    ["deDE"] = {
		-- Unit names
        ["unit.boss_fire"] = "Pyroman",
        ["unit.boss_water"] = "Hydroflux",
	},
    ["frFR"] = {
		-- Unit names
        ["unit.boss_fire"] = "Pyromagnus",
        ["unit.boss_water"] = "Hydroflux",
	},
}

local nLastBombTime = 0
local nLastIceTombTime = 0
local DEBUFF_FROSTBOMB = 75058
local DEBUFF_FIREBOMB = 75059
local DEBUFF_ICE_TOMB = 74326

function Mod:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.instance = "Datascape"
    self.displayName = "Pyrobane & Hydroflux"
    self.groupName = "Elemental Pairs"
    self.tTrigger = {
        sType = "ALL",
        tZones = {
            [1] = {
                continentId = 52,
                parentZoneId = 98,
                mapId = 118,
            },
        },
        tNames = {
            ["enUS"] = {"Pyrobane","Hydroflux"},
            ["deDE"] = {"Pyroman","Hydroflux"},
            ["frFR"] = {"Pyromagnus","Hydroflux"},
        },
    }
    self.run = false
    self.runtime = {}
    self.config = {
        enable = true,
        units = {
            boss_fire = {
                enable = true,
                label = "unit.boss_fire",
                color = "afff2f2f",
            },
            boss_water = {
                enable = true,
                label = "unit.boss_water",
                color = "af1e90ff",
            },
        },
        alerts = {
            bombs = {
                enable = true,
                duration = 3,
                label = "label.bombs",
            },
            ice_tomb = {
                enable = true,
                duration = 3,
                label = "label.ice_tomb",
            },
        },
        sounds = {
            bombs = {
                enable = true,
                file = "info",
                label = "label.bombs",
            },
            ice_tomb = {
                enable = true,
                file = "alert",
                label = "label.ice_tomb",
            },
        },
        timers = {
            bombs = {
                enable = true,
                color = "ade91dfb",
                text = "text.next_bombs",
                label = "label.bombs",
            },
            ice_tomb = {
                enable = true,
                color = "ade91dfb",
                text = "text.next_ice_tomb",
                label = "label.ice_tomb",
            },
        },
        lines = {
            flame_wave = {
                enable = true,
                thickness = 10,
                color = "ffff0000",
                label = "label.flame_waves",
            },
        },
    }
    return o
end

function Mod:Init(parent)
    Apollo.LinkAddon(parent, self)

    self.core = parent
    self.L = parent:GetLocale(Encounter,Locales)
end

function Mod:OnUnitCreated(nId, tUnit, sName, bInCombat)
    if not self.run == true then
        return
    end

    if sName == self.L["unit.boss_fire"] then
        self.core:AddUnit(nId,sName,tUnit,self.config.units.boss_fire)
    elseif sName == self.L["unit.boss_water"] then
        self.core:AddUnit(nId,sName,tUnit,self.config.units.boss_water)
    elseif sName == self.L["unit.flame_wave"] then
        self.core:DrawLine(nId, tUnit, self.config.lines.flame_wave, 20)
    end
end

function Mod:OnUnitDestroyed(nId, tUnit, sName)
    if sName == self.L["unit.flame_wave"] then
        self.core:RemoveLine(nId)
    end
end

function Mod:OnBuffAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
    if nSpellId == DEBUFF_FIREBOMB or nSpellId == DEBUFF_FROSTBOMB then
        local nCurrentTime = GameLib.GetGameTime()
        if nCurrentTime - nLastBombTime > 10 then
            nLastBombTime = nCurrentTime
            self.core:AddTimer("BOMBS", self.L["message.bombs"], 30, self.config.timers.bombs)
        end
    elseif nSpellId == DEBUFF_ICE_TOMB then
        local nCurrentTime = GameLib.GetGameTime()
        if nCurrentTime - nLastIceTombTime > 5 then
            nLastIceTombTime = nCurrentTime
            self.core:AddTimer("ICE_TOMB", self.L["message.ice_tomb"], 15, self.config.timers.ice_tomb)
        end
    end
end

function Mod:IsRunning()
    return self.run
end

function Mod:IsEnabled()
    return self.config.enable
end

function Mod:OnEnable()
    self.run = true
    nLastIceTombTime = 0
    nLastBombTime = 0

    self.core:AddTimer("BOMBS", self.L["message.bombs"], 30, self.config.timers.bombs)
    self.core:AddTimer("ICE_TOMB", self.L["message.ice_tomb"], 26, self.config.timers.ice_tomb)
end

function Mod:OnDisable()
    self.run = false
end

local ModInst = Mod:new()
LUI_BossMods.modules[Encounter] = ModInst
