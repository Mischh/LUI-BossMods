require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("PyrobaneMegalith")

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_fire"] = "Pyrobane",
        ["unit.boss_earth"] = "Megalith",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.boss_fire"] = "Pyroman",
        ["unit.boss_earth"] = "Megalith",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.boss_fire"] = "Pyromagnus",
        ["unit.boss_earth"] = "Mégalithe",
	}
)

function Mod:Setup()
	name("Datascape", "Pyrobane & Megalith", "Elemental Pairs")
	trigger("ALL", {"Pyrobane","Megalith"}, {"Pyroman","Megalith"}, {"Pyromagnus","Mégalithe"}, {continentId = 52, parentZoneId = 98, mapId = 117})
	
	unit("boss_fire", true, "afff2f2f", "unit.boss_fire", 1)
	unit("boss_earth", true, "afff932f", "unit.boss_earth", 2)
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated_Fire", self.L["unit.boss_fire"], true)
	onUnitCreated("BossCreated_Earth", self.L["unit.boss_earth"], true)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

function Mod:BossCreated_Fire(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_fire", tUnit, false, false, false)
end

function Mod:BossCreated_Earth(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_earth", tUnit, false, false, false)
end

Mod:new()