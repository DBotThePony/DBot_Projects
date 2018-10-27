
-- Copyright (C) 2017-2018 DBot

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
local MAX_RANGE = DLib.util.CreateSharedConvar('sv_touchme_range', '1024', 'Maximal range to pickup friends. Set to 0 to disable.')

local schat

if CLIENT then
	CreateConVar('cl_touchme_enabled', '1', {FCVAR_USERINFO, FCVAR_ARCHIVE}, 'Enable Touch Me')
	schat = DLib.chat.registerWithMessages({}, 'Touch Me')
	DLib.RegisterAddonName('Touch Me')
else
	schat = DLib.chat.generate('Touch Me', schat)
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
	if not ENABLED:GetBool() then return end
	if not ent:IsPlayer() then return end
	if ent:InVehicle() then return end

	local mv = ent:GetMoveType()
	if mv ~= MOVETYPE_WALK and mv ~= MOVETYPE_NOCLIP then return end
	if MAX_RANGE:GetInt() > 0 and ply:GetPos():Distance(ent:GetPos()) > MAX_RANGE:GetInt() then return end

	if ply:GetInfoBool('cl_touchme_enabled', true) and ent:GetInfoBool('cl_touchme_enabled', true) and ent:CheckDLibFriendIn(ply, 'touchme') then
		if SERVER then
			ent.__TouchMeStatus = true
			ent.__TouchMePickuper = ply
			ent:SetMoveType(MOVETYPE_NONE)
			ent.__TouchMeLastPos = nil
			ent.__TouchMeLastPositions = nil
			ply.__TouchMeTarget = ent

			table.insert(trackedPlayers, ent)
		end

		return true
	end
end

local function StartCommand(ply, cmd)
	if ply:GetActiveWeaponClass() == 'weapon_physgun' and cmd:KeyDown(IN_ATTACK) then
		if ply:GetNW2Bool('touchme_nono') then
			cmd:RemoveKey(IN_ATTACK)
			return
		end

		local target = ply.__TouchMeTarget

		if IsValid(target) and MAX_RANGE:GetInt() <= target:GetPos():Distance(ply:GetPos()) then
			cmd:RemoveKey(IN_ATTACK)
			target:SetPos(ply:EyeAngles():Forward() * MAX_RANGE:GetInt() * 1.1 + ply:EyePos())
			return
		end
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
		ply.__TouchMeTarget = nil

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
				local pos = ply:GetPos() + ply:OBBCenter()
				ply2.__TouchMeLastPositions = ply2.__TouchMeLastPositions or {}
				local positions = ply2.__TouchMeLastPositions
				table.insert(positions, pos)

				if #positions > 5 then
					table.remove(positions, 1)
				end

				local hit = false

				for i, oldpos in ipairs(positions) do
					for i, oldpos2 in ipairs(positions) do
						if oldpos2 ~= oldpos1 then
							local tr = util.TraceLine({
								start = oldpos,
								endpos = pos,
								filter = {ply, pickuper}
							})

							if tr.Hit then
								schat.LChatPlayer(pickuper, 'message.touchme.exploit_hit')
								ply:SetPos(positions[1])
								pickuper:SetNW2Bool('touchme_nono', true)

								timer.Create('DLib.touchmeno.' .. pickuper:SteamID(), 2, 1, function()
									if IsValid(pickuper) then
										pickuper:SetNW2Bool('touchme_nono', false)
									end
								end)

								ply2.__TouchMeLastPositions = {}
								hit = true

								break
							end
						end

						if hit then
							break
						end
					end

					if hit then
						break
					end
				end
			end
		end
	end

	hook.Add('PhysgunDrop', 'TouchMe', PhysgunDrop)
	hook.Add('Think', 'TouchMe', Think)
end
