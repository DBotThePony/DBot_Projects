
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

include 'shared.lua'
AddCSLuaFile 'shared.lua'

util.AddNetworkString('DTF2.SendWeaponAnim')
util.AddNetworkString('DTF2.SendWeaponSequence')

SWEP.SendWeaponAnim2 = (act = ACT_INVALID) =>
    return if not IsValid(@GetOwner()) or not @GetOwner()\IsPlayer()
    --hands = @GetOwner()\GetHands()
    --seqId = hands\SelectWeightedSequence(act)
    --hands\ResetSequence(seqId) if seqId
    net.Start('DTF2.SendWeaponAnim')
    net.WriteUInt(act, 16)
    net.Send(@GetOwner())

SWEP.SendWeaponSequence = (seq = 0) =>
    return if not IsValid(@GetOwner()) or not @GetOwner()\IsPlayer()
    hands = @GetOwner()\GetViewModel()
    return if not IsValid(hands)
    seq = hands\LookupSequence(seq) if type(seq) ~= 'number'
    hands\SendViewModelMatchingSequence(seq)
    net.Start('DTF2.SendWeaponSequence')
    net.WriteUInt(seq, 16)
    net.Send(@GetOwner())

SWEP.EmitSoundServerside = (...) =>
    SuppressHostEvents(NULL) if @suppressing
    @EmitSound(...)
    SuppressHostEvents(@GetOwner()) if @suppressing

SWEP.CheckCritical = =>
    return if @GetNextCrit()
    return if @lastCritsTrigger > CurTime()
    return if @lastCritsCheck > CurTime()
    @lastCritsCheck = CurTime() + @CritsCheckCooldown if @CritsCheckCooldown ~= 0
    chance = @CritChance + math.min(@CritExponent * @damageDealtForCrit, @CritExponentMax)
    if math.random(1, 100) < chance
        @TriggerCriticals()

SWEP.TriggerCriticals = =>
    return if @lastCritsTrigger > CurTime()
    @damageDealtForCrit = 0
    @lastCritsTrigger = CurTime() + @CritsCooldown
    @SetNextCrit(true)
    if not @SingleCrit
        @lastCritsTrigger = CurTime() + @CritDuration + @CritsCooldown
        @SetCriticalsDuration(CurTime() + @CritDuration)
        timer.Create "DTF2.CriticalsTimer.#{@EntIndex()}", @CritDuration, 1, ->
            @SetNextCrit(false) if @IsValid()

return nil
