
-- Copyright (C) DBotThePony 2018

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local table = table
local weapons = weapons
local hook = hook

local pistols = {}
local shotguns = {}
local miniguns = {}
local revolers = {}
local rifles = {}
local sniper_rifles = {}
local sub_machine_guns = {}

table.insert(miniguns, 'tfa_cso_ak_long')
table.insert(miniguns, 'tfa_cso_avalanche')
table.insert(miniguns, 'tfa_cso_balrog7')
table.insert(miniguns, 'tfa_cso_charger7')
table.insert(miniguns, 'tfa_cso_coilmg')
table.insert(miniguns, 'tfa_cso_gilboa_viper')
table.insert(miniguns, 'tfa_cso_hk121_custom')
table.insert(miniguns, 'tfa_cso_k3')
table.insert(miniguns, 'tfa_cso_laserminigun')
table.insert(miniguns, 'tfa_cso_m134_vulcan')
table.insert(miniguns, 'tfa_cso_m2_v6')
table.insert(miniguns, 'tfa_cso_m2_v8')
table.insert(miniguns, 'tfa_cso_m2')
table.insert(miniguns, 'tfa_cso_m249_xmas')
table.insert(miniguns, 'tfa_cso_m249')
table.insert(miniguns, 'tfa_cso_m249camo')
table.insert(miniguns, 'tfa_cso_m249ep')
table.insert(miniguns, 'tfa_cso_m60_v6')
table.insert(miniguns, 'tfa_cso_m60_v8')
table.insert(miniguns, 'tfa_cso_m60')
table.insert(miniguns, 'tfa_cso_m60g')
table.insert(miniguns, 'tfa_cso_mg3')
table.insert(miniguns, 'tfa_cso_mg36_xmas')
table.insert(miniguns, 'tfa_cso_mg36')
table.insert(miniguns, 'tfa_cso_mg3g')
table.insert(miniguns, 'tfa_cso_mg42')
table.insert(miniguns, 'tfa_cso_mk48_master')
table.insert(miniguns, 'tfa_cso_negev')
table.insert(miniguns, 'tfa_cso_skull8')
table.insert(miniguns, 'tfa_cso_thanatos7')
table.insert(miniguns, 'tfa_cso_turbulent7')
table.insert(miniguns, 'tfa_cso_ultimax100')
table.insert(miniguns, 'tfa_ins2_rpk_r')
table.insert(miniguns, 'tfa_mwr_m60')
table.insert(miniguns, 'tfa_mwr_mk8')
table.insert(miniguns, 'tfa_mwr_pkm')
table.insert(miniguns, 'tfa_mwr_rpd')
table.insert(miniguns, 'tfa_mwr_saw')
table.insert(pistols, 'tfa_cso_balrog1')
table.insert(pistols, 'tfa_cso_crow1')
table.insert(pistols, 'tfa_cso_fnp45')
table.insert(pistols, 'tfa_cso_infinite_black')
table.insert(pistols, 'tfa_cso_infinite_red')
table.insert(pistols, 'tfa_cso_infinite_silver')
table.insert(pistols, 'tfa_cso_luger_expert')
table.insert(pistols, 'tfa_cso_luger_gold')
table.insert(pistols, 'tfa_cso_luger_master')
table.insert(pistols, 'tfa_cso_luger_silver')
table.insert(pistols, 'tfa_cso_luger')
table.insert(pistols, 'tfa_cso_m1911a1')
table.insert(pistols, 'tfa_cso_mauser_c96')
table.insert(pistols, 'tfa_cso_thanatos1')
table.insert(pistols, 'tfa_cso_turbulent1')
table.insert(pistols, 'tfa_ins2_deagle')
table.insert(pistols, 'tfa_ins2_fiveseven')
table.insert(pistols, 'tfa_ins2_m9')
table.insert(pistols, 'tfa_ins2_p220')
table.insert(pistols, 'tfa_ins2_p226')
table.insert(pistols, 'tfa_ins2_p30l')
table.insert(pistols, 'tfa_ins2_sw659')
table.insert(pistols, 'tfa_ins2_usp_match')
table.insert(pistols, 'tfa_ins2_usp45')
table.insert(pistols, 'tfa_l4d2_osp18')
table.insert(pistols, 'tfa_mwr_br9')
table.insert(pistols, 'tfa_mwr_de50')
table.insert(pistols, 'tfa_mwr_m1911')
table.insert(pistols, 'tfa_mwr_m9')
table.insert(pistols, 'tfa_mwr_prokolot')
table.insert(pistols, 'tfa_mwr_usp45')
table.insert(revolers, 'tfa_bms_357')
table.insert(revolers, 'tfa_cso_anaconda')
table.insert(revolers, 'tfa_cso_desperado')
table.insert(revolers, 'tfa_cso_sapientia')
table.insert(revolers, 'tfa_cso_skull1')
table.insert(revolers, 'tfa_cso_skull2')
table.insert(revolers, 'tfa_ins2_thanez_cobra')
table.insert(revolers, 'tfa_l4d2_rhino')
table.insert(revolers, 'tfa_mwr_44mag')
table.insert(rifles, 'tfa_cso_ak47_dragon')
table.insert(rifles, 'tfa_cso_ak47')
table.insert(rifles, 'tfa_cso_ak47red')
table.insert(rifles, 'tfa_cso_ak74u')
table.insert(rifles, 'tfa_cso_akm')
table.insert(rifles, 'tfa_cso_an94')
table.insert(rifles, 'tfa_cso_arx160_expert')
table.insert(rifles, 'tfa_cso_arx160_master')
table.insert(rifles, 'tfa_cso_arx160')
table.insert(rifles, 'tfa_cso_blaster')
table.insert(rifles, 'tfa_cso_brickpiecev2')
table.insert(rifles, 'tfa_cso_burningaug')
table.insert(rifles, 'tfa_cso_crow5')
table.insert(rifles, 'tfa_cso_darkknight_overlord')
table.insert(rifles, 'tfa_cso_darkknight')
table.insert(rifles, 'tfa_cso_ethereal')
table.insert(rifles, 'tfa_cso_f2000')
table.insert(rifles, 'tfa_cso_fnc')
table.insert(rifles, 'tfa_cso_g_ak47')
table.insert(rifles, 'tfa_cso_guardian')
table.insert(rifles, 'tfa_cso_hk_g11')
table.insert(rifles, 'tfa_cso_hk416')
table.insert(rifles, 'tfa_cso_kbkart2000')
table.insert(rifles, 'tfa_cso_l85a2')
table.insert(rifles, 'tfa_cso_lightningguitar')
table.insert(rifles, 'tfa_cso_lycanthrope_expert')
table.insert(rifles, 'tfa_cso_lycanthrope')
table.insert(rifles, 'tfa_cso_m16a1')
table.insert(rifles, 'tfa_cso_m16a1ep')
table.insert(rifles, 'tfa_cso_m16a4')
table.insert(rifles, 'tfa_cso_m1918bar')
table.insert(rifles, 'tfa_cso_m1garand')
table.insert(rifles, 'tfa_cso_m4a1')
table.insert(rifles, 'tfa_cso_m4a1dragon')
table.insert(rifles, 'tfa_cso_m4a1g')
table.insert(rifles, 'tfa_cso_m4a1gold')
table.insert(rifles, 'tfa_cso_m4a1red')
table.insert(rifles, 'tfa_cso_norinco_86s')
table.insert(rifles, 'tfa_cso_oicw')
table.insert(rifles, 'tfa_cso_paladin_tyrant')
table.insert(rifles, 'tfa_cso_paladin')
table.insert(rifles, 'tfa_cso_plasmagun')
table.insert(rifles, 'tfa_cso_scar_l')
table.insert(rifles, 'tfa_cso_stg44')
table.insert(rifles, 'tfa_cso_tar_21')
table.insert(rifles, 'tfa_cso_thanatos5')
table.insert(rifles, 'tfa_cso_turbulent5')
table.insert(rifles, 'tfa_cso_xm8')
table.insert(rifles, 'tfa_ins2_416c')
table.insert(rifles, 'tfa_ins2_abakan')
table.insert(rifles, 'tfa_ins2_ak74_r')
table.insert(rifles, 'tfa_ins2_akm_r')
table.insert(rifles, 'tfa_ins2_aks_r')
table.insert(rifles, 'tfa_ins2_arx160')
table.insert(rifles, 'tfa_ins2_aug')
table.insert(rifles, 'tfa_ins2_cq300')
table.insert(rifles, 'tfa_ins2_cz805')
table.insert(rifles, 'tfa_ins2_famas')
table.insert(rifles, 'tfa_ins2_fas2_g36c')
table.insert(rifles, 'tfa_ins2_groza')
table.insert(rifles, 'tfa_ins2_l85a2')
table.insert(rifles, 'tfa_ins2_mk18')
table.insert(rifles, 'tfa_ins2_sai_gry')
table.insert(rifles, 'tfa_ins2_sks')
table.insert(rifles, 'tfa_l4d2_rk62')
table.insert(rifles, 'tfa_mwr_ak47')
table.insert(rifles, 'tfa_mwr_bos14')
table.insert(rifles, 'tfa_mwr_g3')
table.insert(rifles, 'tfa_mwr_g36c')
table.insert(rifles, 'tfa_mwr_lynx')
table.insert(rifles, 'tfa_mwr_m14')
table.insert(rifles, 'tfa_mwr_m16a4')
table.insert(rifles, 'tfa_mwr_m4a1')
table.insert(rifles, 'tfa_mwr_mp44')
table.insert(rifles, 'tfa_mwr_xmlar')
table.insert(shotguns, 'blast_tfa_sjogren')
table.insert(shotguns, 'tfa_bms_shotgun')
table.insert(shotguns, 'tfa_cso_balrog11')
table.insert(shotguns, 'tfa_cso_batista')
table.insert(shotguns, 'tfa_cso_duckgun')
table.insert(shotguns, 'tfa_cso_ksg12_expert')
table.insert(shotguns, 'tfa_cso_ksg12_gold')
table.insert(shotguns, 'tfa_cso_ksg12_master')
table.insert(shotguns, 'tfa_cso_ksg12')
table.insert(shotguns, 'tfa_cso_m1887_expert')
table.insert(shotguns, 'tfa_cso_m1887_gold')
table.insert(shotguns, 'tfa_cso_m1887_master')
table.insert(shotguns, 'tfa_cso_m1887_maverick')
table.insert(shotguns, 'tfa_cso_m1887')
table.insert(shotguns, 'tfa_cso_m3dragon')
table.insert(shotguns, 'tfa_cso_magnum_lancer')
table.insert(shotguns, 'tfa_cso_magnumdrill_expert')
table.insert(shotguns, 'tfa_cso_magnumdrill')
table.insert(shotguns, 'tfa_cso_mk3a1_flame')
table.insert(shotguns, 'tfa_cso_qbs09')
table.insert(shotguns, 'tfa_cso_quadbarrel')
table.insert(shotguns, 'tfa_cso_railcannon')
table.insert(shotguns, 'tfa_cso_skull11')
table.insert(shotguns, 'tfa_cso_spas12maverick')
table.insert(shotguns, 'tfa_cso_spas12superior')
table.insert(shotguns, 'tfa_cso_thanatos11')
table.insert(shotguns, 'tfa_cso_uts15')
table.insert(shotguns, 'tfa_cso_volcano')
table.insert(shotguns, 'tfa_ins2_m1897')
table.insert(shotguns, 'tfa_ins2_m500')
table.insert(shotguns, 'tfa_ins2_nova')
table.insert(shotguns, 'tfa_l4d2_1887')
table.insert(shotguns, 'tfa_mwr_kam12')
table.insert(shotguns, 'tfa_mwr_m1014')
table.insert(shotguns, 'tfa_mwr_ranger')
table.insert(shotguns, 'tfa_mwr_w1200')
table.insert(sniper_rifles, 'tfa_cso_crimson_hunter_expert')
table.insert(sniper_rifles, 'tfa_cso_crimson_hunter')
table.insert(sniper_rifles, 'tfa_cso_elvenranger')
table.insert(sniper_rifles, 'tfa_cso_m95_expert')
table.insert(sniper_rifles, 'tfa_cso_m95_master')
table.insert(sniper_rifles, 'tfa_cso_m95_xmas')
table.insert(sniper_rifles, 'tfa_cso_m95')
table.insert(sniper_rifles, 'tfa_cso_milkorm32')
table.insert(sniper_rifles, 'tfa_cso_mosin')
table.insert(sniper_rifles, 'tfa_cso_starchasersr')
table.insert(sniper_rifles, 'tfa_cso_thunderbolt')
table.insert(sniper_rifles, 'tfa_cso_wa2000_expert')
table.insert(sniper_rifles, 'tfa_cso_wa2000_gold')
table.insert(sniper_rifles, 'tfa_cso_wa2000_master')
table.insert(sniper_rifles, 'tfa_cso_wa2000')
table.insert(sniper_rifles, 'tfa_ins2_wa2000')
table.insert(sniper_rifles, 'tfa_mwr_d25s')
table.insert(sniper_rifles, 'tfa_mwr_drag')
table.insert(sniper_rifles, 'tfa_mwr_m21')
table.insert(sniper_rifles, 'tfa_mwr_m40a3')
table.insert(sniper_rifles, 'tfa_mwr_m82')
table.insert(sniper_rifles, 'tfa_mwr_r700')
table.insert(sniper_rifles, 'tfa_mwr_tac330')
table.insert(sub_machine_guns, 'tfa_cso_aeolis')
table.insert(sub_machine_guns, 'tfa_cso_balrog3')
table.insert(sub_machine_guns, 'tfa_cso_balrog5')
table.insert(sub_machine_guns, 'tfa_cso_cameragun')
table.insert(sub_machine_guns, 'tfa_cso_dragoncannon')
table.insert(sub_machine_guns, 'tfa_cso_k1a_maverick')
table.insert(sub_machine_guns, 'tfa_cso_m950_attack')
table.insert(sub_machine_guns, 'tfa_cso_mg3xmas')
table.insert(sub_machine_guns, 'tfa_cso_mp40')
table.insert(sub_machine_guns, 'tfa_cso_mp7a1')
table.insert(sub_machine_guns, 'tfa_cso_mp7a160r')
table.insert(sub_machine_guns, 'tfa_cso_newcomen')
table.insert(sub_machine_guns, 'tfa_cso_skull3_a')
table.insert(sub_machine_guns, 'tfa_cso_sten_mk2')
table.insert(sub_machine_guns, 'tfa_cso_tempest')
table.insert(sub_machine_guns, 'tfa_cso_thanatos3')
table.insert(sub_machine_guns, 'tfa_cso_thompson_chicago')
table.insert(sub_machine_guns, 'tfa_cso_thompson_expert')
table.insert(sub_machine_guns, 'tfa_cso_thompson_gold')
table.insert(sub_machine_guns, 'tfa_cso_thompson_master')
table.insert(sub_machine_guns, 'tfa_cso_tmpdragon')
table.insert(sub_machine_guns, 'tfa_cso_uzi')
table.insert(sub_machine_guns, 'tfa_cso_vulcanus3')
table.insert(sub_machine_guns, 'tfa_cso_watergun')
table.insert(sub_machine_guns, 'tfa_ins2_mp7')
table.insert(sub_machine_guns, 'tfa_ins2_mwr_p90')
table.insert(sub_machine_guns, 'tfa_ins2_sterling')
table.insert(sub_machine_guns, 'tfa_l4d2_gepard')
table.insert(sub_machine_guns, 'tfa_l4d2_skorpion')
table.insert(sub_machine_guns, 'tfa_mwr_ak74u')
table.insert(sub_machine_guns, 'tfa_mwr_fang45')
table.insert(sub_machine_guns, 'tfa_mwr_mac10')
table.insert(sub_machine_guns, 'tfa_mwr_mp5')
table.insert(sub_machine_guns, 'tfa_mwr_p90')
table.insert(sub_machine_guns, 'tfa_mwr_psd9')
table.insert(sub_machine_guns, 'tfa_mwr_uzi')
table.insert(sub_machine_guns, 'tfa_mwr_vz61')

