
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


_G.DSitConVars = DLib.Convars('dsit')
_G.DSIT_TRACKED_VEHICLES = _G.DSIT_TRACKED_VEHICLES or {}
local DSitConVars = _G.DSitConVars
local DSIT_TRACKED_VEHICLES = _G.DSIT_TRACKED_VEHICLES

DSitConVars:create('enable', '1', {FCVAR_NOTIFY}, 'Enable')
DSitConVars:create('speed_val', '350', {FCVAR_NOTIFY}, 'Speed check value. Set to 0 or less to disable')
DSitConVars:create('allow_weapons', '1', {FCVAR_NOTIFY}, 'Allow weapons in seat')
DSitConVars:create('distance', '128', {FCVAR_NOTIFY}, 'Max distance (in Hammer Units)')
DSitConVars:create('anyangle', '0', {FCVAR_NOTIFY}, 'Letting players have fun')

DSitConVars:create('allow_ceiling', '1', {FCVAR_NOTIFY}, 'Allow players to sit on ceiling')

DSitConVars:create('entities', '1', {FCVAR_NOTIFY}, 'Allow to sit on entities')
DSitConVars:create('npcs', '1', {FCVAR_NOTIFY}, 'Allow to sit on NPCs')
DSitConVars:create('entities_owner', '0', {FCVAR_NOTIFY}, 'Allow to sit on entities owned only by that player')
DSitConVars:create('entities_world', '0', {FCVAR_NOTIFY}, 'Allow to sit on non-owned entities only')

DSitConVars:create('players', '1', {FCVAR_NOTIFY}, 'Allow to sit on players (heads)')
DSitConVars:create('players_legs', '1', {FCVAR_NOTIFY}, 'Allow to sit on players (legs/sit on sitting players)')

local function PhysgunPickup(ply, ent)
	if IsValid(ply:GetNWEntity('dsit_entity')) then
		return false
	end

	ply.dsit_pickup = true
end

local function PhysgunDrop(ply, ent)
	ply.dsit_pickup = nil
end

DLib.friends.Register('dsit', 'gui.dsit.friend', true)

local function Think()
	local lply, lang

	if CLIENT then
		lply = LocalPlayer()
		lang = Angle(0, 0, 0)

		if lply:InVehicle() then
			lang = lply:GetVehicle():GetAngles()
		end
	end

	for i, vehicle in ipairs(DSIT_TRACKED_VEHICLES) do
		if not IsValid(vehicle) then
			table.remove(DSIT_TRACKED_VEHICLES, i)
			if CLIENT then DSit_RECALCULATE() end
			return
		end

		local ent = vehicle:GetNWEntity('dsit_target')

		if not IsValid(ent) or ent.Alive and not ent:Alive() then
			if SERVER then
				vehicle:Remove()
				table.remove(DSIT_TRACKED_VEHICLES, i)
			end

			goto CONTINUE
		end

		local ang = ent:EyeAngles()

		if ent == lply then
			ang = ang + lang
		end

		local pos, isNPC

		if type(ent) == 'NextBot' then
			pos = ent:GetPos()
			isNPC = true
			pos.z = pos.z + ent:OBBMax().z
		else
			pos = ent:EyePos()
			isNPC = ent:IsNPC()
			pos.z = pos.z + 10
		end

		ang.p = 0
		ang.r = 0
		ang.y = math.floor(ang.y - 90)
		ang:Normalize()

		if vehicle:GetPos() ~= pos then
			local prevpos = vehicle:GetPos()
			vehicle:SetPos(pos)
			local driver = vehicle:GetDriver()

			if IsValid(driver) and driver:GetPos():Distance(prevpos) > 70 then
				driver:SetPos(vector_origin) -- aaaaaaaaaaaaaaaaaaaaaaaaaaaaa
			end
		end

		if vehicle:GetAngles() ~= ang then
			vehicle:SetAngles(ang)
		end

		if CLIENT then
			vehicle:SetRenderOrigin(pos)
			vehicle:SetRenderAngles(ang)
		end

		::CONTINUE::
	end
end

-- hook.Add('PhysgunPickup', 'DSit', PhysgunPickup)
-- hook.Add('PhysgunDrop', 'DSit', PhysgunDrop)
hook.Add('GravGunPickupAllowed', 'DSit', PhysgunPickup)
hook.Add('GravGunPunt', 'DSit', PhysgunPickup)
hook.Add('Think', 'DSit', Think)

function DSit_FindSnappyAngle(ply, tr1, targetAngle)
	local tr2 = util.TraceLine({
		filter = ply,
		start = tr1.HitPos + tr1.HitNormal,
		endpos = tr1.HitPos + tr1.HitNormal * 10
	})

	if tr2.Hit then
		-- not gonna be able to do much here
		return false, 'tr2.Hit', tr2
	end

	local tr3

	for i = 30, 10, -10 do
		tr3 = util.TraceLine({
			filter = ply,
			start = tr2.HitPos,
			endpos = tr2.HitPos + targetAngle:Forward() * 30
		})

		if not tr3.Hit then
			break
		end
	end

	if tr3.Hit then
		-- not gonna be able to do much here
		return false, 'tr3.Hit', tr3
	end

	local things = {}

	for i = 1, 40, 1 do
		local tr4 = util.TraceLine({
			filter = ply,
			start = tr3.HitPos,
			endpos = tr3.HitPos - Vector(0, 0, i)
		})

		if tr4.Hit then
			break
		end

		local tr5 = util.TraceLine({
			filter = ply,
			start = tr4.HitPos,
			endpos = tr4.HitPos - targetAngle:Forward() * 30
		})

		if tr5.Hit then
			table.insert(things, {tr4, tr5})
		end
	end

	if #things == 0 then
		return false, 'no hits'
	end

	if #things == 1 then
		-- only one angle is known
		return true, things[1][2].HitNormal, things[1][2]
	end

	local diff = 0

	for i, thing in ipairs(things) do
		if i ~= 1 then
			diff = diff + thing[2].HitNormal:Distance(things[1][2].HitNormal) * (1 / i)
		end
	end

	if diff < 0.5 then
		return true, things[1][2].HitNormal, things[1][2]
	end

	local x, y, z = 0, 0, 0

	for i, thing in ipairs(things) do
		x = x + thing[2].HitNormal.x * (1 / i)
		y = y + thing[2].HitNormal.y * (1 / i)
		z = z + thing[2].HitNormal.z * (1 / i)
	end

	return true, Vector(x / #things, y / #things, z / #things), things[1][2]
end
