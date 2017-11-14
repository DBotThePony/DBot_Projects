
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local ENABLED = DLib.util.CreateSharedConvar('sv_touchme_enabled', '1', 'Enable Touch Me serverside')

DLib.friends.Register('touchme', 'Touch me~', true)

local function PhysgunPickup(ply, ent)
	if not ent:IsPlayer() then return end
	if ent:InVehicle() then return end

	local mv = ent:GetMoveType()
	if mv ~= MOVETYPE_WALK and mv ~= MOVETYPE_NOCLIP then return end

	if ply:GetInfoBool('cl_touchme_enabled', true) and ent:GetInfoBool('cl_touchme_enabled', true) and ent:CheckDLibFriendIn(ply, 'touchme') then
		if SERVER then
			ent.__TouchMeStatus = true
			ent:SetMoveType(MOVETYPE_NONE)
		end

		return true
	end
end

hook.Add('PhysgunPickup', 'TouchMe', PhysgunPickup)

if SERVER then
	local function PhysgunDrop(ply, ent)
		if not ent:IsPlayer() then return end
		if not ent.__TouchMeStatus then return end
		ent.__TouchMeStatus = false
		ent:SetMoveType(MOVETYPE_WALK)
	end

	hook.Add('PhysgunDrop', 'TouchMe', PhysgunDrop)
end
