AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_forceanature')
SWEP.Base = 'dbot_tf_forceanature'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Soda Popper'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_soda_popper/c_soda_popper.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true
SWEP.IsSodaPopper = true
SWEP.SodaPopperDuration = 10
SWEP.SodaDamageRequired = 350
SWEP.FireSoundsScript = 'Weapon_Soda_Popper.Single'
SWEP.FireCritSoundsScript = 'Weapon_Soda_Popper.SingleCrit'
SWEP.Primary = {
  ['Ammo'] = 'Buckshot',
  ['ClipSize'] = 2,
  ['DefaultClip'] = 2,
  ['Automatic'] = true
}
SWEP.SetupDataTables = function(self)
  self.BaseClass.SetupDataTables(self)
  self:NetworkVar('Int', 16, 'SodaDamageDealt')
  return self:NetworkVar('Bool', 16, 'SodaActive')
end
SWEP.IsSodaReady = function(self)
  return self:GetSodaDamageDealt() >= self.SodaDamageRequired
end
if SERVER then
  hook.Add('EntityTakeDamage', 'DTF2.SodaPopper', function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if not IsValid(attacker) then
      return 
    end
    if not attacker:IsPlayer() then
      return 
    end
    local wep = attacker:GetWeapon('dbot_tf_sodapopper')
    if not IsValid(wep) then
      return 
    end
    if wep.IsSodaPopper and not wep:GetSodaActive() then
      return wep:SetSodaDamageDealt(math.min(wep:GetSodaDamageDealt() + math.max(dmg:GetDamage(), 0), wep.SodaDamageRequired))
    end
  end)
  SWEP.OnRemove = function(self)
    if IsValid(self.miniCritBuffer) then
      return self.miniCritBuffer:Remove()
    end
  end
  SWEP.Think = function(self)
    self.BaseClass.Think(self)
    if self:GetSodaActive() then
      return self:SetSodaDamageDealt(math.max(0, self.SodaDamageRequired * (self.sodaPopperEnd - CurTime()) / 10))
    end
  end
  SWEP.SecondaryAttack = function(self)
    if not self:IsSodaReady() then
      return false
    end
    if self:GetSodaActive() then
      return false
    end
    self:SetSodaActive(true)
    local ply = self:GetOwner()
    self.miniCritBuffer = ents.Create('dbot_tf_logic_minicrit')
    do
      local _with_0 = self.miniCritBuffer
      _with_0:SetPos(ply:GetPos())
      _with_0:Spawn()
      _with_0:Activate()
      _with_0:SetParent(ply)
      _with_0:SetOwner(ply)
      _with_0:SetEnableBuff(true)
    end
    self.sodaPopperEnd = CurTime() + self.SodaPopperDuration
    timer.Create("DTF2.SodaPopper." .. tostring(self:EntIndex()), self.SodaPopperDuration, 1, function()
      if IsValid(self) and IsValid(self.miniCritBuffer) then
        self.miniCritBuffer:Remove()
      end
      if IsValid(self) then
        return self:SetSodaActive(false)
      end
    end)
    return true
  end
else
  SWEP.DrawHUD = function(self)
    return DTF2.DrawCenteredBar(self:GetSodaDamageDealt() / self.SodaDamageRequired, 'Soda')
  end
end
