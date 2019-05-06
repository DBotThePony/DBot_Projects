
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


util.AddNetworkString('DTF2.TrackOverhealEffect')

entMeta = FindMetaTable('Entity')

TRACKED_ENTITIES = {}
REBUILD_TRACKED_ENTS = -> TRACKED_ENTITIES = [ent for ent in *TRACKED_ENTITIES when ent\IsValid() and ent\Health() > ent\GetMaxHealth()]
hook.Add 'EntityRemoved', 'DTF2.OverhealRebuild', -> timer.Create 'DTF2.OverhealRebuild', 0, 1, REBUILD_TRACKED_ENTS

HEALTH_DECAY_SPEED = CreateConVar('tf_dbg_overheal_decay', '0.25', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Overheal Decay speed')
HEALTH_DECAY_STEP = CreateConVar('tf_dbg_overheal_step', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Overheal Decay step')

SwitchStatus = (val = false) =>
	prev = @GetNWBool('DTF2.AffectOverlealing')
	return if prev == val
	@SetNWBool('DTF2.AffectOverlealing', val)
	net.Start('DTF2.TrackOverhealEffect')
	net.WriteEntity(@)
	net.WriteBool(val)
	net.Broadcast()
	if val
		@DTF2_Overheal_NextHealthDecay = CurTime() + HEALTH_DECAY_SPEED\GetFloat()
		for ent in *TRACKED_ENTITIES
			return if ent == @
		table.insert(TRACKED_ENTITIES, @)
	else
		@DTF2_Overheal_NextHealthDecay = nil
		for i = 1, #TRACKED_ENTITIES
			if TRACKED_ENTITIES[i] == @
				table.remove(TRACKED_ENTITIES, i)
				return

EntityClass =
	SetTFIsOverhealed: SwitchStatus
	SetTFAffectAsOverheal: SwitchStatus
	SetTFAffectOverheal: SwitchStatus
	SetTFOverheal: SwitchStatus
	SetTFAffectedByOverheal: SwitchStatus
	AddTFOverheal: (amount = 0) =>
		@dtf2_lastOverhealCall = CurTime() + 0.2
		return if amount <= 0
		hp, mhp = @Health(), @GetMaxHealth()
		@SetTFIsOverhealed(hp + amount > mhp)
		@SetHealth(hp + amount)
	SimulateTFOverheal: (amount = 0, maxOverheal = 1.5, simulate = false) =>
		@dtf2_lastOverhealCall = CurTime() + 0.2
		return 0 if amount <= 0
		hp, mhp = @Health(), @GetMaxHealth()
		return 0 if hp >= mhp * maxOverheal
		newHP = math.min(hp + amount, mhp * maxOverheal)
		amount = newHP - hp
		if not simulate
			@SetTFIsOverhealed(newHP > mhp)
			@SetHealth(newHP)
		return amount

entMeta[k] = v for k, v in pairs EntityClass

hook.Add 'Think', 'DTF2.OverhealThink', ->
	hitUpdate = false
	cTime = CurTime()
	decaySP, decayST = HEALTH_DECAY_SPEED\GetFloat(), HEALTH_DECAY_STEP\GetInt()
	for self in *TRACKED_ENTITIES
		return REBUILD_TRACKED_ENTS() if not @IsValid()
		hp, mhp = @Health(), @GetMaxHealth()
		if hp > mhp
			if @DTF2_Overheal_NextHealthDecay < cTime and (not @dtf2_lastOverhealCall or @dtf2_lastOverhealCall < cTime)
				@DTF2_Overheal_NextHealthDecay = cTime + decaySP
				@SetHealth(math.max(hp - decayST, mhp))
		else
			@SetTFIsOverhealed(false)
			hitUpdate = true

	REBUILD_TRACKED_ENTS() if hitUpdate
