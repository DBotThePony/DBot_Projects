AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_melee')
SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'Bottle'
SWEP.ViewModel = 'models/weapons/c_models/c_demo_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_bottle/c_bottle.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.MissSoundsScript = 'Weapon_Bottle.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Bottle.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Bottle.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Bottle.HitFlesh'
SWEP.DrawAnimation = 'b_draw'
SWEP.IdleAnimation = 'b_idle'
SWEP.AttackAnimation = 'b_swing_a'
SWEP.AttackAnimationTable = {
  'b_swing_a',
  'b_swing_b'
}
SWEP.AttackAnimationCrit = 'b_swing_c'
SWEP.OnHit = function(self, ...)
  BaseClass.OnHit(self, ...)
  if SERVER and not self._bottle_Broken and self.icomingCrit then
    self._bottle_Broken = true
    return self:GetTF2WeaponModel():SetModel('models/weapons/c_models/c_bottle/c_bottle_broken.mdl')
  end
end
