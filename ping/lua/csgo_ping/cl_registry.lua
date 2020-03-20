
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

CSGOPinging.Materials = {}

local function m(name)
	return Material('gui/ping/' .. name .. '.png')
end

CSGOPinging.Sound = Sound('gui/ping/playerping.wav')

CSGOPinging.Materials.ammo = m('ammobox')
CSGOPinging.Materials.ammo_big = m('ammobox_threepack')
CSGOPinging.Materials.animal = m('zoo')
CSGOPinging.Materials.armor = m('armor_helmet')
CSGOPinging.Materials.bullet = m('bullet')
CSGOPinging.Materials.bumpmine = m('bumpmine')
CSGOPinging.Materials.check = m('check')
CSGOPinging.Materials.clock = m('clock')
CSGOPinging.Materials.danger = m('alert')
CSGOPinging.Materials.decoy = m('decoy')
CSGOPinging.Materials.drone = m('controldrone')
CSGOPinging.Materials.explosion = m('bomb')
CSGOPinging.Materials.explosive = m('bomb_icon')
CSGOPinging.Materials.explosive2 = m('breachcharge')
CSGOPinging.Materials.find = m('find')
CSGOPinging.Materials.flashbang = m('flashbang')
CSGOPinging.Materials.frag_grenade = m('frag_grenade')
CSGOPinging.Materials.gift = m('gift')
CSGOPinging.Materials.heavy_armor = m('heavy_armor')
CSGOPinging.Materials.helmet = m('helmet')
CSGOPinging.Materials.home = m('home')
CSGOPinging.Materials.inferno = m('inferno')
CSGOPinging.Materials.info = m('info')
CSGOPinging.Materials.kevlar = m('kevlar')
CSGOPinging.Materials.key = m('key')
CSGOPinging.Materials.leave = m('leave')
CSGOPinging.Materials.locked = m('locked')
CSGOPinging.Materials.machine_gun = m('negev')
CSGOPinging.Materials.health = m('health')
CSGOPinging.Materials.medicine = m('healthshot')
CSGOPinging.Materials.melee = m('knife')
CSGOPinging.Materials.missle = m('missle')
CSGOPinging.Materials.molotov = m('molotov')
CSGOPinging.Materials.money = m('dollar_sign')
CSGOPinging.Materials.no = m('favorite_no')
CSGOPinging.Materials.outofammo = m('outofammo')
CSGOPinging.Materials.pistol = m('deagle')
CSGOPinging.Materials.point_up = m('votenotreadyformatch')
CSGOPinging.Materials.rifle = m('ak47')
CSGOPinging.Materials.shotgun = m('nova')
CSGOPinging.Materials.signal = m('broadcast')
CSGOPinging.Materials.sniper_rifle = m('awp')
CSGOPinging.Materials.sound = m('unmuted')
CSGOPinging.Materials.survival_safe = m('survival_safe')
CSGOPinging.Materials.tablet = m('tablet')
CSGOPinging.Materials.tagrenade = m('tagrenade')
CSGOPinging.Materials.thumbs_up = m('votereadyformatch')
CSGOPinging.Materials.turret = m('dronegun')
CSGOPinging.Materials.unlocked = m('unlocked')
CSGOPinging.Materials.unlocked_wide = m('unlockedwide')
CSGOPinging.Materials.watch = m('watch')
CSGOPinging.Materials.watch_mag = m('watchhighlights')
CSGOPinging.Materials.x = m('exit')
CSGOPinging.Materials.yes = m('favorite_yes')
CSGOPinging.Materials.npc = m('player')

local function HandleDoors(ply, hitpos, ent, class)
	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "func_movelinear" then
		return CSGOPinging.Materials.leave
	end
end

local function HandleTFA(ply, hitpos, ent, class)
	if not ent.IsTFA or not ent:IsTFA() then return end

	local type = ent:GetType():lower()

	if type == 'rifle' then
		return CSGOPinging.Materials.rifle
	elseif type == 'pistol' or type == 'revolver' then
		return CSGOPinging.Materials.pistol
	elseif type == 'light machine gun' or type == 'minigun' or type == 'light machinegun' then
		return CSGOPinging.Materials.machine_gun
	elseif type:find('shotgun') then
		return CSGOPinging.Materials.shotgun
	elseif type:find('sniper') then
		return CSGOPinging.Materials.sniper_rifle
	elseif ent.Base == 'tfa_melee_base' or type:find('melee') then
		return CSGOPinging.Materials.melee
	end
end

local ammo_add = Vector(0, 0, 10)

local function HandleDefaultAmmo(ply, hitpos, ent, class)
	if not class then return end

	if class:startsWith('item_ammo_') and class:EndsWith('_large') then
		return CSGOPinging.Materials.ammo_big, true
	end

	if class:startsWith('item_ammo_') then
		return CSGOPinging.Materials.ammo, true
	end

	if class == 'item_rpg_round' or class == 'item_box_buckshot' then
		return CSGOPinging.Materials.ammo, true
	end
end