local ProtectedCall = ProtectedCall

local function patch(classdef)
	local status = ProtectedCall(function()
		weapons.Register(classdef, classdef.ClassName)
	end)

	if not status then
		print('Unable to patch ' .. classdef.ClassName .. '! Look for error above')
	end
end

hook.Add('InitPostEntity', 'AddWeaponJam', function()
	local weaponMapping = {}

	for num, classdef in ipairs(weapons.GetList()) do
		if classdef.ClassName then
			weaponMapping[classdef.ClassName] = classdef
		end
	end

	for i, classname in ipairs(pistols) do
		if weaponMapping[classname] and (not weaponMapping[classname].CanJam or TFA_AUTOJAMMING_ENABLED) then
			weaponMapping[classname].CanJam = true
			weaponMapping[classname].JamChance = 0.20
			weaponMapping[classname].JamFactor = 0.14
			patch(weaponMapping[classname])
		end
	end

	for i, classname in ipairs(shotguns) do
		if weaponMapping[classname] and (not weaponMapping[classname].CanJam or TFA_AUTOJAMMING_ENABLED) then
			weaponMapping[classname].CanJam = true
			weaponMapping[classname].JamChance = 0.25
			weaponMapping[classname].JamFactor = 0.30
			patch(weaponMapping[classname])
		end
	end

	for i, classname in ipairs(miniguns) do
		if weaponMapping[classname] and (not weaponMapping[classname].CanJam or TFA_AUTOJAMMING_ENABLED) then
			weaponMapping[classname].CanJam = true
			weaponMapping[classname].JamChance = 0.03
			weaponMapping[classname].JamFactor = 0.01
			patch(weaponMapping[classname])
		end
	end

	for i, classname in ipairs(revolers) do
		if weaponMapping[classname] and (not weaponMapping[classname].CanJam or TFA_AUTOJAMMING_ENABLED) then
			weaponMapping[classname].CanJam = true
			weaponMapping[classname].JamChance = 0.17
			weaponMapping[classname].JamFactor = 0.50
			patch(weaponMapping[classname])
		end
	end

	for i, classname in ipairs(rifles) do
		if weaponMapping[classname] and (not weaponMapping[classname].CanJam or TFA_AUTOJAMMING_ENABLED) then
			weaponMapping[classname].CanJam = true
			weaponMapping[classname].JamChance = 0.04
			weaponMapping[classname].JamFactor = 0.06
			patch(weaponMapping[classname])
		end
	end

	for i, classname in ipairs(sniper_rifles) do
		if weaponMapping[classname] and (not weaponMapping[classname].CanJam or TFA_AUTOJAMMING_ENABLED) then
			weaponMapping[classname].CanJam = true
			weaponMapping[classname].JamChance = 0.17
			weaponMapping[classname].JamFactor = 0.35
			patch(weaponMapping[classname])
		end
	end

	for i, classname in ipairs(sub_machine_guns) do
		if weaponMapping[classname] and (not weaponMapping[classname].CanJam or TFA_AUTOJAMMING_ENABLED) then
			weaponMapping[classname].CanJam = true
			weaponMapping[classname].JamChance = 0.04
			weaponMapping[classname].JamFactor = 0.09
			patch(weaponMapping[classname])
		end
	end
end)
