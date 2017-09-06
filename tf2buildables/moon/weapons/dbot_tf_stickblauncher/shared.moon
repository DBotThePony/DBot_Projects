
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

DEFINE_BASECLASS('dbot_tf_launcher')

SWEP.Base = 'dbot_tf_launcher'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Demoman'
SWEP.PrintName = 'Stickybomb Launcher'
SWEP.ViewModel = 'models/weapons/c_models/c_demo_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_stickybomb_launcher/c_stickybomb_launcher.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.IS_STICKYBOMB_LAUNCHER = true

SWEP.MAX_CHARGE_TIME = 4
SWEP.PreFire = SWEP.MAX_CHARGE_TIME
SWEP.MIN_STICKY_SPEED = 800
SWEP.MAX_STICKY_SPEED = 1300
AccessorFunc(SWEP, 'm_chargeStarted', 'StickyChargeStart')
AccessorFunc(SWEP, 'm_isCharging', 'IsCharging')

SWEP.ChargeEndsAt = => @GetIsCharging() and (@GetStickyChargeStart() + DTF2.GrabFloat(@MAX_CHARGE_TIME)) or CurTime()
SWEP.ChargeLeft = => @GetIsCharging() and (@GetStickyChargeStart() + DTF2.GrabFloat(@MAX_CHARGE_TIME) - CurTime()) or 0
SWEP.ChargePercent = => @GetIsCharging() and math.Clamp(1 - (@GetStickyChargeStart() + DTF2.GrabFloat(@MAX_CHARGE_TIME) - CurTime()) / DTF2.GrabFloat(@MAX_CHARGE_TIME), 0, 1) or 0
SWEP.GetChargePercent = => @ChargePercent()
SWEP.IsCharged = => @ChargePercent() == 1

SWEP.GetFireStrength = => @MIN_STICKY_SPEED + (@MAX_STICKY_SPEED - @MIN_STICKY_SPEED) * @ChargePercent()

SWEP.CooldownTime = 0.6

SWEP.FireSoundsScript = 'Weapon_StickyBombLauncher.Single'
SWEP.FireCritSoundsScript = 'Weapon_StickyBombLauncher.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_StickyBombLauncher.ClipEmpty'
SWEP.ProjectileClass = 'dbot_tf_stickybomb'

SWEP.DETONATE_SOUND = 'DTF2_Weapon_StickyBombLauncher.ModeSwitch'
SWEP.CHARGE_UP_SOUND = 'DTF2_Weapon_StickyBombLauncher.ChargeUp'

SWEP.DrawAnimation = 'sb_draw'
SWEP.IdleAnimation = 'sb_idle'
SWEP.AttackAnimation = 'sb_fire'
SWEP.CHARGE_ANIMATION = 'sb_autofire'
SWEP.AttackAnimationCrit = 'sb_fire'
SWEP.ReloadStart = 'sb_reload_start'
SWEP.ReloadLoop = 'sb_reload_loop'
SWEP.ReloadEnd = 'sb_reload_end'
SWEP.ReloadDeployTime = 0.6
SWEP.ReloadTime = 0.7
SWEP.ReloadPlayExtra = true
SWEP.HANDLE_FIRE_SOUND = false

SWEP.FireOffset = Vector(10, -10, -5)

SWEP.Primary = {
	'Ammo': 'ammo_tf_stickybomb'
	'ClipSize': 8
	'DefaultClip': 24
	'Automatic': false
}

SWEP.Secondary = {
	'Ammo': 'none'
	'ClipSize': -1
	'DefaultClip': 0
	'Automatic': false
}

SWEP.GetStickiesCount = => @GetOwner()\GetTFStickiesCount(@ProjectileClass)
SWEP.GetSticksCount = => @GetOwner()\GetTFStickiesCount(@ProjectileClass)
SWEP.GetStickieBombCount = => @GetOwner()\GetTFStickiesCount(@ProjectileClass)
SWEP.GetStickieBombsCount = => @GetOwner()\GetTFStickiesCount(@ProjectileClass)

SWEP.Initialize = =>
	BaseClass.Initialize(@)
	@lastDetonationSound = 0

SWEP.Think = =>
	status = BaseClass.Think(@)
	if @GetIsCharging()
		ply = @GetOwner()
		if not IsValid(ply) or not ply\IsPlayer()
			@incomingCrit = false
			@incomingMiniCrit = false
			@SetIsCharging(false)
			@SetStickyChargeStart(0)
			@incomingFire = false
			@incomingFireTime = 0
		elseif @IsCharged()
			@FireTrigger()
		elseif not ply\KeyDown(IN_ATTACK)
			@FireTrigger()
	return status
