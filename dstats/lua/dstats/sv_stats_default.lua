
--[[
Copyright (C) 2016-2018 DBot


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
