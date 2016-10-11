require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("MnemesisHydroflux")

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_logic"] = "Mnemesis",
        ["unit.boss_water"] = "Hydroflux",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.boss_logic"] = "Mnemesis",
        ["unit.boss_water"] = "Hydroflux",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.boss_logic"] = "Mnémésis",
        ["unit.boss_water"] = "Hydroflux",
	}
)

function Mod:Setup()
	name("Datascape", "Mnemesis & Hydroflux", "Elemental Pairs")
	trigger("ALL", {"Mnemesis","Hydroflux"}, {"Mnemesis","Hydroflux"}, {"Mnémésis","Hydroflux"}, {continentId = 52, parentZoneId = 98, mapId = 118})
			
	unit("boss_logic", true, "afadff2f", "unit.boss_logic", 1)
	unit("boss_water", true, "af1e90ff", "unit.boss_water", 2)
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated_Logic", self.L["unit.boss_logic"], true)
	onUnitCreated("BossCreated_Water", self.L["unit.boss_water"], true)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

function Mod:BossCreated_Logic(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_logic", tUnit, false, false, false)
end

function Mod:BossCreated_Water(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_water", tUnit, false, false, false)
end

Mod:new()