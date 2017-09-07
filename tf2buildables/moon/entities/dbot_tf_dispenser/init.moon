
--
-- Copyright (C) 2017 DBot
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

include 'shared.lua'
AddCSLuaFile 'shared.lua'
AddCSLuaFile 'cl_init.lua'

ENT.CallDestroy = (attacker = NULL, inflictor = NULL, dmg) => hook.Run('TF2DispenserDestroyed', @, attacker, inflictor, dmg)

ENT.Initialize = =>
	@BaseClass.Initialize(@)
	@healing = {}
	@beams = {}
	@nextAmmo = CurTime()
	@nextChangeUp = CurTime()

ENT.HealTarget = (ent = NULL, delta = 1, cTime = CurTime()) =>
	return if not IsValid(ent)
	hp = ent\Health()
	mhp = ent\GetMaxHealth()
	if hp < mhp
		healAdd = math.Clamp(mhp - hp, 0, delta * @GetRessuplyMultiplier() * @HEAL_SPEED_MULT)
		ent\SetHealth(hp + healAdd)
	return if not ent\IsPlayer()
	return if @nextAmmo > cTime
	deltaGive = DTF2.GiveAmmo(ent, @GetAvaliableForAmmo())
	return if deltaGive == 0
	@SetRessuplyAmount(@GetRessuplyAmount() - deltaGive)

ENT.BehaveUpdate = (delta) =>
	BaseClass.BehaveUpdate(@, delta)
	return if not @IsAvaliable()
	@UpdateRelationships()
	
	@healing = @GetAlliesVisible()
	beam.__isValid = false for ply, beam in pairs @beams

	for ply in *@healing
		if not @beams[ply]
			@beams[ply] = ents.Create('dbot_info_healbeam')
			with @beams[ply]
				\SetBeamType(@GetTeamType())
				\SetEntityTarget(ply)
				\SetPos(@WorldSpaceCenter())
				\Spawn()
				\Activate()
				\SetParent(@)
				\UpdateDummy()
		@beams[ply].__isValid = true

	for ply, beam in pairs @beams
		if not beam.__isValid
			beam\Remove()
			@beams[ply] = nil
	
	cTime = CurTime()
	@HealTarget(ply, delta, cTime) for ply in *@healing
	@nextAmmo = cTime + 1 if @nextAmmo < cTime

ENT.ChargeUp = (force = false) =>
	if @GetRessuplyAmount() >= @GetMaxRessuply() and not force
		@nextChangeUp = CurTime() + @GetChargeTime()
		return
	return if @nextChangeUp > CurTime() and not force
	@nextChangeUp = CurTime() + @GetChargeTime()
	toAdd = math.Clamp(@GetMaxRessuply() - @GetRessuplyAmount(), 0, @GetChargeAmount())
	@SetRessuplyAmount(@GetRessuplyAmount() + toAdd)
	@EmitSound('weapons/dispenser_generate_metal.wav')

ENT.Think = =>
	@BaseClass.Think(@)
	if not @IsAvaliable()
		@nextChangeUp = CurTime() + @GetChargeTime()
	else
		@ChargeUp()
	@NextThink(CurTime() + 0.1)
	return true
