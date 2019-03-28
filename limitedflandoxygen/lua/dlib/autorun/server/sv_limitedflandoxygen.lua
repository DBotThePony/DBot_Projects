
--[[
Copyright (C) 2016-2018 DBot


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

util.AddNetworkString('DBot_LimitedFlashlightAndOxygen')

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

local function Water(ply)
	local plyt = ply:GetTable()
	local waterLevel = ply:InVehicle() and ply:GetVehicle():WaterLevel() or ply:WaterLevel()
	local restoring = waterLevel <= 2

	plyt.__Limited_Oxygen_Value = math.Clamp(plyt.__Limited_Oxygen_Value or 100, 0, 100)
	plyt.__Limited_Oxygen_Next = plyt.__Limited_Oxygen_Next or 0
	plyt.__Limited_Oxygen_NextChoke = plyt.__Limited_Oxygen_NextChoke or 0
	plyt.__Limited_Oxygen_Restore = plyt.__Limited_Oxygen_Restore or 0
	plyt.__Limited_Oxygen_RestoreNext = plyt.__Limited_Oxygen_RestoreNext or 0

	local toAdd = FrameTime()

	if restoring then
		if WATER_RESTORE:GetBool() and plyt.__Limited_Oxygen_Restore > 0 then
			if plyt.__Limited_Oxygen_RestoreNext < CurTimeL() then
				local can = hook.Run('CanRestoreOxygenHealth', ply, plyt.__Limited_Oxygen_Restore)
				if can ~= false then
					plyt.__Limited_Oxygen_RestoreNext = CurTimeL() + 1
					local hp, mhp = ply:Health(), ply:GetMaxHealth()
					local percent = hp / mhp
					local toRestore = math.min(plyt.__Limited_Oxygen_Restore, WATER_RESTORE_SPEED:GetFloat())
					plyt.__Limited_Oxygen_Restore = math.max(plyt.__Limited_Oxygen_Restore - WATER_RESTORE_SPEED:GetFloat(), 0)

					if percent < 1 then
						ply:SetHealth(math.min(hp + toRestore, mhp))
					end
				end
			end
		end

		if plyt.__Limited_Oxygen_Value == 100 then return end
		if plyt.__Limited_Oxygen_Next > CurTimeL() then return end

		toAdd = toAdd * WATER_RRATIO:GetFloat() / 25
		local can = hook.Run('CanRestoreOxygen', ply, plyt.__Limited_Oxygen_Value, toAdd)
		if can == false then return end
	else
		toAdd = -toAdd * WATER_RATIO:GetFloat() / 25

		if plyt.__Limited_Oxygen_Value ~= 0 then
			local can = hook.Run('CanLooseOxygen', ply, plyt.__Limited_Oxygen_Value, toAdd)
			if can == false then return end
		end

		plyt.__Limited_Oxygen_Next = CurTimeL() + WATER_PAUSE:GetFloat()
		plyt.__Limited_Oxygen_RestoreNext = plyt.__Limited_Oxygen_Next + 1
	end

	plyt.__Limited_Oxygen_Value = math.Clamp(plyt.__Limited_Oxygen_Value + toAdd, 0, 100)

	if plyt.__Limited_Oxygen_Value == 0 then
		if plyt.__Limited_Oxygen_NextChoke > CurTimeL() then return end
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
			plyt.__Limited_Oxygen_Restore = plyt.__Limited_Oxygen_Restore + math.max(0, oldhp - newhp) * WATER_RESTORE_RATIO:GetFloat()
		end

		ply:EmitSound('player/pl_drown' .. math.random(1, 3) .. '.wav', 55)

		plyt.__Limited_Oxygen_NextChoke = CurTimeL() + WATER_CHOKE_RATIO:GetFloat()
	end
end

local function Flashlight(ply)
	local plyt = ply:GetTable()
	plyt.__Limited_Flashlight_Value = math.Clamp(plyt.__Limited_Flashlight_Value or 100, 0, 100)
	plyt.__Limited_Flashlight_Wait = plyt.__Limited_Flashlight_Wait or 0
	plyt.__Limited_Flashlight_EWait = plyt.__Limited_Flashlight_EWait or 0

	--ply:PrintMessage(HUD_PRINTCONSOLE, tostring(plyt.__Limited_Flashlight_Value))

	local isOn = ply:FlashlightIsOn()
	local toAdd = FrameTime()

	if isOn then
		toAdd = -toAdd * FLASHLIGHT_RATIO:GetFloat() / 50 * (1 + math.pow((100 - plyt.__Limited_Flashlight_Value) / 75, 2))

		if plyt.__Limited_Flashlight_Value ~= 0 then
			local can = hook.Run('CanDischargeFlashlight', ply, plyt.__Limited_Flashlight_Value, toAdd)
			if can == false then return end
		end

		plyt.__Limited_Flashlight_Wait = CurTimeL() + FLASHLIGHT_PAUSE:GetFloat()
	else
		if plyt.__Limited_Flashlight_DisabledByMe and plyt.__Limited_Flashlight_EWait < CurTimeL() then
			ply:AllowFlashlight(true)
			plyt.__Limited_Flashlight_DisabledByMe = nil
		end

		if plyt.__Limited_Flashlight_Value == 100 then return end
		if plyt.__Limited_Flashlight_Wait > CurTimeL() then return end
		toAdd = toAdd * FLASHLIGHT_RRATIO:GetFloat() / 200 * math.pow(plyt.__Limited_Flashlight_Value / 50 + 1, 2)

		local can = hook.Run('CanChargeFlashlight', ply, plyt.__Limited_Flashlight_Value, toAdd)
		if can == false then return end
	end

	plyt.__Limited_Flashlight_Value = math.Clamp(plyt.__Limited_Flashlight_Value + toAdd, 0, 100)

	if plyt.__Limited_Flashlight_Value == 0 and ply:CanUseFlashlight() and not plyt.__Limited_Flashlight_DisabledByMe then
		ply:Flashlight(false)
		ply:AllowFlashlight(false)
		plyt.__Limited_Flashlight_EWait = plyt.__Limited_Flashlight_Wait + FLASHLIGHT_EPAUSE:GetFloat()
		plyt.__Limited_Flashlight_DisabledByMe = true
	end
end

local function PlayerSpawn(ply)
	ply.__Limited_Oxygen_Value = 100
	ply.__Limited_Oxygen_Next = 0
	ply.__Limited_Oxygen_NextChoke = 0
	ply.__Limited_Oxygen_Restore = 0
	ply.__Limited_Oxygen_RestoreNext = 0

	ply.__Limited_Flashlight_Value = 100
	ply.__Limited_Flashlight_Wait = 0
	ply.__Limited_Flashlight_EWait = 0

	if ply.__Limited_Flashlight_DisabledByMe then
		ply:AllowFlashlight(true)
		ply.__Limited_Flashlight_DisabledByMe = nil
	end
end

local function PlayerPostThink(ply)
	if not ply:Alive() then return end
	if WATER:GetBool() then Water(ply) end
	if FLASHLIGHT:GetBool() then Flashlight(ply) end

	if ply.__Limited_Oxygen_Value_Send == ply.__Limited_Oxygen_Value and ply.__Limited_Flashlight_Value_Send == ply.__Limited_Flashlight_Value then return end

	net.Start('DBot_LimitedFlashlightAndOxygen', true)
	net.WriteFloat(ply.__Limited_Oxygen_Value or 100)
	net.WriteFloat(ply.__Limited_Flashlight_Value or 100)
	net.Send(ply)

	ply.__Limited_Oxygen_Value_Send = ply.__Limited_Oxygen_Value
	ply.__Limited_Flashlight_Value_Send = ply.__Limited_Flashlight_Value
end

hook.Add('PlayerPostThink', 'DBot_LimitedFlashlightAndOxygen', PlayerPostThink)
hook.Add('PlayerSpawn', 'DBot_LimitedFlashlightAndOxygen', PlayerSpawn)
