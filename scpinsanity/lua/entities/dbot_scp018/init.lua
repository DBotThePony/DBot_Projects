include('shared.lua')
AddCSLuaFile('cl_init.lua')
local hook
hook = _G.hook
ENT.Initialize = function(self)
  self:SetModel('models/Combine_Helicopter/helicopter_bomb01.mdl')
  self:SetModelScale(0.4)
  self:PhysicsInitSphere(32)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(SOLID_VPHYSICS)
  return timer.Simple(0, function()
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
      self.phys = phys
      phys:SetMass(256)
      return phys:Sleep()
    end
  end)
end
ENT.PhysicsCollide = function(self, data)
  if not self.phys then
    return 
  end
  local vel = self.phys:GetVelocity()
  local mult = data.HitNormal
  local summ = vel.x + vel.y + vel.z
  return self.phys:AddVelocity(-mult * summ * 5 + vel * 2)
end
local big = 2 ^ 31 - 1
return hook.Add('EntityTakeDamage', 'DBot.SCP018', function(ent, dmg)
  if ent == nil then
    ent = NULL
  end
  local attacker = dmg:GetAttacker()
  if not attacker:IsValid() then
    return 
  end
  if attacker:GetClass() ~= 'dbot_scp018' then
    return 
  end
  dmg:SetDamageType(DMG_ACID)
  return dmg:SetDamage(big)
end)
