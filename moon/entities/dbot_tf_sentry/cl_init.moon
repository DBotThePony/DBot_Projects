
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

ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @SetAimPitch(0)
    @SetAimYaw(0)

ENT.Draw = =>
    @SetPoseParameter('aim_pitch', @GetAimPitch())
    @SetPoseParameter('aim_yaw', @GetAimYaw())
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
