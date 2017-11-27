
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

	if (normalCheck.p > 20 or normalCheck.p < -20) and (not DSitConVars:getBool('allow_ceiling') or not (normalCheck.p > 170 or normalCheck.p < -170)) then
		messaging.chatPlayer2(ply, 'Invalid sitting angle (pitch is ', normalCheck.p, ' when should <> +-20 or -180)')
		return false
	end

	if normalCheck.r > 20 or normalCheck.r < -20 then
		messaging.chatPlayer2(ply, 'Invalid sitting angle (roll is ', normalCheck.r, ' when should <> +-20)')
		return false
	end

	return true
end

local function request(ply)
	if not DSitConVars:getBool('enable') then return end
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
	-- if ply.dsit_pickup then return end

	if ply:InVehicle() then return end

	local maxVelocity = DSitConVars:getFloat('speed_val')

	if maxVelocity > 0 then
		if ply:GetVelocity():Length() >= maxVelocity then
			messaging.chatPlayer2(ply, 'You are moving too fast!')
			return
		end
	end

	local mins, maxs = ply:GetHull()
	maxs.z = maxs.z * 0.5
	local eyes = ply:EyePos()
	local ppos = ply:GetPos() + ply:OBBCenter()
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

	if not (type(trh.Entity) == 'Player' and not IsValid(tr.Entity)) then
		if type(tr.Entity) ~= 'Player' and tr.Entity ~= trh.Entity then
			messaging.chatPlayer2(ply, 'Position is unreachable')
			return
		end
	end

	local isPlayer, isEntity, isSitting, entSit, parent = false, false, false, NULL, false
	local ent = tr.Entity

	if IsValid(ent) then
		if not DSitConVars:getBool('entities') then
			messaging.chatPlayer2(ply, 'Sitting on entities is disabled')
			return
		end

		if type(ent) == 'NPC' or type(ent) == 'NextBot' then
			messaging.chatPlayer2(ply, 'You cant sit on NPCs')
			return
		end

		if maxVelocity > 0 then
			if ent:GetVelocity():Length() >= maxVelocity then
				messaging.chatPlayer2(ply, 'Target is moving too fast!')
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

			parent = false
		else
			isSitting = ent:DLibVar('dsit_flag')
			entSit = ent
			parent = not isSitting
		end

		if ent.dsit_player_root == ply then
			messaging.chatPlayer2(ply, 'You cant sit on a person who sits on you')
			return
		end
	end

	local targetPos, targetAngles
	local upsideDown = false

	if isSitting then
		if not DSitConVars:getBool('players_legs') then
			messaging.chatPlayer2(ply, 'Sitting on players legs is disabled')
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
			messaging.chatPlayer2(ply, 'Sitting on players is disabled')
			return
		end

		if not ent:GetInfoBool('cl_dsit_allow_on_me', true) then
			messaging.chatPlayer2(ply, 'Target player disallowed sitting on him')
			return
		end

		do
			local target = ent:GetInfoBool('cl_dsit_friendsonly', false)
			local me = ply:GetInfoBool('cl_dsit_friendsonly', false)
			local isFriends = ply:IsFriend(ent) and ent:IsFriend(ply)

			if (target or me) and not isFriends then
				messaging.chatPlayer2(ply, 'One or both of players has cl_dsit_friendsonly set to 1 and you are not friends')
				return
			end
		end

		targetAngles = ent:EyeAngles()
		targetPos = ent:EyePos()

		targetAngles.p = 0
		targetAngles.r = 0
	elseif isEntity then
		if DSitConVars:getBool('entities_world') and IsValid(ent:CPPIGetOwner()) then
			messaging.chatPlayer2(ply, 'Sitting is allowed only on non owned entities')
			return
		end

		if DSitConVars:getBool('entities_owner') and ent:CPPIGetOwner() ~= ply then
			messaging.chatPlayer2(ply, 'Sitting is allowed only on entities owned by you')
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
			messaging.chatPlayer2(ply, 'Target player restricted amount of sitting on him (', max, ' is max)')
			return
		end
	end

	local vehicle = makeVehicle(ply, targetPos, targetAngles)
	local can = ply:IsBot() or hook.Run('CanPlayerEnterVehicle', ply, vehicle) ~= false

	if not can then
		messaging.chatPlayer2(ply, 'You can not sit right now')
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
		vehicle:SetParent(entSit)
	elseif isPlayer then
		ply.dsit_player_root = ent.dsit_player_root or ent
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

	vehicle.dsit_upsideDown = upsideDown

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

local function PostLeave(ply, vehPos, upsideDown)
	if upsideDown then
		local tr = util.TraceLine({
			start = vehPos - Vector(0, 0, 5),
			endpos = vehPos - Vector(0, 0, 400),
			filter = ply
		})

		vehPos = tr.HitPos + tr.HitNormal * 2
	end

	local space = DLib.Freespace(vehPos + Vector(0, 0, 1), 25, 5)
	local mins, maxs = ply:GetHull()
	space:SetAABB(mins, maxs)
	space:SetSAABB(mins, maxs)
	space:SetStrict(true)
	space:SetMaskReachable(MASK_VISIBLE_AND_NPCS)
	space.filter:addArray(player.GetAll())
	local position = space:Search()

	if position then
		ply:SetPos(position)
	else
		for i, shift in attemptToFind:ipairs() do
			space:SetPos(vehPos + shift)
			position = space:Search()

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

	ply.dsit_player_root = nil
	local upsideDown = vehicle.dsit_upsideDown

	vehicle:Remove()

	local vehPos = vehicle:GetPos()

	timer.Simple(0, function()
		if not IsValid(ply) then return end
		PostLeave(ply, vehPos, upsideDown)
	end)
end

local function PlayerDeath(ply)
	ply.dsit_player_root = nil
	ply:SetDLibVar('dsit_flag', false)
end

local function PlayerSay(ply, text)
	if ply:GetInfoBool('cl_dsit_message', true) and text:lower():find('get off') then
		dsit_getoff(ply)
	end
end

hook.Add('PlayerLeaveVehicle', 'DSit', PlayerLeaveVehicle)
hook.Add('PlayerDeath', 'DSit', PlayerDeath)
hook.Add('PlayerSay', 'DSit', PlayerSay)
