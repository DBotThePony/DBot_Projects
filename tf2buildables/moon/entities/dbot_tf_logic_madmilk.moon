

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


AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'MadMilk Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER

entMeta = FindMetaTable('Entity')

if SERVER
	entMeta.TF2MadMilk = (duration = 0) =>
		if IsValid(@__dtf2_madmilk_logic)
			@__dtf2_madmilk_logic\UpdateDuration(duration)
			return @__dtf2_madmilk_logic
		@__dtf2_madmilk_logic = ents.Create('dbot_tf_logic_madmilk')
		@__dtf2_madmilk_logic\SetPos(@GetPos())
		@__dtf2_madmilk_logic\Spawn()
		@__dtf2_madmilk_logic\Activate()
		@__dtf2_madmilk_logic\SetParent(@)
		@__dtf2_madmilk_logic\SetOwner(@)
		@__dtf2_madmilk_logic\UpdateDuration(duration)
		@SetNWEntity('DTF2.MadMilkLogic', @__dtf2_madmilk_logic)
		return @__dtf2_madmilk_logic
	
	hook.Add 'PlayerDeath', 'DTF2.MadMilkLogic', => @__dtf2_madmilk_logic\Remove() if IsValid(@__dtf2_madmilk_logic)
	hook.Add 'OnNPCKilled', 'DTF2.MadMilkLogic', => @__dtf2_madmilk_logic\Remove() if IsValid(@__dtf2_madmilk_logic)
	hook.Add 'EntityTakeDamage', 'DTF2.MadMilkLogic', (ent, dmg) ->
		milk = ent.__dtf2_madmilk_logic
		return if not IsValid(milk)
		attacker = dmg\GetAttacker()
		return if not IsValid(attacker) or not attacker\IsPlayer()
		with attacker
			hp = \Health()
			mhp = \GetMaxHealth()
			\SetHealth(math.Clamp(hp + math.max(0, dmg\GetDamage() * milk\GetHealthPercent()), 0, mhp)) if hp < mhp
			if IsValid(milk\GetAttacker()) and milk\GetAttacker() ~= attacker
				with milk\GetAttacker()
					hp = \Health()
					mhp = \GetMaxHealth()
					\SetHealth(math.Clamp(hp + math.max(0, dmg\GetDamage() * milk\GetOwnerHealthPercent()), 0, mhp)) if hp < mhp

entMeta.IsMadMilked = => IsValid(@GetNWEntity('DTF2.MadMilkLogic'))

ENT.SetupDataTables = =>
	@NetworkVar('Entity', 0, 'Attacker')
	@NetworkVar('Float', 0, 'HealthPercent')
	@NetworkVar('Float', 1, 'OwnerHealthPercent')

ENT.Initialize = =>
	@SetNoDraw(true)
	@SetNotSolid(true)
	@SetHealthPercent(0.6)
	@SetOwnerHealthPercent(0.2)
	return if CLIENT
	@milkStart = CurTime()
	@duration = 10
	@milkEnd = @milkStart + 10
	@SetMoveType(MOVETYPE_NONE)

ENT.UpdateDuration = (newtime = 10) =>
	return if @milkEnd - CurTime() > newtime
	@duration = newtime
	@milkEnd = CurTime() + newtime

ENT.Think = =>
	return false if CLIENT
	return @Remove() if @milkEnd < CurTime()

ENT.OnRemove = => @particles\StopEmission() if @particles and @particles\IsValid()
ENT.Draw = =>
	return if @particles
	return if not IsValid(@GetParent())
	@particles = CreateParticleSystem(@GetParent(), 'peejar_drips_milk', PATTACH_ABSORIGIN_FOLLOW)