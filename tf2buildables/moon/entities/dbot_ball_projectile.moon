
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


AddCSLuaFile()

ENT.PrintName = 'Ball Projective'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.BallModel = 'models/weapons/c_models/c_xms_festive_ornament.mdl'

ENT.SetupDataTables = =>
	@NetworkVar('Bool', 0, 'IsFlying')
	@NetworkVar('Bool', 1, 'IsCritical')

AccessorFunc(ENT, 'm_Attacker', 'Attacker')
AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_dmgtype', 'DamageType')
AccessorFunc(ENT, 'm_dmg', 'Damage')

ENT.DefaultDamage = 15
ENT.RemoveTimer = 15

ENT.AffectedWeapon = 'dbot_tf_wrapassasin'

ENT.Initialize = =>
	@SetModel(@BallModel)
	return if CLIENT
	@removeAt = CurTime() + @RemoveTimer
	@PhysicsInitSphere(6)
	@SetDamageType(DMG_SLASH)
	@SetDamage(@DefaultDamage)
	@SetAttacker(@)
	@SetInflictor(@)
	@SetIsFlying(true)
	@initialPosition = @GetPos()
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
		@particles = CreateParticleSystem(@, not @GetIsCritical() and 'stunballtrail_red' or 'stunballtrail_red_crit', PATTACH_ABSORIGIN_FOLLOW, 0)

ENT.SetDirection = (dir = Vector(0, 0, 0)) =>
	newVel = Vector(dir)
	newVel.z += 0.05
	@phys\SetVelocity(newVel * 4000)

ENT.Think = =>
	return false if CLIENT
	@Remove() if @removeAt < CurTime()

ENT.OnHit = (ent, data = {}) =>
	dmginfo = DamageInfo()
	dmginfo\SetDamageType(@GetDamageType())
	dmginfo\SetDamage(@GetDamage() * (@GetIsCritical() and 3 or ent\IsMarkedForDeath() and 1.3 or 1))
	dmginfo\SetAttacker(@GetAttacker())
	dmginfo\SetInflictor(@GetInflictor())
	ent\TakeDamageInfo(dmginfo)

	if @GetIsCritical()
		effData = EffectData()
		effData\SetOrigin(data.HitPos)
		util.Effect('dtf2_critical_hit', effData)
		@GetAttacker()\EmitSound('DTF2_TFPlayer.CritHit')
		ent\EmitSound('DTF2_TFPlayer.CritHit')
	elseif ent\IsMarkedForDeath()
		effData = EffectData()
		effData\SetOrigin(data.HitPos)
		util.Effect('dtf2_minicrit', effData)
		@GetAttacker()\EmitSound('DTF2_TFPlayer.CritHitMini')
		ent\EmitSound('DTF2_TFPlayer.CritHitMini')

	dist = @GetPos()\Distance(@initialPosition)
	if ent\IsNPC() or ent\IsPlayer()
		bleed = ent\TF2Bleed(math.Clamp(dist / 128, 1, 15))
		bleed\SetAttacker(@GetAttacker())
		bleed\SetInflictor(@GetInflictor())
		if dist < 1024
			ent\EmitSound('DTF2_BallBuster.OrnamentImpact')
			@GetAttacker()\EmitSound('DTF2_BallBuster.OrnamentImpact')
		else
			ent\EmitSound('DTF2_BallBuster.OrnamentImpactRange')
			@GetAttacker()\EmitSound('DTF2_BallBuster.OrnamentImpactRange')
	else
		ent\EmitSound('DTF2_BallBuster.OrnamentImpact')

	-- @SetIsFlying(false)
	@Remove()

ENT.PhysicsCollide = (data = {}, colldier) =>
	{:HitEntity} = data
	if not @GetIsFlying()
		return if not IsValid(HitEntity)
		return if not HitEntity\IsPlayer()
		wep = HitEntity\GetWeapon(@AffectedWeapon)
		return if not IsValid(wep)
		wep\SetBallReady(wep.BallRestoreTime)
		HitEntity\EmitSound('DTF2_Player.PickupWeapon')
	else
		return false if HitEntity == @GetAttacker()
		if IsValid(HitEntity)
			@OnHit(HitEntity, data)
		else
			-- @SetIsFlying(false)
			@EmitSound('DTF2_BallBuster.OrnamentImpact')
			@Remove()

ENT.IsTF2Ball = true

if SERVER
	hook.Add 'EntityTakeDamage', 'DTF2.BallProjective', (ent, dmg) ->
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker)
		return if not attacker.IsTF2Ball
		return if dmg\GetDamageType() ~= DMG_CRUSH
		dmg\SetDamage(0)
		dmg\SetMaxDamage(0)
