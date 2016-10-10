require "Window"
require "Apollo"

local Mod = {}
local LUI_BossMods = Apollo.GetAddon("LUI_BossMods")
local Encounter = "Mordechai"

local Locales = {
    ["enUS"] = {
        -- Units
        ["unit.boss"] = "Mordechai Redmoon",
    	["unit.kinetic_orb"] = "Kinetic Orb",
        -- Debuffs
        ["debuff.kinetic_link"] = "Kinetic Link",
        ["debuff.kinetic_fixation"] = "Kinetic Fixation",
        ["debuff.shocking_attraction"] = "Shocking Attraction",
        -- Datachron
        ["datachron.airlock_opened"] = "The airlock has been opened!",
    	["datachron.airlock_closed"] = "The airlock has been closed!",
        -- Casts
    	["cast.shatter_shock"] = "Shatter Shock",
        ["cast.vicious_barrage"] = "Vicious Barrage",
        -- Alerts
        ["alert.orb_spawned"] = "Orb spawned!",
        ["alert.kinetic_link"] = "HIT THE ORB!",
        ["alert.kinetic_fixation"] = "ORB ON YOU!",
        ["alert.shocking_attraction_left"] = "MOVE TO THE LEFT!",
        ["alert.shocking_attraction_right"] = "MOVE TO THE RIGHT!",
        -- Messages
        ["message.barrage_next"] = "Next Barrage",
        ["message.shuriken_next"] = "Next Shuriken",
        ["message.orb_next"] = "Next Orb",
        ["message.orb_active"] = "Orb start moving",
        -- Labels
        ["label.orb_next"] = "Kinetic Orb (Next)",
        ["label.orb_active"] = "Kinetic Orb (Active)",
        ["label.shocking_attraction_left"] = "Shocking Attraction (Left)",
        ["label.shocking_attraction_right"] = "Shocking Attraction (Right)",
        ["label.shuriken"] = "Shuriken",
        ["label.airlock"] = "Airlock",
    },
    ["deDE"] = {},
    ["frFR"] = {},
}

local DEBUFF_KINETIC_LINK = 86797
local DEBUFF_KINETIC_FIXATION = 85566
local DEBUFF_SHOCKING_ATTRACTION = 86861
local CLEAVE_OFFSETS = {
	["FRONT_LEFT"] = Vector3.New(3.25, 0, 0),
	["FRONT_RIGHT"] = Vector3.New(-3.25, 0, 0),
	["BACK_LEFT"] = Vector3.New(-3.25, 0, 0),
	["BACK_RIGHT"] = Vector3.New(3.25, 0, 0),
}

function Mod:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.instance = "Redmoon Terror"
    self.displayName = "Mordechai"
    self.tTrigger = {
        sType = "ANY",
        tZones = {
            [1] = {
                continentId = 104,
                parentZoneId = 0,
                mapId = 548,
            },
        },
        tNames = {
            ["enUS"] = {"Mordechai Redmoon"},
        },
    }
    self.run = false
    self.bViciousBarrage = false
    self.runtime = {}
    self.config = {
        enable = true,
        units = {
            boss = {
                enable = true,
                label = "unit.boss",
                color = "afb0ff2f",
                priority = 1,
            },
            orb = {
                enable = true,
                label = "unit.kinetic_orb",
                color = "afb0ff2f",
                priority = 2,
            },
        },
        timers = {
            orb = {
                enable = true,
                priority = 1,
                color = "afb0ff2f",
                label = "label.orb_next",
            },
            orb_active = {
                enable = true,
                priority = 2,
                color = "afff4500",
                label = "label.orb_active",
            },
            shuriken = {
                enable = true,
                priority = 3,
                color = "afb0ff2f",
                label = "label.shuriken",
            },
            airlock = {
                enable = true,
                priority = 4,
                color = "afb0ff2f",
                label = "label.airlock",
            },
            barrage = {
                enable = true,
                priority = 5,
                color = "afff00ff",
                label = "cast.vicious_barrage",
            },
        },
        alerts = {
            orb = {
                enable = true,
                duration = 3,
                priority = 1,
                label = "unit.kinetic_orb",
            },
            kinetic_link = {
                enable = true,
                duration = 3,
                priority = 2,
                label = "debuff.kinetic_link",
            },
            kinetic_fixation = {
                enable = true,
                duration = 3,
                priority = 3,
                label = "debuff.kinetic_fixation",
            },
            shocking_attraction_left = {
                enable = false,
                duration = 3,
                priority = 4,
                label = "label.shocking_attraction_left",
            },
            shocking_attraction_right = {
                enable = true,
                duration = 3,
                priority = 5,
                label = "label.shocking_attraction_right",
            },
        },
        sounds = {
            orb = {
                enable = true,
                priority = 1,
                file = "alert",
                label = "unit.kinetic_orb",
            },
            kinetic_link = {
                enable = true,
                priority = 2,
                file = "burn",
                label = "debuff.kinetic_link",
            },
            kinetic_fixation = {
                enable = true,
                priority = 3,
                file = "run-away",
                label = "debuff.kinetic_fixation",
            },
            shocking_attraction = {
                enable = true,
                priority = 4,
                file = "alert",
                label = "debuff.shocking_attraction",
            },
        },
        lines = {
            boss = {
                enable = true,
                priority = 1,
                thickness = 6,
                color = "ffffffff",
                label = "unit.boss",
            },
            kinetic_fixation = {
                enable = true,
                priority = 2,
                thickness = 6,
                color = "ffb0ff2f",
                label = "debuff.kinetic_fixation",
            },
        },
        icons = {
            kinetic_link = {
                enable = true,
                sprite = "target2",
                size = 60,
                color = "ffff00ff",
                label = "debuff.kinetic_link",
            },
            shocking_attraction = {
                enable = true,
                sprite = "target2",
                size = 60,
                color = "ffb0ff2f",
                label = "debuff.shocking_attraction",
            },
        }
    }
    return o
