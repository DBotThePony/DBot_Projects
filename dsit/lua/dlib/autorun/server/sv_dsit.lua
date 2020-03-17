
-- Copyright (C) 2017-2019 DBotThePony

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


local _, messaging = DLib.MessageMaker({}, 'DSit')
DLib.chat.generate('DSit', messaging)

net.pool('DSit.VehicleTick')

local DSIT_TRACKED_VEHICLES = _G.DSIT_TRACKED_VEHICLES

local function makeVehicle(owner, pos, ang)
	local ent = ents.Create('prop_vehicle_prisoner_pod')
	ent:SetModel('models/nova/airboat_seat.mdl')
	ent:SetKeyValue('vehiclescript', 'scripts/vehicles/prisoner_pod.txt')
	ent:SetKeyValue('limitview', '0')
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()

	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:SetNWBool('dsit_flag', true)
	ent:SetNotSolid(true)
	ent:DrawShadow(false)
	ent:SetColor(TRANSLUCENT)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetNoDraw(true)

	if owner and ent.CPPISetOwner then
		ent:CPPISetOwner(owner)
	end

	local phys = ent:GetPhysicsObject()

	if IsValid(phys) then
		phys:Sleep()
		phys:EnableGravity(false)
		phys:EnableMotion(false)
		phys:EnableCollisions(false)
		phys:SetMass(1)
	end

	return ent
end

local function inRange(x, min, max)
	return x > min and x < max
end

local function checkNormal(ply, normal)
	local normalCheck = normal:Angle()
	normalCheck.p = normalCheck.p - 270

	if not inRange(normalCheck.p, -20, 20) and (not DSitConVars:getBool('allow_ceiling') or not inRange(normalCheck.p, -190, -170) and not inRange(normalCheck.p, 170, 190)) then
		messaging.LChatPlayer2(ply, 'message.dsit.check.pitch', normalCheck.p)
		return false
	end

	if normalCheck.r > 20 or normalCheck.r < -20 then
		messaging.LChatPlayer2(ply, 'message.dsit.check.roll', normalCheck.r)
		return false
	end

	return true
end

