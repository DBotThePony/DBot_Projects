
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

ENT.Base = 'dbot_tf_build_base'
ENT.Type = 'nextbot'
ENT.PrintName = 'Teleporter'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'

ENT.MIN_BREAD = 4
ENT.MAX_BREAD = 7

ENT.MIN_BREAD_TTL = 15
ENT.MAX_BREAD_TTL = 20

ENT.BREAD_MODELS = {
    'models/weapons/c_models/c_bread/c_bread_baguette.mdl'
    'models/weapons/c_models/c_bread/c_bread_burnt.mdl'
    'models/weapons/c_models/c_bread/c_bread_cinnamon.mdl'
    'models/weapons/c_models/c_bread/c_bread_cornbread.mdl'
    'models/weapons/c_models/c_bread/c_bread_crumpet.mdl'
    'models/weapons/c_models/c_bread/c_bread_plainloaf.mdl'
    'models/weapons/c_models/c_bread/c_bread_pretzel.mdl'
    'models/weapons/c_models/c_bread/c_bread_ration.mdl'
    'models/weapons/c_models/c_bread/c_bread_russianblack.mdl'
}

ENT.BuildModel1 = 'models/buildables/teleporter.mdl'
ENT.IdleModel1 = 'models/buildables/teleporter_light.mdl'
ENT.BuildModel2 = 'models/buildables/teleporter.mdl'
ENT.IdleModel2 = 'models/buildables/teleporter_light.mdl'
ENT.BuildModel3 = 'models/buildables/teleporter.mdl'
ENT.IdleModel3 = 'models/buildables/teleporter_light.mdl'

ENT.READY_SOUND = 'DTF2_Building_Teleporter.Ready'
ENT.SEND_SOUND = 'DTF2_Building_Teleporter.Send'
ENT.RECEIVE_SOUND = 'DTF2_Building_Teleporter.Receive'
ENT.ExplosionSound = 'DTF2_Building_Teleporter.Explode'

ENT.ReloadTime1 = 10
ENT.ReloadTime2 = 3
ENT.ReloadTime3 = 1

ENT.BuildTime = 20

ENT.BuildingMins = Vector(-20, -20, 0)
ENT.BuildingMaxs = Vector(20, 20, 18)

ENT.TELE_WAIT = 1.25
ENT.TELE_DELAY = 0.5

ENT.IsLoaded = => @GetResetAt() < CurTime()
ENT.IsAvaliable = => @BaseClass.IsAvaliable(@) and @GetResetAt() < CurTime()
ENT.IsExit = => @GetIsExit()
ENT.IsEntrance = => not @GetIsExit()
ENT.GetBreadPoint = => @GetPos() + Vector(0, 0, 70)
ENT.GetStandPos = => @GetPos() + Vector(0, 0, 23)
ENT.HasExit = => IsValid(@GetExit())
ENT.HasEntrance = => IsValid(@GetEntrance())
ENT.ValidEntrance = => @IsEntrance() and @HasExit()
ENT.ValidExit = => @IsExit() and @HasEntrance()
ENT.IsValidTeleporter = => @ValidEntrance() or @ValidExit()
ENT.GetConnectedTeleporter = => @IsExit() and @GetEntrance() or @GetExit()

ENT.GetTeleAngles = =>
    ang = @GetAngles()
    ang.p = 0
    ang.r = 0
    return ang

ENT.GetChargedEffect = (level = @GetLevel()) =>
    if @GetTeamType()
        switch level
            when 1
                'teleporter_blue_charged_level1'
            when 2
                'teleporter_blue_charged_level2'
            when 3
                'teleporter_blue_charged_level3'
    else
        switch level
            when 1
                'teleporter_red_charged_level1'
            when 2
                'teleporter_red_charged_level2'
            when 3
                'teleporter_red_charged_level3'

ENT.GetAvaliableEffect = (level = @GetLevel()) =>
    if @IsEntrance()
        if @GetTeamType()
            switch level
                when 1
                    'teleporter_blue_entrance_level1'
                when 2
                    'teleporter_blue_entrance_level2'
                when 3
                    'teleporter_blue_entrance_level3'
        else
            switch level
                when 1
                    'teleporter_red_entrance_level1'
                when 2
                    'teleporter_red_entrance_level2'
                when 3
                    'teleporter_red_entrance_level3'
    else
        if @GetTeamType()
            switch level
                when 1
                    'teleporter_blue_exit_level1'
                when 2
                    'teleporter_blue_exit_level2'
                when 3
                    'teleporter_blue_exit_level3'
        else
            switch level
                when 1
                    'teleporter_red_exit_level1'
                when 2
                    'teleporter_red_exit_level2'
                when 3
                    'teleporter_red_exit_level3'

ENT.GetReloadTime = (level = @GetLevel()) =>
    switch level
        when 1
            @ReloadTime1
        when 2
            @ReloadTime2
        when 3
            @ReloadTime3

ENT.GetSpinSound = (level = @GetLevel()) =>
    switch level
        when 1
            'DTF2_Building_Teleporter.SpinLevel1'
        when 2
            'DTF2_Building_Teleporter.SpinLevel2'
        when 3
            'DTF2_Building_Teleporter.SpinLevel3'

ENT.SetupDataTables = =>
    @BaseClass.SetupDataTables(@)
    @NetworkVar('Bool', 8, 'IsExit')
    @SetIsExit(false)
    @NetworkVar('Entity', 16, 'Exit')
    @NetworkVar('Entity', 17, 'Entrance')
    @NetworkVar('Float', 16, 'ResetAt')
    @NetworkVar('Int', 16, 'Uses')
    @SetResetAt(0)

ENT.ThinkPlaybackRate = =>
    oldPlayback = @currentPlayback
    if @BaseClass.IsAvaliable(@)
        @currentPlayback = Lerp(0.05, @currentPlayback, @targetPlayback)
    else
        if @GetIsBuilding()
            @currentPlayback = Lerp(0.05, @currentPlayback, 0.5)
        else
            @currentPlayback = Lerp(0.05, @currentPlayback, 1)
    
    if oldPlayback ~= @currentPlayback
        @SetPlaybackRate(@currentPlayback)

ENT.CalculatePlaybackRate = (animTime = 1 - (@GetResetAt() - CurTime()) / @GetReloadTime()) =>
    if animTime < 0.15
        return 1 - animTime / 0.15
    elseif animTime < 0.85
        return 0.15
    else
        return 0.5

ENT.Think = =>
    @BaseClass.Think(@)
    @ThinkPlaybackRate()
    
    if @BaseClass.IsAvaliable(@)
        if @IsValidTeleporter()
            if @GetResetAt() > CurTime()
                @targetPlayback = @CalculatePlaybackRate()
            else
                @targetPlayback = 1
        else
            @targetPlayback = 0

    @ClientTeleporterThink() if CLIENT
    return true
