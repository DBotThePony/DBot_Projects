AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_scattergun')
SWEP.Base = 'dbot_tf_scattergun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Baby Face Blaster'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pep_scattergun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.MaxCharge = 100
SWEP.ChargeDivider = 200
SWEP.ChargeThersold = 30
SWEP.FireSoundsScript = 'Weapon_Brawler_Blaster.Single'
SWEP.FireCritSoundsScript = 'Weapon_Brawler_Blaster.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Brawler_Blaster.Empty'
SWEP.SetupDataTables = function(self)
  self.BaseClass.SetupDataTables(self)
  return self:NetworkVar('Int', 16, 'BabyCharge')
end
SWEP.Primary = {
  ['Ammo'] = 'Buckshot',
  ['ClipSize'] = 4,
  ['DefaultClip'] = 4,
  ['Automatic'] = true
}
hook.Add('SetupMove', 'DTF2.BabyFaceBlaster', function(self, mv, cmd)
  local wep = self:GetWeapon('dbot_tf_babyblaster')
  if not IsValid(wep) then
    return 
  end
  local mult = 1 + (wep:GetBabyCharge() - wep.ChargeThersold) / wep.ChargeDivider
  mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * mult)
  mv:SetForwardSpeed(mv:GetForwardSpeed() * mult)
  mv:SetSideSpeed(mv:GetSideSpeed() * mult)
  self.__babyBlasterSpeed = self:GetWalkSpeed()
  self.__babyBlasterRSpeed = self:GetRunSpeed()
  self:SetWalkSpeed(self.__babyBlasterSpeed * mult)
  return self:SetRunSpeed(self.__babyBlasterRSpeed * mult)
end)
hook.Add('FinishMove', 'DTF2.BabyFaceBlaster', function(self, mv, cmd)
  if self.__babyBlasterSpeed then
    self:SetWalkSpeed(self.__babyBlasterSpeed)
    self.__babyBlasterSpeed = nil
  end
  if self.__babyBlasterRSpeed then
    self:SetRunSpeed(self.__babyBlasterRSpeed)
    self.__babyBlasterRSpeed = nil
  end
end)
if SERVER then
  return hook.Add('EntityTakeDamage', 'DTF2.BabyFaceBlaster', function(ent, dmg)
    if not (ent:IsNPC() or ent:IsPlayer() or ent.Type == 'nextbot') then
      return 
    end
    if ent:IsPlayer() then
      local wep = ent:GetWeapon('dbot_tf_babyblaster')
      if IsValid(wep) then
        wep:SetBabyCharge(math.min(wep:GetBabyCharge() - math.max(dmg:GetDamage(), 0) * 4, wep.MaxCharge))
      end
    end
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
      local wep = attacker:GetWeapon('dbot_tf_babyblaster')
      if IsValid(wep) then
        return wep:SetBabyCharge(math.min(wep:GetBabyCharge() + math.max(dmg:GetDamage(), 0), wep.MaxCharge))
      end
    end
  end)
else
  SWEP.DrawHUD = function(self)
    return DTF2.DrawCenteredBar(self:GetBabyCharge() / self.MaxCharge, 'Charge')
  end
end
