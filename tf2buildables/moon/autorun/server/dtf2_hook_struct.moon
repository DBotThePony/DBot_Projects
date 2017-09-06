
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

export DTF2
DTF2 = DTF2 or {}
DTF2.HookStruct = {}
self = DTF2.HookStruct

@Damage = (wepClasss = '', affectNPC = true, affectPlayers = true, affectBuildables = false, callback) ->
	return if not callback
	return (dmg) =>
		return if not affectPlayers and @IsPlayer()
		return if not affectNPC and (@IsNPC() or ent.Type == 'nextbot')
		return if not affectBuildables and @IsTF2Building
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker) or not attacker\IsPlayer()
		wep = attacker\GetWeapon(wepClasss)
		return if not IsValid(wep)
		callback(attacker, wep, @, dmg)

@ExplicitDamage = (wepClasss = '', affectNPC = true, affectPlayers = true, affectBuildables = false, callback) ->
	return if not callback
	return (dmg) =>
		return if not affectPlayers and @IsPlayer()
		return if not affectNPC and (@IsNPC() or ent.Type == 'nextbot')
		return if not affectBuildables and @IsTF2Building
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker) or not attacker\IsPlayer()
		wep = attacker\GetActiveWeapon()
		return if not IsValid(wep) or wep\GetClass() ~= wepClasss
		callback(attacker, wep, @, dmg)

@AllDamage = (wepClasss = '', affectNPC = true, affectPlayers = true, affectBuildables = false, callback) ->
	return if not callback
	return (dmg) =>
		return if not affectPlayers and @IsPlayer()
		return if not affectNPC and (@IsNPC() or ent.Type == 'nextbot')
		return if not affectBuildables and @IsTF2Building
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker) or not attacker.GetWeapon
		wep = attacker\GetWeapon(wepClasss)
		return if not IsValid(wep)
		callback(attacker, wep, @, dmg)

@AllExplicitDamage = (wepClasss = '', affectNPC = true, affectPlayers = true, affectBuildables = false, callback) ->
	return if not callback
	return (dmg) =>
		return if not affectPlayers and @IsPlayer()
		return if not affectNPC and (@IsNPC() or ent.Type == 'nextbot')
		return if not affectBuildables and @IsTF2Building
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker) or not attacker.GetActiveWeapon
		wep = attacker\GetActiveWeapon()
		return if not IsValid(wep) or wep\GetClass() ~= wepClasss
		callback(attacker, wep, @, dmg)
