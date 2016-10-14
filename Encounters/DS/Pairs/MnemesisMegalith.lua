require "Window"
require "Apollo"

local Mod = {}
local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Encounter = "MnemesisMegalith"

local Locales = {
    ["enUS"] = {
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
    ["deDE"] = {
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
    ["frFR"] = {
		-- Unit names
        ["unit.boss_logic"] = "Mnémésis",
        ["unit.boss_earth"] = "Mégalithe",
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
	},
}
local DEBUFF_SNAKE = 74570
local snakeStepLength = 6 --the Snake does a Step of 6m each time.
local tStones = {}
local closestStone = nil
local snakePos = nil
local targetUnit = nil
local numSnakeLines = 0

function Mod:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.instance = "Datascape"
    self.displayName = "Mnemesis & Megalith"
    self.groupName = "Elemental Pairs"
    self.tTrigger = {
        sType = "ALL",
        tZones = {
            [1] = {
                continentId = 52,
                parentZoneId = 98,
                mapId = 117,
            },
        },
        tNames = {
            ["enUS"] = {"Mnemesis","Megalith"},
            ["deDE"] = {"Mnemesis","Megalith"},
            ["frFR"] = {"Mnémésis","Mégalithe"},
        },
    }
    self.run = false
    self.runtime = {}
    self.config = {
        enable = true,
        units = {
            boss_logic = {
                enable = true,
				position = 1,
                label = "unit.boss_logic",
                color = "afadff2f",
            },
            boss_earth = {
                enable = true,
				position = 2,
                label = "unit.boss_earth",
                color = "afff932f",
            },
			unit_pillar = {
				enable = true,
				position = 3,
				label = "unit.pillar",
                color = "afff0000",
			},
        },
		lines = {
			line_snakemap = {
				enable = true,
                color = "ffff4500",
				thickness = 26,
				label = "label.snakemap",
			},
		},
		auras = {
			aura_youtarget = {
				enable = true,
                color = "afadff2f",
				label = "label.youtarget",
				sprite = "run",
			},
		},
		icons = {
			icon_target = {
				enable = true,
				sprite = "target",
				size = 50,
                color = "afadff2f",
				label = "label.target",
			},
		},
		timers = {
			timer_retarget = {
				enable = true,
                color = "afadff2f",
				label = "label.retarget",
			},
			timer_defrag = {
				enable = true,
                color = "afff0000",
				label = "label.nextdefragment",
			},
		},
		casts = {
			cast_defrag = {
				enable = true,
                color = "afff0000",
				label = "cast.defragment",
			
			},
		},
    }
    return o
end

function Mod:Init(parent)
    Apollo.LinkAddon(parent, self)

    self.core = parent
    self.L = parent:GetLocale(Encounter,Locales)
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

function Mod:UpdateSnakeLines()
	local info = self:GetSnakeMovement(closestStone or targetUnit)
	
	if not info then return end
	
	self.core:DrawLineBetween(0, snakePos, info.straight, self.config.lines.line_snakemap)
	
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
			self.core:DrawLineBetween(2*i-1, pointA, pointB, self.config.lines.line_snakemap)
			pointA = { --Create new Tables! Important!
				x = pointB.x, 
				y = pointB.y, 
				z = pointB.z + zOff,
			}
			self.core:DrawLineBetween(2*i, pointA, pointB, self.config.lines.line_snakemap)
		end
	else
		for i = 1, info.diagonalSteps, 1 do
			pointB = { --Create new Tables! Important!
				x = pointA.x, 
				y = pointA.y, 
				z = pointA.z + zOff,
			}
			self.core:DrawLineBetween(2*i-1, pointA, pointB, self.config.lines.line_snakemap)
			pointA = { --Create new Tables! Important!
				x = pointB.x + xOff, 
				y = pointB.y, 
				z = pointB.z,
			}
			self.core:DrawLineBetween(2*i, pointA, pointB, self.config.lines.line_snakemap)
		end
	end
	
	for i = 2*info.diagonalSteps+1, numSnakeLines, 1 do
		self:RemoveLineBetween("SnakeLine"..i)
	end
	numSnakeLines = 2*info.diagonalSteps
end

function Mod:OnUnitCreated(nId, tUnit, sName, bInCombat)
    if not self.run == true then
        return
    end
	
	if sName == self.L["unit.snake"] then
	
	elseif sName == self.L["unit.pillar"] then
	
	elseif sName == self.L["unit.stone"] then
	
    elseif sName == self.L["unit.boss_logic"] and bInCombat == true then
        self.core:AddUnit(nId,sName,tUnit,self.config.units.boss_logic)
    elseif sName == self.L["unit.boss_earth"] and bInCombat == true then
        self.core:AddUnit(nId,sName,tUnit,self.config.units.boss_earth)
    end
end

function Mod:OnBuffAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
	if nSpellId == DEBUFF_SNAKE then
	
	end
end

function Mod:OnCastStart(nId, sCastName, tCast, sName, nDuration)
	if sCastName == self.L["cast.defragment"] then
		self:ShowCast("cast_defrag", tCast)
		self:AddTimer("timer_defrag", 40)
	end
end

function Mod:OnUnitDestroyed(nId, tUnit, sName)
	if not self.run == true then
        return
    end
	
	if sName == self.L["unit.pillar"] then
	
	elseif sName == self.L["unit.stone"] then
	
	end
end

function Mod:IsRunning()
    return self.run
end

function Mod:IsEnabled()
    return self.config.enable
end

function Mod:OnEnable()
    self.run = true
	tStones = {}
	closestStone = nil
	snakeUnit = nil
	targetUnit = nil
	numSnakeLines = 0
end

function Mod:OnDisable()
    self.run = false
end

local ModInst = Mod:new()
LUI_BossMods.modules[Encounter] = ModInst