-- this is stupid
local function PlayerPostThink(ply)
	if not ply.__dsit_request then return end
	local args = ply.__dsit_request
	ply.__dsit_request = nil
	local maxVelocity = DSitConVars:getFloat('speed_val')

	if not ply:Alive() then return end
	-- if ply.dsit_pickup then return end

	if ply:InVehicle() then return end

	local mins, maxs = ply:GetHull()
	local eyes = ply:EyePos()
	local spos = ply:GetPos()
	local ppos = spos + ply:OBBCenter()
	local fwd = ply:EyeAngles():Forward()
	maxs.z = 0
	mins.z = 0

	local trDataLine = {
		start = eyes,
		endpos = eyes + fwd * DSitConVars:getFloat('distance'),
		filter = ply
	}

	local trDataHull = {
		start = ppos,
		endpos = trDataLine.endpos,
		filter = ply,
		mins = mins,
		maxs = maxs,
	}

	ply:LagCompensation(true)
	local tr = util.TraceLine(trDataLine)
	local trh = util.TraceHull(trDataHull)
	ply:LagCompensation(false)

	if not tr.Hit then
		return
	end

	if IsValid(tr.Entity) and tr.Entity:GetClass():startsWith('func_door') then
		return
	end

	if not (type(trh.Entity) == 'Player' and not IsValid(tr.Entity)) then
		if type(tr.Entity) ~= 'Player' and tr.Entity ~= trh.Entity then
			messaging.LChatPlayer2(ply, 'message.dsit.check.unreachable')
			return
		end
	end

	local isPlayer, isEntity, isNPC, isSitting, entSit, parent = false, false, false, false, NULL, false
	local ent = tr.Entity

	if IsValid(ent) then
		if not DSitConVars:getBool('entities') then
			messaging.LChatPlayer2(ply, 'message.dsit.status.entities')
			return
		end

		if type(ent) == 'NPC' or type(ent) == 'NextBot' then
			if not DSitConVars:getBool('npcs') then
				messaging.LChatPlayer2(ply, 'message.dsit.status.npc')
				return
			end

			isNPC = true
		end

		if maxVelocity > 0 then
			if ent:GetVelocity():Length() >= maxVelocity then
				messaging.LChatPlayer2(ply, 'message.dsit.status.toofast')
				return
			end
		end

		isPlayer = type(ent) == 'Player'
		isEntity = true

		if isPlayer then
			entSit = ent:GetVehicle()

			if IsValid(entSit) then
				isSitting = entSit:GetNWBool('dsit_flag')
			end

			parent = false
		--elseif isNPC then
		--	parent = false
		else
			isSitting = ent:GetNWBool('dsit_flag')
			entSit = ent
			parent = not isSitting
		end

		if ent.dsit_player_root == ply and ent:InVehicle() then
			messaging.LChatPlayer2(ply, 'message.dsit.status.recursion')
			return
		end

		if ent.dsit_player_root == ply and not ent:InVehicle() then
			ent.dsit_player_root = nil
		end
	end

	local targetPos, targetAngles
	local upsideDown = false

	print(isPlayer, isEntity, isNPC, isSitting)

	if isSitting then
		if not DSitConVars:getBool('players_legs') then
			messaging.LChatPlayer2(ply, 'message.dsit.status.nolegs')
			return
		end

		targetAngles = entSit:GetAngles()
		local fwdAngles = entSit:GetAngles()
		fwdAngles.p = 0
		fwdAngles.r = 0
		fwdAngles.y = fwdAngles.y + 90
		targetPos = entSit:GetPos() + fwdAngles:Forward() * 16 + targetAngles:Up() * 8
	elseif isPlayer then
		if not DSitConVars:getBool('players') then
			messaging.LChatPlayer2(ply, 'message.dsit.status.noplayers')
			return
		end

		if not ent:GetInfoBool('cl_dsit_allow_on_me', true) then
			messaging.LChatPlayer2(ply, 'message.dsit.status.diasallowed')
			return
		end

		do
			local target = ent:GetInfoBool('cl_dsit_friendsonly', false)
			local me = ply:GetInfoBool('cl_dsit_friendsonly', false)
			local isFriends = ply:CheckDLibFriendIn2(ent, 'dsit') and ent:CheckDLibFriendIn2(ply, 'dsit')

			if (target or me) and not isFriends then
				messaging.LChatPlayer2(ply, 'message.dsit.status.friendsonly')
				return
			end
		end

		targetAngles = ent:EyeAngles()
		targetPos = ent:EyePos()

		targetAngles.p = 0
		targetAngles.r = 0
	elseif isNPC then
		targetAngles = ent:EyeAngles()
		targetAngles.y = targetAngles.y - 90
		targetPos = ent:EyePos()

		if type(ent) == 'NextBot' then
			targetPos = ent:GetPos()
			targetPos.z = targetPos.z + ent:OBBMaxs().z
		end

		targetAngles.p = 0
		targetAngles.r = 0
	elseif isEntity then
		if DSitConVars:getBool('entities_world') and IsValid(ent:CPPIGetOwner()) then
			messaging.LChatPlayer2(ply, 'message.dsit.status.nonowned')
			return
		end

		if DSitConVars:getBool('entities_owner') and ent:CPPIGetOwner() ~= ply then
			messaging.LChatPlayer2(ply, 'message.dsit.status.onlyowned')
			return
		end

		if not DSitConVars:getBool('anyangle') and not checkNormal(ply, tr.HitNormal) then
			return
		end

		targetAngles = ply:EyeAngles()

		if tr.HitPos:Distance(ply:GetPos()) < 30 then
			targetAngles.y = targetAngles.y + 90
		else
			targetAngles.y = targetAngles.y - 90
		end

		targetAngles.r = 0
		targetAngles.p = 0

		targetPos = tr.HitPos + tr.HitNormal * 2
	else
		if not DSitConVars:getBool('anyangle') and not checkNormal(ply, tr.HitNormal) then
			return
		end

		local normalAngle = tr.HitNormal:Angle()
		normalAngle.p = normalAngle.p - 270

		targetPos = tr.HitPos - tr.HitNormal * 2

		if tr.HitPos:Distance(ply:GetPos()) < 30 then
			targetAngles = ply:EyeAngles()
			targetAngles.y = targetAngles.y
			targetAngles.r = 0
			targetAngles.p = 0
		else
			local fwdang = ply:EyeAngles()
			fwdang.p = 0
			fwdang.r = 0

			local trForward = util.TraceLine({
				start = tr.HitPos + tr.HitNormal * 2,
				endpos = tr.HitPos + tr.HitNormal * 2 + fwdang:Forward() * 40,
				filter = ply
			})

			local unhit = true

			if not trForward.Hit then
				local newTr2 = util.TraceLine({
					start = trForward.HitPos + tr.HitNormal * 10,
					endpos = trForward.HitPos - tr.HitNormal * 10,
					filter = ply
				})

				if not newTr2.Hit or newTr2.Fraction > 0.65 then
					unhit = false
					targetAngles = ply:EyeAngles()
					targetAngles.r = 0
					targetAngles.p = 0
					targetAngles.y = targetAngles.y - 180
				end
			end

			if unhit then
				targetAngles = ply:EyeAngles()
				targetAngles.y = targetAngles.y
				targetAngles.r = 0
				targetAngles.p = 0
			end
		end

		targetAngles.y = targetAngles.y + 90

		if normalAngle.p > 170 or normalAngle.p < -170 then
			targetAngles.y = targetAngles.y - 180
			targetAngles.p = targetAngles.p - 180
			upsideDown = true
		end
	end

	if isPlayer or isSitting then
		local findRoot

		if isPlayer then
			findRoot = ent
		else
			findRoot = ent.dsit_player_root
		end

		findRoot.dsit_root_sitting_on = findRoot.dsit_root_sitting_on or 0
		local max = findRoot:GetInfoInt('cl_dsit_maxonme')

		if max > 0 and max <= findRoot.dsit_root_sitting_on then
			messaging.LChatPlayer2(ply, 'message.dsit.status.restricted', '(', max, ')')
			return
		end
	end

	local vehicle = makeVehicle(ply, targetPos, targetAngles)
	local can = ply:IsBot() or hook.Run('CanPlayerEnterVehicle', ply, vehicle) ~= false

	if not can then
		messaging.LChatPlayer2(ply, 'message.dsit.status.hook')
		vehicle:Remove()
		return
	end

	local weaponry = DSitConVars:getBool('allow_weapons')
	local flashlight

	if weaponry then
		ply.dsit_weapons = ply:GetAllowWeaponsInVehicle()
		ply:SetAllowWeaponsInVehicle(true)
		flashlight = ply:FlashlightIsOn()
	end

	ply.dsit_old_eyes = ply:EyeAngles()
	ply:DropObject()
	ply:EnterVehicle(vehicle)
	ply:SetEyeAngles(Angle(0, 90, 0))
	ply.dsit_spos = spos

	if weaponry then
		if flashlight then ply:Flashlight(flashlight) end
	end

	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	if parent then
		vehicle:SetParent(ent)
	elseif isSitting then
		vehicle.dsit_player_root = ent.dsit_player_root
		vehicle:SetParent(entSit)
	--[==[elseif isNPC then
		vehicle:SetNWEntity('dsit_target', ent)

		--[[timer.Simple(0.5, function()
			net.Start('DSit.VehicleTick')
			net.WriteEntity(vehicle)
			net.Broadcast()
		end)]]

		table.insert(DSIT_TRACKED_VEHICLES, vehicle)]==]
	elseif isPlayer then
		ply.dsit_player_root = ent.dsit_player_root or ent
		vehicle:SetNWEntity('dsit_target', ent)
		vehicle.dsit_player_root = ent

		timer.Simple(0.5, function()
			net.Start('DSit.VehicleTick')
			net.WriteEntity(vehicle)
			net.Broadcast()
		end)

		table.insert(DSIT_TRACKED_VEHICLES, vehicle)
	end

	if vehicle.dsit_player_root then
		vehicle.dsit_player_root.dsit_root_sitting_on = (vehicle.dsit_player_root.dsit_root_sitting_on or 0) + 1
		vehicle:SetNWEntity('dsit_player_root', vehicle.dsit_player_root)
	end

	vehicle.dsit_upsideDown = upsideDown

	vehicle:SetNWEntity('dsit_entity', ply)
	ply:SetNWEntity('dsit_entity', vehicle)
