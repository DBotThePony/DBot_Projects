
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
	ent:SetDLibVar('dsit_flag', true)
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

local function checkNormal(ply, normal)
	local normalCheck = normal:Angle()
	normalCheck.p = normalCheck.p - 270

	if normalCheck.p > 20 or normalCheck.p < -20 then
		messaging.chatPlayer(ply, 'Invalid sitting angle (pitch is ', normalCheck.p, ' when should <> +-20)')
		return false
	end

	if normalCheck.r > 20 or normalCheck.r < -20 then
		messaging.chatPlayer(ply, 'Invalid sitting angle (roll is ', normalCheck.r, ' when should <> +-20)')
		return false
	end

	return true
end

local function request(ply)
	if not DSitConVars:getBool('enable') then return end
	if not IsValid(ply) then return end
	if not ply:Alive() then return end

	local maxVelocity = DSitConVars:getFloat('speed_val')

	if maxVelocity > 0 then
		if ply:GetVelocity():Length() >= maxVelocity then
			messaging.chatPlayer(ply, 'You are moving too fast!')
			return
		end
	end

	local mins, maxs = ply:GetHull()
	local eyes = ply:EyePos()
	local ppos = ply:GetPos() + Vector(0, 0, 2)
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

	local tr = util.TraceLine(trDataLine)
	local trh = util.TraceHull(trDataHull)

	if not tr.Hit then
		return
	end

	if tr.Entity ~= trh.Entity then
		messaging.chatPlayer(ply, 'Position is unreachable')
		return
	end

	local isPlayer, isEntity, isSitting, entSit, parent = false, false, false, NULL, false
	local ent = tr.Entity

	if IsValid(ent) then
		if not DSitConVars:getBool('entities') then
			messaging.chatPlayer(ply, 'Sitting on entities is disabled')
			return
		end

		if type(ent) == 'NPC' or type(ent) == 'NextBot' then
			messaging.chatPlayer(ply, 'You cant sit on NPCs')
			return
		end

		if maxVelocity > 0 then
			if ent:GetVelocity():Length() >= maxVelocity then
				messaging.chatPlayer(ply, 'Target is moving too fast!')
				return
			end
		end

		isPlayer = type(ent) == 'Player'
		isEntity = true

		if isPlayer then
			entSit = ent:GetVehicle()

			if IsValid(entSit) then
				isSitting = entSit:DLibVar('dsit_flag')
			end
		else
			isSitting = ent:DLibVar('dsit_flag')
			entSit = ent
		end

		parent = not isPlayer and not isSitting
	end

	local targetPos, targetAngles

	if isPlayer then
		if not DSitConVars:getBool('players') then
			messaging.chatPlayer(ply, 'Sitting on players is disabled')
			return
		end

		if not ent:GetInfoBool('cl_dsit_allow_on_me', true) then
			messaging.chatPlayer(ply, 'Target player disallowed sitting on him')
			return
		end

		do
			local target = ent:GetInfoBool('cl_dsit_friendsonly', false)
			local me = ply:GetInfoBool('cl_dsit_friendsonly', false)
			local isFriends = ply:IsFriend(ent) and ent:IsFriend(ply)

			if (target or me) and not isFriends then
				messaging.chatPlayer(ply, 'One or both of players has cl_dsit_friendsonly set to 1 and you are not friends')
				return
			end
		end

		targetAngles = ent:EyeAngles()
		targetPos = ent:EyePos()

		targetAngles.p = 0
		targetAngles.r = 0
	elseif isSitting then
		if not DSitConVars:getBool('players_legs') then
			messaging.chatPlayer(ply, 'Sitting on players legs is disabled')
			return
		end

		targetAngles = entSit:GetAngles()
		targetPos = entSit:GetPos() + targetAngles:Forward() * 7 + targetAngles:Up() * 3
	elseif isEntity then
		if DSitConVars:getBool('entities_world') and IsValid(ent:CPPIGetOwner()) then
			messaging.chatPlayer(ply, 'Sitting is allowed only on non owned entities')
			return
		end

		if DSitConVars:getBool('entities_owner') and ent:CPPIGetOwner() ~= ply then
			messaging.chatPlayer(ply, 'Sitting is allowed only on entities owned by you')
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

		if tr.HitPos:Distance(ply:GetPos()) < 30 then
			targetAngles = ply:EyeAngles()
			targetAngles.y = targetAngles.y
			targetAngles.r = 0
			targetAngles.p = 0

			targetPos = tr.HitPos
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

			targetPos = tr.HitPos

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
	end

	-- ulx hack
	-- will remove after i release DAdmin
	if ply:GetMoveType() == MOVETYPE_NONE or ply:GetMoveType() == MOVETYPE_OBSERVER then
		messaging.chatPlayer(ply, 'You can not sit right now')
		return
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
			messaging.chatPlayer(ply, 'Target player restricted amount of sitting on him (', max, ' is max)')
			return
		end
	end

	local vehicle = makeVehicle(ply, targetPos, targetAngles)
	local can = hook.Run('CanPlayerEnterVehicle', ply, vehicle) ~= false

	if not can then
		messaging.chatPlayer(ply, 'You can not sit right now')
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

	if weaponry then
		if flashlight then ply:Flashlight(flashlight) end
	end

	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	if parent then
		vehicle:SetParent(ent)
	elseif isSitting then
		vehicle.dsit_player_root = ent.dsit_player_root
	elseif isPlayer then
		vehicle:SetDLibVar('dsit_target', ent)
		vehicle.dsit_player_root = ent

		net.Start('DSit.VehicleTick')
		net.WriteEntity(vehicle)
		net.Broadcast()

		DSIT_TRACKED_VEHICLES:insert(vehicle)
	end

	if vehicle.dsit_player_root then
		vehicle.dsit_player_root.dsit_root_sitting_on = vehicle.dsit_player_root.dsit_root_sitting_on + 1
	end

	vehicle:SetDLibVar('dsit_entity', ply)
	ply:SetDLibVar('dsit_entity', vehicle)
