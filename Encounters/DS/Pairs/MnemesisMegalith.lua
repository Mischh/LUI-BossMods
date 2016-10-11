require "Window"
require "Apollo"

local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Mod = LUI_BossMods:EncounterPrototype("MnemesisMegalith")

local DEBUFF_SNAKE = 74570
local snakeStepLength = 6 --the Snake does a Step of 6m each time.
Mod:Locales(
    {--[[enUS]] 
        -- Unit names
        ["unit.boss_logic"] = "Mnemesis",
        ["unit.boss_earth"] = "Megalith",
		["unit.snake"] = "e395- [Datascape] Logic Elemental - Snake Piece (invis unit)",
		["unit.stone"] = "Obsidian Outcropping",
		["unit.pillar"] = "Crystalline Matrix",
		
		-- Casts
		["cast.defragment"] = "Defragment",
		
		-- Labels
		["label.snakemap"] = "Snake Map",
		["label.youtarget"] = "You: Targeted by Snake",
		["label.target"] = "Targeted by Snake",
		["label.retarget"] = "Snake: New Target",
		["label.nextdefragment"] = "Next defragment",
    },
    {--[[deDE]] 
		-- Unit names
        ["unit.boss_logic"] = "Mnemesis",
        ["unit.boss_earth"] = "Megalith",
		["unit.snake"] = "e395- [Datascape] Logic Elemental - Snake Piece (invis unit)",
		["unit.stone"] = "Obsidianvorsprung",
		["unit.pillar"] = "Kristallmatrix",
		
		-- Casts
		["cast.defragment"] = "Defragmentieren",
		
		["label.snakemap"] = "Schlangen Karte",
		["label.youtarget"] = "Du: Von Schlange verfolgt",
		["label.target"] = "Von Schlange verfolgt",
		["label.retarget"] = "Schlange: Neues Ziel",
		["label.nextdefragment"] = "Nächstes Defragmentieren",
	}, 
    {--[[frFR]] 
		-- Unit names
        ["unit.boss_logic"] = "Mnemesis",
        ["unit.boss_earth"] = "Megalith",
		["unit.snake"] = "e395- [Datascape] Logic Elemental - Snake Piece (invis unit)",
		["unit.stone"] = "Affleurement d'obsidienne",
		["unit.pillar"] = "Matrice cristalline",
		
		-- Casts
		["cast.defragment"] = "Défragmentation",
		
		-- Labels
		["label.snakemap"] = "Snake Map",
		["label.youtarget"] = "You: Targeted by Snake",
		["label.target"] = "Targeted by Snake",
		["label.retarget"] = "Snake: New Target",
		["label.nextdefragment"] = "Prochaine defragmentation",
	}
)

function Mod:Setup()
	name("Datascape", "Mnemesis & Megalith", "Elemental Pairs")
	trigger("ALL", {"Mnemesis","Megalith"}, {"Mnemesis","Megalith"}, {"Mnemesis","Megalith"}, {continentId = 52, parentZoneId = 98, mapId = 117})
	
	unit("boss_logic", true, 1, "afadff2f", "unit.boss_logic")
	unit("boss_earth", true, 2, "afff932f", "unit.boss_earth")
	unit("unit_pillar", true, 3, "afff0000", "unit.pillar")
	
	--snake-stuff
	line("line_snakemap", true, "ffff4500", 26, "label.snakemap")
	aura("aura_youtarget", true, "run", "afadff2f", "label.youtarget")
	icon("icon_target", true, "target", 50, "afadff2f", "label.target")
	timer("timer_retarget", true, "afadff2f", "label.retarget")
	
	--defragment
	timer("timer_defrag", true, "afff0000", "label.nextdefragment")
	cast("cast_defrag", true, "afff0000", "cast.defragment")
end

function Mod:SetupEvents()
	onUnitCreated("BossCreated_Logic", self.L["unit.boss_logic"], true)
	onUnitCreated("BossCreated_Earth", self.L["unit.boss_earth"], true)
	
	onUnitCreated("PillarCreated", self.L["unit.pillar"])
	onUnitDestroyed("PillarRemoved", self.L["unit.pillar"])
	
	--snake stuff
	onUnitCreated("StoneCreated", self.L["unit.stone"])
	onUnitDestroyed("StoneDestroyed", self.L["unit.stone"])
	onUnitCreated("SnakePieceCreated", self.L["unit.snake"])
	onBuffAdded("SnakeBuffApplied", nil, nil, DEBUFF_SNAKE)
	
	--defrag
	onCastStart("CastStart_Defrag", "boss_logic", nil, self.L["cast.defragment"])
end

local tStones = {}
local closestStone = nil
local snakePos = nil
local targetUnit = nil
local numSnakeLines = 0
function Mod:OnStart()
	tStones = {}
	closestStone = nil
	snakeUnit = nil
	targetUnit = nil
	numSnakeLines = 0
end

