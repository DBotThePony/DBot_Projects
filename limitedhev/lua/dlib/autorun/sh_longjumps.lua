
-- Copyright (C) 2016-2019 DBot

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

local _CreateConVar = CreateConVar

local function CreateConVar(name, def, desc)
	return _CreateConVar(name, def, CLIENT and FCVAR_REPLICATED or {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, desc)
end

local CHAN = CHAN_USER_BASE + 16

sound.Add({
	name = 'LimitedHEV.LongJump',
	channel = CHAN,
	volume = 0.5,
	level = 80,
	pitch = 100,
	sound = {'bms/jumpmod_boost1.wav', 'bms/jumpmod_boost2.wav'}
})

sound.Add({
	name = 'LimitedHEV.LongJumpDeny',
	channel = CHAN + 1,
	volume = 0.5,
	level = 80,
	pitch = 100,
	sound = 'bms/jumpmod_deny.wav'
})

sound.Add({
	name = 'LimitedHEV.LongJumpReady',
	channel = CHAN + 2,
	volume = 0.5,
	level = 80,
	pitch = 100,
	sound = 'bms/jumpmod_ready.wav'
})

sound.Add({
	name = 'LimitedHEV.JumpBreak',
	channel = CHAN + 3,
	volume = 0.5,
	level = 80,
	pitch = 100,
	sound = 'bms/jumpmod_break.wav'
})

sound.Add({
	name = 'LimitedHEV.LongJumpPickup',
	channel = CHAN + 4,
	volume = 0.8,
	level = 80,
	pitch = 100,
	sound = 'bms/jumpmod_pickup.wav'
})

local ENABLED = CreateConVar('sv_longjump_enabled', '1', 'Enable Long Jump from LimitedHEV addon')
local POWER = CreateConVar('sv_longjump_power', '1', 'Power multiplier of Long Jump')
local MAX_AMOUNT = CreateConVar('sv_longjump_amount', '3', 'Long Jump amount')
local COOLDOWN = CreateConVar('sv_longjump_cooldown', '5', 'Long Jump recharge time in seconds')

local BANK = DLib.PredictedVarList('limitedhev_longjump')
	:AddVar('key', 0)
	:AddVar('ground', false)
	:AddVar('jump', MAX_AMOUNT:GetInt(3))
	:AddVar('recharging', false)
	:AddVar('jumpbreak', false)
	:AddVar('next', 0)
	:AddVar('start', 0)

local plyMeta = FindMetaTable('Player')

function plyMeta:LimitedHEVSyncJump()
	return BANK:Sync(self)
end

function plyMeta:LimitedHEVGetMaxJump()
	return self:GetNWUInt('limitedhev.maxjump', MAX_AMOUNT:GetInt(3):abs())
end

function plyMeta:LimitedHEVSetMaxJump(maxValue)
	return self:SetNWUInt('limitedhev.maxjump', maxValue)
end

function plyMeta:LimitedHEVResetMaxJump()
	return self:LimitedHEVSetMaxJump(MAX_AMOUNT:GetInt(3):abs())
end

function plyMeta:LimitedHEVResetJump()
	BANK:Set(self, 'key', 0)
	BANK:Set(self, 'ground', false)
	BANK:Set(self, 'jump', MAX_AMOUNT:GetInt(3))
	BANK:Set(self, 'recharging', false)
	BANK:Set(self, 'jumpbreak', false)
	BANK:Set(self, 'next', 0)
	BANK:Set(self, 'start', 0)
end

function plyMeta:LimitedHEVGetJump()
	return BANK:Get(self, 'jump')
end

function plyMeta:LimitedHEVNextJumpRecharge()
	return BANK:Get(self, 'next')
end

function plyMeta:LimitedHEVJumpRechargeProgress()
	return CurTime():progression(BANK:Get(self, 'start'), BANK:Get(self, 'next'))
end

function plyMeta:LimitedHEVIsJumpRecharging()
	return BANK:Get(self, 'recharging')
end

function plyMeta:IsLongJumpModuleEquipped()
	return self:GetNWBool('limitedhev.longjump', false)
end

if SERVER then
	function plyMeta:EquipLongJumpModule()
		if self:IsLongJumpModuleEquipped() then return end
		self:EmitSound('LimitedHEV.LongJumpPickup')
		self:SetNWBool('limitedhev.longjump', true)
	end

	function plyMeta:RemoveLongJumpModule()
		self:SetNWBool('limitedhev.longjump', false)
	end
end

local function SetupMove(ply, movedata)
	if ply:GetMoveType() ~= MOVETYPE_WALK then return end
	if not ply:IsLongJumpModuleEquipped() then return end

	local onground = ply:OnGround()
	local water = ply:WaterLevel() <= 0
	local jump = movedata:KeyPressed(IN_JUMP)
	local invalidated = false

	if BANK:Get(ply, 'recharging') and BANK:Get(ply, 'next') < CurTime() then
		BANK:Invalidate(ply)
		invalidated = true

		BANK:Set(ply, 'jump', BANK:Get(ply, 'jump') + 1)
		ply:EmitSoundPredicted('LimitedHEV.LongJumpReady')

		if ply:LimitedHEVGetMaxJump() <= BANK:Get(ply, 'jump') then
			BANK:Set(ply, 'recharging', false)
		else
			BANK:Set(ply, 'next', CurTime() + COOLDOWN:GetFloat())
			BANK:Set(ply, 'start', CurTime())
		end
	end

	if not onground and not BANK:Get(ply, 'jumpbreak') and movedata:KeyPressed(IN_BACK) then
		if not invalidated then
			BANK:Invalidate(ply)
			invalidated = true
		end

		BANK:Set(ply, 'jumpbreak', true)
		ply:EmitSoundPredicted('LimitedHEV.JumpBreak')
	end

	if not movedata:KeyPressed(IN_JUMP) or not water then return end

	if not invalidated then
		BANK:Invalidate(ply)
	end

	if onground then
		BANK:Set(ply, 'key', 0)
		BANK:Set(ply, 'ground', true)
		BANK:Set(ply, 'jumpbreak', true)
	end

	BANK:Set(ply, 'key', BANK:Get(ply, 'key') + 1)

	if BANK:Get(ply, 'key') >= 2 and BANK:Get(ply, 'ground') then
		if BANK:Get(ply, 'jump') > 0 then
			local ang = ply:EyeAngles()
			ang.p = (-ang.p):max(-3, 7) * -1
			ang.r = 0

			local old = movedata:GetVelocity()
			old.z = old.z:abs():sqrt() * (old.z < 0 and -1 or 1)
			local vel = ang:Forward() * POWER:GetFloat() * 900

			movedata:SetVelocity(old + vel)

			BANK:Set(ply, 'ground', false)
			BANK:Set(ply, 'jumpbreak', false)
			BANK:Set(ply, 'jump', BANK:Get(ply, 'jump') - 1)

			if not BANK:Get(ply, 'recharging') then
				BANK:Set(ply, 'recharging', true)
				BANK:Set(ply, 'next', CurTime() + COOLDOWN:GetFloat())
				BANK:Set(ply, 'start', CurTime())
			end

			ply:EmitSoundPredicted('LimitedHEV.LongJump')
		else
			ply:EmitSoundPredicted('LimitedHEV.LongJumpDeny')
		end
	end
end

hook.Add('SetupMove', 'LimitedHEV_LongJump', SetupMove)

local ENT = {}

ENT.PrintName = 'Long Jump module'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = false
ENT.Author = 'DBotThePony'
ENT.Type = 'anim'

if SERVER then
	function ENT:Initialize()
		self:SetModel('models/weapons/w_longjump_mp.mdl')
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end

		self:SetTrigger(true)

		self:SetCustomCollisionCheck(true)
		--self.nextequip = false
		--self.nextequip_ply = NULL
	end

	function ENT:StartTouch(ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		if ent:IsLongJumpModuleEquipped() or not ent:IsSuitEquipped() then return end

		if hook.Run('PlayerCanPickupItem', ent, self) == false then return end

		SafeRemoveEntity(self)

		ent:SendLua([[hook.Run("HUDItemPickedUp", "dbot_longjump_module")]])
		ent:EquipLongJumpModule()
	end
else
	function ENT:Initialize()
		self:SetCustomCollisionCheck(true)
	end
end

hook.Add('ShouldCollide', 'LongJumpModule', function(ent1, ent2)
	if ent1:GetClass() ~= 'dbot_longjump_module' and ent2:GetClass() ~= 'dbot_longjump_module' then return end
	if not ent1:IsPlayer() and not ent2:IsPlayer() then return end

	--[[local ply = ent1:IsPlayer() and ent1 or ent2

	if SERVER and not ply:IsLongJumpModuleEquipped() and ply:IsSuitEquipped() then
		(ent1:IsPlayer() and ent2 or ent1):EquipOnNextFrame(ply)
	end]]

	return false
end)

scripted_ents.Register(ENT, 'dbot_longjump_module')
