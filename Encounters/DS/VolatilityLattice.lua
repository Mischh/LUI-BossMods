require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("VolatilityLattice")

--Localize some of your Variables.
--These will be accessible from self.L, NOT within Mod:Setup(), but everywhere else.
Mod:Locales(
    {--[[enUS]] 
        -- Unit names
		["unit.devourer"] = "Data Devourer",
    },
    {--[[deDE]] 
		-- Unit names
		["unit.devourer"] = "Datenverschlinger"
	}, 
    {--[[frFR]] 
		-- Unit names
		["unit.devourer"] = "Dévoreur de données",
	}
)

function Mod:Setup()
	name("Datascape", "Volatility Lattice")
	
	trigger("ALL", {}, {}, {}, {continentId = 52, parentZoneId = 98, mapId = 116})
	
	line("line_devourer", true, "ff0000ff", 7, "label.devourer")
end

function Mod:SetupEvents()
	onUnitCreated("DevourerSpawned", self.L["unit.devourer"])
	onUnitCreated("DevourerDespawned", self.L["unit.devourer"])
end

function Mod:OnStart()
	print("lattice")
end

function Mod:OnEnd()
	print("endlattice")
end

function Mod:DevourerSpawned(nId, tUnit, sName, bInCombat)
	self:DrawLineBetween("line_devourer", tUnit, nil, nil, nil, nId)
end

function Mod:DevourerDespawned(nId, tUnit, sName, bInCombat)
end

Mod:new() --THIS IS IMPORTANT DONT FORGET! (This should be one of the last lines in every encounter.)