local abs = math.abs
local floor = math.floor
local ceil = math.ceil
function Mod:GetSnakeMovement(tUnit)
	if snakePos and tUnit then
		local info = {}
		local pos = tUnit:GetPosition()
		local x = pos.x-snakePos.x
		local y = pos.z-snakePos.z
		
		local xdir = x<0 and -1 or 1
		local ydir = y<0 and -1 or 1
		
		local xnum = ceil(floor(abs(x)/snakeStepLength*2)/2)-- the number of Steps into X direction
		local ynum = ceil(floor(abs(y)/snakeStepLength*2)/2)
		
		local prioX = abs(x)+((ynum-xnum)*snakeStepLength) > abs(y)
		
		
		if xnum > ynum then
			local diff = xnum-ynum
			
			info.straight = {
				x = snakePos.x+xdir*diff*snakeStepLength,
				y = snakePos.y,
				z = snakePos.z,
			}
			info.diagonalSteps = ynum
			info.diagonalDirection = {x=xdir, z=ydir}
			info.priorizeX = prioX
		else
			local diff = ynum-xnum
		
			info.straight = {
				x = snakePos.x,
				y = snakePos.y,
				z = snakePos.z+ydir*diff*snakeStepLength,
			}
			info.diagonalSteps = xnum
			info.diagonalDirection = {x=xdir, z=ydir}
			info.priorizeX = prioX
		end
		return info
	else
		return nil
	end
end

function Mod:UpdateSnakeLines(force) --this gets forced, whenever something 'big' happens (new Stone, new Target, new SnakeBlock)
	if not closestStone or force then
		local info = self:GetSnakeMovement(closestStone or targetUnit)
		
		if not info then return end
		
		self:DrawLineBetween("line_snakemap", snakePos, info.straight, nil, nil, "SnakeLine"..(0))
		
		local xOff = info.diagonalDirection.x*snakeStepLength
		local zOff = info.diagonalDirection.z*snakeStepLength
		
		local pointA, pointB = info.straight, nil
		if info.priorizeX then--draw the X-Direction first. (Of the diagonal Part)
			for i = 1, info.diagonalSteps, 1 do
				pointB = { --Create new Tables! Important!
					x = pointA.x + xOff, 
					y = pointA.y, 
					z = pointA.z,
				}
				self:DrawLineBetween("line_snakemap", pointA, pointB, nil, nil, "SnakeLine"..(2*i-1))
				pointA = { --Create new Tables! Important!
					x = pointB.x, 
					y = pointB.y, 
					z = pointB.z + zOff,
				}
				self:DrawLineBetween("line_snakemap", pointB, pointA, nil, nil, "SnakeLine"..(2*i))
			end
		else
			for i = 1, info.diagonalSteps, 1 do
				pointB = { --Create new Tables! Important!
					x = pointA.x, 
					y = pointA.y, 
					z = pointA.z + zOff,
				}
				self:DrawLineBetween("line_snakemap", pointA, pointB, nil, nil, "SnakeLine"..(2*i-1))
				pointA = { --Create new Tables! Important!
					x = pointB.x + xOff, 
					y = pointB.y, 
					z = pointB.z,
				}
				self:DrawLineBetween("line_snakemap", pointB, pointA, nil, nil, "SnakeLine"..(2*i))
			end
		end
		
		for i = 2*info.diagonalSteps+1, numSnakeLines, 1 do
			self:RemoveLineBetween("SnakeLine"..i)
		end
		numSnakeLines = 2*info.diagonalSteps
	end
end

function Mod:BossCreated_Logic(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_logic", tUnit, true, false, false) --oncast, onbuff, ondebuff
end

function Mod:BossCreated_Earth(nId, tUnit, sName, bInCombat)
	self:AddUnit("boss_earth", tUnit, false, false, false)
end

function Mod:PillarCreated(nId, tUnit, sName, bInCombat)
	self:AddUnit("unit_pillar", tUnit, false, false, false, nil, "pillar"..nId)
end

function Mod:PillarRemoved(nId, tUnit, sName)
	self:RemoveUnit("pillar"..nId)
end

function Mod:StoneCreated(nId, tUnit, sName, bInCombat)
	if closestStone then
		if self:GetDistance(snakePos, tUnit) < self:GetDistance(snakePos, closestStone) then
			tStones[closestStone] = true
			closestStone = tUnit
		else
			tStones[tUnit] = true
			closestStone = closestStone
		end
	else
		closestStone = tUnit
	end
	self:UpdateSnakeLines(true)
end

function Mod:StoneDestroyed(nId, tUnit, sName)
	if tUnit == closestStone then
		closestStone = nil
	end
end

function Mod:SnakePieceCreated(nId, tUnit, sName, bInCombat)
	snakePos = tUnit:GetPosition()
	self:UpdateSnakeLines(true)
end

function Mod:SnakeBuffTimeout()
	targetUnit = nil --the snake seems to bug out very often and doesnt apply any debuffs anymore, but still changes targets.
	--from then on, we have no idea anymore, who is targeted - so we cant show.
end

function Mod:SnakeBuffApplied(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
	local tUnit = tData.tUnit	
	
	self:HideAura("aura_youtarget", false) --dont trigger SnakeBuffTimeout
	self:HideIcon("icon_target", false)
	
	if tUnit:IsThePlayer() then
		self:ShowAura("aura_youtarget", nDuration, true, nil, nil, nil, self.SnakeBuffTimeout) --after nDuration, call SnakeBuffTimeout
	else
		self:DrawIcon("icon_target", tUnit, 40, nDuration, true, nil, nil, nil, nil, self.SnakeBuffTimeout)
	end
	
	self:AddTimer("timer_retarget", nDuration)
	
	targetUnit = tUnit
	self:UpdateSnakeLines(true)
end

function Mod:CastStrart_Defrag(nId, sCastName, tCast, sName, nDuration)
	self:ShowCast("cast_defrag", tCast)
	self:AddTimer("timer_defrag", 40)
end

Mod:new()