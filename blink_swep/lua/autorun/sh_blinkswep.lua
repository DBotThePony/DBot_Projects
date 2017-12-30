
--m_Blink_SWEP
--Modern Blink SWEP
--[[
Copyright (C) 2016-2018 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local ATTACK_DELAY = CreateConVar('sv_blink_delay', '3', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'How long blink swep takes to reload')
local DEPLOY_DELAY = CreateConVar('sv_blink_deploy', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'How long blink swep takes to deploy')
local MAX_DISTANCE = CreateConVar('sv_blink_distance', '10', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Max distance (in meters)')
local TIME_PREPARE = CreateConVar('sv_blink_prepare', '0.2', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Delay between fire and blink')
local TRACE_MODE = CreateConVar('sv_blink_mode', '0', {FCVAR_ARCHIVE, FCVAR_REPLICATED}, 'Trace mode - 0 is hull (blink), 1 is line (teleport)')

if SERVER then
	util.AddNetworkString('dbot_blink.start')
	util.AddNetworkString('dbot_blink.finish')
end

if CLIENT then
	net.Receive('dbot_blink.start', function()
		local wep = net.ReadEntity()
		if not IsValid(wep) then return end
		wep.Jumping = true
		wep.JumpTime = CurTime() + net.ReadFloat() --I don't trust replicated convars
	end)

	net.Receive('dbot_blink.finish', function()
		local wep = net.ReadEntity()
		if not IsValid(wep) then return end
		wep.Jumping = false
		wep.NextJump = CurTime() + net.ReadFloat() --I don't trust replicated convars
	end)
end

local SWEP = {}

SWEP.Author = 'DBot'
SWEP.PrintName = 'Blink SWEP'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.Category = 'Other'
SWEP.UseHands = false
SWEP.WorldModel = 'models/props_junk/cardboard_box004a.mdl'
SWEP.ViewModel = 'models/weapons/c_arms.mdl'

SWEP.Primary = {}
SWEP.Primary.Ammo = 'none'
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic  = false

SWEP.DrawAmmo = false --I think that custom HUDs (for example, my DHUD, and should be default one) must check Clip Sizes to know draw ammo or not

SWEP.Secondary = SWEP.Primary
SWEP.DeployTime = 0
SWEP.NextJump = 0
SWEP.JumpTime = 0

local METRIC_CONV_VAL = 40

function SWEP:Holster()
	self.Jumping = false
	if self:GetOwner():IsPlayer() then
		self:GetOwner():DrawViewModel(true)
	end

	return true
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:Deploy()
	self.Jumping = false
	self.DeployTime = CurTime() + DEPLOY_DELAY:GetFloat()
	if self:GetOwner():IsPlayer() then
		self:GetOwner():DrawViewModel(false)
	end

	return true
end

function SWEP:NetMessage()
	if not self:GetOwner():IsPlayer() then return end
	net.Start 'dbot_blink.start'
	net.WriteEntity(self)
	net.WriteFloat(TIME_PREPARE:GetFloat())
	net.Send(self:GetOwner())
end

function SWEP:NetMessageFinish()
	if not self:GetOwner():IsPlayer() then return end
	net.Start 'dbot_blink.finish'
	net.WriteEntity(self)
	net.WriteFloat(ATTACK_DELAY:GetFloat())
	net.Send(self:GetOwner())
end

function SWEP:Trace()
	local ply = self:GetOwner()
	local tr
	local pos = ply:GetPos()
	local eyes = ply:EyePos()
	local ang = ply:EyeAngles()
	local fwd = ang:Forward()

	local H = eyes.z - pos.z

	local filter = {ply}

	if ply:IsPlayer() and ply:InVehicle() and IsValid(ply:GetVehicle()) then
		table.insert(filter, ply:GetVehicle())
	end

	if SERVER and ply:IsPlayer() then
		ply:LagCompensation(true)
	end

	if TRACE_MODE:GetBool() then
		tr = util.TraceLine{
			filter = filter,
			start = eyes - fwd * 2,
			endpos = eyes + fwd * MAX_DISTANCE:GetFloat() * METRIC_CONV_VAL
		}
	else
		local Mins, Maxs = ply:OBBMins(), ply:OBBMaxs()

		tr = util.TraceHull{
			filter = filter,
			start = eyes - fwd * 2,
			endpos = eyes + fwd * MAX_DISTANCE:GetFloat() * METRIC_CONV_VAL,
			mins = Mins,
			maxs = Maxs
		}

		tr.HitPos = tr.HitPos + tr.HitNormal * 4
	end

	if SERVER and ply:IsPlayer() then
		ply:LagCompensation(false)
	end

	return tr
end

local NOT_READY = Color(200, 200, 200)
local RED = Color(255, 110, 110)
local FIRING = Color(63, 192, 255)
local READY = Color(117, 255, 250)

function SWEP:DrawHUD()
	local x, y = ScrW() / 2 - 60, ScrH() / 2 + 40

	local cTime = CurTime()
	local hit = false

	if self.DeployTime > cTime then
		draw.RoundedBox(4, x, y, 120, 20, NOT_READY)
		draw.RoundedBox(4, x, y, 120 - (self.DeployTime - cTime) / DEPLOY_DELAY:GetFloat() * 120, 20, READY)
		hit = true
	end

	if self.JumpTime > cTime then
		draw.RoundedBox(4, x, y, 120, 20, NOT_READY)
		draw.RoundedBox(4, x, y, 120 - (self.JumpTime - cTime) / TIME_PREPARE:GetFloat() * 120, 20, FIRING)
		hit = true
	end

	if self.NextJump > cTime then
		local value = (self.NextJump - cTime) / ATTACK_DELAY:GetFloat() * 120
		draw.RoundedBoxEx(4, x + value, y, 120 - value, 20, READY, false, true, false, true)
		draw.RoundedBoxEx(4, x, y, value, 20, RED, true, false, true, false)
		hit = true
	end

	if not hit then
		local tr = self:Trace()

		local dist = math.floor(tr.HitPos:Distance(LocalPlayer():GetPos()) / METRIC_CONV_VAL * 10) / 10

		draw.DrawText('Distance: ' .. dist .. 'm', 'Trebuchet24', x, y, READY)
	end
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	if self.Jumping then return end
	if self.DeployTime > CurTime() then return end
	if self.NextJump > CurTime() then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if ply:IsPlayer() then
		local can = hook.Run('CanPlayerTeleport', ply, self)
		if can == false then return end
	end

	self.Jumping = true
	self.JumpTime = CurTime() + TIME_PREPARE:GetFloat()
	self:NetMessage()
end

function SWEP:Jump()
	self.Jumping = false
	local ply = self:GetOwner()
	self.NextJump = CurTime() + ATTACK_DELAY:GetFloat()

	if not IsValid(ply) then return end --Owner died before jump
	if CLIENT then return end

	local tr = self:Trace()

	if ply:IsPlayer() then
		local can = hook.Run('PrePlayerTeleport', ply, self, tr)

		if can ~= false then
			if ply:InVehicle() then ply:ExitVehicle() end --ply:SetAllowWeaponsInVehicle(true)
			ply:SetPos(tr.HitPos)
			hook.Run('PostPlayerTeleport', ply, self, tr)
		end
	else
		ply:SetPos(tr.HitPos)
	end

	self:NetMessageFinish()
end

function SWEP:Think()
	if CLIENT then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if self.Jumping then
		if self.JumpTime < CurTime() then
			self:Jump()
		end
	end
end

SWEP.SecondaryAttack = SWEP.PrimaryAttack

weapons.Register(SWEP, 'dbot_blink')