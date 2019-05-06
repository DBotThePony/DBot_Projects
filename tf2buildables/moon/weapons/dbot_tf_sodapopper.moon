
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

DEFINE_BASECLASS('dbot_tf_forceanature')

SWEP.Base = 'dbot_tf_forceanature'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Soda Popper'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_soda_popper/c_soda_popper.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true
SWEP.IsSodaPopper = true

SWEP.SodaPopperDuration = 10
SWEP.SodaDamageRequired = 350
SWEP.FireSoundsScript = 'Weapon_Soda_Popper.Single'
SWEP.FireCritSoundsScript = 'Weapon_Soda_Popper.SingleCrit'

SWEP.Primary = {
	'Ammo': 'Buckshot'
	'ClipSize': 2
	'DefaultClip': 2
	'Automatic': true
}

SWEP.SetupDataTables = =>
	@BaseClass.SetupDataTables(@)
	@NetworkVar('Int', 16, 'SodaDamageDealt')
	@NetworkVar('Bool', 16, 'SodaActive')

SWEP.IsSodaReady = => @GetSodaDamageDealt() >= @SodaDamageRequired

if SERVER
	hook.Add 'EntityTakeDamage', 'DTF2.SodaPopper', (ent, dmg) ->
		return unless ent\IsNPC() or ent\IsPlayer() or ent.Type == 'nextbot'
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker)
		return if not attacker\IsPlayer()
		wep = attacker\GetWeapon('dbot_tf_sodapopper')
		return if not IsValid(wep)
		wep\SetSodaDamageDealt(math.min(wep\GetSodaDamageDealt() + math.max(dmg\GetDamage(), 0), wep.SodaDamageRequired))

	SWEP.OnRemove = => @miniCritBuffer\Remove() if IsValid(@miniCritBuffer)

	SWEP.Think = =>
		@BaseClass.Think(@)
		if @GetSodaActive()
			@SetSodaDamageDealt(math.max(0, @SodaDamageRequired * (@sodaPopperEnd - CurTime()) / 10))

	SWEP.SecondaryAttack = =>
		return false if not @IsSodaReady()
		return false if @GetSodaActive()
		@SetSodaActive(true)
		ply = @GetOwner()
		@miniCritBuffer = ents.Create('dbot_tf_logic_minicrit')
		with @miniCritBuffer
			\SetPos(ply\GetPos())
			\Spawn()
			\Activate()
			\SetParent(ply)
			\SetOwner(ply)
			\SetEnableBuff(true)

		@sodaPopperEnd = CurTime() + @SodaPopperDuration
		timer.Create "DTF2.SodaPopper.#{@EntIndex()}", @SodaPopperDuration, 1, ->
			@miniCritBuffer\Remove() if IsValid(@) and IsValid(@miniCritBuffer)
			@SetSodaActive(false) if IsValid(@)

		return true
else
	SWEP.DrawHUD = =>
		DTF2.DrawCenteredBar(@GetSodaDamageDealt() / @SodaDamageRequired, 'Soda')
