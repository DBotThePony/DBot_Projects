
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

local ENABLE = CreateConVar('sv_dsit_enable', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable')
local ENABLE_SPEED_CHECK = CreateConVar('sv_dsit_speed', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable speed check')
local ENABLE_SPEED_CHECK_VALUE = CreateConVar('sv_dsit_speed_val', '350', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Speed check value')
local ALLOW_WEAPONS = CreateConVar('sv_dsit_allow_weapons', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow weapons in seat')
local MAX_DISTANCE = CreateConVar('sv_dsit_distance', '128', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Max distance (in Hammer Units)')
local ALLOW_ON_PLAYERS = CreateConVar('sv_dsit_players', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on players (heads)')
local ALLOW_ON_PLAYERS_LEGS = CreateConVar('sv_dsit_players_legs', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on players (legs/sit on sitting players)')
local PREVENT_EXPLOIT = CreateConVar('sv_dsit_wallcheck', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Check whatever player go through wall or not')
local FUNNY_SIT = CreateConVar('sv_dsit_allow_ceiling', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow players to sit on ceiling')
local NO_SURF_ADMINS = CreateConVar('sv_dsit_nosurf_admins', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Anti surf enable for admins')
local NO_SURF = CreateConVar('sv_dsit_nosurf', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Anti surf when players are sitting on entities')
local SHOULD_PARENT = CreateConVar('sv_dsit_parent', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Should vehicles be parented to players. If enabled, unexpected things may happen')
local HULL_CHECKS = CreateConVar('sv_dsit_hull', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Make hull checks')
local FORCE_FLAT = CreateConVar('sv_dsit_flat', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Force players sit angle "pitch" to be zero')
local ALLOW_ANY = CreateConVar('sv_dsit_anyangle', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Letting players have fun')
local DISABLE_PHYSGUN = CreateConVar('sv_dsit_disablephysgun', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Disable physgun usage in seat')

local ALLOW_ON_ENTITIES = CreateConVar('sv_dsit_entities', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on entities')
local ALLOW_ON_ENTITIES_OWNER = CreateConVar('sv_dsit_entities_owner', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on entities owned only by that player')
local ALLOW_ON_ENTITIES_WORLD_ONLY = CreateConVar('sv_dsit_entities_world', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to sit on non-owned entities only')

--If you want to know:
--This code was written a long time ago by me, and for me it looks slightly shitty.

DSit = DSit or {}

--Taken from DLib

util.AddNetworkString('DSit.ChatMessage')

function DSit.Copy(var)
	if type(var) == 'table' then return table.Copy(var) end
	if type(var) == 'Angle' then return Angle(var.p, var.y, var.r) end
	if type(var) == 'Vector' then return Vector(var.x, var.y, var.z) end
	return var
end

do
	local EntMem = {}

	local function DoSearch(ent)
		if not IsValid(ent) then return end
		if EntMem[ent] then return end
		local all = constraint.GetTable(ent)
		
		EntMem[ent] = true
		
		for k = 1, #all do
			local ent1, ent2 = all[k].Ent1, all[k].Ent2
			
			DoSearch(ent1)
			DoSearch(ent2)
		end
	end

	function DSit.GetAllConnectedEntities(ent)
		EntMem = {}
		
		DoSearch(ent)
		
		local result = {}
		
		for k, v in pairs(EntMem) do
			table.insert(result, k)
		end
		
		return result
	end
end

function DSit.AddPText(ply, ...)
	net.Start 'DSit.ChatMessage'
	net.WriteTable({...})
	net.Send(ply)
end

function DSit.AddText(...)
	net.Start 'DSit.ChatMessage'
	net.WriteTable({...})
	net.Broadcast()
end

local RecalculateConstrained
local TRANSLUCENT = Color(0, 0, 0, 0)

function DSit.CreateVehicle(pos, ang, owner)
	local ent = ents.Create('prop_vehicle_prisoner_pod')
	
	ent:SetModel('models/nova/airboat_seat.mdl')
	ent:SetKeyValue('vehiclescript', 'scripts/vehicles/prisoner_pod.txt')
	ent:SetKeyValue('limitview', '0')
	ent:SetPos(pos)
	ent:SetAngles(ang)
	
	ent:Spawn()
	ent:Activate()
	
	if owner and ent.CPPISetOwner then
		ent:CPPISetOwner(owner)
	end
	
	ent.IsSittingVehicle = true
	
	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	ent:SetNotSolid(true)
	
	local phys = ent:GetPhysicsObject()
	
	if IsValid(phys) then
		phys:Sleep()	
		phys:EnableGravity(false)
		phys:EnableMotion(false)
		phys:EnableCollisions(false)
		phys:SetMass(1)
	end
	
	ent:DrawShadow(false)
	ent:SetColor(TRANSLUCENT)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetNoDraw(true)
	
	ent.VehicleName = 'Airboat Seat'
	ent.ClassOverride = 'prop_vehicle_prisoner_pod'
	
	ent:SetNWBool('IsSittingVehicle', true)
	
	return ent
end

function DSit.PlayerAABB(ply)
	local pos = ply:GetPos()
	local Mins, Maxs = ply:OBBMins(), ply:OBBMaxs()
	
	local Eyes = ply:EyePos()
	
	local heigt = Maxs.z - Mins.z + 10
	Mins.z = 0
	Maxs.z = 0
	
	return Mins, Maxs, heigt
end

local function Sharp(ang)
	ang.y = math.floor(ang.y / 5) * 5
end

local function IsPosSituable(pos, ply, tr)
	local mins, maxs, h = DSit.PlayerAABB(ply)
	
	local start = Vector(0, 0, 3)
	local add = Vector(0, 0, h)
	
	local rang = tr.HitNormal:Angle()
	rang:RotateAroundAxis(rang:Right(), -90)
	add:Rotate(rang)
	start:Rotate(rang)
	
	local tr = util.TraceHull{
		start = pos + start,
		endpos = pos + add,
		mins = mins * 0.7,
		maxs = maxs * 0.7,
		filter = {ply, tr.Entity},
	}
	
	return not tr.Hit
end

local function IsPosSituableCeiling(pos, ply, tr)
	local mins, maxs, h = DSit.PlayerAABB(ply)
	
	local start = Vector(0, 0, 3)
	local add = Vector(0, 0, h)
	
	local rang = tr.HitNormal:Angle()
	rang:RotateAroundAxis(rang:Right(), -90)
	add:Rotate(rang)
	start:Rotate(rang)
	
	local tr = util.TraceHull{
		start = pos + start,
		endpos = pos + add,
		mins = mins * 0.7,
		maxs = maxs * 0.7,
		filter = {ply, tr.Entity},
	}
	
	return not tr.Hit
end

local TRICK_MINS = Vector(-4, -4, 0)
local TRICK_MAXS = Vector(4, 4, 0)

function DSit.TrickPos(ply, pos, ang)
	local FallAng = DSit.Copy(ang)
	FallAng.p = 0
	FallAng.r = 0
	FallAng.y = FallAng.y - 180
	local forward = FallAng:Forward()
	local right = FallAng:Right()
	local FallPos = pos - right * 40
	
	local NewPos = DSit.Copy(pos)
	local NewAng = DSit.Copy(ang)
	
	if ply:GetPos():Distance(pos) > 30 then
		local tr = util.TraceHull{
			start = pos + Vector(0, 0, 4),
			endpos = FallPos + Vector(0, 0, 4),
			filter = ply,
			mins = TRICK_MINS,
			maxs = TRICK_MAXS,
		}
		
		if not tr.Hit then
			local tr = util.TraceLine{
				start = FallPos + Vector(0, 0, 10),
				endpos = FallPos + Vector(0, 0, -5),
				filter = ply
			}
			
			if not tr.Hit then
				NewAng.y = NewAng.y - 180
			end
		end
	end
	
	return NewPos, NewAng
end

local NewEyeAngles = Angle(0, 90, 0)

function DSit.Sit(ply, tr, lpos, eyes, epos, ignore, notify)
	if not IsValid(ply) then return end
	if not tr then return end
	
	local pos = tr.HitPos
	local normal = tr.HitNormal
	local minus = (pos - lpos)
	local Ang1 = normal:Angle()
	local Ang2 = minus:Angle()
	
	local Ang = Ang1
	
	Ang:RotateAroundAxis(Ang:Right(), -90)
	
	Ang.y = Ang2.y + 90
	Sharp(Ang)
	
	pos, Ang = DSit.TrickPos(ply, pos, Ang, tr)
	
	local ValidAngle = Ang1.p < 15 and Ang1.p > -15 or (IsValid(tr.Entity) and not tr.Entity:GetClass():find('func') and not tr.Entity:GetClass():find('prop_door'))
	local OnCeiling = Ang1.r > 170 or Ang1.r < -170
	
	local ALLOW_ANY = ALLOW_ANY:GetBool()
	
	if not ignore then
		if not ValidAngle and not ALLOW_ANY then 
			if notify then ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Invalid angle') end
			return 
		end
		
		if OnCeiling then
			if not FUNNY_SIT:GetBool() then
				if notify then ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Sitting on ceiling is disabled') end
				return
			end

			if not IsPosSituableCeiling(pos, ply, tr) then 
				if notify then ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Something is obstructing your sit position') end
				return 
			end
		else
			if not IsPosSituable(pos, ply, tr) then 
				if notify then ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Something is obstructing your sit position') end
				return 
			end
		end
	end
	
	if OnCeiling then
		Ang.y = Ang.y - 180
	end
	
	if FORCE_FLAT:GetBool() and not ALLOW_ANY then
		Ang.p = 0
	end
	
	local ent = DSit.CreateVehicle(pos, Ang, ply)
	local can = hook.Run('CanPlayerEnterVehicle', ply, ent)
	
	if can == false then
		SafeRemoveEntity(ent)
		
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] You can not sit right now')
			DSit.AddPText(ply, 'You can not sit right now')
		end
		
		return
	end
	
	ent:SetNWEntity('Player', ply)
	
	ply.DSit_LastAngles = eyes
	ply.DSit_LastPos = lpos
	
	local WEAPONS = ALLOW_WEAPONS:GetBool()
	local IsFlashlightOn
	
	ply.DSit_LastCollisionGroup = ply:GetCollisionGroup()
	
	if WEAPONS then
		ply.DSit_LastWeaponMode = ply:GetAllowWeaponsInVehicle()
		ply:SetAllowWeaponsInVehicle(true)
		IsFlashlightOn = ply:FlashlightIsOn()
	end
	
	ply:EnterVehicle(ent)
	
	if WEAPONS then
		if IsFlashlightOn then ply:Flashlight(true) end
	end

	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(1, function() ply:SetCollisionGroup(COLLISION_GROUP_WEAPON) end) -- Kill stupid addons
	
	if IsValid(tr.Entity) then
		ent:SetParent(tr.Entity)
		ply:SetNWEntity('DSit_Vehicle_Parent', tr.Entity)
		if not IsValid(tr.Entity:GetNWEntity('DSit_Vehicle_Parented')) then tr.Entity:SetNWEntity('DSit_Vehicle_Parented', ent) end
		
		RecalculateConstrained(tr.Entity, ply)
	end
	
	ply:SetEyeAngles(NewEyeAngles)
	ply.DSit_Vehicle = ent
	ply:SetNWEntity('DSit_Vehicle', ent)
end

function DSit.SitOnPlayerLegs(ply, tr, lpos, eyes, epos)
	if not IsValid(ply) then return end
	if not tr then return end
	local target = tr.Entity
	local veh = tr.Entity:GetVehicle()
	
	local pos = veh:GetPos()
	local Ang = veh:GetAngles()
	
	local ADD = Vector(0, 10, 5)
	ADD:Rotate(Ang)
	
	local ent = DSit.CreateVehicle(pos + ADD, Ang, ply)
	
	local can = hook.Run('CanPlayerEnterVehicle', ply, ent)
	
	if can == false then
		SafeRemoveEntity(ent)
		
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] You can not sit right now')
			DSit.AddPText(ply, 'You can not sit right now')
		end
		
		return
	end
	
	ent:SetNWEntity('Player', ply)
	
	ply.DSit_LastAngles = eyes
	ply.DSit_LastPos = lpos
	
	local WEAPONS = ALLOW_WEAPONS:GetBool()
	local IsFlashlightOn
	
	ply.DSit_LastCollisionGroup = ply:GetCollisionGroup()
	
	if WEAPONS then
		ply.DSit_LastWeaponMode = ply:GetAllowWeaponsInVehicle()
		ply:SetAllowWeaponsInVehicle(true)
		IsFlashlightOn = ply:FlashlightIsOn()
	end
	
	ply:EnterVehicle(ent)
	
	if WEAPONS then
		if IsFlashlightOn then ply:Flashlight(true) end
	end

	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(1, function() ply:SetCollisionGroup(COLLISION_GROUP_WEAPON) end) -- Kill stupid addons
	
	ent:SetParent(veh)
	ply:SetNWEntity('DSit_Vehicle_Parent', veh)
	
	ply:SetEyeAngles(NewEyeAngles)
	
	ply.DSit_Vehicle = ent
	ply:SetNWEntity('DSit_Vehicle', ent)
	ent.__IsSittingOnPlayer = true
	ent.__SittingPlayer = target
end

local function easyUserParse(str)
	local output = {}
	if not str then return output end
	
	for i, s in pairs(string.Explode(',', str)) do
		local n = tonumber(s)
		
		if n then
			local get = Player(s)
			
			if IsValid(get) then
				table.insert(output, get)
			end
		end
	end
	
	return output
end

local CALCULATE_MEM = {}
local CALCULATE_MEM_VEH = {}

local function calculatePlayersRecursion(ply)
	for k = 1, #CALCULATE_MEM_VEH do
		local veh = CALCULATE_MEM_VEH[k]
		local ply2 = veh.ParentedToPlayer
		local driver = veh:GetDriver()
		
		if ply2 == ply and driver:IsValid() then -- ???
			CALCULATE_MEM[driver] = driver
			calculatePlayersRecursion(driver)
		end
	end
end

local function calculatePlayers(ply)
	CALCULATE_MEM_VEH = ents.FindByClass('prop_vehicle_prisoner_pod')
	
	calculatePlayersRecursion(ply)
	local reply = {}
	
	for k, v in pairs(CALCULATE_MEM) do
		table.insert(reply, v)
	end
	
	CALCULATE_MEM = {}
	return reply
end

function DSit.SitOnPlayer(ply, tr, lpos, eyes, epos, notify)
	if not IsValid(ply) then return end
	if not tr then return end
	
	local cl_dsit_allow_on_me = ply:GetInfo('cl_dsit_allow_on_me')
	
	if cl_dsit_allow_on_me and cl_dsit_allow_on_me == '0' then
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] You disallowed sitting on players')
			DSit.AddPText(ply, 'You disallowed sitting on players')
		end
		
		return
	end
	
	local Ply = tr.Entity
	
	local cl_dsit_allow_on_me = Ply:GetInfo('cl_dsit_allow_on_me')
	
	if cl_dsit_allow_on_me and cl_dsit_allow_on_me == '0' then
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Target disallowed sitting on him')
			DSit.AddPText(ply, 'Target disallowed sitting on him')
		end
		
		return
	end
	
	local friends_self = ply:GetInfo('cl_dsit_friendsonly')
	local __dsit_friends_self = easyUserParse(ply:GetInfo('__dsit_friends'))
	local __dsit_blocked_self = easyUserParse(ply:GetInfo('__dsit_blocked'))
	
	local friends_target = Ply:GetInfo('cl_dsit_friendsonly')
	local __dsit_friends_target = easyUserParse(Ply:GetInfo('__dsit_friends'))
	local __dsit_blocked_target = easyUserParse(Ply:GetInfo('__dsit_blocked'))
	
	if table.HasValue(__dsit_blocked_self, Ply) then
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] You blacklisted this player')
			DSit.AddPText(ply, 'You blacklisted this player')
		end
		
		return
	end
	
	if table.HasValue(__dsit_blocked_target, ply) then
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Target blacklisted you')
			DSit.AddPText(ply, 'Target blacklisted you')
		end
		
		return
	end
	
	if (friends_self and friends_self ~= '0' and friends_self ~= '' or friends_target and friends_target ~= '0' and friends_target ~= '') and (not table.HasValue(__dsit_friends_target, ply) or not table.HasValue(__dsit_friends_self, Ply)) then
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] One or both players has cl_dsit_friendsonly set to 1 and you are not friends')
			DSit.AddPText(ply, 'One or both players has cl_dsit_friendsonly set to 1 and you are not friends')
		end
		
		return
	end
	
	if cl_dsit_allow_on_me and cl_dsit_allow_on_me == '0' then
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Target disallowed sitting on him')
			DSit.AddPText(ply, 'Target disallowed sitting on him')
		end
		
		return
	end
	
	local maxonme = tonumber(Ply:GetInfo('cl_dsit_maxonme') or '')
	
	if maxonme and maxonme > 0 and #calculatePlayers(Ply) >= maxonme then
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Player restricted maximal amount of players on him')
			DSit.AddPText(ply, 'Player restricted maximal amount of players on him')
		end
		
		return
	end
	
	local pos = tr.HitPos
	local normal = tr.HitNormal
	local minus = (pos - lpos)
	local Ang1 = normal:Angle()
	local Ang2 = minus:Angle()
	
	local Ang = Angle(Ang1.p, Ang2.y + 90, Ang1.r)
	
	Ang:RotateAroundAxis(Ang:Right(), -90)
	
	local ent = DSit.CreateVehicle(pos, Ang, ply)
	
	local can = hook.Run('CanPlayerEnterVehicle', ply, ent)
	
	if can == false then
		SafeRemoveEntity(ent)
		
		if notify then 
			ply:PrintMessage(HUD_PRINTCENTER, '[DSit] You can not sit right now')
			DSit.AddPText(ply, 'You can not sit right now')
		end
		
		return
	end
	
	ent:SetNWEntity('Player', ply)
	
	ply.DSit_LastAngles = eyes
	ply.DSit_LastPos = lpos
	
	local WEAPONS = ALLOW_WEAPONS:GetBool()
	local IsFlashlightOn
	
	ply.DSit_LastCollisionGroup = ply:GetCollisionGroup()
	
	if WEAPONS then
		ply.DSit_LastWeaponMode = ply:GetAllowWeaponsInVehicle()
		
		ply:SetAllowWeaponsInVehicle(true)
		
		IsFlashlightOn = ply:FlashlightIsOn()
	end
	
	ply:EnterVehicle(ent)
	
	if WEAPONS then
		if IsFlashlightOn then ply:Flashlight(true) end
	end
	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	ply:SetEyeAngles(NewEyeAngles)
	
	ply.DSit_Vehicle = ent
	
	ent.ParentedToPlayer = Ply
	ent:SetNWEntity('ParentedToPlayer', Ply)
	
	if SHOULD_PARENT:GetBool() then
		local EYES = Ply:EyePos()
		
		local eAttach = Ply:LookupAttachment('eyes')
		local hAttach = Ply:LookupAttachment('head')
		
		if hAttach and hAttach ~= 0 then
			local d = Ply:GetAttachment(hAttach)
			EYES = d.Pos
		elseif eAttach and eAttach ~= 0 then
			local d = Ply:GetAttachment(eAttach)
			EYES = d.Pos
		end
		
		EYES.z = EYES.z + 10
		
		ent:SetAngles(Ply:EyeAngles())
		
		ent:SetPos(EYES)
		ent:SetParent(Ply, hAttach or eAttach or -1)
	end
end

local function RecursionCheck(ply, ent, fPly)
	if ent.ParentedToPlayer == ply then return true end
	
	if fPly then
		for k, v in pairs(ents.FindByClass('prop_vehicle_prisoner_pod')) do
			if v.ParentedToPlayer == fPly and ent.ParentedToPlayer == ply then return true end
		end
	end
	
	return false
end

local MINS = Vector(-4, -4, 0)
local MAXS = Vector(4, 4, 0)

local function Request(ply)
	if not ENABLE:GetBool() then return end
	if not IsValid(ply) then print('No sit for console') return end
	
	if ply:InVehicle() then return end
	
	if ply:GetMoveType() == MOVETYPE_NONE then
		ply:PrintMessage(HUD_PRINTCENTER, '[DSit] You can not sit right now')
		DSit.AddPText(ply, 'You can not sit right now')
		return
	end
	
	if ENABLE_SPEED_CHECK:GetBool() and ply:GetVelocity():Length() > ENABLE_SPEED_CHECK_VALUE:GetInt() then
		ply:PrintMessage(HUD_PRINTCENTER, '[DSit] You are moving too fast to sit right now')
		DSit.AddPText(ply, 'You are moving too fast to sit right now')
		return
	end
	
	local lpos = ply:GetPos()
	local epos = ply:EyePos()
	local eyes = ply:EyeAngles()
	local fwd = eyes:Forward()
	
	local Mins, Maxs, Height = DSit.PlayerAABB(ply)
	
	local tr = util.TraceHull{
		start = epos - fwd * 3,
		endpos = epos + fwd * MAX_DISTANCE:GetFloat(),
		filter = ply,
		mins = MINS,
		maxs = MAXS,
	}
	
	if HULL_CHECKS:GetBool() then
		local tr2 = util.TraceHull{
			start = epos - fwd * 3,
			endpos = epos + fwd * MAX_DISTANCE:GetFloat(),
			mins = Mins,
			maxs = Maxs,
			filter = function(ent)
				if ply == ent then return false end
				if ent == tr.Entity then return true end
				if IsValid(ent) and ent:IsPlayer() then return false end
				return true
			end,
		}
		
		if tr2.Entity ~= tr.Entity then tr = tr2 end
	end
	
	if not tr.Hit then return end
	if tr.HitSky then return end

	ply.DSit_LastTry = ply.DSit_LastTry or 0
	if ply.DSit_LastTry > CurTime() then return false end
	
	local can, reason = hook.Run('CanSit', ply, tr, tr.Entity)
	
	if can == false then
		if reason then
			ply:PrintMessage(HUD_PRINTCENTER, reason)
			DSit.AddPText(ply, reason)
		end
		
		return
	end
	
	local ent = tr.Entity
	
	local IsPlayer
	
	ply.DSit_LastTry = CurTime() + 1
	
	if IsValid(ent) then
		local class = ent:GetClass()
		IsPlayer = class == 'player'
		
		if ent.ParentedToPlayer == ply or class:sub(1, 5) == 'func_' or class:sub(1, 9) == 'func_door' then
			return
		end
		
		if not IsPlayer then
			if not ALLOW_ON_ENTITIES:GetBool() then
				ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Server owner has disabled ability to sit on entities')
				DSit.AddPText(ply, 'Server owner has disabled ability to sit on entities')
				return
			end
			
			if ALLOW_ON_ENTITIES_OWNER:GetBool() and ent.CPPIGetOwner then
				if ent:CPPIGetOwner() ~= ply then
					ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Server owner has disabled ability to sit on entities not owned by you')
					DSit.AddPText(ply, 'Server owner has disabled ability to sit on entities not owned by you')
					return
				end
			end
			
			if ALLOW_ON_ENTITIES_WORLD_ONLY:GetBool() and ent.CPPIGetOwner then
				if ent:CPPIGetOwner() ~= NULL and ent:CPPIGetOwner() ~= nil then
					ply:PrintMessage(HUD_PRINTCENTER, '[DSit] Server owner has disabled ability to sit on owned entities')
					DSit.AddPText(ply, 'Server owner has disabled ability to sit on owned entities')
					return
				end
			end
		end
	end
	
	if IsPlayer then
		local Ply = ent
		
		if IsValid(Ply:GetVehicle()) then 
			if RecursionCheck(ply, Ply:GetVehicle(), Ply) then return end
		end
		
		if not Ply:InVehicle() and ALLOW_ON_PLAYERS:GetBool() then
			ply:DropObject()
			DSit.SitOnPlayer(ply, tr, lpos, eyes, epos, true)
		elseif not Ply:GetVehicle().IsSittingVehicle and ALLOW_ON_PLAYERS:GetBool() then
			ply:DropObject()
			DSit.SitOnPlayer(ply, tr, lpos, eyes, epos, false, true)
		elseif ALLOW_ON_PLAYERS_LEGS:GetBool() then
			ply:DropObject()
			DSit.SitOnPlayerLegs(ply, tr, lpos, eyes, epos, false, true)
		end
		
		return
	end
	
	ply:DropObject()
	DSit.Sit(ply, tr, lpos, eyes, epos, false, true)
end

concommand.Add('dsit', Request)

local function CanExitVehicle(ply, ent)
	if not IsValid(ent) then return end
	
	ply.DSit_LastTry = ply.DSit_LastTry or (CurTime() + 1)
	if ply.DSit_LastTry > CurTime() then return false end
	ply.DSit_LastTry = CurTime() + 1
end

local function DropPointToFloor(pos, mins, maxs, filter)
	return util.TraceHull{
		filter = filter,
		start = pos,
		endpos = pos - Vector(0, 0, 100),
		mins = mins,
		maxs = maxs,
	}
end

local CheckSides = {}

for z = -6, 6 do
	for x = -6, 6 do
		for y = -6, 6 do
			table.insert(CheckSides, Vector(x * 30, y * 30, z * 30 - 20))
		end
	end
end

local function CheckVectors(vec1, vec2, filter)
	local tr = util.TraceLine{
		start = vec1,
		endpos = vec2,
		filter = filter
	}
	
	return tr.HitPos == vec2
end

local function FindPos(ply, pos, oldpos, H, vehpos, trCheck)
	local mins, maxs, heigt = DSit.PlayerAABB(ply)
	
	local PREVENT_EXPLOIT = PREVENT_EXPLOIT:GetBool()
	
	local tr = util.TraceHull{
		start = pos,
		endpos = pos + Vector(0, 0, heigt),
		filter = function(ent)
			if ent == ply then return false end
			local col = ent:GetCollisionGroup()
			return col ~= COLLISION_GROUP_WEAPON and col ~= COLLISION_GROUP_WORLD
		end,
		
		mins = mins,
		maxs = maxs,
		mask = MASK_ALL,
	}
	
	if tr.Entity == NULL then
		-- Did we got outside of map?
		
		local trMap = util.TraceLine{
			start = pos,
			endpos = pos + Vector(0, 0, -16000),
			filter = ply,
			mask = MASK_ALL,
		}
		
		if trMap.Entity == NULL then
			ply:SetPos(oldpos)
			return false, oldpos
		end
	end

	if not tr.Hit and CheckVectors(tr.HitPos, oldpos, trCheck.filter) then
		ply:SetPos(pos)
		return true, pos
	else
		local hit = false
		local validpos
		
		if vehpos then
			local tr = util.TraceHull{
				start = vehpos + Vector(0, 0, 6),
				endpos = vehpos + Vector(0, 0, 8), --Maxs have high Z
				
				mins = mins,
				maxs = maxs,
				filter = ply,
			}
			
			if not tr.Hit and CheckVectors(tr.HitPos, oldpos, trCheck.filter) then
				validpos = tr.HitPos
				hit = true
			else
				local ValidPositions = {}

				for k, vec in ipairs(CheckSides) do
					local newvec = vehpos + vec
					local tr = DropPointToFloor(newvec, mins, maxs, ply)
					
					if tr.HitPos == newvec then continue end
					-- Make it really sure that we are found right position
					
					local trCheck2 = util.TraceLine{
						start = tr.HitPos,
						endpos = tr.HitPos + Vector(0, 0, ply:OBBMaxs().z + 20),
						filter = ply,
					}
					
					if trCheck2.Hit then
						continue
					else
						-- Wew, final check
						
						local maxs = ply:OBBMaxs()
						maxs.z = 0
						
						local trCheck3 = util.TraceHull{
							start = tr.HitPos,
							endpos = tr.HitPos + Vector(0, 0, ply:OBBMaxs().z + 20),
							filter = ply,
							mins = ply:OBBMins(),
							maxs = maxs,
						}
						
						if trCheck3.Hit then
							continue
						end
					end
					
					if PREVENT_EXPLOIT then
						trCheck.endpos = tr.HitPos
						local result = util.TraceLine(trCheck)
						if result.Hit then continue end
					end

					table.insert(ValidPositions, tr.HitPos)
				end
				
				table.sort(ValidPositions, function(a, b)
					return a:DistToSqr(vehpos) < b:DistToSqr(vehpos)
				end)
				
				local pos = ValidPositions[1]
				
				if pos then
					validpos = pos
					hit = true
				end
			end
		end
		
		if not hit then
			ply:SetPos(oldpos)
			return false, oldpos
		else
			ply:SetPos(validpos)
			return true, validpos
		end
	end
end

local function PostLeaveVehicle(ply, tr, vehpos)
	if not IsValid(ply) then return end
	ply:SetAllowWeaponsInVehicle(ply.DSit_LastWeaponMode)
	ply:SetCollisionGroup(ply.DSit_LastCollisionGroup)
	ply:SetEyeAngles(ply.DSit_LastAngles)

	local H = ply:OBBMaxs().z - ply:OBBMins().z
	
	local status, newPlyPos = FindPos(ply, ply:GetPos(), ply.DSit_LastPos, H, vehpos, table.Copy(tr))
	
	if status then
		tr.endpos = newPlyPos
		
		if PREVENT_EXPLOIT:GetBool() and util.TraceLine(tr).Hit then
			ply:SetPos(ply.DSit_LastPos)
			DSit.AddPText(ply, 'You go through wall and was teleported to previous location')
		end
	else
		DSit.AddPText(ply, 'You were stuck and teleported to previous location')
	end
	
	ply:SetNWEntity('DSit_Vehicle_Parent', NULL)
end

local function isValid(ent)
	return IsValid(ent) and not ent.DSIT_IGNORE
end

local function DoUsualCheck(ply, ent)
	if not isValid(ent) then return false end
	if ent.IsSittingVehicle then return true end
	
	if ent:IsVehicle() then
		local d = ent:GetDriver()
		if IsValid(d) then
			ply = d
		end
	end

	if isValid(ent:GetNWEntity('DSit_Vehicle_Parented')) then return true end
	
	if ply then
		if ent == ply:GetNWEntity('DSit_Vehicle') then return true end
		if ent == ply:GetNWEntity('DSit_Vehicle_Parent') then return true end
		if not ply:IsAdmin() and isValid(ent:GetNWEntity('DSit_Vehicle_Parented')) then return true end
	end
	
	if isValid(ent:GetNWEntity('DSit_Vehicle')) then return true end
end

function RecalculateConstrained(ent, ply)
	if true then return end --For now it is disabled
	if not IsValid(ent) then return end
	if ent._DSit_LastReaclc == CurTime() then return end
	local result = DSit.GetAllConnectedEntities(ent)
	ent._DSit_LastReaclc = CurTime()

	local hit = false
	local size = #result
	
	for k = 1, size do
		if DoUsualCheck(ply, result[k]) then hit = true break end
	end
	
	for k = 1, size do
		result[k]:SetNWBool('DSit_IsConstrained', hit)
	end
end

local function EntityRemoved(ent)
	if not ent:IsConstraint() then return end
	local ent1, ent2 = ent:GetConstrainedEntities()
	
	if IsValid(ent1) then
		RecalculateConstrained(ent1)
	end
	
	if IsValid(ent2) then
		RecalculateConstrained(ent2)
	end
end

local function OnEntityCreated(ent)
	if not ent.IsConstraint or not ent:IsConstraint() then return end
	
	timer.Simple(0, function()
		local ent1, ent2 = ent:GetConstrainedEntities()
		if IsValid(ent1) then
			RecalculateConstrained(ent1)
		end
		
		if IsValid(ent2) then
			RecalculateConstrained(ent2)
		end
	end)
end

local function PlayerLeaveVehicle(ply, ent)
	if not IsValid(ent) then return end
	if not ent.IsSittingVehicle then return end
	
	ply.NoClip = nil -- ULX
	ent.DSIT_IGNORE = true

	local parent = ent:GetParent()
	
	if IsValid(parent) and not parent:IsPlayer() then
		timer.Simple(0.5, function()
			RecalculateConstrained(parent, ply)
		end)
	end
	
	ply.DSit_LastTry = CurTime() + 1
	
	local tr = {
		start = ent:GetPos(),
		endpos = ply:GetPos(),
		filter = function(ent2)
			if ent2 == ent then return false end
			if ent2 == ply then return false end
			
			if IsValid(ent2) then
				local class = ent2:GetClass()
				if class:sub(1, 5) == 'func_' then return true end
				if class:sub(1, 9) == 'prop_door' then return true end
			else
				return true
			end
			
			return false
		end,
	}
	
	local vehpos = ent:GetPos() + Vector(0, 0, 3)
	
	SafeRemoveEntity(ent)
	
	if ply._DSit_IgnoreUnstuckUntil and ply._DSit_IgnoreUnstuckUntil > CurTime() then
		return
	end
	
	if ent.__IsSittingOnPlayer then
		local Ply = ent.__SittingPlayer
		if IsValid(Ply) then
			ply:SetPos(Ply:EyePos() + Vector(0, 0, 10))
		end
	end
	
	timer.Simple(0, function()
		PostLeaveVehicle(ply, tr, vehpos)
	end)
end

local function PlayerDeath(ply)
	if ply.DSit_Vehicle and IsValid(ply.DSit_Vehicle) then SafeRemoveEntity(ply.DSit_Vehicle) end
	ply:SetNWEntity('DSit_Vehicle_Parent', NULL)
end

local function PlayerDisconnected(ply)
	if ply.DSit_Vehicle and IsValid(ply.DSit_Vehicle) then SafeRemoveEntity(ply.DSit_Vehicle) end
	ply:SetNWEntity('DSit_Vehicle_Parent', NULL)
end

local function VehicleTick(ent)
	if not IsValid(ent) then return end
	if not ent.IsSittingVehicle then return end
	if not ent.ParentedToPlayer then return end
	
	if not IsValid(ent.ParentedToPlayer) then
		SafeRemoveEntity(ent)
		return
	end
	
	if not ent.ParentedToPlayer:Alive() then
		SafeRemoveEntity(ent)
		return
	end
	
	if ent.ParentedToPlayer:GetNWBool('Spectator') then
		SafeRemoveEntity(ent)
		return
	end
	
	local ply = ent.ParentedToPlayer
	
	if not SHOULD_PARENT:GetBool() then
		local eAng = ply:EyeAngles()
		local ePos = ply:EyePos()
		
		if not ply:InVehicle() then
			eAng.p = 0
			eAng.r = 0
		end
		
		local deltaZ = ply:GetPos():Distance(ply:EyePos())
		local localPos, localAng = WorldToLocal(ent:GetPos(), ent:GetAngles(), ePos, eAng)
		localPos.x = 0
		localPos.y = 0
		localPos.z = 20
		
		localAng.p = 0
		localAng.y = -90
		localAng.r = 0
		
		local nPos, nAng = LocalToWorld(localPos, localAng, ePos, eAng)
		
		ent:SetAngles(nAng)
		ent:SetPos(nPos)
	end
end

local function Tick()
	if not ENABLE:GetBool() then return end
	for k, ent in pairs(ents.FindByClass('prop_vehicle_prisoner_pod')) do
		VehicleTick(ent)
	end
end

local LastSay = 0

local function PhysgunPickup(ply, ent)
	if ent:IsPlayer() and ent:InVehicle() and ent:GetVehicle().IsSittingVehicle then return false end
	if DISABLE_PHYSGUN:GetBool() and ply:InVehicle() and ply:GetVehicle().IsSittingVehicle then return false end
	if not NO_SURF:GetBool() then return end
	if not NO_SURF_ADMINS:GetBool() and ply:IsAdmin() then return end
	
	local res = DoUsualCheck(ply, ent)
	if res then return false end
	
	if ent:GetNWBool('DSit_IsConstrained') then 
		if LastSay + 1 < CurTime() then
			DSit.AddPText(ply, 'That entity is constrained with chair')
			LastSay = CurTime()
		end
		
		return false 
	end
end

local function KeyPress(ply, key)
	if key ~= IN_USE then return end
	
	if ply:KeyDown(IN_WALK) then Request(ply) end
end

do
	local phrase = 'get off'

	local function PlayerSay(ply, message)
		if ply:GetInfo('cl_dsit_message') ~= '1' then return end
		local fixed = message:Trim():lower()
		local textHit = fixed == phrase or fixed:sub(1, #phrase) == phrase or fixed:sub(-#phrase) == phrase
		if not textHit then return end
		local hit = false
		
		for k, ent in pairs(ents.FindByClass('prop_vehicle_prisoner_pod')) do
			if ent.ParentedToPlayer == ply then
				ent:GetDriver():ExitVehicle()
				hit = true
			end
		end
		
		if hit then
			DSit.AddPText(ply, 'Next time you should type in console "dsit_getoff" or spawn menu > Utilities > User > DSit > Get off player on you')
		end
	end

	hook.Add('PlayerSay', 'DSit.Hooks', PlayerSay)
end

local function playerArrested(ply)
	ply._DSit_IgnoreUnstuckUntil = CurTime() + 1
end

PlayerSit = Request

local hooks = {
	PlayerDeath = PlayerDeath,
	PlayerDisconnected = PlayerDisconnected,
	PlayerLeaveVehicle = PlayerLeaveVehicle,
	CanExitVehicle = CanExitVehicle,
	KeyPress = KeyPress,
	playerArrested = playerArrested,
}

for k, v in pairs(hooks) do
	hook.Add(k, 'DSit.Hooks', v)
end

timer.Create('DSit.UpdateVehiclePositions', 0.1, 0, Tick)

--I WAS TRYING TO OVERRIDE, I FAILED.
DSit.ulxPlayerPickup = DSit.ulxPlayerPickup or hook.GetTable().PhysgunPickup and hook.GetTable().PhysgunPickup.ulxPlayerPickup

hook.Remove('PhysgunPickup', 'ulxPlayerPickup')
hook.Add('PhysgunPickup', '!DSit.Hooks', function(ply, ent)
	if PhysgunPickup(ply, ent) == false then return false end
	if DSit.ulxPlayerPickup then return DSit.ulxPlayerPickup(ply, ent) end 
end, -1)

concommand.Add('dsit_var', function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not args[1] then return end
	if not args[2] then return end
	RunConsoleCommand('sv_dsit_' .. args[1], args[2])
end)

concommand.Add('dsit_getoff', function(ply)
	if not IsValid(ply) then return end
	
	for k, ent in pairs(ents.FindByClass('prop_vehicle_prisoner_pod')) do
		if ent.ParentedToPlayer == ply then
			ent:GetDriver():ExitVehicle()
		end
	end
end)

concommand.Add('dsit_about', function()
	MsgC([[
DSit - Sit Everywhere!
Maded by DBot

Licensed under Apache License 2
http://www.apache.org/licenses/LICENSE-2.0

DSit distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

]])
	MsgC([[
Steam Workshop:
http://steamcommunity.com/sharedfiles/filedetails/?id=673317324
Github:
https://github.com/roboderpy/dsit
]])
end)
