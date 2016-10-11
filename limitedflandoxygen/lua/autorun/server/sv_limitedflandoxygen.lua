
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

util.AddNetworkString('DBot_LimitedFlashlightAndOxygen')

local WATER = CreateConVar('sv_limited_oxygen', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable limited oxygen')
local WATER_RESTORE = CreateConVar('sv_limited_oxygen_restore', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Restore health that player lost while drowing')
local WATER_RESTORE_RATIO = CreateConVar('sv_limited_oxygen_restorer', '0.8', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Multipler of returned health')
local WATER_RESTORE_SPEED = CreateConVar('sv_limited_oxygen_restores', '4', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Speed for restoring health in HP/s')
local WATER_PAUSE = CreateConVar('sv_limited_oxygen_pause', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Seconds to wait before starting restoring oxygen')
local WATER_CHOKE_RATIO = CreateConVar('sv_limited_oxygen_choke', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Delay of choke in seconds')
local WATER_CHOKE_DMG = CreateConVar('sv_limited_oxygen_choke_dmg', '4', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Damage of choke')
local WATER_RATIO = CreateConVar('sv_limited_oxygen_ratio', '100', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of draining oxygen from player')
local WATER_RRATIO = CreateConVar('sv_limited_oxygen_restore_ratio', '500', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of restoring oxygen')

local function Water(ply)
	local waterLevel = ply:InVehicle() and ply:GetVehicle():WaterLevel() or ply:WaterLevel()
	local restoring = waterLevel <= 2
	
	ply.__Limited_Oxygen_Value = math.Clamp(ply.__Limited_Oxygen_Value or 100, 0, 100)
	ply.__Limited_Oxygen_Next = ply.__Limited_Oxygen_Next or 0
	ply.__Limited_Oxygen_NextChoke = ply.__Limited_Oxygen_NextChoke or 0
	ply.__Limited_Oxygen_Restore = ply.__Limited_Oxygen_Restore or 0
	ply.__Limited_Oxygen_RestoreNext = ply.__Limited_Oxygen_RestoreNext or 0
	
	local toAdd = FrameTime()
	
	if restoring then
		if WATER_RESTORE:GetBool() and ply.__Limited_Oxygen_Restore > 0 then
			if ply.__Limited_Oxygen_RestoreNext < CurTime() then
				local can = hook.Run('CanRestoreOxygenHealth', ply, ply.__Limited_Oxygen_Restore)
				if can ~= false then
					ply.__Limited_Oxygen_RestoreNext = CurTime() + 1
					local hp, mhp = ply:Health(), ply:GetMaxHealth()
					local percent = hp / mhp
					local toRestore = math.min(ply.__Limited_Oxygen_Restore, WATER_RESTORE_SPEED:GetFloat())
					ply.__Limited_Oxygen_Restore = math.max(ply.__Limited_Oxygen_Restore - WATER_RESTORE_SPEED:GetFloat(), 0)
					
					if percent < 1 then
						ply:SetHealth(math.min(hp + toRestore, mhp))
					end
				end
			end
		end
		
		if ply.__Limited_Oxygen_Value == 100 then return end
		if ply.__Limited_Oxygen_Next > CurTime() then return end
		
		toAdd = toAdd * WATER_RRATIO:GetFloat() / 25
		local can = hook.Run('CanRestoreOxygen', ply, ply.__Limited_Oxygen_Value, toAdd)
		if can == false then return end
	else
		toAdd = -toAdd * WATER_RATIO:GetFloat() / 25
		
		if ply.__Limited_Oxygen_Value ~= 0 then
			local can = hook.Run('CanLooseOxygen', ply, ply.__Limited_Oxygen_Value, toAdd)
			if can == false then return end
		end
		
		ply.__Limited_Oxygen_Next = CurTime() + WATER_PAUSE:GetFloat()
		ply.__Limited_Oxygen_RestoreNext = ply.__Limited_Oxygen_Next + 1
	end
	
	ply.__Limited_Oxygen_Value = math.Clamp(ply.__Limited_Oxygen_Value + toAdd, 0, 100)
	
	if ply.__Limited_Oxygen_Value == 0 then
		if ply.__Limited_Oxygen_NextChoke > CurTime() then return end
		local can = hook.Run('CanChoke', ply)
		if can == false then return end
		
		local dmg = DamageInfo()
		dmg:SetAttacker(ply)
		dmg:SetInflictor(ply)
		dmg:SetDamageType(DMG_DROWN)
		dmg:SetDamage(WATER_CHOKE_DMG:GetFloat())
		
		local oldhp = ply:Health()
		ply:TakeDamageInfo(dmg)
		local newhp = ply:Health()
		
		if WATER_RESTORE:GetBool() then
			ply.__Limited_Oxygen_Restore = ply.__Limited_Oxygen_Restore + math.max(0, oldhp - newhp) * WATER_RESTORE_RATIO:GetFloat()
		end
		
		ply:EmitSound('player/pl_drown' .. math.random(1, 3) .. '.wav', 55)
		
		ply.__Limited_Oxygen_NextChoke = CurTime() + WATER_CHOKE_RATIO:GetFloat()
	end
end

local FLASHLIGHT = CreateConVar('sv_limited_flashlight', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable limited flashlight')
local FLASHLIGHT_RATIO = CreateConVar('sv_limited_flashlight_ratio', '100', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of draining power from flashlight')
local FLASHLIGHT_RRATIO = CreateConVar('sv_limited_flashlight_restore_ratio', '500', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Ratio of restoring power of flashlight')
local FLASHLIGHT_PAUSE = CreateConVar('sv_limited_flashlight_pause', '4', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Seconds to wait before starting restoring power of flashlight')
local FLASHLIGHT_EPAUSE = CreateConVar('sv_limited_flashlight_epause', '2', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Seconds to wait before granting player ability to enable his flashlight after starting power restoring')

local function Flashlight(ply)
	ply.__Limited_Flashlight_Value = math.Clamp(ply.__Limited_Flashlight_Value or 100, 0, 100)
	ply.__Limited_Flashlight_Wait = ply.__Limited_Flashlight_Wait or 0
	ply.__Limited_Flashlight_EWait = ply.__Limited_Flashlight_EWait or 0
	
	--ply:PrintMessage(HUD_PRINTCONSOLE, tostring(ply.__Limited_Flashlight_Value))
	
	local isOn = ply:FlashlightIsOn()
	local toAdd = FrameTime()
	
	if isOn then
		toAdd = -toAdd * FLASHLIGHT_RATIO:GetFloat() / 50
		
		if ply.__Limited_Flashlight_Value ~= 0 then
			local can = hook.Run('CanDischargeFlashlight', ply, ply.__Limited_Flashlight_Value, toAdd)
			if can == false then return end
		end
		
		ply.__Limited_Flashlight_Wait = CurTime() + FLASHLIGHT_PAUSE:GetFloat()
	else
		if ply.__Limited_Flashlight_DisabledByMe and ply.__Limited_Flashlight_EWait < CurTime() then
			ply:AllowFlashlight(true)
			ply.__Limited_Flashlight_DisabledByMe = nil
		end
		
		if ply.__Limited_Flashlight_Value == 100 then return end
		if ply.__Limited_Flashlight_Wait > CurTime() then return end
		toAdd = toAdd * FLASHLIGHT_RRATIO:GetFloat() / 50
		
		local can = hook.Run('CanChargeFlashlight', ply, ply.__Limited_Flashlight_Value, toAdd)
		if can == false then return end
	end
	
	ply.__Limited_Flashlight_Value = math.Clamp(ply.__Limited_Flashlight_Value + toAdd, 0, 100)
	
	if ply.__Limited_Flashlight_Value == 0 and ply:CanUseFlashlight() and not ply.__Limited_Flashlight_DisabledByMe then
		ply:Flashlight(false)
		ply:AllowFlashlight(false)
		ply.__Limited_Flashlight_EWait = ply.__Limited_Flashlight_Wait + FLASHLIGHT_EPAUSE:GetFloat()
		ply.__Limited_Flashlight_DisabledByMe = true
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

local function Tick()
	for k, v in ipairs(player.GetAll()) do
		if v:Alive() then
			if WATER:GetBool() then Water(v) end
			if FLASHLIGHT:GetBool() then Flashlight(v) end
			
			net.Start('DBot_LimitedFlashlightAndOxygen')
			net.WriteFloat(v.__Limited_Oxygen_Value or 100, 8)
			net.WriteFloat(v.__Limited_Flashlight_Value or 100, 8)
			net.Send(v)
		end
	end
end

hook.Add('Tick', 'DBot_LimitedFlashlightAndOxygen', Tick)
hook.Add('PlayerSpawn', 'DBot_LimitedFlashlightAndOxygen', PlayerSpawn)
