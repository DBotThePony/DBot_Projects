
--
-- Copyright (C) 2017-2019 DBot

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

net.Receive 'DTF2.SendWeaponAnim', ->
	act = net.ReadUInt(16)
	wep = LocalPlayer()\GetActiveWeapon()
	return if not IsValid(wep)
	return if not wep.SendWeaponAnim2
	wep\SendWeaponAnim2(act)

net.Receive 'DTF2.SendWeaponSequence', ->
	act = net.ReadUInt(16)
	wep = LocalPlayer()\GetActiveWeapon()
	return if not IsValid(wep)
	return if not wep.SendWeaponSequence
	wep\SendWeaponSequence(act)

SWEP.SendWeaponSequence = (seq = 0) =>
	return if not IsValid(@GetOwner())
	hands = @GetOwner()\GetViewModel()
	return if not IsValid(hands)
	oseq = seq
	seq = hands\LookupSequence(seq) if type(seq) ~= 'number'
	print("[DTF2] Starting unknown sequence #{oseq} for #{@GetClass()} on #{@ViewModel}!") if seq == -1
	hands\SendViewModelMatchingSequence(seq)

SWEP.SendWeaponAnim2 = (act = ACT_INVALID) =>
	return if not IsValid(@GetOwner())
	hands = @GetOwner()\GetHands()
	return if not IsValid(hands)
	seqId = hands\SelectWeightedSequence(act)
	hands\ResetSequence(seqId) if seqId

SWEP.PostDrawViewModel = (viewmodel = NULL, weapon = NULL, ply = NULL) =>
	return if @GetHideVM()
	return if not IsValid(@GetTF2WeaponModel())
	@GetTF2WeaponModel()\DrawModel()

SWEP.WaitForSoundSuppress = (soundPlay, time = 0, callback = (->)) =>
	timer.Create "DTF2.WeaponSound.#{@EntIndex()}", time, 1, ->
		return if not IsValid(@)
		return if not IsValid(@GetOwner())
		return if @GetOwner()\GetActiveWeapon() ~= @
		@EmitSound(soundPlay)
		callback()
