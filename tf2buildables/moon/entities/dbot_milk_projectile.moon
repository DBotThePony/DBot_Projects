
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

ENT.PrintName = 'Milk Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.BallModel = 'models/weapons/c_models/c_madmilk/c_madmilk.mdl'

ENT.SetupDataTables = =>
	@NetworkVar('Bool', 0, 'IsCritical') -- does not affect anything

if SERVER
	AccessorFunc(ENT, 'm_Attacker', 'Attacker')
	AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
	AccessorFunc(ENT, 'm_npcs', 'AffectNPCs')
	AccessorFunc(ENT, 'm_players', 'AffectPlayers')
	AccessorFunc(ENT, 'm_bots', 'AffectNextBots')
	AccessorFunc(ENT, 'm_blowRadius', 'BlowRadius')
	AccessorFunc(ENT, 'm_milktime', 'MilkTime')

ENT.RemoveTimer = 10

ENT.Initialize = =>
	@SetModel(@BallModel)
	if CLIENT
		@SetOwner(@)
		return
	@SetAffectNPCs(true)
	@SetAffectPlayers(true)
	@SetAffectNextBots(false)
	@SetBlowRadius(256)
	@SetMilkTime(10)
	@removeAt = CurTime() + @RemoveTimer
	@PhysicsInitSphere(12)
	phys = @GetPhysicsObject()
	@phys = phys
	with phys
		\EnableMotion(true)
		\EnableDrag(false)
		\SetMass(5)
		\Wake()

ENT.Draw = =>
	@DrawModel()
	if not @particles
		@particles = CreateParticleSystem(@, 'peejar_trail_red', PATTACH_ABSORIGIN_FOLLOW, 0)

ENT.SetDirection = (dir = Vector(0, 0, 0)) =>
	newVel = Vector(dir)
	newVel.z += 0.08
	@phys\SetVelocity(newVel * 1000)
	@SetAngles(dir\Angle())

ENT.Think = =>
	return false if CLIENT
	@Remove() if @removeAt < CurTime()

ENT.PhysicsCollide = (data = {}, colldier) =>
	{:HitPos, :HitNormal, :HitEntity} = data
	return false if HitEntity == @GetAttacker()
	for ent in *ents.FindInSphere(HitPos, @GetBlowRadius())
		if ent ~= @GetAttacker()
			tr = util.TraceLine({
				start: HitPos - HitNormal
				endpos: ent\WorldSpaceCenter()
				filter: @
			})

			if tr.Entity == ent
				with ent\TF2MadMilk(@GetMilkTime())
					\SetAttacker(@GetAttacker())

	@EmitSound('DTF2_Jar.Explode')
	ParticleEffect('peejar_impact_milk', HitPos - HitNormal, Angle(0, 0, 0))
	@Remove()


ENT.IsTF2Milk = true

if SERVER
	hook.Add 'EntityTakeDamage', 'DTF2.MilkProjectile', (ent, dmg) ->
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker)
		return if not attacker.IsTF2Milk
		return if dmg\GetDamageType() ~= DMG_CRUSH
		dmg\SetDamage(0)
		dmg\SetMaxDamage(0)
