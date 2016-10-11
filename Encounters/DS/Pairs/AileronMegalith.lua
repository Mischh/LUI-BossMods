require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("AileronMegalith")

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_air"] = "Aileron",
        ["unit.boss_earth"] = "Megalith",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.boss_air"] = "Aileron",
        ["unit.boss_earth"] = "Megalith",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.boss_air"] = "Ventemort",
        ["unit.boss_earth"] = "Mégalithe",
	}
)

function Mod:Setup()
	name("Datascape", "Aileron & Megalith", "Elemental Pairs")
	trigger("ALL", {"Aileron","Megalith"}, {"Aileron","Megalith"}, {"Ventemort","Mégalithe"}, {continentId = 52, parentZoneId = 98, mapId = 118})
			
	unit("boss_air", true, "af00ffff", "unit.boss_air", 1)
	unit("boss_earth", true, "afff932f", "unit.boss_earth", 2)
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated_Air", self.L["unit.boss_air"], true)
	onUnitCreated("BossCreated_Earth", self.L["unit.boss_earth"], true)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

function Mod:BossCreated_Air(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_logic", tUnit, false, false, false)
end

function Mod:BossCreated_Earth(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_water", tUnit, false, false, false)
end

Mod:new()