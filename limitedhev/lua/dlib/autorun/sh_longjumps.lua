
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
local DELAY = CreateConVar('sv_longjump_delay', '0.2', 'Delay between two Long Jumps in seconds')

local plyMeta = FindMetaTable('Player')

--[[local function Define(name, mtype, def)
	plyMeta['Get' .. name] = function(self)
		return self['GetNW2' .. mtype](self, name, def)
	end

	plyMeta['Set' .. name] = function(self, val)
		return self['SetNW2' .. mtype](self, name, val)
	end

	plyMeta['Reset' .. name] = function(self)
		return self['SetNW2' .. mtype](self, name, def)
	end
end]]

local BANK = DLib.PredictedVarList('LongJumps')

local function Define(name, mtype, def)
	BANK:AddVar(name, def)
end

Define('LongJumpKey', 'Int', 0)
Define('LongJumpCount', 'Int', 3)
Define('LongJumpNextR', 'Float', 0)
Define('LongJumpStartR', 'Float', 0)
Define('LongJumpDelay', 'Float', 0)
Define('LongJumpGround', 'Bool', false)
Define('LongJumpIsRecharging', 'Bool', false)
Define('LongJumpBreak', 'Bool', false)

BANK:RegisterMeta('PredictLongJump', 'SyncLongJump')

function plyMeta:GetMaxLongJumps()
	return self:GetNWUInt('limitedhev.maxjumps', MAX_AMOUNT:GetInt(3):abs())
end

function plyMeta:SetMaxLongJumps(maxValue)
	return self:SetNWUInt('limitedhev.maxjumps', maxValue)
end

function plyMeta:ResetMaxLongJumps()
	return self:SetMaxLongJumps(MAX_AMOUNT:GetInt(3):abs())
end

function plyMeta:ResetLongJumpValues()
	self:ResetLongJumpKey()
	self:ResetLongJumpCount()
	self:ResetLongJumpNextR()
	self:ResetLongJumpStartR()
	self:ResetLongJumpDelay()
	self:ResetLongJumpGround()
	self:ResetLongJumpIsRecharging()
	self:ResetLongJumpBreak()
end

function plyMeta:LimitedHEVGetJumps()
	return self:GetLongJumpCount()
end

function plyMeta:LongJumpRechargeProgress()
	return CurTime():progression(self:GetLongJumpStartR(), self:GetLongJumpNextR())
end

function plyMeta:IsLongJumpsModuleEquipped()
	return self:GetNWBool('limitedhev.longjumps', false)
end

if SERVER then
	function plyMeta:EquipLongJumpsModule()
		if self:IsLongJumpsModuleEquipped() then return end
		self:EmitSound('LimitedHEV.LongJumpPickup')
		self:SetNWBool('limitedhev.longjumps', true)
	end

	function plyMeta:RemoveLongJumpsModule()
		self:SetNWBool('limitedhev.longjumps', false)
	end
end

local whut = true

hook.Add('SetupMove', 'movetest', function()
	whut = IsFirstTimePredicted()
end, -9)

local function SetupMove(self, movedata)
	if self:GetMoveType() ~= MOVETYPE_WALK then return end
	if not self:IsLongJumpsModuleEquipped() then return end

	local onground = self:OnGround()
	local water = self:WaterLevel() <= 0
	local jump = movedata:KeyPressed(IN_JUMP)

	if self:GetLongJumpIsRecharging() and self:GetLongJumpNextR() < CurTime() then
		self:PredictLongJump(true)
		self:SetLongJumpCount(self:GetLongJumpCount() + 1)
		self:EmitSoundPredicted('LimitedHEV.LongJumpReady')

		if self:GetMaxLongJumps() <= self:GetLongJumpCount() then
			self:SetLongJumpIsRecharging(false)
		else
			self:SetLongJumpNextR(CurTime() + COOLDOWN:GetFloat())
			self:SetLongJumpStartR(CurTime())
		end
	end

	if not onground and not self:GetLongJumpBreak() and movedata:KeyPressed(IN_BACK) then
		self:SetLongJumpBreak(true)
		self:EmitSoundPredicted('LimitedHEV.JumpBreak')
	end

	if not movedata:KeyPressed(IN_JUMP) or not water then
		self:DLibInvalidatePrediction(false)
		return
	end

	self:DLibInvalidatePrediction(true)
	self:PredictLongJump(true)

	if onground then
		self:SetLongJumpKey(0)
		self:SetLongJumpGround(true)
		self:SetLongJumpBreak(true)
	end

	self:SetLongJumpKey(self:GetLongJumpKey() + 1)

	if self:GetLongJumpKey() >= 2 and self:GetLongJumpGround() then
		if self:GetLongJumpCount() > 0 then
			local ang = movedata:GetAngles()
			ang.p = (-ang.p):max(-3, 7) * -1
			ang.r = 0

			local old = movedata:GetVelocity()
			old.z = old.z:abs():sqrt() * (old.z < 0 and -1 or 1)
			local vel = ang:Forward() * POWER:GetFloat() * 900

			movedata:SetVelocity(old + vel)

			self:SetLongJumpKey(0)
			self:SetLongJumpGround(false)
			self:SetLongJumpBreak(false)
			self:SetLongJumpCount(self:GetLongJumpCount() - 1)
			self:SetLongJumpDelay(CurTime() + DELAY:GetFloat())

			if not self:GetLongJumpIsRecharging() then
				self:SetLongJumpIsRecharging(true)
				self:SetLongJumpNextR(CurTime() + COOLDOWN:GetFloat())
				self:SetLongJumpStartR(CurTime())
			end

			self:EmitSoundPredicted('LimitedHEV.LongJump')
		else
			self:EmitSoundPredicted('LimitedHEV.LongJumpDeny')
		end
	end

	self:DLibInvalidatePrediction(false)
end

hook.Add('SetupMove', 'LimitedHEV_LongJumps', SetupMove)

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
		if ent:IsLongJumpsModuleEquipped() or not ent:IsSuitEquipped() then return end

		if hook.Run('PlayerCanPickupItem', ent, self) == false then return end

		SafeRemoveEntity(self)

		ent:SendLua([[hook.Run("HUDItemPickedUp", "dbot_longjump_module")]])
		ent:EquipLongJumpsModule()
	end
else
	function ENT:Initialize()
		self:SetCustomCollisionCheck(true)
	end
end

hook.Add('ShouldCollide', 'LongJumpsModule', function(ent1, ent2)
	if ent1:GetClass() ~= 'dbot_longjump_module' and ent2:GetClass() ~= 'dbot_longjump_module' then return end
	if not ent1:IsPlayer() and not ent2:IsPlayer() then return end

	--[[local ply = ent1:IsPlayer() and ent1 or ent2

	if SERVER and not ply:IsLongJumpsModuleEquipped() and ply:IsSuitEquipped() then
		(ent1:IsPlayer() and ent2 or ent1):EquipOnNextFrame(ply)
	end]]

	return false
end)

scripted_ents.Register(ENT, 'dbot_longjump_module')
