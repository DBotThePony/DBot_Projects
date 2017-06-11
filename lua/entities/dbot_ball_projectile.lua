ENT.PrintName = 'Ball Projective'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.BallModel = 'models/weapons/c_models/c_xms_festive_ornament.mdl'
ENT.SetupDataTables = function(self)
  self:NetworkVar('Bool', 0, 'IsFlying')
  return self:NetworkVar('Bool', 1, 'IsCritical')
end
AccessorFunc(ENT, 'm_Attacker', 'Attacker')
AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
AccessorFunc(ENT, 'm_dmgtype', 'DamageType')
AccessorFunc(ENT, 'm_dmg', 'Damage')
ENT.DefaultDamage = 15
ENT.RemoveTimer = 15
ENT.AffectedWeapon = 'dbot_tf_wrapassasin'
ENT.Initialize = function(self)
  self:SetModel(self.BallModel)
  if CLIENT then
    return 
  end
  self.removeAt = CurTime() + self.RemoveTimer
  self:PhysicsInitSphere(6)
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
ENT.Draw = function(self)
  self:DrawModel()
  if not self.particles then
    self.particles = CreateParticleSystem(self, not self:GetIsCritical() and 'stunballtrail_red' or 'stunballtrail_red_crit', PATTACH_ABSORIGIN_FOLLOW, 0)
  end
end
ENT.SetDirection = function(self, dir)
  if dir == nil then
    dir = Vector(0, 0, 0)
  end
  local newVel = Vector(dir)
  newVel.z = newVel.z + 0.05
  return self.phys:SetVelocity(newVel * 4000)
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
  local dmginfo = DamageInfo()
  dmginfo:SetDamageType(self:GetDamageType())
  dmginfo:SetDamage(self:GetDamage() * (self:GetIsCritical() and 3 or ent:IsMarkedForDeath() and 1.3 or 1))
  dmginfo:SetAttacker(self:GetAttacker())
  dmginfo:SetInflictor(self:GetInflictor())
  ent:TakeDamageInfo(dmginfo)
  if self:GetIsCritical() then
    local effData = EffectData()
    effData:SetOrigin(data.HitPos)
    util.Effect('dtf2_critical_hit', effData)
    self:GetAttacker():EmitSound('DTF2_TFPlayer.CritHit')
    ent:EmitSound('DTF2_TFPlayer.CritHit')
  elseif ent:IsMarkedForDeath() then
    local effData = EffectData()
    effData:SetOrigin(data.HitPos)
    util.Effect('dtf2_minicrit', effData)
    self:GetAttacker():EmitSound('DTF2_TFPlayer.CritHitMini')
    ent:EmitSound('DTF2_TFPlayer.CritHitMini')
  end
  local dist = self:GetPos():Distance(self.initialPosition)
  if ent:IsNPC() or ent:IsPlayer() then
    local bleed = ent:TF2Bleed(math.Clamp(dist / 128, 1, 15))
    bleed:SetAttacker(self:GetAttacker())
    bleed:SetInflictor(self:GetInflictor())
    if dist < 1024 then
      ent:EmitSound('DTF2_BallBuster.OrnamentImpact')
      self:GetAttacker():EmitSound('DTF2_BallBuster.OrnamentImpact')
    else
      ent:EmitSound('DTF2_BallBuster.OrnamentImpactRange')
      self:GetAttacker():EmitSound('DTF2_BallBuster.OrnamentImpactRange')
    end
  else
    ent:EmitSound('DTF2_BallBuster.OrnamentImpact')
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
    if not IsValid(HitEntity) then
      return 
    end
    if not HitEntity:IsPlayer() then
      return 
    end
    local wep = HitEntity:GetWeapon(self.AffectedWeapon)
    if not IsValid(wep) then
      return 
    end
    wep:SetBallReady(wep.BallRestoreTime)
    return HitEntity:EmitSound('DTF2_Player.PickupWeapon')
  else
    if HitEntity == self:GetAttacker() then
      return false
    end
    if IsValid(HitEntity) then
      return self:OnHit(HitEntity, data)
    else
      self:EmitSound('DTF2_BallBuster.OrnamentImpact')
      return self:Remove()
    end
  end
end
ENT.IsTF2Ball = true
if SERVER then
  return hook.Add('EntityTakeDamage', 'DTF2.BallProjective', function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if not IsValid(attacker) then
      return 
    end
    if not attacker.IsTF2Ball then
      return 
    end
    if dmg:GetDamageType() ~= DMG_CRUSH then
      return 
    end
    dmg:SetDamage(0)
    return dmg:SetMaxDamage(0)
  end)
end
