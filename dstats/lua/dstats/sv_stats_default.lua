
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

local self = DStats.stats

self.DefaultStats = {
	deaths = 0,
	kills = 0,
	npckills = 0,
	damage = 0,
	npcdamage = 0,
	recivdamage = 0,
	
	noclipdist = 0,
	walkdist = 0,
	duckdist = 0,
	vehdist = 0,
	rundist = 0,
	flooddist = 0,
	underwaterdist = 0,
	waterdist = 0,
	falldist = 0,
	climbdist = 0,
	say = 0,
	say_words = 0,
	say_chars = 0,
}

local function N(ply)
	return ply.DStats.stats
end

local function PlayerThink(ply)
	if not ply.DStats then return end
	if not N(ply) then return end
	if not N(ply).LOADED then return end
	
	N(ply).dists = N(ply).dists or {}
	local i = N(ply).dists
	
	local pos = ply:GetPos()
	i.lastpos = i.lastpos or pos
	local lastpos = i.lastpos
	local dist = i.lastpos:Distance(pos)
	
	i.lastpos = pos
	if dist > 500 then
		return --Impossible for walking. Possibly teleported, or respawned
	end
	
	local zDelta = pos.z - lastpos.z
	
	if zDelta > 0 then
		self.AddStat(ply, 'climbdist', zDelta)
	elseif zDelta < 0 then
		self.AddStat(ply, 'falldist', -zDelta)
	end
	
	if ply:GetMoveType() == MOVETYPE_NOCLIP then
		self.AddStat(ply, 'noclipdist', dist)
		return
	end
	
	if ply:GetMoveType() ~= MOVETYPE_WALK then
		return
	end
	
	if ply:InVehicle() then
		self.AddStat(ply, 'vehdist', dist)
		return
	end
	
	local wLevel = ply:WaterLevel()
	
	if wLevel == 1 then
		self.AddStat(ply, 'waterdist', dist)
		return
	elseif wLevel == 2 then
		self.AddStat(ply, 'flooddist', dist)
		return
	elseif wLevel == 2 then
		self.AddStat(ply, 'underwaterdist', dist)
		return
	end
	
	if not ply:OnGround() then return end
	
	if ply:KeyDown(IN_DUCK) then
		self.AddStat(ply, 'duckdist', dist)
		return
	end
	
	if ply:KeyDown(IN_RUN) then
		self.AddStat(ply, 'rundist', dist)
		return
	end
	
	self.AddStat(ply, 'walkdist', dist)
end

self.StatsHooks = {
	PlayerDeath = function(ply, weapon, attacker)
		self.AddStat(ply, 'deaths')
		
		if IsValid(attacker) and attacker:IsPlayer() then
			self.AddStat(attacker, 'kills')
		end
	end,
	
	OnNPCKilled = function(npc, attacker)
		if IsValid(attacker) and attacker:IsPlayer() then
			self.AddStat(attacker, 'npckills')
		end
	end,
	
	EntityTakeDamage = function(ent, dmg)
		local attacker = dmg:GetAttacker()
		
		if IsValid(attacker) and attacker:IsPlayer() then
			self.AddStat(attacker, 'damage', math.ceil(dmg:GetDamage()))
			
			if ent:IsNPC() then
				self.AddStat(attacker, 'npcdamage', math.ceil(dmg:GetDamage()))
			end
		end
		
		if ent:IsPlayer() then
			self.AddStat(ent, 'recivdamage', math.ceil(dmg:GetDamage()))
		end
	end,
	
	Think = function()
		for k, v in ipairs(player.GetAll()) do
			PlayerThink(v)
		end
	end,
	
	PlayerSay = function(ply, text)
		self.AddStat(ply, 'say')
		self.AddStat(ply, 'say_words', #string.Explode(' ', text))
		self.AddStat(ply, 'say_chars', #text)
	end,
}

local Spawns = {
	{'PlayerSpawnedEffect', 'effect'},
	{'PlayerSpawnedNPC', 'npc'},
	{'PlayerSpawnedProp', 'prop'},
	{'PlayerSpawnedRagdoll', 'ragdoll'},
	{'PlayerSpawnedSENT', 'sent'},
	{'PlayerSpawnedSWEP', 'swep'},
	{'PlayerSpawnedVehicle', 'vehicle'},
}

for k, v in ipairs(Spawns) do
	self.StatsHooks[v[1]] = function(ply)
		self.AddStat(ply, 'spawn_' .. v[2])
	end
	
	self.DefaultStats['spawn_' .. v[2]] = 0
end

for k, v in pairs(self.DefaultStats) do
	self.RegisterStat(k, v)
end

for k, v in pairs(self.StatsHooks) do
	hook.Add(k, 'DStats.stats.hooks', v)
end
