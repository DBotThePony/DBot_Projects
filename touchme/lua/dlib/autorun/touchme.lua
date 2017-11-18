
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

local DLib = DLib
local CAMI = CAMI
local SERVER = SERVER
local CLIENT = CLIENT
local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
local MOVETYPE_NONE = MOVETYPE_NONE
local MOVETYPE_WALK = MOVETYPE_WALK
local hook = hook
local IN_ATTACK = IN_ATTACK
local table = table
local ipairs = ipairs
local IsValid = IsValid
local util = util
local engine = engine

local ENABLED = DLib.util.CreateSharedConvar('sv_touchme_enabled', '1', 'Enable Touch Me serverside')
local ENABLED_SANDBOX = DLib.util.CreateSharedConvar('sv_touchme_sandbox', '1', 'Sandbox has no restrictions')
DLib.nw.poolBoolean('touchme_nono', false)

local schat

if CLIENT then
	CreateConVar('cl_touchme_enabled', '1', {FCVAR_USERINFO, FCVAR_ARCHIVE}, 'Enable Touch Me')
	DLib.chat.registerChat('touchme', Color(0, 200, 0), '[Touch Me] ', Color(200, 200, 200))
else
	schat = DLib.chat.generate('touchme', schat)
end

CAMI.RegisterPrivilege({
	Name = 'touchme_nochecks',
	MinAccess = 'admin',
	Description = 'Whatever Touch Me ignores exploits checks. This should be a rank with regular ability to pickup players.'
})

local Watchdog = DLib.CAMIWatchdog('TouchMe', 10, 'touchme_nochecks')

DLib.friends.Register('touchme', 'Touch me~', true)
DLib.getinfo.Replicate('cl_touchme_enabled')

local trackedPlayers = {}

local function PhysgunPickup(ply, ent)
	if not ent:IsPlayer() then return end
	if ent:InVehicle() then return end

	local mv = ent:GetMoveType()
	if mv ~= MOVETYPE_WALK and mv ~= MOVETYPE_NOCLIP then return end

	if ply:GetInfoBool('cl_touchme_enabled', true) and ent:GetInfoBool('cl_touchme_enabled', true) and ent:CheckDLibFriendIn(ply, 'touchme') then
		if SERVER then
			ent.__TouchMeStatus = true
			ent.__TouchMePickuper = ply
			ent:SetMoveType(MOVETYPE_NONE)
			ent.__TouchMeLastPos = nil

			table.insert(trackedPlayers, ent)
		end

		return true
	end
end

local function StartCommand(ply, cmd)
	if ply:DLibVar('touchme_nono') and ply:GetActiveWeaponClass() == 'weapon_physgun' and cmd:KeyDown(IN_ATTACK) then
		cmd:RemoveKey(IN_ATTACK)
	end
end

hook.Add('PhysgunPickup', 'TouchMe', PhysgunPickup)
hook.Add('StartCommand', 'TouchMe', StartCommand)

if SERVER then
	local function PhysgunDrop(ply, ent)
		if not ent:IsPlayer() then return end
		if not ent.__TouchMeStatus then return end
		ent.__TouchMeStatus = false
		ent:SetMoveType(MOVETYPE_WALK)

		for i, ply2 in ipairs(trackedPlayers) do
			if ply2 == ent then
				table.remove(trackedPlayers, i)
				break
			end
		end
	end

	local function Think()
		if not ENABLED:GetBool() then return end
		if ENABLED_SANDBOX:GetBool() and engine.ActiveGamemode() == 'sandbox' then return end

		for i, ply in ipairs(trackedPlayers) do
			if not ply:IsValid() then
				table.remove(trackedPlayers, i)
				break
			end

			local ply2 = ply:GetTable()
			local pickuper = ply2.__TouchMePickuper

			if not IsValid(pickuper) then
				table.remove(trackedPlayers, i)
				break
			end

			if not Watchdog:HasPermission(pickuper, 'touchme_nochecks') then
				local pos = ply:GetPos()
				ply2.__TouchMeLastPos = ply2.__TouchMeLastPos or pos

				local tr = util.TraceLine({
					start = ply2.__TouchMeLastPos,
					endpos = pos,
					filter = {ply, pickuper}
				})

				if tr.Hit then
					schat.chatPlayer(pickuper, 'No no and no! Bad pone!')
					ply:SetPos(ply2.__TouchMeLastPos)
					pickuper:SetDLibVar('touchme_nono', true)

					timer.Create('DLib.touchmeno.' .. pickuper:SteamID(), 2, 1, function()
						if IsValid(pickuper) then
							pickuper:SetDLibVar('touchme_nono', false)
						end
					end)
				else
					ply2.__TouchMeLastPos = pos
				end
			end
		end
	end

	hook.Add('PhysgunDrop', 'TouchMe', PhysgunDrop)
	hook.Add('Think', 'TouchMe', Think)
end
