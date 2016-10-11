require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("AileronVisceralus")

Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_air"] = "Aileron",
        ["unit.boss_life"] = "Visceralus",
		["unit.thorns"] = "Wild Brambles",
		["unit.jumppad"] = "[DS] e395 - Air - Tornado",
		["unit.healthorb"] = "Life Force",
		["unit.tree"] = "Lifekeeper",
		
		["label.healthorb"] = "Health Orb",
		["label.midphase"] = "Midphase",
		["label.midphase_end"] = "Midphase Ending",
		["label.thorns"] = "Thorns",
		["label.twirl"] = "Twirl",
		["label.trees"] = "Next Trees",
		
		--alerts
		["alert.twirlyou"] = "Twirl on YOU!",
    },
    {--[[deDE]] 
        -- Unit names
        ["unit.boss_air"] = "Aileron",
        ["unit.boss_life"] = "Viszeralus",
		["unit.thorns"] = "Wilde Brombeeren",
		["unit.jumppad"] = "[DS] e395 - Air - Tornado",
		["unit.healthorb"] = "Lebenskraft",
		["unit.tree"] = "Lebensbewahrer",
		
		["label.healthorb"] = "Lebenskugel",
		["label.midphase"] = "Mittelphase",
		["label.midphase_end"] = "Mittelphase Endet",
		["label.thorns"] = "Dornen",
		["label.twirl"] = "Wirbel",
		["label.trees"] = "Nächste Bäume",
		
		--alerts
		["alert.twirlyou"] = "Wirbel auf DIR!",
	}, 
    {--[[frFR]] 
        -- Unit names
        ["unit.boss_air"] = "Ventemort",
        ["unit.boss_life"] = "Visceralus",
		["unit.thorns"] = "Ronces sauvages",
		["unit.jumppad"] = "[DS] e395 - Air - Tornado",
		["unit.healthorb"] = "Force vitale",
		["unit.tree"] = "Garde-vie",
		
		["label.healthorb"] = "Health Orb",
		["label.midphase"] = "Midphase",
		["label.midphase_end"] = "Midphase Ending",
		["label.thorns"] = "Thorns",
		["label.twirl"] = "Twirl",
		["label.trees"] = "Next Trees",
		
		--alerts
		["alert.twirlyou"] = "Twirl on YOU!",
	}
)

function Mod:Setup()
	name("Datascape", "Aileron & Visceralus", "Elemental Pairs")
	trigger("ALL", {"Aileron","Visceralus"}, {"Aileron","Viszeralus"}, {"Ventemort","Visceralus"}, {continentId = 52, parentZoneId = 98, mapId = 119})

	unit("boss_air", true, "af00ffff", "unit.boss_air", 1)
	unit("boss_life", true, "af228b22", "unit.boss_life", 2)
	
	line("line_healthorb", true, "ff0000ff", 7, "label.healthorb")
	
	timer("timer_midphase", true, "af00ffff", "label.midphase")
	timer("timer_midphase_end", true, "afff0000", "label.midphase_end")
	timer("timer_thorns", true, "af228b22", "label.thorns")
	timer("timer_twirl", true, "afff0000", "label.twirl")
	timer("timer_trees", true, "af7cfc00", "label.trees")
	
	alert("alert_twirl", true, nil, nil, "alert.twirlyou")
	sound("sound_twirl", true, "inferno", "alert.twirlyou")
	icon("icon_twirl", true, "target", 40, "ffff0000", "label.twirl")
end

function Mod:SetupEvents()
	local DEBUFFID_TWIRL = 70440

	onUnitCreated("BossCreated_Air", self.L["unit.boss_air"], true)
	onUnitCreated("BossCreated_Life", self.L["unit.boss_life"], true)
	
	onUnitCreated("ThornsSpawned", self.L["unit.thorns"])
	
	onUnitCreated("JumppadSpawned", self.L["unit.jumppad"])
	onUnitCreated("JumppadDespawned", self.L["unit.jumppad"])
	
	onUnitCreated("HealthOrbSpawned", self.L["unit.healthorb"])
	onUnitDestroyed("HealthOrbDespawned", self.L["unit.healthorb"])
	
	onUnitCreated("TreeSpawned", self.L["unit.tree"])
	
	onBuffAdded("TwirlAdded", nil, nil, DEBUFFID_TWIRL)
	onBuffRemoved("TwirlRemoved", nil, nil, DEBUFFID_TWIRL)
