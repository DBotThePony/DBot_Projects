ENT.PrintName = 'Sentry Rockets'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Initialize = function(self)
  self:SetModel('models/buildables/sentry3_rockets.mdl')
  if CLIENT then
    return 
  end
  self:PhysicsInitSphere(12)
  local phys = self:GetPhysicsObject()
  self.phys = phys
  do
    local _with_0 = phys
    _with_0:EnableMotion(true)
    _with_0:SetMass(5)
    _with_0:EnableGravity(false)
    _with_0:Wake()
    return _with_0
  end
end
ENT.Think = function(self)
  if CLIENT then
    return 
  end
  if not self.phys:IsValid() then
    return self:Remove()
  end
  return self.phys:SetVelocity(self.vectorDir * 1500)
end
ENT.PhysicsCollide = function(self, data, colldier)
  if data == nil then
    data = { }
  end
  local HitPos, HitEntity, HitNormal
  HitPos, HitEntity, HitNormal = data.HitPos, data.HitEntity, data.HitNormal
  if HitEntity == self.attacker then
    return false
  end
  self:SetSolid(SOLID_NONE)
  util.BlastDamage(self, self.attacker or self, HitPos + HitNormal, 64, 128)
  local effData = EffectData()
  effData:SetNormal(-HitNormal)
  effData:SetOrigin(HitPos - HitNormal)
  util.Effect('sentry_rocket_explosion', effData)
  util.Decal('DTF2_SentryRocketExplosion', HitPos - HitNormal, HitPos + HitNormal)
  return self:Remove()
end
