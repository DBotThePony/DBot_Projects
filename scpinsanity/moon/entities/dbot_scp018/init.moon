
--
-- Copyright (C) 2017 DBot

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
