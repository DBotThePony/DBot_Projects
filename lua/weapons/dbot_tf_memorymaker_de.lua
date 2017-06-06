AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_melee')
SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Demoman'
SWEP.PrintName = 'Memory Maker'
SWEP.ViewModel = 'models/weapons/c_models/c_demo_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_8mm_camera/c_8mm_camera.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.MissSoundsScript = 'Weapon_Bottle.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Bottle.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Bottle.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Bottle.HitFlesh'
SWEP.DrawAnimation = 'melee_allclass_draw'
SWEP.IdleAnimation = 'melee_allclass_idle'
SWEP.AttackAnimation = 'melee_allclass_swing_a'
SWEP.AttackAnimationTable = {
  'melee_allclass_swing_a',
  'melee_allclass_swing_b'
}
SWEP.AttackAnimationCrit = 'melee_allclass_swing_c'
