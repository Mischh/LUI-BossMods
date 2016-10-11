require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("PyrobaneHydroflux")

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_fire"] = "Pyrobane",
        ["unit.boss_water"] = "Hydroflux",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.boss_fire"] = "Pyroman",
        ["unit.boss_water"] = "Hydroflux",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.boss_fire"] = "Pyromagnus",
        ["unit.boss_water"] = "Hydroflux",
	}
)

function Mod:Setup()
	name("Datascape", "Pyrobane & Hydroflux", "Elemental Pairs")
	trigger("ALL", {"Pyrobane","Hydroflux"}, {"Pyroman","Hydroflux"}, {"Pyromagnus","Hydroflux"}, {continentId = 52, parentZoneId = 98, mapId = 118})
			
	unit("boss_fire", true, "afff2f2f", "unit.boss_fire", 1)
	unit("boss_water", true, "af1e90ff", "unit.boss_water", 2)
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated_Fire", self.L["unit.boss_fire"], true)
	onUnitCreated("BossCreated_Water", self.L["unit.boss_water"], true)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

function Mod:BossCreated_Fire(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_fire", tUnit, false, false, false)
end

function Mod:BossCreated_Water(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_water", tUnit, false, false, false)
end

Mod:new()