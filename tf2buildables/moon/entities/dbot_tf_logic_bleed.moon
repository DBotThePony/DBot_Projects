

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

ENT.Type = 'anim'
ENT.PrintName = 'Bleeding Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER

entMeta = FindMetaTable('Entity')

if SERVER
	entMeta.TF2Bleed = (duration = 0) =>
		if IsValid(@__dtf2_bleed_logic)
			@__dtf2_bleed_logic\UpdateDuration(duration)
			return @__dtf2_bleed_logic
		@__dtf2_bleed_logic = ents.Create('dbot_tf_logic_bleed')
		@__dtf2_bleed_logic\SetPos(@GetPos())
		@__dtf2_bleed_logic\Spawn()
		@__dtf2_bleed_logic\Activate()
		@__dtf2_bleed_logic\SetParent(@)
		@__dtf2_bleed_logic\SetOwner(@)
		@__dtf2_bleed_logic\UpdateDuration(duration)
		@SetNWEntity('DTF2.BleedLogic', @__dtf2_bleed_logic)
		return @__dtf2_bleed_logic

	hook.Add 'PlayerDeath', 'DTF2.BleedLogic', => @__dtf2_bleed_logic\Remove() if IsValid(@__dtf2_bleed_logic)
	hook.Add 'OnNPCKilled', 'DTF2.BleedLogic', => @__dtf2_bleed_logic\Remove() if IsValid(@__dtf2_bleed_logic)

entMeta.IsTF2Bleeding = => IsValid(@GetNWEntity('DTF2.BleedLogic'))

with ENT
	.SetupDataTables = =>
		@NetworkVar('Entity', 0, 'Attacker')
		@NetworkVar('Entity', 1, 'Inflictor')
		@NetworkVar('Float', 0, 'HitDelay')
		@NetworkVar('Float', 1, 'Damage')

	.Initialize = =>
		@SetNoDraw(true)
		@SetNotSolid(true)
		@SetHitDelay(.5)
		@SetDamage(4)
		@nextBloodParticle = CurTime()
		return if CLIENT
		@bleedStart = CurTime()
		@duration = 4
		@bleedEnd = @bleedStart + 4
		@SetMoveType(MOVETYPE_NONE)

	.UpdateDuration = (newtime = 0) =>
		return if @bleedEnd - CurTime() > newtime
		@duration = newtime
		@bleedEnd = CurTime() + newtime

	.Think = =>
		return false if CLIENT
		return @Remove() if @bleedEnd < CurTime()
		owner = @GetOwner()
		return @Remove() if not IsValid(@GetOwner())
		dmginfo = DamageInfo()
		dmginfo\SetAttacker(IsValid(@GetAttacker()) and @GetAttacker() or @)
		dmginfo\SetInflictor(IsValid(@GetInflictor()) and @GetInflictor() or @)
		dmginfo\SetDamageType(DMG_SLASH)
		dmginfo\SetDamage(@GetDamage() * (owner\IsMarkedForDeath() and 1.3 or 1))
		owner\TakeDamageInfo(dmginfo)

		if owner\IsMarkedForDeath()
			mins, maxs = owner\GetRotatedAABB(owner\OBBMins(), owner\OBBMaxs())
			pos = owner\GetPos()
			newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
			pos.z = newZ

			effData = EffectData()
			effData\SetOrigin(pos)
			util.Effect('dtf2_minicrit', effData)
			@GetAttacker()\EmitSound('DTF2_TFPlayer.CritHitMini')
			owner\EmitSound('DTF2_TFPlayer.CritHitMini')

		@NextThink(CurTime() + @GetHitDelay())
		return true

	.Draw = =>
		return if not IsValid(@GetParent())
		return if @nextBloodParticle > CurTime()
		@nextBloodParticle = CurTime() + @GetHitDelay()
		ent = @GetParent()
		mins, maxs = ent\GetRotatedAABB(ent\OBBMins(), ent\OBBMaxs())

		for i = 1, 4
			randX = math.random(mins.x, maxs.x)
			randY = math.random(mins.y, maxs.y)
			randZ = math.random(mins.z, maxs.z)
			CreateParticleSystem(ent, 'blood_impact_red_01', PATTACH_ABSORIGIN, 0, Vector(randX, randY, randZ))
