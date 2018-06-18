
--
-- Copyright (C) 2017-2018 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

DEFINE_BASECLASS 'dbot_tf_build_base'
AddCSLuaFile()

ENT.Base = 'dbot_tf_build_base'
ENT.Type = 'nextbot'
ENT.PrintName = 'Sentry gun'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBot'
ENT.Category = 'TF2'

ENT.BuildModel1 = 'models/buildables/sentry1_heavy.mdl'
ENT.IdleModel1 = 'models/buildables/sentry1.mdl'
ENT.BuildModel2 = 'models/buildables/sentry2_heavy.mdl'
ENT.IdleModel2 = 'models/buildables/sentry2.mdl'
ENT.BuildModel3 = 'models/buildables/sentry3_heavy.mdl'
ENT.IdleModel3 = 'models/buildables/sentry3.mdl'

ENT.ROCKET_SOUND = 'weapons/sentry_rocket.wav'

ENT.BuildTime = CreateConVar('tf_sentry_build', '10', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry buildup time')

ENT.SENTRY_ANGLE_CHANGE_MULT = CreateConVar('tf_dbg_sentry_angle', '66', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry angle change multiplier')
ENT.SENTRY_SCAN_YAW_MULT = CreateConVar('tf_dbg_sentry_scan_m', '50', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry scan multiplier')
ENT.SENTRY_SCAN_YAW_CONST = CreateConVar('tf_dbg_sentry_scan_c', '45', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry scan constant')

ENT.IDLE_ANIM = 'idle_off'

ENT.MAX_DISTANCE = CreateConVar('tf_dbg_sentry_range', '1100', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry targeting range')

ENT.MAX_AMMO_1 = CreateConVar('tf_sentry_ammo1', '150', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Maximal amount of lvl 1 sentry ammo')
ENT.MAX_AMMO_2 = CreateConVar('tf_sentry_ammo2', '200', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Maximal amount of lvl 2 sentry ammo')
ENT.MAX_AMMO_3 = CreateConVar('tf_sentry_ammo3', '200', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Maximal amount of lvl 3 sentry ammo')
ENT.MAX_ROCKETS = CreateConVar('tf_sentry_rockets', '20', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Maximal amount of lvl 3 sentry rockets')
ENT.AMMO_RESTORE_ON_HIT = CreateConVar('tf_dbg_ammo_restore', '75', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Ammo restored on wrench hit')
ENT.ROCKETS_RESTORE_ON_HIT = CreateConVar('tf_dbg_rockets_restore', '5', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Rockets restored on wrench hit')

ENT.BULLET_DAMAGE = CreateConVar('tf_dbg_sentry_damage', '12', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry bullets damage')
ENT.BULLET_RELOAD_1 = CreateConVar('tf_dbg_sentry_reload1', '0.3', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry bullets reload time')
ENT.BULLET_RELOAD_2 = CreateConVar('tf_dbg_sentry_reload2', '0.1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry bullets reload time')
ENT.BULLET_RELOAD_3 = CreateConVar('tf_dbg_sentry_reload3', '0.1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry bullets reload time')
ENT.ROCKETS_RELOAD = CreateConVar('tf_dbg_sentry_reloadr', '5', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Sentry rockets reload time')
ENT.ROCKETS_RELOAD_ANIM = 2.75

ENT.ATTACK_ANIM_1 = 0.35
ENT.ATTACK_ANIM_2 = 0.3
ENT.ROCKET_CLASS = 'dbot_sentry_rocket'

ENT.GetBulletAnimTime = (level = @GetLevel()) =>
	switch level
		when 1
			return @ATTACK_ANIM_1
		when 2, 3
			return @ATTACK_ANIM_2

ENT.Gibs1 = {
	'models/buildables/gibs/sentry1_gib1.mdl'
	'models/buildables/gibs/sentry1_gib2.mdl'
	'models/buildables/gibs/sentry1_gib3.mdl'
	'models/buildables/gibs/sentry1_gib4.mdl'
}

ENT.Gibs2 = {
	'models/buildables/gibs/sentry2_gib1.mdl'
	'models/buildables/gibs/sentry2_gib2.mdl'
	'models/buildables/gibs/sentry2_gib3.mdl'
	'models/buildables/gibs/sentry2_gib4.mdl'
}

ENT.Gibs3 = {
	'models/buildables/gibs/sentry2_gib1.mdl'
	'models/buildables/gibs/sentry2_gib2.mdl'
	'models/buildables/gibs/sentry2_gib3.mdl'
	'models/buildables/gibs/sentry2_gib4.mdl'
	'models/buildables/gibs/sentry3_gib1.mdl'
}

ENT.GibsValue = CreateConVar('tf_sentry_gibs', '15', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Gibs value for sentry')

ENT.ExplosionSound = 'DTF2_Building_Sentry.Explode'

ENT.Gibs = (level = @GetLevel()) =>
	switch level
		when 1
			@Gibs1
		when 2
			@Gibs2
		when 3
			@Gibs3

ENT.GetReloadTime = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabFloat(@BULLET_RELOAD_1)
		when 2
			DTF2.GrabFloat(@BULLET_RELOAD_2)
		when 3
			DTF2.GrabFloat(@BULLET_RELOAD_3)

ENT.GetAmmoPercent = (level = @GetLevel()) => @GetAmmoAmount() / @GetMaxAmmo()
ENT.GetRocketsPercent = => @GetRockets() / DTF2.GrabInt(@MAX_ROCKETS)
ENT.GetMaxAmmo = (level = @GetLevel()) =>
	switch level
		when 1
			DTF2.GrabInt(@MAX_AMMO_1)
		when 2
			DTF2.GrabInt(@MAX_AMMO_2)
		when 3
			DTF2.GrabInt(@MAX_AMMO_3)

ENT.SetupDataTables = =>
	BaseClass.SetupDataTables(@)
	@NetworkVar('Int', 2, 'AimPitch')
	@NetworkVar('Int', 3, 'AimYaw')
	@NetworkVar('Int', 4, 'AmmoAmount')
	@NetworkVar('Int', 5, 'Rockets')
	@NetworkVar('Int', 6, 'Kills')
	@anglesUpdated = false
	@SetKills(0)

ENT.UpdateSequenceList = =>
	BaseClass.UpdateSequenceList(@)
	@fireSequence = @LookupSequence('fire')
	@muzzle = @LookupAttachment('muzzle')
	@muzzle_l = @LookupAttachment('muzzle_l')
	@muzzle_r = @LookupAttachment('muzzle_r')

ENT.CustomRepair = (thersold = 200, simulate = CLIENT) =>
	return 0 if thersold == 0
	weight = 0
	rockets = 0
	ammo = 0
	ammo = math.Clamp(math.min((@GetMaxAmmo() - @GetAmmoAmount()) * 0.25, DTF2.GrabInt(@AMMO_RESTORE_ON_HIT) * 0.25), 0, thersold - weight)
	rockets = math.Clamp(math.min(DTF2.GrabInt(@MAX_ROCKETS) - @GetRockets(), DTF2.GrabInt(@ROCKETS_RESTORE_ON_HIT)) * 2, 0, thersold - weight) if @GetLevel() == 3
	rockets -= 1 if math.floor(rockets / 2) ~= rockets / 2
	weight += math.ceil(ammo)
	weight += rockets
	@SetAmmoAmount(@GetAmmoAmount() + math.floor(ammo * 4)) if not simulate
	@SetRockets(@GetRockets() + rockets / 2) if not simulate
	return weight
