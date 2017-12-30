
-- Copyright (C) 2015-2018 DBot

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

util.AddNetworkString("DBot.BloodMoon")
util.AddNetworkString("DBot.Eclipse")

CreateConVar("sv_dbot_bloodmoon_chance", 10000, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Chance of happening bloodmoon")
CreateConVar("sv_dbot_eclipse_chance", 30000, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Chance of happening eclipse")

BloodMoon = BloodMoon or {}
BloodMoon.Death = BloodMoon.Death or 0
function BloodMoon.Start()
	if GetGlobalBool("DBot.BloodMoon") then return end
	if GetGlobalBool("DBot.Eclipse") then return end
	SetGlobalBool("DBot.BloodMoon", true)
	net.Start("DBot.BloodMoon")
	net.WriteBool(true)
	net.Broadcast()
end

concommand.Add("bloodmoon", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not GetGlobalBool("DBot.BloodMoon") then BloodMoon.Start() else BloodMoon.End() end
end, nil, "Starts/Ends bloodmoon")

concommand.Add("eclipse", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not GetGlobalBool("DBot.Eclipse") then BloodMoon.StartEclipse() else BloodMoon.EndEclipse() end
end, nil, "Starts/Ends Eclipse")

function BloodMoon.End()
	if not GetGlobalBool("DBot.BloodMoon") then return end
	SetGlobalBool("DBot.BloodMoon", false)
	net.Start("DBot.BloodMoon")
	net.WriteBool(false)
	net.Broadcast()
	for _, t in pairs(ents.GetAll()) do
		if t.BloodMoonZombie then SafeRemoveEntity(t) end
	end
end

function BloodMoon.StartEclipse()
	if GetGlobalBool("DBot.BloodMoon") then return end
	if GetGlobalBool("DBot.Eclipse") then return end
	SetGlobalBool("DBot.Eclipse", true)
	net.Start("DBot.Eclipse")
	net.WriteBool(true)
	net.Broadcast()
end

function BloodMoon.EndEclipse()
	if not GetGlobalBool("DBot.Eclipse") then return end
	SetGlobalBool("DBot.Eclipse", false)
	net.Start("DBot.Eclipse")
	net.WriteBool(false)
	net.Broadcast()
	for _, t in pairs(ents.GetAll()) do
		if t.EclipseZombie then SafeRemoveEntity(t) end
	end
end

local ztypes = {"npc_zombie", "npc_zombine", "npc_headcrab"}

if not IsMounted("ep2") then
	ztypes = {"npc_zombie", "npc_headcrab_fast", "npc_headcrab"}
end

timer.Create("BloodMoon", 5, 0, function()
	if not GetGlobalBool("BloodMoon") then return end

	local zombies = 0
	for _, t in pairs(ztypes) do
		zombies = zombies + #ents.FindByClass(t)
	end

	if zombies < 200 then
		for _, ply in pairs(player.GetAll()) do
			local ent = ents.Create(table.Random(ztypes))
			local pos = ply:GetPos()
			local newpos = pos+Vector(math.random(-500, 500), math.random(-500, 500), math.random(-20, 20))
			ent:SetPos(newpos)
			ent:Spawn()
			ent:SetAngles(Angle(0, (pos-newpos):Angle().y, 0))
			ent.BloodMoonZombie = true
		end
	end
end)

local ztypes = {"npc_zombie", "npc_zombine", "npc_poisonzombie"}

if not IsMounted("ep2") then
	ztypes = {"npc_zombie", "npc_poisonzombie"}
end

timer.Create("Eclipse", 3, 0, function()
	if not GetGlobalBool("Eclipse") then return end

	local zombies = 0
	for _, t in pairs(ztypes) do
		zombies = zombies + #ents.FindByClass(t)
	end

	if zombies < 200 then
		for _, ply in pairs(player.GetAll()) do
			local ent = ents.Create(table.Random(ztypes))
			local pos = ply:GetPos()
			local newpos = pos+Vector(math.random(-500, 500), math.random(-500, 500), math.random(-20, 20))
			ent:SetPos(newpos)
			ent:Spawn()
			ent:SetAngles(Angle(0, (pos-newpos):Angle().y, 0))
			ent:SetMaxHealth(ent:Health()*3)
			ent:SetHealth(ent:Health()*3)
			ent.EclipseZombie = true
		end
	end
end)

hook.Add("PlayerDeath", "BloodMoon", function(ply)
	BloodMoon.Death = BloodMoon.Death + 1

	if BloodMoon.Death > 5 then
		if math.random(1, HandleMoonChance() - BloodMoon.Death * 200) == 1 then
			BloodMoon.Start()

			timer.Simple(math.random(120, 360), function()
				BloodMoon.End()
			end)
		end
	end
end)

timer.Create("BloodMoonDeath", 30, 0, function()
	BloodMoon.Death = math.max(BloodMoon.Death - 1, 0)
end)

timer.Create("BloodMoonEvent", 1, 0, function()
	if math.random(1, GetConVar("sv_dbot_bloodmoon_chance"):GetInt()) == 1 then
		BloodMoon.Start()
		timer.Simple(math.random(120, 360), function()
			BloodMoon.End()
		end)
	end

	if math.random(1, GetConVar("sv_dbot_eclipse_chance"):GetInt()) == 1 then
		BloodMoon.StartEclipse()
		timer.Simple(math.random(60, 120), function()
			BloodMoon.EndEclipse()
		end)
	end
end)
