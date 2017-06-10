AddCSLuaFile()
SWEP.Base = 'dbot_tf_pistol'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = "Pretty Boy's PocketPistol"
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.CooldownTime = 0.13 * 1.25
if SERVER then
  return hook.Add('EntityTakeDamage', 'DTF2.PrettyBoyPistol', function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
      local wep = attacker:GetWeapon('dbot_tf_pep')
      if IsValid(wep) then
        do
          local hp = attacker:Health()
          local mhp = attacker:GetMaxHealth()
          if hp < mhp then
            attacker:SetHealth(math.Clamp(hp + 5, 0, mhp))
          end
        end
      end
    end
    if ent:IsPlayer() and IsValid(ent:GetWeapon('dbot_tf_pep')) then
      if dmg:IsFallDamage() then
        dmg:SetDamage(0)
        return dmg:SetMaxDamage(0)
      else
        return dmg:ScaleDamage(1.2)
      end
    end
  end)
end