end

local function dsit_getoff(ply)
	if not IsValid(ply) then return end

	for i, vehicle in DSIT_TRACKED_VEHICLES:ipairs() do
		if IsValid(vehicle) then
			local ent = vehicle:DLibVar('dsit_target')

			if ent == ply then
				vehicle:GetDriver():ExitVehicle()
			end
		end
	end
end

concommand.Add('dsit', request)
concommand.Add('dsit_getoff', dsit_getoff)

_G.DSIT_REQUEST_DEBUG = request

local attemptToFind = table()

for x = -1, 1 do
	for y = -1, 1 do
		attemptToFind:insert(Vector(x * 40, y * 40, 5))
	end
end

local function PostLeave(ply, vehPos)
	local space = DLib.Freespace(vehPos + Vector(0, 0, 1), 25, 5)
	local mins, maxs = ply:GetHull()
	local h = maxs.z - mins.z
	mins.z = 0
	maxs.z = 0
	space:setAABB(mins, maxs)
	space:setSAABB(mins * 1.2, maxs * 1.2)
	space:setStrict(true)
	space:SetStrictHeight(h)
	space.filter:addArray(player.GetAll())
	local position = space:search()

	if position then
		ply:SetPos(position)
	else
		for i, shift in attemptToFind:ipairs() do
			space:SetPos(vehPos + shift)
			position = space:search()

			if position then
				ply:SetPos(position)
				return
			end
		end
	end

	ply:SetPos(vehPos)
end

local function PlayerLeaveVehicle(ply, vehicle)
	if not vehicle:DLibVar('dsit_flag') then return end

	if IsValid(vehicle.dsit_player_root) then
		vehicle.dsit_player_root.dsit_root_sitting_on = vehicle.dsit_player_root.dsit_root_sitting_on - 1
	else
		if ply.dsit_old_eyes then ply:SetEyeAngles(ply.dsit_old_eyes) end
	end

	vehicle:Remove()

	local vehPos = vehicle:GetPos()

	timer.Simple(0, function()
		if not IsValid(ply) then return end
		PostLeave(ply, vehPos)
	end)
end

hook.Add('PlayerLeaveVehicle', 'DSit', PlayerLeaveVehicle)
