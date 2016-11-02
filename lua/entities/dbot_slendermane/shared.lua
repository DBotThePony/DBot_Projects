
--[[
Copyright (C) 2016 DBot

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

ENT.Type = 'anim'
ENT.PrintName = 'Slendermane'
ENT.Author = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.IsSlendermane = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'Frags')
	self:NetworkVar('Int', 1, 'PFrags')
	self:NetworkVar('Bool', 0, 'IsAttacking')
	self:NetworkVar('Entity', 0, 'MyVictim')
end

function ENT:Initialize()
	self.LastMove = 0
	self.JumpTries = 0
	self.CurrentVictimTimer = 0
	self.WATCHING_AT_ME_FOR = 0
	
	self:SetModel('models/ppm/player_default_base.mdl')
	self:SetSequence(self:LookupSequence('idle_all_01'))
	
	if SERVER then
		self:PhysicsInitBox(Vector(-16, -16, 0), Vector(16, 16, 60))
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	else
		self:SetPlaybackRate(2)
	end
	
	self.LastFrame = CurTime()
	
	if CLIENT then
		timer.Simple(0.5, function()
			for k, v in ipairs(self:GetBodyGroups()) do
				self:SetBodygroup(v.id, math.random(1, v.num))
			end
		end)
	end
end
