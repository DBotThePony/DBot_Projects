AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_melee')
SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Medic'
SWEP.PrintName = 'Memory Maker'
SWEP.ViewModel = 'models/weapons/c_models/c_medic_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_8mm_camera/c_8mm_camera.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.MissSoundsScript = 'Weapon_BoneSaw.Miss'
SWEP.MissCritSoundsScript = 'Weapon_BoneSaw.MissCrit'
SWEP.HitSoundsScript = 'Weapon_BoneSaw.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_BoneSaw.HitFlesh'
SWEP.DrawAnimation = 'melee_allclass_draw'
SWEP.IdleAnimation = 'melee_allclass_idle'
SWEP.AttackAnimation = 'melee_allclass_swing'
SWEP.AttackAnimationTable = {
  'melee_allclass_swing'
}
SWEP.AttackAnimationCrit = 'melee_allclass_swing'
