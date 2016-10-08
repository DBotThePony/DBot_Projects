
--Better View

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


local ENABLE = CreateConVar('dhud_smoothview', '1', FCVAR_ARCHIVE, 'Enable soomth view')
local ENABLE_ALWAYS = CreateConVar('dhud_smoothview_always', '1', FCVAR_ARCHIVE, 'Always enable soomth view (If sharpeye is detected, it is always disabled)')
DHUD2.AddConVar('dhud_smoothview', 'Enable smooth view', ENABLE)
DHUD2.AddConVar('dhud_smoothview_always', 'Always enable soomth view (If sharpeye is detected, it is always disabled)', ENABLE_ALWAYS)
local oldPos, oldAng

local bypass = false

local function CalcView(ply, pos, ang, fov, nearZ, farZ)
	if not ENABLE:GetBool() then return end
	if not DHUD2.ServerConVar('smoothview') then return end
	if not DHUD2.IsEnabled() then return end
	if bypass then return end
	
	local inVehicle = ply:InVehicle()
	local always = ENABLE_ALWAYS:GetBool()
	
	if not always and not inVehicle then return end
	
	--Sharpeye already have it
	if not inVehicle and always and not (not sharpeye or sharpeye and sharpeye.IsEnabled and sharpeye.IsEnabled()) then return end
	local veh = ply:GetVehicle()
	
	local newData
	
	bypass = true
	for k, v in pairs(hook.GetTable().CalcView) do
		local Data = v(ply, pos, ang, fov, nearZ, farZ)
		if Data ~= nil then
			newData = Data
			break
		end
	end
	bypass = false
	
	if not newData then 
		local gm = gmod.GetGamemode()
		
		if gm and gm.CalcView then
			newData = gm:CalcView(ply, pos, ang, fov, nearZ, farZ)
			
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
		else
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
	local newang
	if inVehicle then
		newang = LerpAngle(math.min(0.4 * math.sqrt(DHUD2.Multipler), 1), oldAng, newData.angles)
	else
		newang = LerpAngle(math.min(0.4 * math.sqrt(DHUD2.Multipler), 1), oldAng, newData.angles)
	end
	newData.angles = newang
	oldAng = newang
	
	return newData
end

hook.Add('CalcView', '!DHUD2.VehicleView', CalcView, -1)
