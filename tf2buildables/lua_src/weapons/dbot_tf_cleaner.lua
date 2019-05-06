
--
-- Copyright (C) 2017-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


AddCSLuaFile()

DEFINE_BASECLASS('dbot_tf_ranged')

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Sniper'
SWEP.PrintName = 'The Cleaners Carbine'
SWEP.ViewModel = 'models/weapons/c_models/c_sniper_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_pro_smg/c_pro_smg.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

SWEP.CritChance = 1
SWEP.CritExponent = 0.05
SWEP.CritExponentMax = 2

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CooldownTime = 0.1 * 1.25
SWEP.BulletDamage = 8
SWEP.ReloadBullets = 25
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.02

SWEP.FireSoundsScript = 'Weapon_UrbanProfessional.Single'
SWEP.FireCritSoundsScript = 'Weapon_UrbanProfessional.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_SMG.Empty'

SWEP.DrawAnimation = 'smg_draw'
SWEP.IdleAnimation = 'smg_idle'
SWEP.AttackAnimation = 'smg_fire'
SWEP.AttackAnimationCrit = 'smg_fire'
SWEP.SingleReloadAnimation = true
SWEP.ReloadStart = 'smg_reload'
SWEP.ReloadDeployTime = 1.12

SWEP.CRITEY_DURACTION = 8
SWEP.CRITEY_REQUIRED = 100

SWEP.Primary = {
	['Ammo'] = 'SMG1',
	['ClipSize'] = 25 * 0.8,
	['DefaultClip'] = 75,
	['Automatic'] = true
}

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar('Int', 16, 'SMGDamageDealt')
	self:NetworkVar('Bool', 16, 'SMGBonusActive')
	self:SetSMGDamageDealt(0)
	self:SetSMGBonusActive(false)
end

function SWEP:IsCriteyReady() return self:GetSMGDamageDealt() >= DTF2.GrabInt(self.CRITEY_REQUIRED) end

if SERVER then
	hook.Add('EntityTakeDamage', 'DTF2.CleanerCarabine', DTF2.HookStruct.AllExplicitDamage('dbot_tf_cleaner', true, true, false, function(self, weapon, ent, dmg)
		if weapon:GetSMGBonusActive() then return end
		weapon:SetSMGDamageDealt(math.Clamp(weapon:GetSMGDamageDealt() + dmg:GetDamage(), 0, DTF2.GrabInt(weapon.CRITEY_REQUIRED)))
	end))

	function SWEP:Think()
		BaseClass.Think(self)
		if self:GetSMGBonusActive() then
			self:SetSMGDamageDealt(math.max(0, DTF2.GrabInt(self.CRITEY_REQUIRED) * (self.criteyEndsAt - CurTimeL()) / DTF2.GrabInt(self.CRITEY_DURACTION)))
		end
	end

	function SWEP:SecondaryAttack()
		if not self:IsCriteyReady() then return false end
		 if self:GetSMGBonusActive() then return false end
		self:SetMiniCritBoosted(true)
		self:SetSMGBonusActive(true)
		self.criteyEndsAt = CurTimeL() + DTF2.GrabInt(self.CRITEY_DURACTION)

		timer.Create('DTF2.ProSMG.' .. self:EntIndex(), DTF2.GrabInt(self.CRITEY_DURACTION), 1, function()
			if IsValid(self) then
				self:SetMiniCritBoosted(false)
				self:SetSMGBonusActive(false)
			end
		end)

		return true
	end
else
	function SWEP:DrawHUD()
		DTF2.DrawCenteredBar(self:GetSMGDamageDealt() / DTF2.GrabInt(self.CRITEY_REQUIRED), 'CRITEY')
	end
end
