
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

include 'shared.lua'
AddCSLuaFile 'cl_init.lua'

import hook from _G

ENT.Initialize = =>
	@SetModel('models/Combine_Helicopter/helicopter_bomb01.mdl')
	@SetModelScale(0.4)
	
	@PhysicsInitSphere(32)
	@SetSolid(SOLID_VPHYSICS)
	@SetMoveType(SOLID_VPHYSICS)
	@SetBallColor(Vector(math.random(0, 255) / 255, math.random(0, 255) / 255, math.random(0, 255) / 255))
	
	timer.Simple 0, ->
		phys = @GetPhysicsObject()
		if IsValid(phys)
			@phys = phys
			phys\SetMass(256)
			phys\Sleep()

ENT.PhysicsCollide = (data) =>
	if not @phys return
	vel = @phys\GetVelocity()
	mult = data.HitNormal
	summ = vel.x + vel.y + vel.z
	@phys\AddVelocity(-mult * summ * 5 + vel * 2)

big = 2 ^ 31 - 1

hook.Add 'EntityTakeDamage', 'DBot.SCP018', (ent = NULL, dmg) ->
	attacker = dmg\GetAttacker()
	return if not attacker\IsValid()
	return if attacker\GetClass() ~= 'dbot_scp018'
	dmg\SetDamageType(DMG_ACID)
	dmg\SetDamage(big)
