
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

SCP_NoKill = false

SCP_Ignore = {
	bullseye_strider_focus = true,
}

SCP_HaveZeroHP = {
	npc_rollermine = true,
}

local dbot_scp_player = CreateConVar('dbot_scp_player', '1', FCVAR_ARCHIVE, 'Whatever attack players')
SCP_ATTACK_PLAYERS = dbot_scp_player:GetBool()

local VALID_NPCS = {}

concommand.Add('dbot_reset173', function(ply)
	if not ply:IsAdmin() then return end
	
	for k, v in ipairs(player.GetAll()) do
		v.SCP_Killed = nil
	end
end)

local function CreateSpawnCommand(ent, comm)
	if not SERVER then return end
	
	concommand.Add('dbot_scp' .. comm, function(ply)
		if ply ~= DBot_GetDBot() then return end
		
		local tr = ply:GetEyeTrace()
		
		local ent = ents.Create(ent)
		ent:SetPos(tr.HitPos)
		ent:Spawn()
		ent:Activate()
		
		undo.Create(comm)
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
		undo.Finish()
	end)
	
	concommand.Add('dbot_scp' .. comm .. '_m', function(ply)
		if ply ~= DBot_GetDBot() then return end
		
		local tr = ply:GetEyeTrace()
		
		undo.Create(comm)
		
		for x = -1, 1 do
			for y = -1, 1 do
				for z = -1, 1 do
					local ent = ents.Create(ent)
					ent:SetPos(tr.HitPos + Vector(x, y, z) * 32)
					ent:Spawn()
					ent:Activate()
					
					undo.AddEntity(ent)
				end
			end
		end
		
		undo.SetPlayer(ply)
		undo.Finish()
	end)
end

timer.Create('dbot_SCP_UpdateNPCs', 1, 0, function()
	SCP_ATTACK_PLAYERS = dbot_scp_player:GetBool()
	VALID_NPCS = {}
	
	for k, v in pairs(ents.GetAll()) do
		if not v:IsNPC() then continue end
		if v:GetNPCState() == NPC_STATE_DEAD then continue end
		
		table.insert(VALID_NPCS, v)
	end
end)

function SCP_GetTargets()
	local reply = {}
	
	if SCP_ATTACK_PLAYERS then
		for k, v in ipairs(player.GetAll()) do
			if v:HasGodMode() then continue end
			if v == DBot_GetDBot() then continue end
			if v.SCP_Killed then continue end
			table.insert(reply, v)
		end
	end
	
	for k, v in ipairs(VALID_NPCS) do
		if not IsValid(v) then continue end
		if v.SCP_SLAYED then continue end
		if v.SCP_Killed then continue end
		if SCP_Ignore[v:GetClass()] then continue end
		table.insert(reply, v)
	end
	
	return reply
end

local ENT = {}
ENT.PrintName = 'MAGIC'
ENT.Author = 'DBot'
ENT.Type = 'point'

scripted_ents.Register(ENT, 'dbot_scp173_killer')

CreateSpawnCommand('dbot_scp173', '173')
CreateSpawnCommand('dbot_scp173p', '173p')
CreateSpawnCommand('dbot_scp596', '596')
CreateSpawnCommand('dbot_scp689', '689')
CreateSpawnCommand('dbot_scp219', '219')
CreateSpawnCommand('dbot_scp018', '018')

concommand.Add('dbot_scp018_mc', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	local tr = ply:GetEyeTrace()
	
	undo.Create('018')
	
	for x = -1, 1 do
		for y = -1, 1 do
			for z = -1, 1 do
				local ent = ents.Create('dbot_scp018')
				ent:SetPos(tr.HitPos + Vector(x, y, z + 8) * 16)
				ent:Spawn()
				ent:Activate()
				ent:SetColor(Color(math.random(255), math.random(255), math.random(255)))
				
				undo.AddEntity(ent)
			end
		end
	end
	
	undo.SetPlayer(ply)
	undo.Finish()
end)

concommand.Add('dbot_scp173p', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	local tr = ply:GetEyeTrace()
	
	local ent = ents.Create('dbot_scp173p')
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	
	undo.Create('173')
	undo.AddEntity(ent)
	undo.SetPlayer(ply)
	undo.Finish()
end)

concommand.Add('dbot_scp409', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	local tr = ply:GetEyeTrace()
	
	local ent = ents.Create('dbot_scp409')
	ent:SetPos(tr.HitPos + tr.HitNormal * 30)
	ent:Spawn()
	ent:Activate()
	
	undo.Create('409')
	undo.AddEntity(ent)
	undo.SetPlayer(ply)
	undo.Finish()
end)

concommand.Add('dbot_scp173_clear', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	local tr = ply:GetEyeTrace()
	
	for k, v in ipairs(ents.FindByClass('dbot_scp173')) do
		v.REAL_REMOVE = true
		v:Remove()
	end
end)

concommand.Add('dbot_scp173t', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	DBot_GetDBot():SetPos(ents.FindByClass('dbot_scp173')[1]:GetPos())
end)

concommand.Add('dbot_scp173pt', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	DBot_GetDBot():SetPos(ents.FindByClass('dbot_scp173p')[1]:GetPos())
end)

concommand.Add('dbot_scp689t', function(ply)
	if ply ~= DBot_GetDBot() then return end
	
	DBot_GetDBot():SetPos(ents.FindByClass('dbot_scp689')[1]:GetPos())
end)

local function OnNPCKilled(npc, wep, attacker)
	if not IsValid(attacker) then return end
	if not attacker.IsSCP173 then return end
	attacker:SetFrags(attacker:GetFrags() + 1)
end

local function PlayerDeath(ply, wep, attacker)
	if not IsValid(attacker) then return end
	if not attacker.IsSCP173 then return end
	attacker:SetPFrags(attacker:GetPFrags() + 1)
end

hook.Add('OnNPCKilled', 'DBot_SCP', OnNPCKilled)
hook.Add('PlayerDeath', 'DBot_SCP', PlayerDeath)
