
-- Copyright (C) 2020 DBotThePony

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

local CSGOPinging = CSGOPinging
local ENABLE = CreateConVar('sv_csgoping', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Enable CS:GO Pinging')

AddCSLuaFile('csgo_ping/cl_registry.lua')

net.pool('csgoping_ping_position')
net.pool('csgoping_ping_entity')

local function goup(ent)
	return ent:IsNPC() or ent:IsPlayer() or type(ent) == 'NextBot' or ent:IsWeapon() or ent:IsVehicle()
end

net.receive('csgoping_ping_position', function(len, ply)
	if not ENABLE:GetBool() then return end
	if not ply:Alive() then return end

	local pos, start, endpos = net.ReadVectorDouble(), net.ReadVectorDouble(), net.ReadVectorDouble()

	local tr = util.TraceLine({
		start = start,
		endpos = endpos,
		filter = ply,
		mask = MASK_ALL,
	})

	if not IsValid(tr.Entity) or tr.Entity:EntIndex() <= 0 then
		local playerlist = RecipientFilter()
		playerlist:AddAllPlayers()

		hook.Run('DCSGO_Pinging_ChoosePlayerList_Ent', playerlist, ply, tr.Entity)
		if playerlist:GetCount() == 0 then return end

		net.Start('csgoping_ping_position')
		net.WritePlayer(ply)
		net.WriteVectorDouble(pos)
		net.Send(playerlist)

		return
	end

	local playerlist = RecipientFilter()
	playerlist:AddAllPlayers()

	hook.Run('DCSGO_Pinging_ChoosePlayerList_Pos', playerlist, ply, tr)
	if playerlist:GetCount() == 0 then return end

	net.Start('csgoping_ping_entity')
	net.WritePlayer(ply)
	net.WriteVectorDouble(tr.HitPos)
	net.WriteEntity(tr.Entity)
	net.WriteBool(goup(tr.Entity))
	net.Send(playerlist)
end)

local skip = {
	prop_static = true,
	prop_dynamic = true,
	prop_ragdoll = true,
	prop_physics = true
}

net.receive('csgoping_ping_entity', function(len, ply)
	if not ENABLE:GetBool() then return end
	if not ply:Alive() then return end

	local pos = net.ReadVectorDouble()
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end

	--[[if ent:GetClass() and skip[ent:GetClass()] then
		net.Start('csgoping_ping_position')
		net.WritePlayer(ply)
		net.WriteVectorDouble(pos)
		net.Broadcast()
		return
	end]]

	local playerlist = RecipientFilter()
	playerlist:AddAllPlayers()

	hook.Run('DCSGO_Pinging_ChoosePlayerList_Ent', playerlist, ply, ent)
	if playerlist:GetCount() == 0 then return end

	net.Start('csgoping_ping_entity')
	net.WritePlayer(ply)
	net.WriteVectorDouble(pos)
	net.WriteEntity(ent)
	net.WriteBool(goup(ent))
	net.Send(playerlist)
end)