local function HandleDefaultItems(ply, hitpos, ent, class)
	if not class then return end

	if class == 'item_healthkit' then
		return CSGOPinging.Materials.health, true
	end

	if class == 'item_healthvial' then
		return CSGOPinging.Materials.medicine, true
	end

	if class == 'item_battery' then
		return CSGOPinging.Materials.kevlar, true
	end

	if class == 'grenade_helicopter' then
		return CSGOPinging.Materials.explosion, true
	end

	if class == 'npc_grenade_frag' then
		return CSGOPinging.Materials.explosion, true
	end

	if class == 'weapon_striderbuster' then
		return CSGOPinging.Materials.explosive2, true
	end

	if class == 'combine_mine' then
		return CSGOPinging.Materials.bumpmine, true
	end
end

local function HandleDefaultMisc(ply, hitpos, ent, class)
	if ent:IsOnFire() then
		return CSGOPinging.Materials.inferno
	end

	if class:startsWith('prop_') then
		local info = util.GetModelInfo(ent:GetModel())

		if info and info.ModelKeyValues then
			local parse = util.KeyValuesToTable(info.ModelKeyValues)

			if parse and parse.prop_data and (parse.prop_data.explosive_damage or parse.prop_data.explosive_radius) then
				return CSGOPinging.Materials.explosion, true
			end
		end
	end
end

local function HandleTFAAmmo(ply, hitpos, ent, class)
	if not class then return end

	if class:startsWith('tfa_ammo_') then
		return CSGOPinging.Materials.ammo, true
	end
end

local animals = {
	'npc_crow',
	'npc_pigeon',
	'npc_seagull',
	'monster_cockroach',
}

local enemies = {
	'npc_metropolice',
	'npc_manhack',
	'npc_combine_s',
	'npc_hunter',
	'npc_strider',
	'npc_stalker',
	'npc_clawscanner',
	'npc_rollermine',
	'npc_helicopter',
	'npc_headcrab',
	'npc_headcrab_black',
	'npc_poisonzombie',
	'npc_zombie',
	'npc_zombie_torso',
	'npc_zombine',
	'npc_fastzombie',
	'npc_headcrab_fast',
	'npc_fastzombie_torso',
	'npc_antlion',
	'npc_antlionguard',
	'npc_antlionguardian',
	'npc_antlion_worker',
	'monster_snark',
	'monster_alien_slave',
	'monster_alien_grunt',
	'monster_human_assassin',
	'monster_babycrab',
	'monster_bullchicken',
	'monster_alien_controller',
	'monster_gargantua',
	'monster_bigmomma',
	'monster_human_grunt',
	'monster_headcrab',
	'monster_houndeye',
	'monster_nihilanth',
	'monster_snark',
	'monster_tentacle',
	'monster_zombie',
}

local barnacle_vector = Vector(0, 0, -20)

local function HandleDefaultNPC(ply, hitpos, ent, class)
	if not class then return end

	if class == 'npc_tripmine' then
		return CSGOPinging.Materials.danger, true, ammo_add
	end

	if class == 'npc_satchel' then
		return CSGOPinging.Materials.explosive2, true
	end

	if class == 'npc_turret_floor' or class == 'monster_sentry' then
		return CSGOPinging.Materials.turret
	end

	if class == 'npc_turret_ceiling' or class == 'monster_turret' or class == 'monster_miniturret' then
		return CSGOPinging.Materials.turret, false, barnacle_vector
	end

	if class == 'npc_combine_camera' then
		return CSGOPinging.Materials.watch_mag, false, barnacle_vector
	end

	if class == 'npc_barnacle' then
		return CSGOPinging.Materials.danger, false, barnacle_vector
	end

	if class == 'npc_gman' then
		return CSGOPinging.Materials.watch
	end

	if class == 'npc_antlion_grub' then
		return CSGOPinging.Materials.no, false
	end

	if table.qhasValue(animals, class) then
		return CSGOPinging.Materials.animal
	end

	if table.qhasValue(enemies, class) then
		return CSGOPinging.Materials.danger
	end
end

local function HandleNoneNPC(ply, hitpos, ent, class)
	if not class then return end

	if ent:IsNPC() then
		return CSGOPinging.Materials.npc
	end
end

hook.Add('CSGOPing_HandleEntity', 'Default.Doors', HandleDoors, 1)
hook.Add('CSGOPing_HandleEntity', 'Default.TFA', HandleTFA, 1)
hook.Add('CSGOPing_HandleEntity', 'Default.DefaultAmmo', HandleDefaultAmmo, 4)
hook.Add('CSGOPing_HandleEntity', 'Default.DefaultItems', HandleDefaultItems, 4)
hook.Add('CSGOPing_HandleEntity', 'Default.TFAAmmo', HandleTFAAmmo, 1)
hook.Add('CSGOPing_HandleEntity', 'Default.DefaultNPC', HandleDefaultNPC, 4)
hook.Add('CSGOPing_HandleEntity', 'Default.NoneNPC', HandleNoneNPC, 10)
hook.Add('CSGOPing_HandleEntity', 'Default.DefaultMisc', HandleDefaultMisc, 3)