end

local function request(ply, args)
	if not DSitConVars:getBool('enable') then return end
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
	-- if ply.dsit_pickup then return end

	if ply:InVehicle() then return end

	local maxVelocity = DSitConVars:getFloat('speed_val')

	if maxVelocity > 0 then
		if ply:GetVelocity():Length() >= maxVelocity then
			messaging.LChatPlayer2(ply, 'message.dsit.sit.toofast')
			return
		end
	end

	ply.__dsit_request = args or {}
end

local tonumber = tonumber

local function dsit_getoff(ply, cmd, args)
	if not IsValid(ply) then return end

	local tokick = tonumber((args[1] or ''):trim())
	local pkick = Entity(tokick or -1)

	if pkick:IsValid() then
		for i, vehicle in ipairs(DSIT_TRACKED_VEHICLES) do
			if IsValid(vehicle) then
				if vehicle:GetNWEntity('dsit_player_root', NULL) == ply and vehicle:GetDriver() == pkick then
					vehicle:GetDriver():ExitVehicle()
					break
				end
			end
		end
	else
		for i, vehicle in ipairs(DSIT_TRACKED_VEHICLES) do
			if IsValid(vehicle) then
				local ent = vehicle:GetNWEntity('dsit_target')

				if ent == ply then
					vehicle:GetDriver():ExitVehicle()
				end
			end
		end
	end
