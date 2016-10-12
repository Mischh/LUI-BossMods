require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("Avatus")

local portalColor = {
	green = "ff00ff00",
	yellow = "ffffff00",
	blue = "ff0000ff",
	red = "ffff0000",
}

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.avatus"] = "Avatus",
		["unit.gridcannon"] = "Holo Cannon",
		["boss/portal.green"] = "Unstoppable Object Simulation",
		["boss/portal.yellow"] = "Mobius Physics Constructor",
		["boss/portal.blue"] = "Infinite Logic Loop",
		["boss/portal.red"] = "Excessive Force Protocol",
		
		
		["label.portals"] = "Portals",
		["label.gungrid"] = "Gungrid",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.avatus"] = "Avatus",
		["unit.gridcannon"] = "Holokanone",
		["boss/portal.green"] = "Unaufhaltbare Objektsimulation",
		["boss/portal.yellow"] = "Mobius' Physikkonstrukteur",
		["boss/portal.blue"] = "Unendliche Logikschleife",
		["boss/portal.red"] = "Überzogene Gewaltprotokolle",
		
		["The Excessive Force Protocol's protective barrier has fallen."] = "Die Barriere des Überzogenen Gewaltprotokolls ist gefallen.",
		["The Excessive Force Protocol has been terminated."] = "Das Überzogene Gewaltprotokoll wurde terminiert.",
		
		
		["label.portals"] = "Portale",
		["label.gungrid"] = "Gungrid",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.avatus"] = "Avatus",
		["unit.gridcannon"] = "Holocanon",
		["boss/portal.green"] = "Simulacre invincible",
		["boss/portal.yellow"] = "Constructeur de physique de Möbius",
		["boss/portal.blue"] = "Boucle de logique infinie",
		["boss/portal.red"] = "Protocole de force excessive",
		
		
		["label.portals"] = "Portals",
		["label.gungrid"] = "Gungrid",
	}
)

function Mod:Setup()
	name("Datascape", "Avatus")
	trigger("ALL", {"Avatus"}, {"Avatus"}, {"Avatus"}, {continentId = 52, parentZoneId = 98, mapId = 104})
	unit("boss_avatus", true, 1, nil, "unit.avatus")
	
	-- line("line_twirltotomb", true, "ff0f0f0f", 7, "Twirl to Tomb")
	line("line_portals", true, false, 7, "label.portals")
	line("line_gungrid", true, "ff0000ff", 5, "label.gungrid")
end

function Mod:SetupEvents()
	onUnitCreated("AvatusAdded", self.L["unit.avatus"], true)
	onUnitDestroyed("AvatusRemoved", self.L["unit.avatus"])
	
	onUnitCreated("BossPortalSpawned_Green", self.L["boss/portal.green"])
	onUnitCreated("BossPortalSpawned_Yellow")
	onUnitCreated("BossPortalSpawned_Blue", self.L["boss/portal.blue"])
	onUnitCreated("BossPortalSpawned_Red", self.L["boss/portal.red"])
	
	onUnitDestroyed("PotentialPortalDespawned", self.L["boss/portal.green"])
	onUnitDestroyed("PotentialPortalDespawned")
	onUnitDestroyed("PotentialPortalDespawned", self.L["boss/portal.blue"])
	onUnitDestroyed("PotentialPortalDespawned", self.L["boss/portal.red"])
	
	onUnitCreated("GungridUnitSpawned", self.L["unit.gridcannon"])
	onUnitDestroyed("GungridUnitDespawned", self.L["unit.gridcannon"])
end

function Mod:AvatusAdded(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_avatus", tUnit, false, false, false)
end

function Mod:AvatusRemoved(nId, tUnit, sName)
	self:RemoveUnit("boss_avatus")
end

function Mod:BossPortalSpawned_Green(nId, tUnit, sName, bInCombat)
print(sName)
	if tUnit:GetHealth() then
	else --the portal
		self:DrawLineBetween("line_portals", tUnit, nil, nil, nil, nId, nil, portalColor.green)
	end
end

function Mod:BossPortalSpawned_Yellow(nId, tUnit, sName, bInCombat)
	local x = sName:match("Mobius(.+)")
	if x then
		print(string.byte(x,1,20))
	else
		return
	end
	
	if tUnit:GetHealth() then
	else --the portal
		self:DrawLineBetween("line_portals", tUnit, nil, nil, nil, nId, nil, portalColor.yellow)
	end
end

function Mod:BossPortalSpawned_Blue(nId, tUnit, sName, bInCombat)
	if tUnit:GetHealth() then
	else --the portal
		self:DrawLineBetween("line_portals", tUnit, nil, nil, nil, nId, nil, portalColor.blue)
	end
end

function Mod:BossPortalSpawned_Red(nId, tUnit, sName, bInCombat)
	if tUnit:GetHealth() then
	else --the portal
		self:DrawLineBetween("line_portals", tUnit, nil, nil, nil, nId, nil, portalColor.red)
	end
end

function Mod:PotentialPortalDespawned(nId, tUnit, sName)
	if not tUnit:GetHealth() then
		self:RemoveLineBetween(nId)
	end
end

function Mod:GungridUnitSpawned(nId, tUnit, sName, bInCombat)
	self:DrawLine("line_gungrid", tUnit, 100, nil, nil, nil, nil, nil, nId)
end

function Mod:GungridUnitDespawned(nId, tUnit, sName)
	self:DrawLine(nId)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end

Mod:new()