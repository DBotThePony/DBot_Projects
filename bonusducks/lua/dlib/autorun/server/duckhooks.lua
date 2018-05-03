
-- Copyright (C) 2016-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local DUCK_SOUND = {
	'vo/halloween_merasmus/sf14_merasmus_minigame_duckhunt_bonusducks_01.mp3',
	'vo/halloween_merasmus/sf14_merasmus_minigame_duckhunt_bonusducks_02.mp3',
	'vo/halloween_merasmus/sf14_merasmus_minigame_duckhunt_bonusducks_03.mp3',
}

resource.AddWorkshop('690794994')

local ENABLE = CreateConVar('sv_ducks_enable', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'BONUS DUCKS!')
local ENABLE_NPC = CreateConVar('sv_ducks_npc', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'BONUS DUCKS FOR NPC!')
local ENABLE_PLAYER = CreateConVar('sv_ducks_drop', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'BONUS DUCKS for Players')
local MIN = CreateConVar('sv_ducks_min', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Minimal Ducks')
local MAX = CreateConVar('sv_ducks_max', '12', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Maximum Ducks')
local CHANCE = CreateConVar('sv_ducks_chance', '2', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Chance. 2 means 50%, 4 means 20%, etc.')

local BEER_ENABLE = CreateConVar('sv_beer_enable', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable Mann Bear')
local BEER_ENABLE_NPC = CreateConVar('sv_beer_npc', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Beer drop for NPC')
local BEER_ENABLE_PLAYER = CreateConVar('sv_beer_drop', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Beer drop for Players')
local BEER_MIN = CreateConVar('sv_beer_min', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Minimal Mann Beer')
local BEER_MAX = CreateConVar('sv_beer_max', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Maximum Mann Beer')
local BEER_CHANCE = CreateConVar('sv_beer_chance', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Chance. 1 means 100%, 4 means 20%, etc.')

local function DoAction(ply)
	if not ENABLE:GetBool() then return end
	if math.random(1, CHANCE:GetInt()) ~= 1 then return end

	local epos = ply:EyePos()
	local count = math.random(MIN:GetInt(), MAX:GetInt())
	ply:EmitSound(table.Random(DUCK_SOUND), 75)

	for i = 1, count do
		local ent = ents.Create('dbot_duck')
		ent:SetPos(epos)
		ent:Spawn()
		ent:Activate()
		ent:Push()
	end
end

local function DoActionBeer(ply)
	if not BEER_ENABLE:GetBool() then return end
	if math.random(1, BEER_CHANCE:GetInt()) ~= 1 then return end

	local epos = ply:EyePos()
	local count = math.random(BEER_MIN:GetInt(), BEER_MAX:GetInt())
	ply:EmitSound('vo/watergate/drop_beer.mp3', 75)

	for i = 1, count do
		local ent = ents.Create('dbot_mannbeer')
		ent:SetPos(epos)
		ent:Spawn()
		ent:Activate()
		ent:Push()
	end
end

hook.Add('DoPlayerDeath', 'DBot_BONUS_DUCKS', function(ply)
	if BEER_ENABLE_PLAYER:GetBool() then DoActionBeer(ply)  end
	if ENABLE_PLAYER:GetBool() then DoAction(ply)  end
end)

hook.Add('OnNPCKilled', 'DBot_BONUS_DUCKS', function(npc)
	if BEER_ENABLE_NPC:GetBool() then DoActionBeer(npc) end
	if ENABLE_NPC:GetBool() then DoAction(npc) end
end)

local BEER_HEALTH = CreateConVar('sv_beer_health', '10', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'How much beer gives health on pickup. 0 to disable')

hook.Add('PostCollectBeer', 'DBot_BeerHookExample', function(self, ply)
	if BEER_HEALTH:GetInt() <= 0 then return end
	if ply:IsPlayer() then
		ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + BEER_HEALTH:GetInt()))
	end
end)