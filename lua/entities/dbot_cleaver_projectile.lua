ENT.PrintName = 'Cleaver Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.BallModel = 'models/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl'
ENT.SetupDataTables = function(self)
  self:NetworkVar('Bool', 0, 'IsFlying')
  return self:NetworkVar('Bool', 1, 'IsCritical')
end
AccessorFunc(ENT, 'm_Attacker', 'Attacker')
AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_dmgtype', 'DamageType')
AccessorFunc(ENT, 'm_dmg', 'Damage')
ENT.DefaultDamage = 50
ENT.RemoveTimer = 10
ENT.Initialize = function(self)
  self:SetModel(self.BallModel)
  if CLIENT then
    return 
  end
  self.removeAt = CurTime() + self.RemoveTimer
  self:PhysicsInitSphere(12)
  self:SetDamageType(DMG_SLASH)
  self:SetDamage(self.DefaultDamage)
  self:SetAttacker(self)
  self:SetInflictor(self)
  self:SetIsFlying(true)
  self.initialPosition = self:GetPos()
  local phys = self:GetPhysicsObject()
  self.phys = phys
  do
    local _with_0 = phys
    _with_0:EnableMotion(true)
    _with_0:EnableDrag(false)
    _with_0:SetMass(5)
    _with_0:Wake()
    return _with_0
  end
end
ENT.SetDirection = function(self, dir)
  if dir == nil then
    dir = Vector(0, 0, 0)
  end
  local newVel = Vector(dir)
  newVel.z = newVel.z + 0.05
  self.phys:SetVelocity(newVel * 4000)
  return self:SetAngles(dir:Angle())
end
ENT.Think = function(self)
  if CLIENT then
    return false
  end
  if self.removeAt < CurTime() then
    return self:Remove()
  end
end
ENT.OnHit = function(self, ent, data)
  if data == nil then
    data = { }
  end
  local dist = self:GetPos():Distance(self.initialPosition)
  local miniCrit = dist > 1024 or ent:IsMarkedForDeath()
  local dmginfo = DamageInfo()
  dmginfo:SetDamageType(self:GetDamageType())
  dmginfo:SetDamage(self:GetDamage() * (self:GetIsCritical() and 3 or miniCrit and 1.3 or 1))
  dmginfo:SetAttacker(self:GetAttacker())
  dmginfo:SetInflictor(self:GetInflictor())
  ent:TakeDamageInfo(dmginfo)
  if self:GetIsCritical() then
    local effData = EffectData()
    effData:SetOrigin(data.HitPos)
    util.Effect('dtf2_critical_hit', effData)
    self:GetAttacker():EmitSound('DTF2_TFPlayer.CritHit')
    ent:EmitSound('DTF2_TFPlayer.CritHit')
  elseif miniCrit then
    local effData = EffectData()
    effData:SetOrigin(data.HitPos)
    util.Effect('dtf2_minicrit', effData)
    self:GetAttacker():EmitSound('DTF2_TFPlayer.CritHitMini')
    ent:EmitSound('DTF2_TFPlayer.CritHitMini')
  end
  if ent:IsNPC() or ent:IsPlayer() then
    local bleed = ent:TF2Bleed(math.Clamp(dist / 256, 5, 10))
    bleed:SetAttacker(self:GetAttacker())
    bleed:SetInflictor(self:GetInflictor())
    ent:EmitSound('DTF2_Cleaver.ImpactFlesh')
    self:GetAttacker():EmitSound('DTF2_Cleaver.ImpactFlesh')
  else
    ent:EmitSound('DTF2_Cleaver.ImpactWorld')
  end
  return self:Remove()
end
ENT.PhysicsCollide = function(self, data, colldier)
  if data == nil then
    data = { }
  end
  local HitEntity
  HitEntity = data.HitEntity
  if not self:GetIsFlying() then
    return 
  end
  if HitEntity == self:GetAttacker() then
    return false
  end
  if IsValid(HitEntity) then
    return self:OnHit(HitEntity, data)
  else
    self:SetIsFlying(false)
    return self:EmitSound('DTF2_Cleaver.ImpactWorld')
  end
end
ENT.IsTF2Cleaver = true
if SERVER then
  return hook.Add('EntityTakeDamage', 'DTF2.CleaverProjective', function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if not IsValid(attacker) then
      return 
    end
    if not attacker.IsTF2Cleaver then
      return 
    end
    if dmg:GetDamageType() ~= DMG_CRUSH then
      return 
    end
    dmg:SetDamage(0)
    return dmg:SetMaxDamage(0)
  end)
end
