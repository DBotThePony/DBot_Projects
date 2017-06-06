AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_melee')
SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Pyro'
SWEP.PrintName = 'Memory Maker'
SWEP.ViewModel = 'models/weapons/c_models/c_pyro_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_8mm_camera/c_8mm_camera.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.BulletDamage = 65
SWEP.BulletForce = 20
SWEP.PreFire = 0.24
SWEP.CooldownTime = 0.8
SWEP.MissSoundsScript = 'Weapon_FireAxe.Miss'
SWEP.MissCritSoundsScript = 'Weapon_FireAxe.MissCrit'
SWEP.HitSoundsScript = 'Weapon_FireAxe.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_FireAxe.HitFlesh'
SWEP.DrawAnimation = 'melee_allclass_draw'
SWEP.IdleAnimation = 'melee_allclass_idle'
SWEP.AttackAnimation = 'melee_allclass_swing'
SWEP.AttackAnimationTable = {
  'melee_allclass_swing'
}
SWEP.AttackAnimationCrit = 'melee_allclass_swing'
