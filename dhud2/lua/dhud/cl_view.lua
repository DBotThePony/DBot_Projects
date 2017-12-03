
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
local LocalPlayer = LocalPlayer

local function CalcView(newData)
	local ply = LocalPlayer()
	if not ENABLE:GetBool() or not DHUD2.ServerConVar('smoothview') or not DHUD2.IsEnabled() then
		if newData then
			DHUD2.EyePos = newData.origin
			DHUD2.EyeAngles = newData.angles
		else
			DHUD2.EyePos = EyePos()
			DHUD2.EyeAngles = EyeAngles()
		end

		DHUD2.PredictedEntity = DHUD2.SelectPlayer()
		return newData
	end

	local inVehicle = ply:InVehicle()

	-- Sharpeye already has it
	if not (not sharpeye or sharpeye and sharpeye.IsEnabled and sharpeye.IsEnabled()) then return newData end
	local veh = ply:GetVehicle()

	newData.origin = newData.origin or EyePos()	
	newData.angles = newData.angles or EyeAngles()	

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
			if ent:IsPlayer() or ent:GetSolid() == SOLID_NONE or ent:IsWeapon() or ent:GetOwner():IsValid() or ent:GetParent():IsValid() then goto CNT end
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

			::CNT::
		end

		if not hit then
			DHUD2.PredictedEntity = LocalPlayer()
		end
	else
		DHUD2.PredictedEntity = LocalPlayer()
	end

	return newData
end

hook.AddPostModifier('CalcView', 'DHUD2.CalcView', CalcView)
