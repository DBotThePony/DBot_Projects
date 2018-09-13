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
local revolvers = {}
local rifles = {}
local sniper_rifles = {}
local sub_machine_guns = {}

-- tfa_bms_crowbar has invalid type: weapon
-- tfa_bms_glock has invalid type: 9mm semi automatic handgun
-- tfa_bms_grenade has invalid type: grenade
-- tfa_bms_mp5 has invalid type: 9mm smg with underbarrel grenade launcher (+zoom key to toggle)
-- tfa_bms_rpg has invalid type: launcher
-- tfa_cso_automagv has invalid type: machine pistol
-- tfa_cso_beam_sword has invalid type: weapon
-- tfa_cso_cake has invalid type: grenade
-- tfa_cso_chaingrenade has invalid type: grenade
-- tfa_cso_coldsteelblade has invalid type: weapon
-- tfa_cso_crossbow has invalid type: designated marksman rifle
-- tfa_cso_deagle has invalid type: machine pistol
-- tfa_cso_deaglered has invalid type: machine pistol
-- tfa_cso_divinelock has invalid type: weapon
-- tfa_cso_dmp7a1 has invalid type: dual sub-machine guns
-- tfa_cso_dragonblade has invalid type: weapon
-- tfa_cso_dragonblade_expert has invalid type: weapon
-- tfa_cso_dualinfinity has invalid type: dual pistols
-- tfa_cso_dualinfinityfinal has invalid type: dual pistols
-- tfa_cso_dualkrisscustom has invalid type: dual sub-machine guns
-- tfa_cso_dualsword has invalid type: weapon
-- tfa_cso_dualuzi has invalid type: dual sub-machine guns
-- tfa_cso_fglauncher has invalid type: weapon
-- tfa_cso_g_deagle has invalid type: machine pistol
-- tfa_cso_infinityex1 has invalid type: dual pistols
-- tfa_cso_m249ex has invalid type: designated marksman rifle
-- tfa_cso_m24grenade has invalid type: grenade
-- tfa_cso_m60craft has invalid type: designated marksman rifle
-- tfa_cso_m79 has invalid type: weapon
-- tfa_cso_m79_gold has invalid type: weapon
-- tfa_cso_mk48 has invalid type: designated marksman rifle
-- tfa_cso_mk48_expert has invalid type: designated marksman rifle
-- tfa_cso_runebreaker has invalid type: weapon
-- tfa_cso_runebreaker_expert has invalid type: weapon
-- tfa_cso_serpent_blade has invalid type: weapon
-- tfa_cso_skull3_b has invalid type: dual sub-machine guns
-- tfa_cso_skull4 has invalid type: dual guns
-- tfa_cso_skull5 has invalid type: designated marksman rifle
-- tfa_cso_skull6 has invalid type: designated marksman rifle
-- tfa_cso_skull9 has invalid type: weapon
-- tfa_cso_stormgiant has invalid type: weapon
-- tfa_cso_stormgiant_tw has invalid type: weapon
-- tfa_cso_thanatos9 has invalid type: weapon
-- tfa_cso_vulcanus1_a has invalid type: dual pistols
-- tfa_cso_vulcanus1_b has invalid type: dual pistols
-- tfa_elephant_ak47 has invalid type: one of, if not the most iconic gun in the world
-- tfa_elephant_aks74 has invalid type: smaller calibre version of the classic ak-47 rifle
-- tfa_elephant_bizon has invalid type: russian submachine gun with a unique helical magazine
-- tfa_elephant_l110a1 has invalid type: standard issue lmg of the united kingdom
-- tfa_elephant_l34a1 has invalid type: a silenced variant of the british sterling smg
-- tfa_elephant_m14 has invalid type: a .30 caliber battle rifle manufactured in the united states of america
-- tfa_elephant_m16a2 has invalid type: former service rifle of the united states of america
-- tfa_elephant_m16a3 has invalid type: fully automatic variant of the m16a2 rifle
-- tfa_elephant_m1911 has invalid type: an american made pistol that served in both world wars
-- tfa_elephant_m249 has invalid type: standard issue lmg of the united states of america
-- tfa_elephant_m4 has invalid type: carbine variant of the m16a4 rifle
-- tfa_elephant_m4a1 has invalid type: current service rifle of the united states of america
-- tfa_elephant_m79 has invalid type: an american grenade launcher used by the united states of america in vietnam
-- tfa_elephant_m870 has invalid type: a 12 gauge, american shotgun and is currently in service of the united states of america
-- tfa_elephant_mac11 has invalid type: a smaller version of the infamous mac-10 submachine-gun
-- tfa_elephant_mk7 has invalid type: a sub-compact variant of the sterling smg
-- tfa_elephant_ots33 has invalid type: russian machine-pistol designed by igor stechkin
-- tfa_elephant_p226 has invalid type: a popular swiss-german pistol used by militaries around the world
-- tfa_elephant_rpk has invalid type: machine gun variant of the ak-47 rifle
-- tfa_elephant_sterling has invalid type: a submachine gun manufactured in the united kingdom
-- tfa_ins2_ak5d has invalid type: swedish 5.56x45mm automatic carbine rifle
-- tfa_ins2_akm has invalid type: russian 7.62x39mm automatic assault rifle
-- tfa_ins2_aks74u has invalid type: russian 5.56x39mm automatic carbine rifle
-- tfa_ins2_asval has invalid type: russian 9x39mm sp5 automatic special assault rifle
-- tfa_ins2_d25s has invalid type: american .308 semi automatic designated marksman rifle
-- tfa_ins2_doublebarrel has invalid type: russian 12 gauge break action shotgun
-- tfa_ins2_epcwn has invalid type: belgian 7.62x115mm burst battle rifle
-- tfa_ins2_f1 has invalid type: russian fragmentation hand grenade
-- tfa_ins2_fnfal has invalid type: belgian 7.62x51mm automatic battle rifle
-- tfa_ins2_g36c has invalid type: german 5.56x45mm automatic carbine rifle
-- tfa_ins2_g3a3 has invalid type: german 7.62x51mm automatic assault rifle
-- tfa_ins2_galil has invalid type: israeli 5.56x45mm automatic assault rifle
-- tfa_ins2_glock17 has invalid type: austrian 9x19mm parabellum semi automatic pistol
-- tfa_ins2_gurkha has invalid type: weapon
-- tfa_ins2_kabar has invalid type: weapon
-- tfa_ins2_m1014 has invalid type: italian 12 gauge semi-auto shotgun
-- tfa_ins2_m1911 has invalid type: american .45 acp semi automatic pistol
-- tfa_ins2_m40a1 has invalid type: american 7.62x51mm bolt-action sniper rifle
-- tfa_ins2_m4a1 has invalid type: american 5.56x45mm automatic carbine rifle
-- tfa_ins2_m590 has invalid type: american 12 gauge pump-action shotgun
-- tfa_ins2_m67 has invalid type: american fragmentation hand grenade
-- tfa_ins2_makm has invalid type: russian 7.62x39mm automatic assault rifle
-- tfa_ins2_mosin has invalid type: russian 7.62x54mmr bolt-action sniper rifle
-- tfa_ins2_mp5 has invalid type: german 9x19mm automatic sub machine gun
-- tfa_ins2_p90 has invalid type: belgian 5.7x28mm automatic personal defence weapon
-- tfa_ins2_pkp has invalid type: russian 7.62x54mm automatic light machine gun
-- tfa_ins2_pm has invalid type: russian 9×18mm semi automatic pistol
-- tfa_ins2_ppsh has invalid type: russian 7.62x25mm automatic sub machine gun
-- tfa_ins2_rpk has invalid type: russian 7.62x39mm automatic light machine gun
-- tfa_ins2_scarl has invalid type: belgian 5.56x45mm automatic assault rifle
-- tfa_ins2_svd has invalid type: russian 7.62x54mmr semi automatic sniper rifle
-- tfa_ins2_svt40 has invalid type: russian 7.62x54mmr semi automatic rifle
-- tfa_ins2_tt33 has invalid type: russian 7.62x25mm semi automatic pistol
-- tfa_ins2_uzi has invalid type: israeli 9x19mm automatic sub machine gun
-- tfa_ins2_volk has invalid type: energy assault rifle
-- tfa_l4d2_pipewrench has invalid type: weapon
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
table.insert(revolvers, 'tfa_bms_357')
table.insert(revolvers, 'tfa_cso_anaconda')
table.insert(revolvers, 'tfa_cso_desperado')
table.insert(revolvers, 'tfa_cso_sapientia')
table.insert(revolvers, 'tfa_cso_skull1')
table.insert(revolvers, 'tfa_cso_skull2')
table.insert(revolvers, 'tfa_ins2_thanez_cobra')
table.insert(revolvers, 'tfa_l4d2_rhino')
table.insert(revolvers, 'tfa_mwr_44mag')
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

	for i, classname in ipairs(revolvers) do
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
