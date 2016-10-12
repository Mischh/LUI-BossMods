require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("Kuralak")

--Localize some of your Variables.
--These will be accessible from self.L, NOT within Mod:Setup(), but everywhere else.
Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.kuralak"] = "Kuralak the Defiler",
		["msg.kuralak_returns"] = "Kuralak the Defiler returns to the Archive Core",
		
		["label.vanish"] = "Vanish",
		["label.egg"] = "Eggs",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.kuralak"] = "Kuralak die Schänderin",
		["msg.kuralak_returns"] = "Kuralak die Schänderin kehrt zum Archivkern zurück, um wieder zu Kräften zu kommen.",
		
		["label.vanish"] = "Verstecken",
		["label.egg"] = "Eier",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.kuralak"] = "Kuralak la Profanatrice",
		["msg.kuralak_returns"] = "Kuralak la Profanatrice retourne au Noyau d'accès aux archives pour reprendre des forces",
		
		
		["label.vanish"] = "Vanish",
		["label.egg"] = "Eggs",
	}
)
local DEBUFFID_CHROMOSOME_CORRUPTION = 56652

function Mod:Setup()
	name("Genetic Archives", "Kuralak")
	trigger("ALL", {"Kuralak the Defiler"}, {"Kuralak die Schänderin"}, {"Kuralak la Profanatrice"}, {continentId = 67, parentZoneId = 147, mapId = 148})
	
	unit("kuralak", true, nil, "unit.kuralak", 1)
	timer("timer_vanish", true, nil, "label.vanish", false, false, 1)
	icon("icon_egg", true, "target", 30, "ffff0000", "label.egg", 1)
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated", self.L["unit.kuralak"], true)
	onUnitDestroyed("BossDestroyed", self.L["unit.kuralak"])
	
	onDatachron("Vanish_Msg", self.L["msg.kuralak_returns"])
	
	onBuffAdded("EggAdded", nil, nil, DEBUFFID_CHROMOSOME_CORRUPTION)
	
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

function Mod:BossCreated(nId, tUnit, sName, bInCombat)
	self:AddUnit("kuralak", tUnit, false, false, false)
end

function Mod:BossDestroyed(nId, tUnit, sName)
	self:RemoveUnit("kuralak")
end

function Mod:Vanish_Msg()
	self:AddTimer("timer_vanish", 47)
end

function Mod:EggAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
	self:DrawIcon("icon_egg", tData.tUnit, 40, nil, nil, nId)
end


Mod:new()