
--Better View

--[[
Copyright (C) 2016-2017 DBot

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

local ENABLE = CreateConVar('dhud_smoothview', '1', FCVAR_ARCHIVE, 'Enable soomth view. Disabling this WILL affect other features.')
DHUD2.AddConVar('dhud_smoothview', 'Enable smooth view', ENABLE)
DHUD2.EyePos = Vector()
DHUD2.EyeAngles = Angle(0, 0, 0)
DHUD2.PredictedEntity = NULL
local oldPos, oldAng
local lastCall = 0
local lastResult

local bypass = false

local function CalcView(ply, pos, ang, fov, nearZ, farZ)
	if not ENABLE:GetBool() or not DHUD2.ServerConVar('smoothview') or not DHUD2.IsEnabled() then
		DHUD2.EyePos = pos
		DHUD2.EyeAngles = ang
		DHUD2.PredictedEntity = DHUD2.SelectPlayer()
		return
	end
	
	if bypass then return end
	
	if lastCall == CurTime() then return lastResult end
	lastCall = CurTime()
	
	local inVehicle = ply:InVehicle()
	
	-- Sharpeye already has it
	if not (not sharpeye or sharpeye and sharpeye.IsEnabled and sharpeye.IsEnabled()) then return end
	local veh = ply:GetVehicle()
	
	local newData
	
	bypass = true
	for k, v in pairs(hook.GetTable().CalcView) do
		if type(k) ~= 'string' and IsValid(k) then
			local Data = v(k, ply, pos, ang, fov, nearZ, farZ)
			if Data ~= nil then
				newData = Data
				break
			end
		else
			local Data = v(ply, pos, ang, fov, nearZ, farZ)
			if Data ~= nil then
				newData = Data
				break
			end
		end
	end
	bypass = false
	
	if not newData then 
		local gm = gmod.GetGamemode()
		
		if gm and gm.CalcView then
			newData = gm:CalcView(ply, pos, ang, fov, nearZ, farZ)
		end

		if not newData then
			newData = {
				origin = pos,
				angles = ang,
				fov = fov,
				znear = nearZ,
				zfar = farZ,
				drawviewer = inVehicle and veh:GetThirdPersonMode(),
			}
		end
	end
	
	oldAng = oldAng or newData.angles
	local newang = LerpAngle(math.min(0.4 * math.sqrt(DHUD2.Multipler or 1), 1), oldAng, newData.angles)
	newData.angles = newang
	oldAng = newang
	
	DHUD2.EyePos = newData.origin
	DHUD2.EyeAngles = newData.angles
	
	if LocalPlayer() ~= DHUD2.SelectPlayer() then
		DHUD2.PredictedEntity = DHUD2.SelectPlayer()
	elseif LocalPlayer():ShouldDrawLocalPlayer() then
		local Ents = ents.FindInSphere(newData.origin, 128)
		local hit = false
		local min = 99999999
		local maxSize = 0
		
		for k = 1, #Ents do
			local ent = Ents[k]
			if ent:IsPlayer() or ent:GetSolid() == SOLID_NONE or ent:IsWeapon() or ent:GetOwner():IsValid() or ent:GetParent():IsValid() then continue end
			local mins, maxs = ent:WorldSpaceAABB()
			
			if mins and maxs then
				local aMins, aMaxs = ent:OBBMins(), ent:OBBMaxs()
				mins = mins + aMins * .4
				maxs = maxs + aMaxs * .4
				local dist = newData.origin:DistToSqr(ent:GetPos())
				local size = mins:DistToSqr(maxs)
				
				if DHUD2.pointInsideBox(newData.origin, mins, maxs) and min > dist and size > maxSize then
					DHUD2.PredictedEntity = ent
					min = dist
					maxSize = size
					hit = true
				end
			end
		end
		
		if not hit then
			DHUD2.PredictedEntity = LocalPlayer()
		end
	else
		DHUD2.PredictedEntity = LocalPlayer()
	end
	
	lastResult = newData
	return newData
end

hook.Add('CalcView', '.DHUD2.CalcView', CalcView, -1)
