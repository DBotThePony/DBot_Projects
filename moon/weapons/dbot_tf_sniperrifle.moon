
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

BaseClass = baseclass.Get('dbot_tf_ranged')

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Sniper'
SWEP.PrintName = 'Sniper Rifle'
SWEP.ViewModel = 'models/weapons/c_models/c_sniper_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false
SWEP.Reloadable = false
SWEP.IsTF2SniperRifle = true

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CooldownTime = 1.35
SWEP.BulletDamage = 50
SWEP.DefaultBulletDamage = 50
SWEP.DefaultSpread = Vector(0, 0, 0)

SWEP.FireSoundsScript = 'Weapon_SniperRifle.Single'
SWEP.FireCritSoundsScript = 'Weapon_SniperRifle.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_SniperRifle.Empty'

SWEP.DrawAnimation = 'draw'
SWEP.IdleAnimation = 'idle'
SWEP.AttackAnimation = 'fire'
SWEP.AttackAnimationCrit = 'fire'

SWEP.MaxCharge = 100

SWEP.Primary = {
    'Ammo': 'XBowBolt'
    'ClipSize': -1
    'DefaultClip': 25
    'Automatic': true
}

SWEP.Secondary = {
    'Ammo': 'none'
    'ClipSize': -1
    'DefaultClip': -1
    'Automatic': false
}

SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    @BaseClass.PreOnHit(@, hitEntity, tr, dmginfo)
    if tr.HitGroup == HITGROUP_HEAD and @GetIsCharging()
        @ThatWasCrit()
        dmginfo\ScaleDamage(0.5)
        if CLIENT
            @GetOwner()\EmitSound('DTF2_TFPlayer.CritHit')
            @GetOwner()\EmitSound('DTF2_' .. @FireCritSoundsScript)

SWEP.PostOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
    @BaseClass.PostOnHit(@, hitEntity, tr, dmginfo)
    if @GetIsCharging()
        @SetIsCharging(false)
        @SetCharge(0)
        @Callback 'zoom', @CooldownTime, -> @SetIsCharging(true)

SWEP.PreFireTrigger = =>
    @BaseClass.PreFireTrigger(@)
    if @GetIsCharging()
        @BulletDamage = @DefaultBulletDamage + @GetCharge()
    else
        @BulletDamage = @DefaultBulletDamage

SWEP.SetupDataTables = =>
    @BaseClass.SetupDataTables(@)
    @NetworkVar('Bool', 16, 'IsCharging')
    @NetworkVar('Float', 16, 'Charge')

SWEP.Initialize = =>
    @BaseClass.Initialize(@)
    @currentZoom = 70
    @targetZoom = 70
    @lastChargeThink = CurTime()

SWEP.Deploy = =>
    status = @BaseClass.Deploy(@)
    return status if status == false
    @SetIsCharging(false)
    return true

if SERVER
    SWEP.Think = =>
        @BaseClass.Think(@)
        ctime = CurTime()
        delta = ctime - @lastChargeThink
        @lastChargeThink = ctime
        if @GetIsCharging()
            @SetCharge(math.min(@GetCharge() + delta * 25, @MaxCharge))
        else
            @SetCharge(0)
else
    --ScopeMaterial = Material('hud/scope_sniper_alt_ul')
    --ScopeW = 512
    --ScopeH = 372
    SWEP.DrawHUD = =>
        return if not @GetIsCharging()
        --surface.SetMaterial(ScopeMaterial)
        --w, h = ScrW(), ScrH()
        --min = math.min(w, h)
        --surface.SetDrawColor(0, 0, 0)
        --surface.DrawRect(0, 0, w, h)
        --surface.SetDrawColor(255, 255, 255)
        --surface.DrawTexturedRectRotated(w / 2 - ScopeW / 2, h / 2 - ScopeH / 2, ScopeW, ScopeH, 0)
        --surface.DrawTexturedRectRotated(w / 2 - ScopeH / 2 - 7, h / 2 + ScopeW / 2, ScopeW, ScopeH + 14, 90)
        DTF2.DrawSmallCenteredBar(@GetCharge() / @MaxCharge, 'Charge')
    SWEP.TranslateFOV = (fov) =>
        @currentZoom = Lerp(FrameTime() * 4, @currentZoom, @targetZoom)
        @targetZoom = @GetIsCharging() and 20 or fov
        return @currentZoom

SWEP.ZoomCooldown = 0.5

SWEP.SecondaryAttack = =>
    return false if not IsFirstTimePredicted()
    return false if @GetNextPrimaryFire() > CurTime()
    return false if @GetNextSecondaryFire() > CurTime()
    @SetNextSecondaryFire(CurTime() + @ZoomCooldown)
    @SetIsCharging(not @GetIsCharging())
    return true

hook.Add 'SetupMove', 'DTF2.SniperRifle', (mv, cmd) =>
    wep = @GetActiveWeapon()
    return if not IsValid(wep) or not wep.IsTF2SniperRifle or not wep\GetIsCharging()
    mv\SetMaxClientSpeed(70)

if CLIENT
    hook.Add 'AdjustMouseSensitivity', 'DTF2.SniperRifle', =>
        wep = LocalPlayer()\GetActiveWeapon()
        return if not IsValid(wep) or not wep.IsTF2SniperRifle or not wep\GetIsCharging()
        return 0.15
