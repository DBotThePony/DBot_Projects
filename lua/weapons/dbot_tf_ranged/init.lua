include('shared.lua')
AddCSLuaFile('shared.lua')
local BaseClass = baseclass.Get('dbot_tf_weapon_base')
SWEP.Think = function(self)
  BaseClass.Think(self)
  if self.isReloading and self.reloadNext < CurTime() then
    if self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
      self.reloadNext = CurTime() + self.ReloadTime
      local oldClip = self:Clip1()
      local newClip = math.Clamp(oldClip + self.ReloadBullets, 0, self:GetMaxClip1())
      self:SetClip1(newClip)
      if self:GetOwner():IsPlayer() then
        self:GetOwner():RemoveAmmo(newClip - oldClip, self.Primary.Ammo)
      end
      self:SendWeaponAnim(ACT_VM_RELOAD)
      if newClip == self:GetMaxClip1() then
        self.isReloading = false
        self:WaitForAnimation(ACT_RELOAD_FINISH, self.ReloadFinishAnimTime, (function()
          if IsValid(self) then
            return self:WaitForAnimation(ACT_VM_IDLE, self.ReloadFinishAnimTimeIdle)
          end
        end))
      end
    elseif self:GetOwner():IsPlayer() and self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 or newClip == self:GetMaxClip1() then
      self.isReloading = false
      self:WaitForAnimation(ACT_RELOAD_FINISH, self.ReloadFinishAnimTime, (function()
        if IsValid(self) then
          return self:WaitForAnimation(ACT_VM_IDLE, self.ReloadFinishAnimTimeIdle)
        end
      end))
    end
  end
  self:NextThink(CurTime() + 0.1)
  return true
end
