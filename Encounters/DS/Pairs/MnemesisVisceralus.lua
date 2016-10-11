require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("MnemesisVisceralus")

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_logic"] = "Mnemesis",
        ["unit.boss_life"] = "Visceralus",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.boss_logic"] = "Mnemesis",
        ["unit.boss_life"] = "Viszeralus",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.boss_logic"] = "Mnémésis",
        ["unit.boss_life"] = "Visceralus",
	}
)

function Mod:Setup()
	name("Datascape", "Mnemesis & Visceralus", "Elemental Pairs")
	trigger("ALL", {"Mnemesis","Visceralus"}, {"Mnemesis","Viszeralus"}, {"Mnémésis","Visceralus"}, {continentId = 52, parentZoneId = 98,  mapId = 119})
			
	unit("boss_logic", true, "afadff2f", "unit.boss_logic", 1)
	unit("boss_life", true, "af228b22", "unit.boss_life", 2)
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated_Logic", self.L["unit.boss_logic"], true)
	onUnitCreated("BossCreated_Life", self.L["unit.boss_life"], true)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

function Mod:BossCreated_Logic(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_logic", tUnit, false, false, false)
end

function Mod:BossCreated_Life(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_life", tUnit, false, false, false)
end

Mod:new()