
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
