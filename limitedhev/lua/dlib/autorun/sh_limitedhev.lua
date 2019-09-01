
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

DLib.pred.Define('LimitedHEVPower', 'Float', 100)
DLib.pred.Define('LimitedHEVPowerRestoreStart', 'Float', 0)
DLib.pred.Define('LimitedHEVSuitLastPower', 'Bool', true)
DLib.pred.Define('LimitedHEVSuitDarn', 'Bool', false)

DLib.pred.Define('LimitedHEVOxygenNextChoke', 'Float', 0)
DLib.pred.Define('LimitedHEVHPLost', 'Int', 0)
DLib.pred.Define('LimitedHEVHPNext', 'Float', 0)
DLib.pred.Define('FlashlightCharge', 'Float', 100)
DLib.pred.Define('FlashlightNext', 'Float', 0)
DLib.pred.Define('FlashlightENext', 'Float', 0)

-- IsFirstTimePredicted is always false on client realm
-- in this hook, so
local function SetupMove(ply, movedata, cmd)
	if not SPRINT:GetBool() then return end
	if not ply:Alive() or (not ply:OnGround() and ply:WaterLevel() == 0) or ply:GetMoveType() ~= MOVETYPE_WALK then return end

	if movedata:GetButtons():band(IN_FORWARD:bor(IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) == 0 then
		return
	end

	local whut = movedata:KeyPressed(IN_SPEED) ~= ply.__lsp_whut
	ply.__lsp_whut = movedata:KeyPressed(IN_SPEED)

	if movedata:KeyPressed(IN_SPEED) and (ply:GetLimitedHEVPower() <= SPRINT_LIMIT_ACT:GetFloat() or ply:GetLimitedHEVSuitDarn()) then
		movedata:SetButtons(movedata:GetButtons():band(IN_SPEED:bnot()))
		movedata:SetMaxClientSpeed(ply:GetWalkSpeed())

		if whut then
			ply:EmitSoundPredicted('HL2Player.SprintNoPower')
		end

		return
	end

	if (not ply:IsSuitEquipped() or ply:GetLimitedHEVPower() <= 0) and not ply:InVehicle() then
		movedata:SetButtons(movedata:GetButtons():band(IN_SPEED:bnot()))
		movedata:SetMaxClientSpeed(ply:GetWalkSpeed())

		if ply:GetLimitedHEVPower() <= 0 then
			ply:SetLimitedHEVSuitDarn(true)
			hook.Run('LimitedHEVPlayerExhausted', ply, IsFirstTimePredicted())
		end

		return
	end

	if movedata:KeyDown(IN_SPEED) then
		if movedata:KeyPressed(IN_SPEED) then
			ply:EmitSoundPredicted('HL2Player.SprintStart')
		end

		ply:AddLimitedHEVPower(-FrameTime() * 15 * SPRINT_MUL:GetFloat(), 0, 100)
		ply:SetLimitedHEVSuitLastPower(false)
		ply:SetLimitedHEVPowerRestoreStart(CurTime() + POWER_RESTORE_DELAY:GetFloat())
	end
end

local math = math
local FrameTime = FrameTime
local hook = hook

local function ProcessWater(ply, fldata, ctime, toRemove)
	local waterLevel = ply:InVehicle() and ply:GetVehicle():WaterLevel() or ply:WaterLevel()
	local restoring = waterLevel <= 2

	if restoring then
		if SERVER and WATER_RESTORE:GetBool() and ply:GetLimitedHEVHPLost() > 0 and ply:GetLimitedHEVHPNext() < CurTimeL() then
			local hp, mhp = ply:Health(), ply:GetMaxHealth()
			local toRestore = ply:GetLimitedHEVHPLost():min(WATER_RESTORE_SPEED:GetFloat(), mhp - hp):max(0)

			if toRestore > 0 then
				if hook.Run('CanRestoreOxygenHealth', ply, fldata.oxygen_hp_lost, toRestore) ~= false then
					ply:SetLimitedHEVHPNext(CurTimeL() + 1)
					ply:AddLimitedHEVHPLost(-toRestore)
					ply:SetHealth(mhp:min(hp + toRestore))
				end
			else
				ply:SetLimitedHEVHPLost(0)
			end
		end

		return
	end

	toRemove = toRemove * WATER_RATIO:GetFloat() * 7

	if not ply:IsSuitEquipped() then
		toRemove = toRemove * WATER_RATIO_MUL:GetFloat()
	end

	toRemove = toRemove:min(ply:GetLimitedHEVPower())

	if ply:GetLimitedHEVPower() > 0 then
		if hook.Run('CanLoseHEVPower', ply, ply:GetLimitedHEVPower(), toRemove) == false then return end
	end

	ply:SetLimitedHEVSuitLastPower(false)
	ply:SetLimitedHEVPowerRestoreStart(ctime + POWER_RESTORE_DELAY:GetFloat())
	ply:SetLimitedHEVHPNext(ctime + WATER_RESTORE_PAUSE:GetFloat())
	ply:AddLimitedHEVPower(-toRemove, 0, 100)

	if ply:GetLimitedHEVPower() > 0 or ply:GetLimitedHEVOxygenNextChoke() > ctime then return end

	local can = hook.Run('CanChoke', ply, toRemove)
	if can == false then return end

	ply:EmitSound('player/pl_drown' .. math.random(1, 3) .. '.wav', 55)
	ply:SetLimitedHEVOxygenNextChoke(CurTime() + WATER_CHOKE_RATIO:GetFloat())
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
		ply:AddLimitedHEVHPLost(math.max(0, oldhp - newhp) * WATER_RESTORE_RATIO:GetFloat())
	end
end

local function ProcessSuit(ply, fldata, ctime, toAdd)
	if ply:GetLimitedHEVPowerRestoreStart() < ctime and ply:GetLimitedHEVSuitLastPower() and (ply:OnGround() or ply:GetMoveType() ~= MOVETYPE_WALK) then
		ply:AddLimitedHEVPower(FrameTime() * POWER_RESTORE_MUL:GetFloat() * 7, 0, 100)

		if ply:GetLimitedHEVPower() >= 100 then
			ply:SetLimitedHEVSuitDarn(false)
			hook.Run('LimitedHEVPlayerRecovered', ply, IsFirstTimePredicted())
		end
	end

	ply:SetLimitedHEVSuitLastPower(true)
end

local function ProcessFlashlight(ply, fldata, ctime, toAdd)
	if ply:FlashlightIsOn() then
		toAdd = toAdd * FLASHLIGHT_RATIO:GetFloat() / 50 * (1 + math.pow((100 - ply:GetFlashlightCharge()) / 75, 2))

		if ply:GetFlashlightCharge() ~= 0 then
			local can = hook.Run('CanDischargeFlashlight', ply, ply:GetFlashlightCharge(), toAdd)
			if can == false then return end
		end

		ply:SetFlashlightNext(ctime + FLASHLIGHT_PAUSE:GetFloat())
		ply:AddFlashlightCharge(-toAdd, 0, 100)

		if ply:GetFlashlightCharge() == 0 and ply:FlashlightIsOn() then
			if SERVER then
				ply:Flashlight(false)
			end

			ply:SetFlashlightENext(ctime + FLASHLIGHT_PAUSE:GetFloat() + FLASHLIGHT_EPAUSE:GetFloat())
		end

		return
	end

	if ply:GetFlashlightCharge() >= 100 or ply:GetFlashlightNext() > ctime then return end
	toAdd = toAdd * FLASHLIGHT_RRATIO:GetFloat() / 200 * math.pow(ply:GetFlashlightCharge() / 35 + 1, 2)

	local can = hook.Run('CanChargeFlashlight', ply, ply:GetFlashlightCharge(), toAdd)
	if can == false then return end

	ply:AddFlashlightCharge(toAdd, 0, 100)
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
		ply:ResetLimitedHEVPower()
		ply:ResetLimitedHEVPowerRestoreStart()
		ply:ResetLimitedHEVSuitLastPower()

		ply:ResetLimitedHEVOxygenNextChoke()
		ply:ResetLimitedHEVHPLost()
		ply:ResetLimitedHEVHPNext()

		ply:ResetFlashlightCharge()
		ply:ResetFlashlightNext()
		return
	end

	if WATER:GetBool() then
		ProcessWater(ply, fldata, ctime, FrameTime())
	end

	ProcessSuit(ply, fldata, ctime, FrameTime())

	if FLASHLIGHT:GetBool() then
		ProcessFlashlight(ply, fldata, ctime, FrameTime())
	end
end

local plyMeta = FindMetaTable('Player')

function plyMeta:LimitedHEVGetPowerFillage()
	return self:GetLimitedHEVPower():progression(0, 100)
end

function plyMeta:LimitedHEVGetFlashlightFillage()
	return self:GetFlashlightCharge():progression(0, 100)
end

hook.Add('PlayerPostThink', 'LimitedHEVPower', PlayerPostThink, 2)
hook.Add('SetupMove', 'LimitedHEV', SetupMove, 3)
hook.Remove('StartCommand', 'LimitedHEV', StartCommand, 3)

if CLIENT and game.SinglePlayer() then
	hook.Remove('PlayerPostThink', 'LimitedHEVPower')

	hook.Add('Think', 'LimitedHEVPower Сингл От Сорса Сука', function()
		_PlayerPostThink(LocalPlayer())
	end)
end
