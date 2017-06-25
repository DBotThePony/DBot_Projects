
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

BaseClass = baseclass.Get('dbot_tf_clipbased')

SWEP.Base = 'dbot_tf_clipbased'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'TF2 Projectiled Weapon Base'
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.SlotPos = 16
SWEP.DamageDegradation = false
SWEP.Slot = 3
SWEP.DefaultViewPunch = Angle(0, 0, 0)
SWEP.FireOffset = Vector(0, -10, 0)

SWEP.Primary = {
    'Ammo': 'RPG_Round'
    'ClipSize': 4
    'DefaultClip': 4
    'Automatic': true
}

SWEP.Secondary = {
    'Ammo': 'none'
    'ClipSize': -1
    'DefaultClip': 0
    'Automatic': false
}

SWEP.PreFireTrigger = =>
SWEP.PostFireTrigger = =>
SWEP.EmitMuzzleFlash = =>
SWEP.GetViewPunch = => @DefaultViewPunch

SWEP.PlayFireSound = (isCrit = @incomingCrit) =>
    if not isCrit
        return @EmitSound('DTF2_' .. @FireSoundsScript) if @FireSoundsScript
        playSound = table.Random(@FireSounds) if @FireSounds
        @EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound
    else
        return @EmitSound('DTF2_' .. @FireCritSoundsScript) if @FireCritSoundsScript
        playSound = table.Random(@FireCritSounds) if @FireCritSounds
        @EmitSound(playSound, SNDLVL_GUNSHOT, 100, .7, CHAN_WEAPON) if playSound

SWEP.PrimaryAttack = =>
    return false if @GetNextPrimaryFire() > CurTime()
    status = BaseClass.PrimaryAttack(@)
    return status if status == false

    @PlayFireSound()
    @GetOwner()\ViewPunch(@GetViewPunch())

    if game.SinglePlayer() and SERVER
        @CallOnClient('EmitMuzzleFlash')
    if CLIENT and @GetOwner() == LocalPlayer() and @lastMuzzle ~= FrameNumber()
        @lastMuzzle = FrameNumber()
        @EmitMuzzleFlash()
    
    return true
