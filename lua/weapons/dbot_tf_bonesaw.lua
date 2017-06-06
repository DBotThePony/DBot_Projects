AddCSLuaFile()
SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'Bonesaw'
SWEP.ViewModel = 'models/weapons/c_models/c_medic_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_bonesaw/c_bonesaw.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.MissSoundsScript = 'Weapon_BoneSaw.Miss'
SWEP.MissCritSoundsScript = 'Weapon_BoneSaw.MissCrit'
SWEP.HitSoundsScript = 'Weapon_BoneSaw.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_BoneSaw.HitFlesh'
SWEP.DrawAnimation = 'bs_draw'
SWEP.IdleAnimation = 'bs_idle'
SWEP.AttackAnimation = 'bs_swing_a'
SWEP.AttackAnimationTable = {
  'bs_swing_a',
  'bs_swing_b'
}
SWEP.AttackAnimationCrit = 'bs_swing_c'
