
-- Copyright (C) 2016-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

local _CreateConVar = CreateConVar

local function CreateConVar(name, def, desc)
	return _CreateConVar(name, def, CLIENT and FCVAR_REPLICATED or {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, desc)
end

local SPRINT = CreateConVar('sv_limited_sprint', '1', 'Enable limited sprint')
local WATER = CreateConVar('sv_limited_oxygen', '1', 'Enable limited oxygen')
local WATER_RESTORE = CreateConVar('sv_limited_oxygen_restore', '1', 'Restore health that player lost while drowing')

local WATER_RESTORE_RATIO = CreateConVar('sv_limited_oxygen_restorer', '0.8', 'Multipler of recovering health from drown')
local WATER_RESTORE_SPEED = CreateConVar('sv_limited_oxygen_restores', '4', 'Speed for recovering health in HP/s')
local WATER_RESTORE_PAUSE = CreateConVar('sv_limited_oxygen_restorep', '1', 'Pause in seconds before startint to recover HP')

local WATER_CHOKE_RATIO = CreateConVar('sv_limited_oxygen_choke', '1', 'Time between drown damage in seconds')
local WATER_CHOKE_DMG = CreateConVar('sv_limited_oxygen_choke_dmg', '4', 'Damage of choke')

local WATER_RATIO = CreateConVar('sv_limited_oxygen_r', '1', 'Ratio of draining power for oxygen from player')
local WATER_RATIO_MUL = CreateConVar('sv_limited_oxygen_r_mul', '3', 'Multiplier of "power" drain when player is not wearing a suit')

local POWER_RESTORE_DELAY = CreateConVar('sv_limited_hev_rd', '0', 'Delay before starting to restore power of suit')
local POWER_RESTORE_MUL = CreateConVar('sv_limited_hev_rmul', '1', 'Multiplier of power restore speed')
local SPRINT_LIMIT_ACT = CreateConVar('sv_limited_hev_slim', '10', 'Minimum % of HEV power to enter sprint mode')
local SPRINT_MUL = CreateConVar('sv_limited_hev_sprint', '1', 'Sprint power drain multiplier')

local FLASHLIGHT = CreateConVar('sv_limited_flashlight', '1', 'Enable limited flashlight')
local FLASHLIGHT_RATIO = CreateConVar('sv_limited_flashlight_ratio', '100', 'Ratio of draining power from flashlight')
local FLASHLIGHT_RRATIO = CreateConVar('sv_limited_flashlight_restore_ratio', '500', 'Ratio of restoring power of flashlight')
local FLASHLIGHT_PAUSE = CreateConVar('sv_limited_flashlight_pause', '4', 'Seconds to wait before starting restoring power of flashlight')
local FLASHLIGHT_EPAUSE = CreateConVar('sv_limited_flashlight_epause', '2', 'Seconds to wait before granting player ability to enable his flashlight after starting power restoring')

LIMITEDHEV_FLASHLIGHT_EPAUSE = FLASHLIGHT_EPAUSE

local lastCommandCall = CurTime()

-- IsFirstTimePredicted is always false on client realm
-- in this hook, so
local function StartCommand(ply, cmd)
	local delta

	if CLIENT then
		delta = CurTime() - lastCommandCall
		lastCommandCall = CurTime()
	end

	if not SPRINT:GetBool() then return end
	if not ply:Alive() or (not ply:OnGround() and ply:WaterLevel() == 0) or ply:GetMoveType() ~= MOVETYPE_WALK then return end

	if cmd:GetButtons():band(IN_FORWARD:bor(IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) == 0 then
		ply.__lastPressHEV = false
		ply.__lastPressHEV2 = false
		return
	end

	local newHev = cmd:GetButtons():band(IN_SPEED) ~= 0
	local statusChanged = newHev ~= ply.__lastPressHEV
	local statusChanged2 = newHev ~= ply.__lastPressHEV2
	ply.__lastPressHEV = newHev
	ply.__lastPressHEV2 = newHev

	if newHev and ply:LimitedHEVGetPower() <= SPRINT_LIMIT_ACT:GetFloat() and statusChanged then
		cmd:SetButtons(cmd:GetButtons():band(IN_SPEED:bnot()))
		ply.__lastPressHEV = false

		if statusChanged2 then
			ply:EmitSoundPredicted('HL2Player.SprintNoPower')
		end

		return
	end

	if not ply:IsSuitEquipped() and not ply:InVehicle() then
		cmd:SetButtons(cmd:GetButtons():band(IN_SPEED:bnot()))
		return
	end

	if ply:LimitedHEVGetPower() <= 0 then
		cmd:SetButtons(cmd:GetButtons():band(IN_SPEED:bnot()))
		ply.__lastPressHEV = false
		ply.__lastPressHEV2 = true
		return
	end

	if cmd:GetButtons():band(IN_SPEED) ~= 0 then
		if statusChanged then
			ply:EmitSoundPredicted('HL2Player.SprintStart')
		end

		local fldata = ply._fldata
		fldata.suit_power = (fldata.suit_power - (delta or FrameTime()) * 10 * SPRINT_MUL:GetFloat()):clamp(0, 100)
		fldata.suit_last_frame = false
		fldata.suit_restore_start = CurTimeL() + POWER_RESTORE_DELAY:GetFloat()
	end
end

local math = math
local FrameTime = FrameTime
local hook = hook

local function ProcessWater(ply, fldata, ctime, toRemove)
	local waterLevel = ply:InVehicle() and ply:GetVehicle():WaterLevel() or ply:WaterLevel()
	local restoring = waterLevel <= 2

	fldata.ox_Value = (fldata.ox_Value or 100):clamp(0, 100)
	fldata.oxygen_next_choke = fldata.oxygen_next_choke or 0
	fldata.oxygen_hp_lost = fldata.oxygen_hp_lost or 0
	fldata.oxygen_hp_restore_next = fldata.oxygen_hp_restore_next or 0

	if restoring then
		if SERVER and WATER_RESTORE:GetBool() and fldata.oxygen_hp_lost > 0 and fldata.oxygen_hp_restore_next < CurTimeL() then
			local hp, mhp = ply:Health(), ply:GetMaxHealth()
			local toRestore = fldata.oxygen_hp_lost:min(WATER_RESTORE_SPEED:GetFloat(), mhp - hp):max(0)

			if toRestore > 0 then
				if hook.Run('CanRestoreOxygenHealth', ply, fldata.oxygen_hp_lost, toRestore) ~= false then
					fldata.oxygen_hp_restore_next = CurTimeL() + 1
					fldata.oxygen_hp_lost = fldata.oxygen_hp_lost - toRestore
					ply:SetHealth(mhp:min(hp + toRestore))
				end
			else
				fldata.oxygen_hp_lost = 0
			end
		end

		return
	end

	toRemove = toRemove * WATER_RATIO:GetFloat() * 7

	if not ply:IsSuitEquipped() then
		toRemove = toRemove * WATER_RATIO_MUL:GetFloat()
	end

	toRemove = toRemove:min(fldata.suit_power)

	if fldata.suit_power > 0 then
		if hook.Run('CanLoseHEVPower', ply, fldata.suit_power, toRemove) == false then return end
	end

	fldata.suit_last_frame = false
	fldata.suit_restore_start = ctime + POWER_RESTORE_DELAY:GetFloat()
	fldata.oxygen_hp_restore_next = ctime + WATER_RESTORE_PAUSE:GetFloat()
	fldata.suit_power = (fldata.suit_power - toRemove):clamp(0, 100)

	if fldata.suit_power > 0 then return end
	if fldata.oxygen_next_choke > ctime then return end

	local can = hook.Run('CanChoke', ply)
	if can == false then return end

	ply:EmitSound('player/pl_drown' .. math.random(1, 3) .. '.wav', 55)
	fldata.oxygen_next_choke = ctime + WATER_CHOKE_RATIO:GetFloat()
	if CLIENT then return end

	local dmg = DamageInfo()
	dmg:SetAttacker(Entity(0))
	dmg:SetInflictor(Entity(0))
	dmg:SetDamageType(DMG_DROWN)
	dmg:SetDamage(WATER_CHOKE_DMG:GetFloat())

	local oldhp = ply:Health()
	ply:TakeDamageInfo(dmg)
	local newhp = ply:Health()

	if WATER_RESTORE:GetBool() then
		fldata.oxygen_hp_lost = fldata.oxygen_hp_lost + math.max(0, oldhp - newhp) * WATER_RESTORE_RATIO:GetFloat()
	end
end

local function ProcessSuit(ply, fldata, ctime, toAdd)
	fldata.suit_power = (fldata.suit_power or 100):clamp(0, 100)
	fldata.suit_restore_start = fldata.suit_restore_start or 0

	if fldata.suit_restore_start < ctime and fldata.suit_last_frame then
		fldata.suit_power = (fldata.suit_power + FrameTime() * POWER_RESTORE_MUL:GetFloat() * 7):clamp(0, 100)
	end

	fldata.suit_last_frame = true
end

local function ProcessFlashlight(ply, fldata, ctime, toAdd)
	fldata.fl_Value = (fldata.fl_Value or 100):clamp(0, 100)
	fldata.fl_Wait = fldata.fl_Wait or 0

	local isOn = ply:FlashlightIsOn()

	if isOn then
		toAdd = -toAdd * FLASHLIGHT_RATIO:GetFloat() / 50 * (1 + math.pow((100 - fldata.fl_Value) / 75, 2))

		if fldata.fl_Value ~= 0 then
			local can = hook.Run('CanDischargeFlashlight', ply, fldata.fl_Value, toAdd)
			if can == false then return end
		end

		fldata.fl_Wait = ctime + FLASHLIGHT_PAUSE:GetFloat()
	else
		if fldata.fl_Value >= 100 then return end
		if fldata.fl_Wait > ctime then return end
		toAdd = toAdd * FLASHLIGHT_RRATIO:GetFloat() / 200 * math.pow(fldata.fl_Value / 35 + 1, 2)

		local can = hook.Run('CanChargeFlashlight', ply, fldata.fl_Value, toAdd)
		if can == false then return end
	end

	fldata.fl_Value = (fldata.fl_Value + toAdd):clamp(0, 100)

	if fldata.fl_Value == 0 and ply:FlashlightIsOn() then
		if SERVER then
			ply:Flashlight(false)
			net.Start('LimitedHEV.SyncFlashLight')
			net.WriteBool(false)
			net.Send(ply)
		end

		fldata.fl_EWait = fldata.fl_Wait + FLASHLIGHT_EPAUSE:GetFloat()
	end
end

local _PlayerPostThink

local function PlayerPostThink(ply)
	if CLIENT and not IsFirstTimePredicted() then return end
	_PlayerPostThink(ply)
end

function _PlayerPostThink(ply)
	ply._fldata = ply._fldata or {}
	local fldata = ply._fldata

	local ctime = CurTimeL()

	if not ply:Alive() then
		fldata.suit_power = 100
		fldata.suit_restore_start = 0
		fldata.suit_last_frame = true

		fldata.oxygen_next_choke = 0
		fldata.oxygen_hp_lost = 0
		fldata.oxygen_hp_restore_next = 0

		fldata.fl_Value = 100
		fldata.fl_Wait = 0
		fldata.fl_EWait = 0
		return
	end

	ply._fldata.last = ply._fldata.last or ctime
	local delta = ctime - ply._fldata.last
	ply._fldata.last = ctime

	if WATER:GetBool() then
		ProcessWater(ply, fldata, ctime, delta)
	end

	ProcessSuit(ply, fldata, ctime, delta)

	if FLASHLIGHT:GetBool() then
		ProcessFlashlight(ply, fldata, ctime, delta)
	end

	--[[if fldata._suit_power == fldata.suit_power and fldata.fl_Value_Send == fldata.fl_Value then return end

	net.Start('LimitedHEVPower', true)
	net.WriteFloat(fldata.suit_power or 100)
	net.WriteFloat(fldata.fl_Value or 100)
	net.Send(ply)

	fldata._suit_power = fldata.suit_power
	fldata.fl_Value_Send = fldata.fl_Value]]
end

local plyMeta = FindMetaTable('Player')

function plyMeta:LimitedHEVGetPowerFillage()
	if not self._fldata then return 1 end
	return self._fldata.suit_power / 100
end

function plyMeta:LimitedHEVGetFlashlightFillage()
	if not self._fldata then return 1 end
	return self._fldata.fl_Value / 100
end

function plyMeta:LimitedHEVGetPower()
	if not self._fldata then return 100 end
	return self._fldata.suit_power
end

function plyMeta:LimitedHEVGetFlashlight()
	if not self._fldata then return 100 end
	return self._fldata.fl_Value
end

function plyMeta:LimitedHEVSetPower(value)
	assert(SERVER or self == LocalPlayer(), 'Tried to use a non local player!')
	if not self._fldata then self._fldata = {} end
	self._fldata.suit_power = assert(type(value) == 'number' and value, 'Value must be a number!'):floor():clamp(0, 100)
end

function plyMeta:LimitedHEVSetFlashlight(value)
	assert(SERVER or self == LocalPlayer(), 'Tried to use a non local player!')
	if not self._fldata then self._fldata = {} end
	self._fldata.fl_Value = assert(type(value) == 'number' and value, 'Value must be a number!'):floor():clamp(0, 100)
end

hook.Add('PlayerPostThink', 'LimitedHEVPower', PlayerPostThink, 2)
hook.Add('StartCommand', 'LimitedHEV', StartCommand, 3)

if CLIENT and game.SinglePlayer() then
	hook.Remove('PlayerPostThink', 'LimitedHEVPower')

	hook.Add('Think', 'LimitedHEVPower Сингл От Сорса Сука', function()
		_PlayerPostThink(LocalPlayer())
	end)
end
