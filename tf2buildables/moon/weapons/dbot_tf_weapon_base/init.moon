
--
-- Copyright (C) 2017-2018 DBot

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


include 'shared.lua'
AddCSLuaFile 'shared.lua'
AddCSLuaFile 'cl_init.lua'

util.AddNetworkString('DTF2.SendWeaponAnim')
util.AddNetworkString('DTF2.SendWeaponSequence')

SWEP.SendWeaponAnim2 = (act = ACT_INVALID) =>
	return if not IsValid(@GetOwner()) or not @GetOwner()\IsPlayer()
	--hands = @GetOwner()\GetHands()
	--seqId = hands\SelectWeightedSequence(act)
	--hands\ResetSequence(seqId) if seqId
	net.Start('DTF2.SendWeaponAnim')
	net.WriteUInt(act, 16)
	net.Send(@GetOwner())

SWEP.SendWeaponSequence = (seq = 0) =>
	return if not IsValid(@GetOwner()) or not @GetOwner()\IsPlayer()
	hands = @GetOwner()\GetViewModel()
	return if not IsValid(hands)
	oseq = seq
	seq = hands\LookupSequence(seq) if type(seq) ~= 'number'
	print("[DTF2] Starting unknown sequence #{oseq} for #{@GetClass()} on #{@ViewModel}!") if seq == -1
	hands\SendViewModelMatchingSequence(seq)
	net.Start('DTF2.SendWeaponSequence')
	net.WriteUInt(seq, 16)
	net.Send(@GetOwner())

SWEP.EmitSoundServerside = (...) =>
	SuppressHostEvents(NULL) if @suppressing
	@EmitSound(...)
	SuppressHostEvents(@GetOwner()) if @suppressing

SWEP.WaitForSoundSuppress = (soundPlay, time = 0, callback = (->)) =>
	timer.Create "DTF2.WeaponSound.#{@EntIndex()}", time, 1, ->
		return if not IsValid(@)
		return if not IsValid(@GetOwner())
		return if @GetOwner()\GetActiveWeapon() ~= @
		SuppressHostEvents(@GetOwner())
		@EmitSound(soundPlay)
		SuppressHostEvents(NULL)
		callback()

SWEP.CheckCritical = =>
	return if not @RandomCriticals
	return if @GetNextCrit()
	return if @lastCritsTrigger > CurTime()
	return if @lastCritsCheck > CurTime()
	@lastCritsCheck = CurTime() + @CritsCheckCooldown if @CritsCheckCooldown ~= 0
	chance = @CritChance + math.min(@CritExponent * @damageDealtForCrit, @CritExponentMax)
	if math.random(1, 100) < chance
		@TriggerCriticals()

SWEP.TriggerCriticals = =>
	return if not @RandomCriticals
	return if @lastCritsTrigger > CurTime()
	@damageDealtForCrit = 0
	@lastCritsTrigger = CurTime() + @CritsCooldown
	@SetNextCrit(true)
	if not @SingleCrit
		@lastCritsTrigger = CurTime() + @CritDuration + @CritsCooldown
		@SetCriticalsDuration(CurTime() + @CritDuration)
		timer.Create "DTF2.CriticalsTimer.#{@EntIndex()}", @CritDuration, 1, ->
			@SetNextCrit(false) if @IsValid()

SWEP.OnKilled = (victim = NULL, dmginfo = @lastDMGDealed) =>

hook.Add 'OnNPCKilled', 'DTF2.WeaponTrigger', (npc = NULL, attacker = NULL, weapon = NULL) ->
	return if not IsValid(weapon)
	return if not weapon.IsTF2Weapon
	return if not weapon.OnKilled
	weapon\OnKilled(npc)

hook.Add 'DoPlayerDeath', 'DTF2.WeaponTrigger', (ply = NULL, attacker = NULL, dmginfo) ->
	weapon = dmginfo\GetInflictor()
	return if not IsValid(weapon)
	return if not weapon.IsTF2Weapon
	return if not weapon.OnKilled
	weapon\OnKilled(ply, dmginfo)

return nil
