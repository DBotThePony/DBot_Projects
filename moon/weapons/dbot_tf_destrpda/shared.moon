
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

AddCSLuaFile()

BaseClass = baseclass.Get('dbot_tf_weapon_base')

SWEP.Base = 'dbot_tf_weapon_base'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Engineer'
SWEP.PrintName = 'Destruction PDA'
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pda_engineer/c_pda_engineer.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.DrawAnimation = 'pda_draw'
SWEP.IdleAnimation = 'pda_idle'

SWEP.SLOT_SENTRY = 1
SWEP.SLOT_DISPENSER = 2
SWEP.SLOT_TELE_IN = 3
SWEP.SLOT_TELE_OUT = 4

SWEP.DrawTimeAnimation = 0.9
SWEP.BoxDrawTimeAnimation = 0.9

SWEP.Initialize = =>
    BaseClass.Initialize(@)
    @__InputCache = {} if CLIENT

SWEP.GetBuildAngle = =>
    ply = @GetOwner()
    ang = ply\EyeAngles()
    angReturn = Angle(0, ang.y, 0)
    angReturn.y += @GetBuildRotation() * 90
    return angReturn

SWEP.CheckBuildableAvaliability = (slot = @SLOT_SENTRY) =>
    with @GetOwner()
        switch slot
            when @SLOT_SENTRY
                return not IsValid(\GetBuildedSentry())
            when @SLOT_DISPENSER
                return not IsValid(\GetBuildedDispenser())
            when @SLOT_TELE_IN
                return not IsValid(\GetBuildedTeleporterIn())
            when @SLOT_TELE_OUT
                return not IsValid(\GetBuildedTeleporterOut())

SWEP.TriggerDestructionRequest = (requestType = @SLOT_SENTRY) =>
    ply = @GetOwner()
    return false if not IsValid(ply) or not ply\IsPlayer()
    return false if @CheckBuildableAvaliability(requestType)

    if CLIENT
        net.Start('DTF2.DestroyRequest')
        net.WriteUInt(requestType, 8)
        net.WriteEntity(@)
        net.SendToServer()
        return true

    switch requestType
        when @SLOT_SENTRY
            ply\GetBuildedSentry()\TriggerDestruction()
        when @SLOT_DISPENSER
            ply\GetBuildedDispenser()\TriggerDestruction()
        when @SLOT_TELE_IN
            ply\GetBuildedTeleporterIn()\TriggerDestruction()
        when @SLOT_TELE_OUT
            ply\GetBuildedTeleporterOut()\TriggerDestruction()

    @SwitchToWrench()
    return true

SWEP.PrimaryAttack = => false
SWEP.SecondaryAttack = => false
