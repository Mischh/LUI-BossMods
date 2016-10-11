require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("PyrobaneVisceralus")

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_fire"] = "Pyrobane",
        ["unit.boss_life"] = "Visceralus",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.boss_fire"] = "Pyroman",
        ["unit.boss_life"] = "Viszeralus",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.boss_fire"] = "Pyromagnus",
        ["unit.boss_life"] = "Visceralus",
	}
)

function Mod:Setup()
	name("Datascape", "Pyrobane & Visceralus", "Elemental Pairs")
	trigger("ALL", {"Pyrobane","Visceralus"}, {"Pyroman","Viszeralus"}, {"Pyromagnus","Visceralus"}, {continentId = 52, parentZoneId = 98, mapId = 119})
	
	unit("boss_fire", true, "afff2f2f", "unit.boss_fire", 1)
	unit("boss_life", true, "af228b22", "unit.boss_life", 2)
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated_Fire", self.L["unit.boss_fire"], true)
	onUnitCreated("BossCreated_Life", self.L["unit.boss_life"], true)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

function Mod:BossCreated_Fire(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_fire", tUnit, false, false, false)
end

function Mod:BossCreated_Life(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_life", tUnit, false, false, false)
end

Mod:new()