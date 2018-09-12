
--
-- Copyright (C) 2017-2018 DBot

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
