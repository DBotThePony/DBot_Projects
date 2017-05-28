
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

ENT.Initialize = =>
    @SetModel(@BuildModel1)
    @SetHP(@HealthLevel1)
    @SetMHP(@HealthLevel1)
    
    @buildSequence = @LookupSequence('build')
    @upgradeSequence = @LookupSequence('upgrade')
    @lastSeqModel = @BuildModel1
    @lastAnimTick = CurTime()

ENT.Think = =>
    if @GetIsBuilding()
        if @GetBuildSpeedup()
            @SetPlaybackRate(1)
        else
            @SetPlaybackRate(0.5)
    else
        @SetPlaybackRate(1)

ENT.Draw = =>
    ctime = CurTime()
    @FrameAdvance(ctime - @lastAnimTick)
    @lastAnimTick = ctime

    @DrawModel()
    