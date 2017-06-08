AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_ranged')
SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Shortstop'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shortstop/c_shortstop.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true
SWEP.MuzzleAttachment = 'muzzle'
SWEP.BulletDamage = 12
SWEP.BulletsAmount = 4
SWEP.ReloadBullets = 4
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.05
SWEP.FireSoundsScript = 'Weapon_Short_Stop.Single'
SWEP.FireCritSoundsScript = 'Weapon_Short_Stop.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Short_Stop.Empty'
SWEP.Primary = {
  ['Ammo'] = 'Buckshot',
  ['ClipSize'] = 4,
  ['DefaultClip'] = 4,
  ['Automatic'] = true
}
SWEP.CooldownTime = 0.35
SWEP.ReloadDeployTime = 1.3
SWEP.DrawAnimation = 'ss_draw'
SWEP.IdleAnimation = 'ss_idle'
SWEP.AttackAnimation = 'ss_fire'
SWEP.AttackAnimationCrit = 'ss_fire'
SWEP.ReloadStart = 'ss_reload'
SWEP.SingleReloadAnimation = true
SWEP.SecondaryAttack = function(self)
  local trace = self:GetOwner():GetEyeTrace()
  local lpos = self:GetOwner():GetPos()
  if not IsValid(trace.Entity) or trace.Entity:GetPos():Distance(lpos) > 130 then
    return 
  end
  if SERVER then
    local ent = trace.Entity
    local dir = ent:GetPos() - lpos
    dir:Normalize()
    local vel = dir * 300 + Vector(0, 0, 200)
    DTF2.ApplyVelocity(ent, vel)
  end
  self:EmitSound('DTF2_Player.ScoutShove')
  self:SetNextSecondaryFire(CurTime() + 1)
  return true
end
