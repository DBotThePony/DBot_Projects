
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
    @idleSound = CreateSound(@, 'weapons/dispenser_idle.wav')
    @idleSound\ChangeVolume(0.75)
    @idleSound\SetSoundLevel(75)
    @idleSound\Play()

ENT.OnRemove = =>
    @idleSound\Stop() if @idleSound
ENT.Think = =>
    @BaseClass.Think(@)

ENT.Draw = =>
    screenMat = '' if @GetTeamType()
    screenMat = '' if not @GetTeamType()
    @BaseClass.Draw(@)
