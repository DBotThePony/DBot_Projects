
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

util.AddNetworkString('DTF2.Event.StickyBombStick')

AddCSLuaFile 'cl_init.lua'
AddCSLuaFile 'shared.lua'
include 'shared.lua'

DEFINE_BASECLASS('dbot_tf_projectile')

ENT_CACHE = {}
ENT_CHECK = {}

ENT.Initialize = =>
	BaseClass.Initialize(@)
	@__activateAt = CurTime() + DTF2.GrabFloat(@ACTIVATE_TIMER)
	table.insert(ENT_CACHE, @)
	table.insert(ENT_CHECK, @)

ENT.OnHit = (entHit, normal, reportedPos) =>
	return false if IsValid(entHit)
	@SetMoveType(MOVETYPE_NONE)
	@__normal = normal
	@__reportedPos = reportedPos
	return true

ENT.SetDirection = (dir = Vector(0, 0, 0)) =>
	BaseClass.SetDirection(@, dir)
	@phys\AddAngleVelocity(VectorRand() * 400)

ENT.Destruct = =>
	eff = EffectData()
	eff\SetOrigin(@GetPos())
	eff\SetNormal(@__normal) if @__normal
	util.Effect('StunstickImpact', eff)
	spawnedEnts = for i = 1, math.random(DTF2.GrabInt(@MIN_GIBS), DTF2.GrabInt(@MAX_GIBS))
		with ents.Create('prop_physics')
			\SetModel(DTF2.TableRandom(@GIBS))
			\SetAngles(AngleRand())
			\SetPos(@GetPos() + VectorRand() * 4)
			\Spawn()
			\Activate()
			\SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	timer.Simple DTF2.GrabFloat(@GIBS_TTL), -> ent\Remove() for ent in *spawnedEnts when ent\IsValid()
	@Remove()

ENT.OnTakeDamage = (dmgInfo) =>
	return if bit.band(dmgInfo\GetDamageType(), DMG_BULLET) == 0
	return if dmgInfo\GetAttacker() == @GetAttacker() or dmgInfo\GetInflictor() == @GetAttacker()
	return if dmgInfo\GetAttacker() == @GetInflictor() or dmgInfo\GetInflictor() == @GetInflictor()
	@Destruct()

ENT.Explode = (force = false) =>
	return false if @GetIsExploded()
	return false if not force and @__activateAt and @__activateAt > CurTime()
	return true, BaseClass.Explode(@, NULL, @__normal, @__reportedPos)

ENT.Think = =>
	BaseClass.Think(@)
	if @__activateAt and @__activateAt <= CurTime()
		net.Start('DTF2.Event.StickyBombStick', true)
		net.WriteEntity(@)
		net.Broadcast()
		@__activateAt = nil

hook.Add 'PlayerDeath', 'DTF2.StickyBombs', =>
	ENT_CACHE = [ent for ent in *ENT_CACHE when ent\IsValid()]
	for ent in *ENT_CACHE
		ent\Destruct() if ent\GetAttacker() == @
	timer.Simple 0.2, -> @RefreshTFStickies() if @IsValid()

hook.Add 'Think', 'DTF2.StickyBombs', ->
	check = ENT_CHECK
	ENT_CHECK = {}
	for ent in *check
		if ent\IsValid()
			ply = ent\GetAttacker()
			if IsValid(ply) and ply\IsPlayer()
				mclass = ent\GetClass()
				dict = 'DTF2_Stickies_' .. mclass
				ply[dict] = ply[dict] or {}
				table.insert(ply[dict], ent)
				for ent3 in *ply[dict]
					if not ent3\IsValid()
						ply[dict] = [ent2 for ent2 in *ply[dict] when ent2\IsValid()]
						break
				stickiesCount = #ply[dict]
				if DTF2.GrabBool(ent.HANDLE_MAX_STICKIES) and ent.MAX_STICKIES < stickiesCount and ent.MAX_STICKIES >= 1
					while ent.MAX_STICKIES < stickiesCount
						pop = table.remove(ply[dict], 1)
						pop\Explode(true)
						stickiesCount -= 1
				ply\SetNWInt('DTF2.Stickies.' .. mclass, stickiesCount)

entMeta = FindMetaTable('Entity')

EntityClass = 
	RefreshTFStickies: (mclass = 'dbot_tf_stickybomb') =>
		dict = 'DTF2_Stickies_' .. mclass
		@[dict] = @[dict] or {}
		@[dict] = [ent2 for ent2 in *@[dict] when ent2\IsValid()]
		ent = @[dict][1]
		if ent
			stickiesCount = #@[dict]
			if DTF2.GrabBool(ent.HANDLE_MAX_STICKIES) and ent.MAX_STICKIES < stickiesCount and ent.MAX_STICKIES >= 1
				while ent.MAX_STICKIES < stickiesCount
					pop = table.remove(@[dict], 1)
					pop\Explode(true)
					stickiesCount -= 1
			@SetNWInt('DTF2.Stickies.' .. mclass, stickiesCount)
		else
			@SetNWInt('DTF2.Stickies.' .. mclass, 0)
	GetTFStickies: (mclass = 'dbot_tf_stickybomb', copy = true) =>
		dict = 'DTF2_Stickies_' .. mclass
		@[dict] = @[dict] or {}
		for ent in *@[dict]
			if not ent\IsValid()
				@RefreshTFStickies()
				break
		return [ent for ent in *@[dict]] if copy
		return @[dict] if not copy
	GetTFSticky: (...) => @GetTFStickies(...)
	GetTFStickyBombs: (...) => @GetTFStickies(...)
	GetTFStickiesBombs: (...) => @GetTFStickies(...)

entMeta[k] = v for k, v in pairs EntityClass