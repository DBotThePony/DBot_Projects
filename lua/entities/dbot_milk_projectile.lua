ENT.PrintName = 'Milk Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'base_anim'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.BallModel = 'models/weapons/c_models/c_madmilk/c_madmilk.mdl'
ENT.SetupDataTables = function(self)
  return self:NetworkVar('Bool', 0, 'IsCritical')
end
if SERVER then
  AccessorFunc(ENT, 'm_Attacker', 'Attacker')
  AccessorFunc(ENT, 'm_Inflictor', 'Inflictor')
  AccessorFunc(ENT, 'm_npcs', 'AffectNPCs')
  AccessorFunc(ENT, 'm_players', 'AffectPlayers')
  AccessorFunc(ENT, 'm_bots', 'AffectNextBots')
  AccessorFunc(ENT, 'm_blowRadius', 'BlowRadius')
  AccessorFunc(ENT, 'm_milktime', 'MilkTime')
end
ENT.RemoveTimer = 10
ENT.Initialize = function(self)
  self:SetModel(self.BallModel)
  if CLIENT then
    self:SetOwner(self)
    return 
  end
  self:SetAffectNPCs(true)
  self:SetAffectPlayers(true)
  self:SetAffectNextBots(false)
  self:SetBlowRadius(256)
  self:SetMilkTime(10)
  self.removeAt = CurTime() + self.RemoveTimer
  self:PhysicsInitSphere(12)
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
    self.particles = CreateParticleSystem(self, 'peejar_trail_red', PATTACH_ABSORIGIN_FOLLOW, 0)
  end
end
ENT.SetDirection = function(self, dir)
  if dir == nil then
    dir = Vector(0, 0, 0)
  end
  local newVel = Vector(dir)
  newVel.z = newVel.z + 0.08
  self.phys:SetVelocity(newVel * 1000)
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
ENT.PhysicsCollide = function(self, data, colldier)
  if data == nil then
    data = { }
  end
  local HitPos, HitNormal, HitEntity
  HitPos, HitNormal, HitEntity = data.HitPos, data.HitNormal, data.HitEntity
  if HitEntity == self:GetAttacker() then
    return false
  end
  local _list_0 = ents.FindInSphere(HitPos, self:GetBlowRadius())
  for _index_0 = 1, #_list_0 do
    local ent = _list_0[_index_0]
    if ent ~= self:GetAttacker() then
      local tr = util.TraceLine({
        start = HitPos - HitNormal,
        endpos = ent:WorldSpaceCenter(),
        filter = self
      })
      if tr.Entity == ent then
        do
          local _with_0 = ent:TF2MadMilk(self:GetMilkTime())
          _with_0:SetAttacker(self:GetAttacker())
        end
      end
    end
  end
  self:EmitSound('DTF2_Jar.Explode')
  ParticleEffect('peejar_impact_milk', HitPos - HitNormal, Angle(0, 0, 0))
  return self:Remove()
end
ENT.IsTF2Milk = true
if SERVER then
  return hook.Add('EntityTakeDamage', 'DTF2.MilkProjectile', function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if not IsValid(attacker) then
      return 
    end
    if not attacker.IsTF2Milk then
      return 
    end
    if dmg:GetDamageType() ~= DMG_CRUSH then
      return 
    end
    dmg:SetDamage(0)
    return dmg:SetMaxDamage(0)
  end)
end
