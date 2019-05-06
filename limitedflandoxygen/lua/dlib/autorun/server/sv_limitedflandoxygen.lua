
--[[
Copyright (C) 2016-2019 DBotThePony


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

]]

net.pool('DBot_LFAO')

local WATER = CreateConVar('sv_limited_oxygen', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable limited oxygen')
local WATER_RESTORE = CreateConVar('sv_limited_oxygen_restore', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Restore health that player lost while drowing')
local WATER_RESTORE_RATIO = CreateConVar('sv_limited_oxygen_restorer', '0.8', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Multipler of returned health')
local WATER_RESTORE_SPEED = CreateConVar('sv_limited_oxygen_restores', '4', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Speed for restoring health in HP/s')
local WATER_PAUSE = CreateConVar('sv_limited_oxygen_pause', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Seconds to wait before starting restoring oxygen')
local WATER_CHOKE_RATIO = CreateConVar('sv_limited_oxygen_choke', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Delay of choke in seconds')
local WATER_CHOKE_DMG = CreateConVar('sv_limited_oxygen_choke_dmg', '4', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Damage of choke')
local WATER_RATIO = CreateConVar('sv_limited_oxygen_ratio', '100', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of draining oxygen from player')
local WATER_RRATIO = CreateConVar('sv_limited_oxygen_restore_ratio', '500', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of restoring oxygen')

local FLASHLIGHT = CreateConVar('sv_limited_flashlight', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable limited flashlight')
local FLASHLIGHT_RATIO = CreateConVar('sv_limited_flashlight_ratio', '100', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of draining power from flashlight')
local FLASHLIGHT_RRATIO = CreateConVar('sv_limited_flashlight_restore_ratio', '500', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of restoring power of flashlight')
local FLASHLIGHT_PAUSE = CreateConVar('sv_limited_flashlight_pause', '4', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Seconds to wait before starting restoring power of flashlight')
local FLASHLIGHT_EPAUSE = CreateConVar('sv_limited_flashlight_epause', '2', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Seconds to wait before granting player ability to enable his flashlight after starting power restoring')

local math = math
local FrameTime = FrameTime
local hook = hook

local function Water(ply)
	local fldata = ply._fldata
	local waterLevel = ply:InVehicle() and ply:GetVehicle():WaterLevel() or ply:WaterLevel()
	local restoring = waterLevel <= 2

	fldata.ox_Value = (fldata.ox_Value or 100):clamp(0, 100)
	fldata.ox_Next = fldata.ox_Next or 0
	fldata.ox_NextChoke = fldata.ox_NextChoke or 0
	fldata.ox_Restore = fldata.ox_Restore or 0
	fldata.ox_RestoreNext = fldata.ox_RestoreNext or 0

	local toAdd = FrameTime()

	if restoring then
		if WATER_RESTORE:GetBool() and fldata.ox_Restore > 0 and fldata.ox_RestoreNext < CurTimeL() then
			if hook.Run('CanRestoreOxygenHealth', ply, fldata.ox_Restore) ~= false then
				fldata.ox_RestoreNext = CurTimeL() + 1
				local hp, mhp = ply:Health(), ply:GetMaxHealth()
				local percent = hp / mhp
				local toRestore = math.min(fldata.ox_Restore, WATER_RESTORE_SPEED:GetFloat())
				fldata.ox_Restore = math.max(fldata.ox_Restore - WATER_RESTORE_SPEED:GetFloat(), 0)

				if percent < 1 then
					ply:SetHealth(math.min(hp + toRestore, mhp))
				end
			end
		end

		if fldata.ox_Value >= 100 then return end
		if fldata.ox_Next > CurTimeL() then return end

		toAdd = toAdd * WATER_RRATIO:GetFloat() / 25
		if hook.Run('CanRestoreOxygen', ply, fldata.ox_Value, toAdd) == false then return end
	else
		toAdd = -toAdd * WATER_RATIO:GetFloat() / 25

		if fldata.ox_Value ~= 0 then
			if hook.Run('CanLooseOxygen', ply, fldata.ox_Value, toAdd) == false then return end
		end

		fldata.ox_Next = CurTimeL() + WATER_PAUSE:GetFloat()
		fldata.ox_RestoreNext = fldata.ox_Next + 1
	end

	fldata.ox_Value = math.clamp(fldata.ox_Value + toAdd, 0, 100)

	if fldata.ox_Value ~= 0 then return end
	if fldata.ox_NextChoke > CurTimeL() then return end

	local can = hook.Run('CanChoke', ply)
	if can == false then return end

	local dmg = DamageInfo()
	dmg:SetAttacker(Entity(0))
	dmg:SetInflictor(Entity(0))
	dmg:SetDamageType(DMG_DROWN)
	dmg:SetDamage(WATER_CHOKE_DMG:GetFloat())

	local oldhp = ply:Health()
	ply:TakeDamageInfo(dmg)
	local newhp = ply:Health()

	if WATER_RESTORE:GetBool() then
		fldata.ox_Restore = fldata.ox_Restore + math.max(0, oldhp - newhp) * WATER_RESTORE_RATIO:GetFloat()
	end

	ply:EmitSound('player/pl_drown' .. math.random(1, 3) .. '.wav', 55)

	fldata.ox_NextChoke = CurTimeL() + WATER_CHOKE_RATIO:GetFloat()
end

local function Flashlight(ply)
	local fldata = ply._fldata
	fldata.fl_Value = (fldata.fl_Value or 100):clamp(0, 100)
	fldata.fl_Wait = fldata.fl_Wait or 0

	local isOn = ply:FlashlightIsOn()
	local toAdd = FrameTime()

	if isOn then
		toAdd = -toAdd * FLASHLIGHT_RATIO:GetFloat() / 50 * (1 + math.pow((100 - fldata.fl_Value) / 75, 2))

		if fldata.fl_Value ~= 0 then
			local can = hook.Run('CanDischargeFlashlight', ply, fldata.fl_Value, toAdd)
			if can == false then return end
		end

		fldata.fl_Wait = CurTimeL() + FLASHLIGHT_PAUSE:GetFloat()
	else
		if fldata.fl_Value >= 100 then return end
		if fldata.fl_Wait > CurTimeL() then return end
		toAdd = toAdd * FLASHLIGHT_RRATIO:GetFloat() / 200 * math.pow(fldata.fl_Value / 50 + 1, 2)

		local can = hook.Run('CanChargeFlashlight', ply, fldata.fl_Value, toAdd)
		if can == false then return end
	end

	fldata.fl_Value = math.clamp(fldata.fl_Value + toAdd, 0, 100)

	if fldata.fl_Value == 0 and ply:FlashlightIsOn() then
		ply:Flashlight(false)
		fldata.fl_EWait = fldata.fl_Wait + FLASHLIGHT_EPAUSE:GetFloat()
	end
end

local function PlayerSwitchFlashlight(ply, enabled)
	if not FLASHLIGHT:GetBool() then return end
	if not enabled then return end
	local fldata = ply._fldata
	if not fldata then return end
	if fldata.fl_Value == 0 then return false end
	if fldata.fl_EWait and fldata.fl_EWait > CurTimeL() then return false end
end

local function PlayerSpawn(ply)
	ply._fldata = ply._fldata or {}
	local fldata = ply._fldata

	fldata.ox_Value = 100
	fldata.ox_Next = 0
	fldata.ox_NextChoke = 0
	fldata.ox_Restore = 0
	fldata.ox_RestoreNext = 0

	fldata.fl_Value = 100
	fldata.fl_Wait = 0
	fldata.fl_EWait = 0
end

local function PlayerPostThink(ply)
	if not ply:Alive() then return end
	ply._fldata = ply._fldata or {}
	local fldata = ply._fldata

	if WATER:GetBool() then Water(ply) end
	if FLASHLIGHT:GetBool() then Flashlight(ply) end

	if fldata.ox_Value_Send == fldata.ox_Value and fldata.fl_Value_Send == fldata.fl_Value then return end

	net.Start('DBot_LFAO', true)
	net.WriteFloat(fldata.ox_Value or 100)
	net.WriteFloat(fldata.fl_Value or 100)
	net.Send(ply)

	fldata.ox_Value_Send = fldata.ox_Value
	fldata.fl_Value_Send = fldata.fl_Value
end

local plyMeta = FindMetaTable('Player')

function plyMeta:LFAOGetOxygenFillage()
	if not self._fldata then return 1 end
	return self._fldata.ox_Value / 100
end

function plyMeta:LFAOGetFlashlightFillage()
	if not self._fldata then return 1 end
	return self._fldata.fl_Value / 100
end

function plyMeta:LFAOGetOxygen()
	if not self._fldata then return 100 end
	return self._fldata.ox_Value
end

function plyMeta:LFAOGetFlashlight()
	if not self._fldata then return 100 end
	return self._fldata.fl_Value
end

function plyMeta:LFAOSetOxygen(value)
	if not self._fldata then self._fldata = {} end
	self._fldata.ox_Value = assert(type(value) == 'number' and value, 'Value must be a number!'):floor():clamp(0, 100)
end

function plyMeta:LFAOSetFlashlight(value)
	if not self._fldata then self._fldata = {} end
	self._fldata.fl_Value = assert(type(value) == 'number' and value, 'Value must be a number!'):floor():clamp(0, 100)
end

hook.Add('PlayerPostThink', 'DBot_LFAO', PlayerPostThink)
hook.Add('PlayerSwitchFlashlight', 'DBot_LFAO', PlayerSwitchFlashlight)
hook.Add('PlayerSpawn', 'DBot_LFAO', PlayerSpawn)