end

function Mod:Init(parent)
    Apollo.LinkAddon(parent, self)

    self.core = parent
    self.L = parent:GetLocale(Encounter,Locales)
end

function Mod:OnUnitCreated(nId, tUnit, sName, bInCombat)
    if not self.run == true then
        return
    end

    if sName == self.L["unit.boss"] and bInCombat == true then
        self.core:AddUnit(nId,sName,tUnit,self.config.units.boss.enable,true,false,false,nil,self.config.units.boss.color, self.config.units.boss.priority)
        self.tUnitBoss = tUnit
        self:AddMarkerLines()
    elseif sName == self.L["unit.kinetic_orb"] and bInCombat == true then
        self.core:AddUnit(nId,sName,tUnit,self.config.units.orb.enable,false,false,false,nil,self.config.units.orb.color, self.config.units.orb.priority)
        self.tUnitOrb = tUnit

        if self.config.timers.orb.enable == true then
            self.core:AddTimer("NEXT_ORB", self.L["message.orb_next"], 26, self.config.timers.orb.color, self.config.timers.orb.sound, self.config.timers.orb.alert)
        end

        if self.config.timers.orb_active.enable == true then
            self.core:AddTimer("ORB_ACTIVE", self.L["message.orb_active"], 4.5, self.config.timers.orb_active.color, self.config.timers.orb_active.sound, self.config.timers.orb_active.alert)
        end

        if self.config.alerts.orb.enable == true then
            self.core:ShowAlert("ORB"..tostring(nId), self.L["alert.orb_spawned"],self.config.alerts.orb.duration, self.config.alerts.orb.color)
        end

        if self.config.sounds.orb.enable == true then
            self.core:PlaySound(self.config.sounds.orb.file)
        end
	end
end

function Mod:OnUnitDestroyed(nId, tUnit, sName)
    if sName == self.L["unit.kinetic_orb"] then
        self.core:RemoveLineBetween("ORB")
    end
end

function Mod:OnBuffAdded(nId, nSpellId, sName, tData, sUnitName, nStack, nDuration)
    if nSpellId == DEBUFF_KINETIC_LINK then
        if tData.tUnit:IsThePlayer() then
            if self.config.alerts.kinetic_link.enable == true then
                self.core:ShowAlert("KL"..tostring(nId), self.L["alert.kinetic_link"],self.config.alerts.kinetic_link.duration, self.config.alerts.kinetic_link.color)
            end

            if self.config.sounds.kinetic_link.enable == true then
                self.core:PlaySound(self.config.sounds.kinetic_link.file)
            end
        end

        if self.config.icons.kinetic_link.enable == true then
            self.core:DrawIcon("KL"..tostring(nId), tData.tUnit, self.config.icons.kinetic_link.sprite, self.config.icons.kinetic_link.size, nil, self.config.icons.kinetic_link.color, nDuration)
        end
    elseif nSpellId == DEBUFF_KINETIC_FIXATION then
        if tData.tUnit:IsThePlayer() then
            if self.config.alerts.kinetic_fixation.enable == true then
                self.core:ShowAlert("KF"..tostring(nId), self.L["alert.kinetic_fixation"],self.config.alerts.kinetic_fixation.duration, self.config.alerts.kinetic_fixation.color)
            end

            if self.config.sounds.kinetic_fixation.enable == true then
                self.core:PlaySound(self.config.sounds.kinetic_fixation.file)
            end
        end

        if self.config.lines.kinetic_fixation.enable == true and self.tUnitOrb then
            self.core:DrawLineBetween("ORB", tData.tUnit, self.tUnitOrb, self.config.lines.kinetic_fixation.color, self.config.lines.kinetic_fixation.thickness)
        end
    elseif nSpellId == DEBUFF_SHOCKING_ATTRACTION then
        if tData.tUnit:IsThePlayer() then
            if self.config.alerts.shocking_attraction_right.enable == true then
                self.core:ShowAlert("SA"..tostring(nId), self.L["alert.shocking_attraction_right"],self.config.alerts.shocking_attraction_right.duration, self.config.alerts.shocking_attraction_right.color)
            else
                if self.config.alerts.shocking_attraction_left.enable == true then
                    self.core:ShowAlert("SA"..tostring(nId), self.L["alert.shocking_attraction_left"],self.config.alerts.shocking_attraction_left.duration, self.config.alerts.shocking_attraction_left.color)
                end
            end

            if self.config.sounds.shocking_attraction.enable == true then
                self.core:PlaySound(self.config.sounds.shocking_attraction.file)
            end
        end

        if self.config.icons.shocking_attraction.enable == true then
            self.core:DrawIcon("SA"..tostring(nId), tData.tUnit, self.config.icons.shocking_attraction.sprite, self.config.icons.shocking_attraction.size, nil, self.config.icons.shocking_attraction.color, nDuration)
        end
    end
