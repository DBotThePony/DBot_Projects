AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_melee')
SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Heavy'
SWEP.PrintName = 'Memory Maker'
SWEP.ViewModel = 'models/weapons/c_models/c_heavy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_8mm_camera/c_8mm_camera.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.BulletDamage = 65
SWEP.BulletForce = 20
SWEP.PreFire = 0.24
SWEP.CooldownTime = 0.8
SWEP.MissSoundsScript = 'Weapon_Fist.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Fist.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Fist.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Fist.HitFlesh'
SWEP.DrawAnimation = 'melee_allclass_draw'
SWEP.IdleAnimation = 'melee_allclass_idle'
SWEP.AttackAnimation = 'melee_allclass_swing'
SWEP.AttackAnimationTable = {
  'melee_allclass_swing'
}
SWEP.AttackAnimationCrit = 'melee_allclass_swing'
