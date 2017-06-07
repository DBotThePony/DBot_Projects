
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

BaseClass = baseclass.Get('dbot_tf_forceanature')

SWEP.Base = 'dbot_tf_forceanature'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Soda Popper'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_soda_popper/c_soda_popper.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true
SWEP.IsSodaPopper = true

SWEP.SodaPopperDuration = 10
SWEP.SodaDamageRequired = 350
SWEP.FireSoundsScript = 'Weapon_Soda_Popper.Single'
SWEP.FireCritSoundsScript = 'Weapon_Soda_Popper.SingleCrit'

SWEP.Primary = {
    'Ammo': 'Buckshot'
    'ClipSize': 2
    'DefaultClip': 2
    'Automatic': true
}

SWEP.SetupDataTables = =>
    BaseClass.SetupDataTables(@)
    @NetworkVar('Int', 16, 'SodaDamageDealt')
    @NetworkVar('Bool', 16, 'SodaActive')

SWEP.IsSodaReady = => @GetSodaDamageDealt() >= @SodaDamageRequired

if SERVER
    hook.Add 'EntityTakeDamage', 'DTF2.SodaPopper', (ent, dmg) ->
        attacker = dmg\GetAttacker()
        return if not IsValid(attacker)
        return if not attacker\IsPlayer()
        for wep in *attacker\GetWeapon()
            if wep.IsSodaPopper and not wep\GetSodaActive()
                wep\SetSodaDamageDealt(math.min(wep\GetSodaDamageDealt() + math.max(dmg\GetDamage(), 0), wep.SodaDamageRequired))
    
    SWEP.OnRemove = => @miniCritBuffer\Remove() if IsValid(@miniCritBuffer)

    SWEP.Think = =>
        BaseClass.Think(@)
        if @GetSodaActive()
            @SetSodaDamageDealt(math.max(0, @SodaDamageRequired * (@sodaPopperEnd - CurTime())))

    SWEP.SecondaryAttack = =>
        return false if not @IsSodaReady()
        return false if @GetSodaActive()
        @SetSodaActive(true)
        ply = @GetOwner()
        @miniCritBuffer = ents.Create('dbot_tf_logic_minicrit')
        with @miniCritBuffer
            \SetPos(ply\GetPos())
            \Spawn()
            \Activate()
            \SetParent(ply)
            \SetOwner(ply)
            \SetEnableBuff(true)
        
        @sodaPopperEnd = CurTime() + @SodaPopperDuration
        timer.Create "DTF2.SodaPopper.#{@EntIndex()}", @SodaPopperDuration, 1, ->
            @miniCritBuffer\Remove() if IsValid(@) and IsValid(@miniCritBuffer)

        return true
else
    SWEP.DrawHUD = =>
        DTF2.DrawCenteredBar(@GetSodaDamageDealt() / @SodaDamageRequired, 'Soda')
