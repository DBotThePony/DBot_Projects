local BaseClass = baseclass.Get('dbot_tf_ranged')
SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'Shotgun'
SWEP.ViewModel = 'models/weapons/v_models/v_shotgun_engineer.mdl'
SWEP.WorldModel = 'models/weapons/w_models/w_shotgun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.MuzzleAttachment = 'muzzle'
SWEP.MuzzleEffect = 'muzzle_shotgun'
SWEP.BulletDamage = 14
SWEP.BulletsAmount = 6
SWEP.ReloadBullets = 1
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.05
SWEP.FireSounds = {
  'weapons/shotgun_shoot.wav'
}
SWEP.Primary = {
  ['Ammo'] = 'Buckshot',
  ['ClipSize'] = 6,
  ['DefaultClip'] = 6,
  ['Automatic'] = true
}