end

local nLifeBossId = 0
local nTreeKeeperCount = 0
local tTreeKeeperList = {}
local nFirstTreeId = 0
local nLastThornsTime = 0
local bIsMidPhase = false
local nMidPhaseTime = 0
local nTwirlCount = 0

function Mod:OnStart()
	nLastThornsTime = 0
    bIsMidPhase = false
    nMidPhaseTime = GameLib.GetGameTime() + 90
    nTwirlCount = 0
    nTreeKeeperCount = 0
    tTreeKeeperList = {}
    nFirstTreeId = nil
	
	self:AddTimer("timer_midphase", 90)
	self:AddTimer("timer_thorns", 20)
    --mod:AddTimerBar("AVATUS_INCOMING", "Avatus incoming", 500)
end

function Mod:OnEnd()
end

function Mod:BossCreated_Air(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_air", tUnit, false, false, false)
end

function Mod:BossCreated_Life(nId, tUnit, sName, bInCombat)
	nLifeBossId = nId
	self:AddUnit("boss_life", tUnit, false, false, false)
end

function Mod:ThornsSpawned(nId, tUnit, sName, bInCombat)
	local nCurrentTime = GameLib.GetGameTime()
	if nLastThornsTime + 5 < nCurrentTime and nCurrentTime + 16 < nMidPhaseTime then
		nLastThornsTime = nCurrentTime
		nTwirlCount = nTwirlCount + 1
		self:AddTimer("timer_thorns", 15)
		if nTwirlCount % 2 == 1 then
			self:AddTimer("timer_twirl", 15)
		end
	end
end

function Mod:JumppadSpawned(nId, tUnit, sName, bInCombat)
	if not bIsMidPhase then
		local nCurrentTime = GameLib.GetGameTime()
		bIsMidPhase = true
		nTwirlCount = 0
		nMidPhaseTime = nCurrentTime + 115
		self:AddTimer("timer_midphase_end", 35)
		self:AddTimer("timer_thorns", 35)
		self:AddTimer("timer_trees", 35)
	end
end

function Mod:JumppadDespawned(nId, tUnit, sName, bInCombat)
    if bIsMidPhase then
        bIsMidPhase = false
		self:AddTimer("timer_midphase", 90)
	end
end

function Mod:HealthOrbSpawned(nId, tUnit, sName, bInCombat)
	self:DrawLineBetween("line_healthorb", tUnit, nLifeBossId, nil, nil, "line_healthorb"..nId)
end

function Mod:HealthOrbDespawned(nId, tUnit, sName, bInCombat)
	self:RemoveLineBetween("line_healthorb"..nId)
end

function Mod:TreeSpawned(nId, tUnit, sName, bInCombat)
	nTreeKeeperCount = nTreeKeeperCount + 1
	if nTreeKeeperCount % 2 == 0 then
		if (nTreeKeeperCount + 2) % 4 == 0 then -- nTreeKeeperCount == 2, 6, 10, 14, ...
			self:AddTimer("timer_trees", 30)
		end
	end
end

function Mod:TwirlAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration) 
	local tUnit = tData.tUnit
	if tUnit:IsThePlayer() then
		self:ShowAlert("alert_twirl")
		self:PlaySound("sound_twirl")
	else
		self:DrawIcon("icon_twirl", tUnit, 30, 20, nil, "twirl"..tUnit:GetId()) --show for max 20s
	end
end

function Mod:TwirlRemoved(nId, nSpellId, sName, tData, sUnitName)
	if not tData.tUnit:IsThePlayer() then
		self:RemoveIcon("twirl"..tData.tUnit:GetId())
	end
end

Mod:new()