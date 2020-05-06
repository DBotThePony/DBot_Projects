
--
-- Copyright (C) 2017-2019 DBotThePony

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


AddCSLuaFile 'cl_init.lua'
include 'shared.lua'

util.AddNetworkString('DTF2.DestroyRequest')

DEFINE_BASECLASS('dbot_tf_weapon_base')

net.Receive 'DTF2.DestroyRequest', (len = 0, ply = NULL) ->
	return if not IsValid(ply)
	slot = net.ReadUInt(8)
	ent = net.ReadEntity()
	return if not IsValid(ply)
	return if ent\GetClass() ~= 'dbot_tf_destrpda'
	ent\TriggerDestructionRequest(slot)

holster = (ply, wep) =>
	ply\SelectWeapon(wep)
	ply\SetActiveWeapon(ply\GetWeapon(wep))
	@Holster()

SWEP.SwitchToWrench = =>
	weapon_crowbar = false
	dbot_tf_wrench = false
	ply = @GetOwner()
	return false if not IsValid(ply) or not ply\IsPlayer()
	for _, wep in pairs ply\GetWeapons()
		switch wep\GetClass()
			when 'weapon_crowbar'
				weapon_crowbar = true
			when 'dbot_tf_wrench'
				dbot_tf_wrench = true
	if dbot_tf_wrench
		holster(@, ply, 'dbot_tf_wrench')
		return true
	elseif weapon_crowbar
		holster(@, ply, 'weapon_crowbar')
		return true
	return false
