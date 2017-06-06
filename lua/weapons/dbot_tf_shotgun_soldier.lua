AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_shotgun')
SWEP.Base = 'dbot_tf_shotgun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'Soldier Shotgun'
SWEP.ViewModel = 'models/weapons/c_models/c_soldier_arms.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.DrawAnimation = 'draw'
SWEP.IdleAnimation = 'idle'
SWEP.AttackAnimation = 'fire'
SWEP.AttackAnimationCrit = 'fire'
SWEP.ReloadStart = 'reload_start'
SWEP.ReloadLoop = 'reload_loop'
SWEP.ReloadEnd = 'reload_end'
