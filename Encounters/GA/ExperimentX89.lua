require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("ExperimentX89")

Mod:Locales(
    {--[[enUS]] 
        ["unit.experiment"] = "Experiment X-89",
		["label.bossline"] = "Front directing Boss-Line",
		["label.bomb.small"] = "Small Bomb",
		["label.bomb.big"] = "Big Bomb",
    },
    {--[[deDE]] 
        ["unit.experiment"] = "Experiment X-89",
		["label.bossline"] = "Vorwärtszeigende Boss-Linie",
		["label.bomb.small"] = "Kleine Bombe",
		["label.bomb.big"] = "Große Bombe",
	}, 
    {--[[frFR]] 
        ["unit.experiment"] = "Experiment X-89",
		["label.bossline"] = "Front directing Boss-Line",
		["label.bomb.small"] = "Small Bomb",
		["label.bomb.big"] = "Big Bomb",
	}
)

local DEBUFFID_LITTLE_BOMB = 47316
local DEBUFFID_BIG_BOMB = 47285

function Mod:Setup()
	name("Genetic Archives", "Experiment X-89")
	trigger("ALL", {"Experiment X-89"}, {"Experiment X-89"}, {"Experiment X-89"}, {continentId = 67, parentZoneId = 147, mapId = 148})
	unit("boss", true, 1, "afff0000", "unit.experiment")
	line("line_boss", true, "ff0000ff", 5, "label.bossline")
	aura("aura_bomb.small", true, "bomb", "ffff0000", "label.bomb.small")
	aura("aura_bomb.big", true, "target4", "ffffa500", "label.bomb.big")
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated", self.L["unit.experiment"], true)
	onUnitDestroyed("BossDestroyed", self.L["unit.experiment"])
	onBuffAdded("SmallBombAdded", nil, nil, DEBUFFID_LITTLE_BOMB)
	onBuffAdded("BigBombAdded", nil, nil, DEBUFFID_BIG_BOMB)
	onBuffRemoved("SmallBombRemoved", nil, nil, DEBUFFID_LITTLE_BOMB)
	onBuffRemoved("BigBombRemoved", nil, nil, DEBUFFID_BIG_BOMB)
end

function Mod:OnStart()
end

function Mod:OnEnd()
end


function Mod:BossCreated(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss", tUnit, true, false, false) --oncast, onbuff, ondebuff
	self:DrawLine("line_boss", tUnit, 20, nil, 3)
end

function Mod:BossDestroyed(nId, tUnit, sName)
	self:RemoveUnit("boss")
	self:RemoveLine("line_boss")
end

function Mod:SmallBombAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
	if tData.tUnit:IsThePlayer() then
		self:ShowAura("aura_bomb.small", nDuration, true)
	end
end

function Mod:BigBombAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
	if tData.tUnit:IsThePlayer() then
		self:ShowAura("aura_bomb.big", nDuration)
	end
end

function Mod:SmallBombRemoved(nId, nSpellId, sName, tData, sUnitName)
	if tData.tUnit:IsThePlayer() then
		self:HideAura("aura_bomb.small")
	end
end

function Mod:BigBombRemoved(nId, nSpellId, sName, tData, sUnitName)
	if tData.tUnit:IsThePlayer() then
		self:HideAura("aura_bomb.big")
	end
end

Mod:new()