end

concommand.Add('dsit', function(a, b, c) request(a, c) end)
concommand.Add('dsit_getoff', dsit_getoff)

_G.DSIT_REQUEST_DEBUG = request

local attemptToFind = {}

for x = -2, 2 do
	for y = -2, 2 do
		table.insert(attemptToFind, Vector(x * 40, y * 40, 5))
	end
end

local function PostLeave(ply, vehPos, upsideDown)
	if upsideDown then
		local tr = util.TraceLine({
			start = vehPos - Vector(0, 0, 5),
			endpos = vehPos - Vector(0, 0, 400),
			filter = ply
		})

		vehPos = tr.HitPos + tr.HitNormal * 2
	end

	if ply.dsit_weapons ~= nil then
		ply:SetAllowWeaponsInVehicle(ply.dsit_weapons)
		ply.dsit_weapons = nil
	end

	local space = DLib.Freespace(vehPos + Vector(0, 0, 5), 25, 5)
	local mins, maxs = ply:GetHull()
	space:SetAABB(mins, maxs)
	space:SetSAABB(mins, maxs)
	space:SetStrict(false)
	space:SetMaskReachable(MASK_VISIBLE_AND_NPCS)
	space.filter:addArray(player.GetAll())
	local position = space:SearchOptimal()

	if position then
		ply:SetPos(position)
		return
	end

	--[[for i, shift in ipairs(attemptToFind) do
		space:SetPos(vehPos + shift)
		position = space:Search()

		if position then
			ply:SetPos(position)
			return
		end
	end]]

	messaging.LChatPlayer2(ply, 'info.dsit.nopos')
	ply:SetPos(ply.dsit_spos or vehPos)
end

local function PlayerLeaveVehicle(ply, vehicle)
	if not vehicle:GetNWBool('dsit_flag') then return end

	if IsValid(vehicle.dsit_player_root) then
		vehicle.dsit_player_root.dsit_root_sitting_on = (vehicle.dsit_player_root.dsit_root_sitting_on or 1) - 1
	else
		if ply.dsit_old_eyes then ply:SetEyeAngles(ply.dsit_old_eyes) end
	end

	ply.dsit_player_root = nil
	local upsideDown = vehicle.dsit_upsideDown

	local vehPos = vehicle:GetPos()

	vehicle:Remove()

	timer.Simple(0, function()
		if not IsValid(ply) then return end
		PostLeave(ply, vehPos, upsideDown)
	end)
end

local function PlayerDeath(ply)
	ply.dsit_player_root = nil
	ply:SetNWBool('dsit_flag', false)
end

local function PlayerSay(ply, text)
	if ply:GetInfoBool('cl_dsit_message', true) and text:lower():find('get off') then
		dsit_getoff(ply, 'dsit_getoff', {})
	end
end

hook.Add('PlayerLeaveVehicle', 'DSit', PlayerLeaveVehicle)
hook.Add('PlayerDeath', 'DSit', PlayerDeath)
hook.Add('PlayerSay', 'DSit', PlayerSay)
hook.Add('PlayerPostThink', 'DSit', PlayerPostThink)
