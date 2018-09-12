
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


TRACKED_ENTITIES = {}
REBUILD_TRACKED_ENTS = -> TRACKED_ENTITIES = [ent for ent in *TRACKED_ENTITIES when ent\IsValid() and ent\Health() > ent\GetMaxHealth()]
hook.Add 'EntityRemoved', 'DTF2.OverhealRebuild', -> timer.Create 'DTF2.OverhealRebuild', 0, 1, REBUILD_TRACKED_ENTS

net.Receive 'DTF2.TrackOverhealEffect', ->
	self = net.ReadEntity()
	status = net.ReadBool()
	return if not IsValid(@)
	if status
		for ent in *TRACKED_ENTITIES
			return if ent == @
		table.insert(TRACKED_ENTITIES, @)
	else
		for i = 1, #TRACKED_ENTITIES
			if TRACKED_ENTITIES[i] == @
				table.remove(TRACKED_ENTITIES, i)
				return
		if IsValid(@DTF2_OverhealParticleSystem)
			@DTF2_OverhealParticleSystem\StopEmission()

hook.Add 'Think', 'DTF2.OverhealThink', ->
	hitUpdate = false
	cTime = CurTime()
	for self in *TRACKED_ENTITIES
		return REBUILD_TRACKED_ENTS() if not @IsValid()
		if @Health() > @GetMaxHealth()
			if not IsValid(@DTF2_OverhealParticleSystem)
				@DTF2_OverhealParticleSystem = CreateParticleSystem(@, 'overhealedplayer_red_pluses', PATTACH_ABSORIGIN_FOLLOW, 0)
		else
			if IsValid(@DTF2_OverhealParticleSystem)
				@DTF2_OverhealParticleSystem\StopEmission()
				@DTF2_OverhealParticleSystem = nil
			hitUpdate = true
		
	REBUILD_TRACKED_ENTS() if hitUpdate