end

function Mod:OnBuffRemoved(nId, nSpellId, sName, tData, sUnitName)
    if nSpellId == DEBUFF_KINETIC_LINK then
		self.core:RemoveIcon("KL" .. nId)
	elseif nSpellId == DEBUFF_SHOCKING_ATTRACTION then
		self.core:RemoveIcon("SA" .. nId)
	end
end

function Mod:OnCastStart(nId, sCastName, tCast, sName, nDuration)
    if sName == self.L["Mordechai Redmoon"] then
		if sCastName == self.L["cast.shatter_shock"] then
            if self.config.timers.shuriken.enable == true then
                self.core:AddTimer("NEXT_SHURIKEN", self.L["message.shuriken_next"], 22, self.config.timers.shuriken.color, self.config.timers.shuriken.sound, self.config.timers.shuriken.alert)
            end
        elseif sCastName == self.L["cast.vicious_barrage"] then
            if self.config.timers.barrage.enable == true then
                self.core:AddTimer("NEXT_BARRAGE", self.L["message.barrage_next"], 33, self.config.timers.barrage.color, self.config.timers.barrage.sound, self.config.timers.barrage.alert)
            end
		end
	end
end

function Mod:OnDatachron(sMessage, sSender, sHandler)
    if sMessage:find(self.L["datachron.airlock_closed"]) then
        self:AddMarkerLines()

        if self.config.timers.shuriken.enable == true then
            self.core:AddTimer("NEXT_SHURIKEN", self.L["message.shuriken_next"], 10, self.config.timers.shuriken.color, self.config.timers.shuriken.sound, self.config.timers.shuriken.alert)
        end

        if self.config.timers.orb.enable == true then
            self.core:AddTimer("NEXT_ORB", self.L["message.orb_next"], 15, self.config.timers.orb.color, self.config.timers.orb.sound, self.config.timers.orb.alert)
        end

        if self.config.timers.barrage.enable == true and self.bViciousBarrage == true then
            self.core:AddTimer("NEXT_BARRAGE", self.L["message.barrage_next"], 19, self.config.timers.barrage.color, self.config.timers.barrage.sound, self.config.timers.barrage.alert)
        end

        self.bViciousBarrage = true
    elseif sMessage:find(self.L["datachron.airlock_opened"]) then
        self:RemoveMarkerLines()
        self.core:RemoveTimer("NEXT_ORB")
        self.core:RemoveTimer("NEXT_SHURIKEN")
        self.core:RemoveTimer("NEXT_BARRAGE")

        if self.config.timers.airlock.enable == true then
            self.core:AddTimer("AIRLOCK", self.L["label.airlock"], 25, self.config.timers.airlock.color, self.config.timers.airlock.sound, self.config.timers.airlock.alert)
        end
	end
end

function Mod:AddMarkerLines()
    if self.tUnitBoss and self.config.lines.boss.enable == true then
        self.core:DrawLine("Cleave_1", self.tUnitBoss, self.config.lines.boss.color, self.config.lines.boss.thickness, 60, -23.5, 0, CLEAVE_OFFSETS["FRONT_LEFT"])
        self.core:DrawLine("Cleave_2", self.tUnitBoss, self.config.lines.boss.color, self.config.lines.boss.thickness, 60, 23.5, 0, CLEAVE_OFFSETS["FRONT_RIGHT"])
        self.core:DrawLine("Cleave_3", self.tUnitBoss, self.config.lines.boss.color, self.config.lines.boss.thickness, -60, -23.5, 0, CLEAVE_OFFSETS["BACK_LEFT"])
        self.core:DrawLine("Cleave_4", self.tUnitBoss, self.config.lines.boss.color, self.config.lines.boss.thickness, -60, 23.5, 0, CLEAVE_OFFSETS["BACK_RIGHT"])
    end
end

function Mod:RemoveMarkerLines()
    if self.config.lines.boss.enable == true then
        self.core:RemoveLine("Cleave_1")
        self.core:RemoveLine("Cleave_2")
        self.core:RemoveLine("Cleave_3")
        self.core:RemoveLine("Cleave_4")
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
    self.tUnitBoss = nil
    self.tUnitOrb = nil
    self.bViciousBarrage = false

    if self.config.timers.orb.enable == true then
        self.core:AddTimer("NEXT_ORB", self.L["message.orb_next"], 22, self.config.timers.orb.color, self.config.timers.orb.sound, self.config.timers.orb.alert)
    end
end

function Mod:OnDisable()
    self.run = false
end

local ModInst = Mod:new()
LUI_BossMods.modules[Encounter] = ModInst
