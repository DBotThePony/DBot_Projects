
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
        return if amount <= 0
        hp, mhp = @Health(), @GetMaxHealth()
        @SetTFIsOverhealed(hp + amount > mhp)
        @SetHealth(hp + amount)

entMeta[k] = v for k, v in pairs EntityClass

hook.Add 'Think', 'DTF2.OverhealThink', ->
    hitUpdate = false
    cTime = CurTime()
    decaySP, decayST = HEALTH_DECAY_SPEED\GetFloat(), HEALTH_DECAY_STEP\GetInt()
    for self in *TRACKED_ENTITIES
        return REBUILD_TRACKED_ENTS() if not @IsValid()
        hp, mhp = @Health(), @GetMaxHealth()
        if hp > mhp
            if @DTF2_Overheal_NextHealthDecay < cTime
                @DTF2_Overheal_NextHealthDecay = cTime + decaySP
                @SetHealth(math.max(hp - decayST, mhp))
        else
            @SetTFIsOverhealed(false)
            hitUpdate = true
        
    REBUILD_TRACKED_ENTS() if hitUpdate
