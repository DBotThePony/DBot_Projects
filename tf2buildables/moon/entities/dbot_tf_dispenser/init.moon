
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
	@MoveCategory = @MOVE_DISPENSER

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

ENT.OnPlayerDoMove = =>
	beam\Remove() for ply, beam in pairs @beams
	@beams = {}
