
--
-- Copyright (C) 2017-2019 DBot

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


AddCSLuaFile()

ENT.PrintName = 'Cow Mangler Rocket Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_rocket_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.BlowEffect1 = 'dtf2_mangler_explosion'
ENT.BlowEffect2 = 'dtf2_mangler_explosion_charged'
ENT.BlowSound1 = 'DTF2_Weapon_CowMangler.Explode'
ENT.BlowSound2 = 'DTF2_Weapon_CowMangler.ExplodeCharged'

ENT.BurnTime = 6

ENT.Draw = =>
	return if @particleSetup
	@particleSetup = true
	CreateParticleSystem(@, 'drg_cow_rockettrail_normal', PATTACH_ABSORIGIN_FOLLOW) if not @GetIsMiniCritical()
	CreateParticleSystem(@, 'drg_cow_rockettrail_charged', PATTACH_ABSORIGIN_FOLLOW) if @GetIsMiniCritical()

return if CLIENT
ENT.OnHit = (ent) =>
	@SetBlowSound(@GetIsMiniCritical() and @BlowSound2 or @BlowSound1)
	@SetBlowEffect(@GetIsMiniCritical() and @BlowEffect2 or @BlowEffect1)

ENT.OnHitAfter = (ent, dmg) =>
	return if not @dtf2_GetIsMiniCritical
	with ent\TF2Burn(@BurnTime)
		\SetAttacker(dmg\GetAttacker())
		\SetInflictor(dmg\GetInflictor())
