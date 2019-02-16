
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


export DTF2
DTF2 = DTF2 or {}

if SERVER
	util.AddNetworkString('DTF2.MetalEffect')
else
	net.Receive 'DTF2.MetalEffect', (len = 0, ply = NULL) ->
		hook.Run 'DTF2.MetalEffect', net.ReadBool(), net.ReadUInt(16)

plyMeta = FindMetaTable('Player')

DTF2.MAX_METAL = CreateConVar('tf_max_metal', '200', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Max metal per player')
DTF2.INFINITY_METAL = CreateConVar('tf_infinity_metal', '0', {FCVAR_REPLICARED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Whatever ANY operation consumes metal')

PlayerClass =
	GetMaxTF2Metal: => @GetNWInt('DTF2.MaxMetal', DTF2.MAX_METAL\GetInt())
	MaxTF2Metal: => @GetNWInt('DTF2.MaxMetal', DTF2.MAX_METAL\GetInt())
	SetMaxTF2Metal: (amount = DTF2.MAX_METAL\GetInt()) => @SetNWInt('DTF2.MaxMetal', amount)
	ResetMaxTF2Metal: => @SetNWInt('DTF2.MaxMetal', DTF2.MAX_METAL\GetInt())
	ResetTF2Metal: => @SetNWInt('DTF2.Metal', DTF2.MAX_METAL\GetInt())
	GetTF2Metal: => @GetNWInt('DTF2.Metal')
	SetTF2Metal: (amount = @GetTF2Metal()) => @SetNWInt('DTF2.Metal', amount)
	AddTF2Metal: (amount = 0) => @SetNWInt('DTF2.Metal', @GetTF2Metal() + amount)
	ReduceTF2Metal: (amount = 0) => @SetNWInt('DTF2.Metal', @GetTF2Metal() - amount)
	RemoveTF2Metal: => @SetNWInt('DTF2.Metal', 0)
	HasTF2Metal: (amount = 0) => @GetTF2Metal() >= amount
	CanAffordTF2Metal: (amount = 0) => @SimulateTF2MetalRemove(amount, false, false) == amount
	AffordAndSimulateTF2Metal: (amount = 0, display = true) =>
		newAmount = @SimulateTF2MetalRemove(amount, false, false)
		return false if newAmount ~= amount
		@SimulateTF2MetalRemove(amount, true, display)
		return true
	SimulateTF2MetalRemove: (amount = 0, apply = true, display = apply) =>
		return 0 if @GetTF2Metal() <= 0
		oldMetal = @GetTF2Metal()
		newMetal = math.Clamp(oldMetal - amount, 0, @GetMaxTF2Metal())
		@SetTF2Metal(newMetal) if apply and not DTF2.INFINITY_METAL\GetBool()
		if SERVER and display
			net.Start 'DTF2.MetalEffect'
			net.WriteBool false
			net.WriteUInt oldMetal - newMetal, 16
			net.Send @
		return oldMetal - newMetal
	SimulateTF2MetalAdd: (amount = 0, apply = true, playSound = apply, display = apply) =>
		return 0 if @GetTF2Metal() >= @GetMaxTF2Metal()
		oldMetal = @GetTF2Metal()
		newMetal = math.Clamp(oldMetal + amount, 0, @GetMaxTF2Metal())
		@SetTF2Metal(newMetal) if apply
		@EmitSound('items/ammo_pickup.wav', 50, 100, 0.7) if playSound
		if SERVER and display
			net.Start 'DTF2.MetalEffect'
			net.WriteBool true
			net.WriteUInt newMetal - oldMetal, 16
			net.Send @
		return newMetal - oldMetal

plyMeta[k] = v for k, v in pairs PlayerClass

if SERVER
	hook.Add 'PlayerSpawn', 'DTF2.Metal', =>
		@ResetTF2Metal()
		@ResetMaxTF2Metal()
