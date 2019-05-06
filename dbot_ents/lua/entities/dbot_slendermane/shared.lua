
--[[
Copyright (C) 2016-2019 DBotThePony


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
	self:NetworkVar('Float', 0, 'WatchingAtMeFor')
	self:NetworkVar('Bool', 0, 'IsAttacking')
	self:NetworkVar('Bool', 0, 'IsVisible')
	self:NetworkVar('Entity', 0, 'MyVictim')
end

function ENT:Initialize()
	self.LastMove = 0
	self.JumpTries = 0
	self.CurrentVictimTimer = 0
	self.CLOSE_ENOUGH_FOR = 0
	self.IDLE_FOR = 0
	self.CLOSE_ENOUGH_FOR_LAST = CurTimeL()
	self.WATCH_ME_FOR_LAST = CurTimeL()
	self.TARGET_SELECT_COOLDOWN = CurTimeL()
	self.CHASE_STARTED_AT = CurTimeL()

	self:SetModel('models/ppm/player_default_base.mdl')
	self:SetSequence(self:LookupSequence('idle_all_01'))

	if SERVER then
		self:PhysicsInitBox(Vector(-16, -16, 0), Vector(16, 16, 60))
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	else
		self:SetPlaybackRate(2)
	end

	self.LastFrame = CurTimeL()

	if CLIENT then
		timer.Simple(0.5, function()
			for k, v in ipairs(self:GetBodyGroups()) do
				self:SetBodygroup(v.id, math.random(1, v.num))
			end
		end)
	end
end
