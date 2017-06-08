AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_bat')
SWEP.Base = 'dbot_tf_bat'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'BAT-SABER'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.MissSoundsScript = 'Weapon_BatSaber.Swing'
SWEP.MissCritSoundsScript = 'Weapon_BatSaber.SwingCrit'
SWEP.HitSoundsScript = 'Weapon_BatSaber.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_BatSaber.HitFlesh'
