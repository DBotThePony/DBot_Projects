
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

MUZZLE_BONE_ID_1 = 4
MUZZLE_ANIM_TIME = 0.3

ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @SetAimPitch(0)
    @SetAimYaw(0)
    @lastPitch = 0
    @lastYaw = 0
    @fireAnim = 0
    @isEmpty = false

ENT.Draw = =>
    deltaFireAnim = @fireAnim - CurTime()
    pitchAdd = 0
    if deltaFireAnim > 0
        deltaFireAnimNormal = math.abs(0.3 - deltaFireAnim / MUZZLE_ANIM_TIME)
        pitchAdd += deltaFireAnimNormal * 5 if not @isEmpty
        @ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector(0, 0, -deltaFireAnimNormal * 4))
    else
        @ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector())
    
    diffPitch = math.AngleDifference(@lastPitch, @GetAimPitch())
    diffYaw = math.AngleDifference(@lastYaw, @GetAimYaw())
    @lastPitch = Lerp(FrameTime() * 10, @lastPitch, @lastPitch - diffPitch)
    @lastYaw = Lerp(FrameTime() * 10, @lastYaw, @lastYaw - diffYaw)
    @SetPoseParameter('aim_pitch', @lastPitch + pitchAdd)
    @SetPoseParameter('aim_yaw', @lastYaw)
    @InvalidateBoneCache()
    @BaseClass.Draw(@)

net.Receive 'DTF2.SentryWing', ->
    sentry = net.ReadEntity()
    return if not IsValid
    target = net.ReadEntity()
    if target ~= LocalPlayer()
        sentry\EmitSound('weapons/sentry_spot.wav', SNDLVL_85dB)
    else
        sentry\EmitSound('weapons/sentry_spot_client.wav', SNDLVL_105dB)

net.Receive 'DTF2.SentryFire', ->
    sentry = net.ReadEntity()
    return if not IsValid
    isEmpty = not net.ReadBool()
    sentry.isEmpty = isEmpty
    sentry.fireAnim = CurTime() + MUZZLE_ANIM_TIME