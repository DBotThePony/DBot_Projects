
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

if cleanup then
	cleanup.Register('mcswep2blocks')
end

local mc = MCSWEP2

local ENT = {}
ENT.Type = 'point'
ENT.PrintName = 'Choke'
ENT.Author = 'DBot'

function ENT:Think()
	if SERVER and not IsValid(self.block) then self:Remove() end
end

scripted_ents.Register(ENT, 'dbot_mcblock_choke')

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.PrintName = 'Minecraft Block'
ENT.Spawnable = false
ENT.IsMCBlock = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
mc.BLOCK_ENT = ENT

function ENT:SetupDataTables()
	self:NetworkVar('Int', 0, 'BlockID')
	self:NetworkVar('Float', 0, 'HP')
	self:NetworkVar('Float', 1, 'MaxHP')
	self:NetworkVar('Float', 2, 'FallStartZ')
	self:NetworkVar('Float', 3, 'FallEndZ')
	self:NetworkVar('Float', 4, 'FallDivider')
	self:NetworkVar('Float', 5, 'FallStart')
	self:NetworkVar('Float', 6, 'FallEnd')
	self:NetworkVar('Bool', 0, 'IsFalling')
	self:NetworkVar('Entity', 0, 'NWOwner')
end

function ENT:DuplicatorFunc()
	self.NOT_INITALIZED = true

	--Duplicator Support
	timer.Simple(0, function()
		if not IsValid(self) then return end

		if self.NOT_INITALIZED then
			if self:GetBlockID() then
				self:InitializeBlockID(self:GetBlockID())
			elseif self.DUPE_BLOCK_ID then
				self:InitializeBlockID(self.DUPE_BLOCK_ID)
			end
		end
	end)
end

function ENT:Initialize()
	self:DrawShadow(false)

	if CLIENT then return end

	if not self:GetBlockID() then
		self:InitializeBlockID(2)
	end

	self:DuplicatorFunc()

	self.rotatedir = MCSWEP2.ROTATE_SOUTH

	self.REDSTONE_INPUT_BLOCKS = {}
	self.FirstThink = true

	if self:CanChoke() then
		self:ChokeEntity()
	end

	self:SetTrigger(true)
	self:CreateWireOutputs()
end

function ENT:GetBlockHeight()
	return 1
end

function ENT:GetBlockWidth()
	return 1
end

function ENT:Touch(ent)
	self:Hook('Touch', ent)
end

function ENT:StartTouch(ent)
	self:Hook('StartTouch', ent)
end

function ENT:EndTouch(ent)
	self:Hook('EndTouch', ent)
end

function ENT:ChokeEntity()
	self.choke = ents.Create('dbot_mcblock_choke')
	self.choke.block = self
	self.choke:SetParent(self)
	self.choke:Spawn()
	self.choke:Activate()
end

function ENT:BlockUpdate()
	if self.CAN_NOT_BE_UPATED then return end
	self:Hook('BlockUpdate')

	if CLIENT then return end

	net.Start('MCSWEP2.BlockUpdate')
	net.WriteEntity(self)
	net.Broadcast()

	if not self:CanFloat() then
		local block = self:GetBlockAtSide(mc.SIDE_DOWN)

		if not IsValid(block) or not block:IsSolid() then
			self:OnDestruct()
			return
		end
	end

	if self:IsRedstoneActivated() then
		self:RedstoneUpdate()
	end
end

function ENT:TriggerUpdate()
	for k, v in pairs(self:GetConnectedBlocks()) do
		if IsValid(v) then v:BlockUpdate() end
	end
end

function ENT:CanFall()
	return self:GetData().physics
end

function ENT:TraceDown()
	return util.TraceHull{
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0, 0, 6000),
		mins = self:OBBMins() * .7,
		maxs = self:OBBMaxs() * .7,
		filter = function(ent)
			if ent == self then return false end
			if ent:IsPlayer() then return false end
			if ent:IsNPC() then return false end
			return true
		end,
	}
end

function ENT:DownIsFree()
	local tr = util.TraceHull{
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0, 0, mc.STEP - 5),
		mins = self:OBBMins() * .7,
		maxs = self:OBBMaxs() * .7,
		filter = function(ent)
			if ent == self then return false end
			if ent:IsPlayer() then return false end
			if ent:IsNPC() then return false end
			return true
		end,
	}

	return not tr.Hit
end

function ENT:FallSpeedMultipler()
	return 100
end

function ENT:CanGlow()
	return self:GetData().glow
end

function ENT:GlowMultipler()
	return self:GetData().glowmult
end

function ENT:GlowR()
	return self:GetData().glowr
end

function ENT:GlowG()
	return self:GetData().glowg
end

function ENT:GlowB()
	return self:GetData().glowb
end

function ENT:GlowColor()
	local data = self:GetData()
	return data.glowr, data.glowg, data.glowb
end

ENT.GetGlowColor = ENT.GlowColor
ENT.GetGlowR = ENT.GlowR
ENT.GetGlowG = ENT.GlowG
ENT.GetGlowB = ENT.GlowB
ENT.GetGlowMultipler = ENT.GlowMultipler
ENT.GetCanGlow = ENT.CanGlow

function ENT:RedstoneInputStart(block)
	--Override
end

function ENT:RedstoneInputChanged(status)
	--Override
end

function ENT:RedstoneInputEnd(block)
	--Override
end

function ENT:IsRedstoneActivated(norefresh)
	self.REDSTONE_INPUT_BLOCKS = self.REDSTONE_INPUT_BLOCKS or {}
	if not norefresh then self:RedstoneUpdate() end
	return table.Count(self.REDSTONE_INPUT_BLOCKS) ~= 0
end

function ENT:RedstoneUpdate()
	self.REDSTONE_INPUT_BLOCKS = self.REDSTONE_INPUT_BLOCKS or {}

	local count = table.Count(self.REDSTONE_INPUT_BLOCKS)

	local lpos = self:GetPos()

	for k, v in pairs(self.REDSTONE_INPUT_BLOCKS) do
		if not IsValid(v) or v == self then --???
			self.REDSTONE_INPUT_BLOCKS[k] = nil
			continue
		end

		local dist = v:GetPos():Distance(lpos)

		if dist > mc.STEP * 1.3 then
			self.REDSTONE_INPUT_BLOCKS[k] = nil
			continue
		end
	end

	local newcount = table.Count(self.REDSTONE_INPUT_BLOCKS)

	if newcount == 0 and count ~= 0 then
		self:RedstoneInputChanged(false)
	end
end

--Dun't override pleaz
function ENT:RedstoneInput(block, status)
	self.REDSTONE_INPUT_BLOCKS = self.REDSTONE_INPUT_BLOCKS or {}

	self:RedstoneUpdate()

	local count = table.Count(self.REDSTONE_INPUT_BLOCKS)

	if status then
		self:RedstoneInputStart(block)
		self.REDSTONE_INPUT_BLOCKS[block] = block

		if count == 0 then
			self:RedstoneInputChanged(true)
		end
	else
		self:RedstoneInputEnd(block)
		self.REDSTONE_INPUT_BLOCKS[block] = nil

		if count == 1 then
			self:RedstoneInputChanged(false)
		end
	end
end

function ENT:SetProvidesRedstoneSignal(status)
	self.PROVIDES_RESDTSONE_SIGNAL = status

	self:TriggerUpdate()
	self:BlockUpdate()
end

function ENT:ProvidesRedstoneSignal()
	if self.PROVIDES_RESDTSONE_SIGNAL ~= nil then
		return self.PROVIDES_RESDTSONE_SIGNAL
	end

	return self:GetData().redstone
end

function ENT:MakeItFall()
	if self:GetIsFalling() then return end
	self:SetIsFalling(true)

	local lpos = self:GetPos()
	local tr = self:TraceDown()

	self:SetFallStartZ(lpos.z)
	self:SetFallEndZ(tr.HitPos.z)

	self:SetFallDivider((lpos.z - tr.HitPos.z) / self:FallSpeedMultipler())
	self:SetFallStart(CurTimeL())
	self:SetFallEnd(CurTimeL() + self:GetFallDivider())

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:SetupWireConstants()
	for k, v in ipairs(self.DefaultWireOutputs) do
		mc.SafeTriggerOutput(self, v, mc.tonumber(self[v](self)))
	end
end

ENT.DefaultWireOutputs = {
	'CanFall',
	'CanBeFlipped',
	'CanBeRotated',
	'CanGlow',
	'IsOpaque',
	'IsSolid',
	'CanFloat',
	'HaveOwner',
	'CanChoke',
	'GlowR',
	'GlowG',
	'GlowB',
}

--Override
--ENT.CustomWireOutputs = {}

function ENT:CreateWireOutputs()
	local toCreate = table.Copy(self.DefaultWireOutputs)

	if self.CustomWireOutputs then
		for k, v in ipairs(self.CustomWireOutputs) do
			table.insert(toCreate, v)
		end
	end

	self.Outputs = mc.SafeWireOutputs(self, toCreate)
end

local DefaultAngle = Angle()

function ENT:StopFall()
	self:SetIsFalling(false)

	if self:DownIsFree() then
		local startz = self:GetFallStartZ()
		local div = self:GetFallDivider()
		local start = self:GetFallStart()

		self:MakeItFall()

		self:SetFallDivider(self:GetFallDivider() + div)
		self:SetFallStartZ(startz)
		self:SetFallStart(start)
		self:SetFallEnd(start + self:GetFallDivider())

		self:FixedMove()

		return false
	end

	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.phys:EnableMotion(false)
	self:SetAngles(DefaultAngle)
	self:FixedMove()

	self:PreformRotate()

	self:TriggerUpdate()

	return true
end

function ENT:CanFloat()
	return self:GetData().canfloat
end

function ENT:GetFallPosition()
	local lpos = self:GetPos()
	local ctime = CurTimeL()
	local lerp = math.Clamp((self:GetFallEnd() - ctime) / self:GetFallDivider(), 0, 1)

	lpos.z = self:GetFallStartZ() - (self:GetFallStartZ() - self:GetFallEndZ()) * (1 - lerp)

	return lpos, lerp
end

function ENT:FallThink()
	local pos, lerp = self:GetFallPosition()
	if lerp <= 0 then
		self:StopFall()
		self:SetPos(pos)
		self:FixedMove()
	else
		self:SetPos(pos)
	end
end

function ENT:InitializeBlockID(id, keephp, noupdate)
	self:SetBlockID(id)
	self:UpdateData(keephp)
	self.DUPE_BLOCK_ID = id

	--Dun't save this var
	self.NOT_INITALIZED = nil
	if not noupdate then
		self:TriggerUpdate()
		self:BlockUpdate()
	end

	self:SetupWireConstants()
end

function ENT:HaveOwner()
	return self:GetNWOwner() and IsValid(self:GetNWOwner())
end

function ENT:CanBeRemoved(ply)
	if not self:HaveOwner() then return true end

	if not self.CPPICanTool then
		return self:GetNWOwner() == ply
	else
		return self:CPPICanTool(ply, 'remover')
	end
end

function ENT:OnRemove()
	self.CAN_NOT_BE_UPATED = true
	self:TriggerUpdate()
end

function ENT:SetupOwner(ply)
	if not IsValid(ply) then return end

	self:SetNWOwner(ply)
	if self.CPPISetOwner then
		self:CPPISetOwner(ply)
	end

	if ply.AddCleanup then
		ply:AddCleanup('mcswep2blocks', self)
	end
end

function ENT:GetData()
	return MCSWEP2.GetBlockData(self:GetBlockID())
end

function ENT:UpdateModel()
	self:SetModel(self:GetData().model)
end

function ENT:CanBeFlipped()
	return self:GetData().flip
end

function ENT:CanBeRotated()
	return self:GetData().rotate
end

function ENT:SetRotate(dir)
	if not self:CanBeRotated() then return end
	self.rotatedir = dir
	self.DUPE_ROTATE = dir
end

function ENT:SetFlip(flip)
	if not self:CanBeFlipped() then return end
	self.flipped = flip
	self.DUPE_FLIP = flip
end

function ENT:GetRotate()
	return self.rotatedir
end

function ENT:GetFlip()
	return self.flipped
end

local ROTATE_ANGS = mc.ROTATE_ANGLES

function ENT:PreformRotate()
	local ang = self:GetAngles()
	local r = self:GetRotate()
	ang.y = ROTATE_ANGS[r]
	self:SetAngles(ang)
end

function ENT:PreformFlip()
	local flip = self:GetFlip()
	local ang = self:GetAngles()
	local pos = self:GetPos()

	if flip then
		ang.p = -180
		ang.y = -180 + ang.y
		pos.z = pos.z + mc.STEP
	else
		ang.p = 0
	end

	self:SetAngles(ang)
	self:SetPos(pos)
	self:FixedMove()
end

if SERVER then
	local MaxDistThink = (mc.STEP * 1.3) ^ 2

	local ENTS = {}
	local LastUpdate = 0

	timer.Create('MCSWEP2.ChokeEnts', 0.25, 0, function()
		if LastUpdate + 1 < CurTimeL() then
			ENTS = ents.GetAll()
			LastUpdate = CurTimeL()
		end

		local mcblocks = {}

		for k = 1, #ENTS do
			local v = ENTS[k]
			if not v then continue end

			if v.IsMCBlock and v:CanChoke() then
				table.insert(mcblocks, {v, v:GetPos()})
				ENTS[k] = nil
				continue
			end

			if not v.GetSolid or not (v:GetSolid() ~= SOLID_NONE and (v:IsPlayer() or v:IsNPC() or v:GetClass() == 'prop_physics')) then
				ENTS[k] = nil
				continue
			else
				ENTS[k] = {v, v:GetPos()}
			end
		end

		for id, block in ipairs(mcblocks) do
			local hit = false

			for k, ent in pairs(ENTS) do
				if block[2]:DistToSqr(ent[2]) < MaxDistThink then
					hit = true
					break
				end
			end

			block[1].CHOKE_ENABLED = hit
		end
	end)
end

function ENT:IsOpaque()
	return self:GetData().opaque
end

function ENT:IsSolid()
	return self:GetData().solid
end

function ENT:Think()
	if not self.GetBlockID then return end
	self:Hook('Think')

	if SERVER then
		if self.FirstThink then
			self.FirstThink = nil

			if not self:HaveOwner() and self.CPPIGetOwner then
				self:SetupOwner(self:CPPIGetOwner())
			end
		end

		if self:CanFall() then
			if self:DownIsFree() then
				self:MakeItFall()
			end
		end

		if self:GetIsFalling() then
			self:FallThink()
		end

		if self:CanChoke() and self.CHOKE_ENABLED then
			local tr = util.TraceHull{
				mins = self:OBBMins() * .4,
				maxs = self:OBBMaxs() * .4,
				start = self:GetPos(),
				endpos = self:GetPos(),
				filter = function(ent)
					if ent:IsPlayer() then return true end
					if ent:IsNPC() then return true end
					if ent:GetClass() == 'prop_physics' then return true end
					return false
				end
			}

			if IsValid(tr.Entity) then
				local ent = tr.Entity
				if ent:GetMoveType() ~= MOVETYPE_NOCLIP then
					ent:TakeDamage(4, self, self.choke)
				end
			end
		end
	end
end

function ENT:UpdatePhysics()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self.phys = self:GetPhysicsObject()
	self.phys:Sleep()
	self.phys:EnableMotion(false)
end

function ENT:Hook(event, ...)
	MCSWEP2.BlockEvent(self:GetBlockID(), event, self, ...)
end

function ENT:FixedMove()
	self:SetPos(MCSWEP2.SharpVector(self:GetPos()))
end

function ENT:PhysicsCollide(data)
	self:Hook('PhysicsCollide', data)
end

function ENT:OnTakeDamage(dmg)
	self:Hook('OnTakeDamage', dmg)

	self:PlaySound()

	if self.godmode then return end

	local hp = self:GetHP()
	self:SetHP(self:GetHP() - dmg:GetDamage())

	if self:GetHP() <= 0 then
		dmg:SetDamage(dmg:GetDamage() - hp)
		self:OnDestruct(dmg)
	end
end

function ENT:OnDestruct(dmg)
	self:Hook('OnDestruct', dmg)
	self:Sparkles()

	self:Remove()
end

function ENT:Sparkles()
	mc.Sparkles(self:GetPos())
end

local BlockMins, BlockMaxs = Vector(- mc.STEP / 2, - mc.STEP / 2, 0), Vector(mc.STEP / 2, mc.STEP / 2, mc.STEP)

function ENT:DrawLines()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	mc.DrawLines(pos, ang, BlockMins, BlockMaxs)
end

function ENT:HealthPercent()
	return self:GetHP() / self:GetMaxHP()
end

function ENT:UpdateData(keephp)
	self:UpdateModel()
	self:UpdatePhysics()

	self.godmode = not self:GetData().destructable

	if not keephp then
		self:SetMaxHP(self:GetData().health)
		self:SetHP(self:GetMaxHP())
	end
end

function ENT:CanChoke()
	return self:GetData().canchoke
end

function ENT:GetMatType()
	return self:GetData().material
end

function ENT:PlaySound()
	self:EmitSound(MCSWEP2.GetSound(self:GetMatType()))
end

function ENT:PlayPlaceSound()
	self:EmitSound(MCSWEP2.GetPlaceSound(self:GetMatType()))
end

local BlockMins, BlockMaxs = -Vector(mc.STEP, mc.STEP, 0) * .4, Vector(mc.STEP, mc.STEP, 0) * .4

function ENT:GetBlockAtSideByVector(vec)
	local lpos = self:GetPos()
	local add = vec

	local start = lpos + add * mc.STEP * .5
	start.z = start.z + 2

	local tr = util.TraceHull{
		start = start,
		endpos = start + Vector(0, 0, mc.STEP - 2.5),
		mins = BlockMins,
		maxs = BlockMaxs,
		filter = function(ent)
			if ent == self then return false end
			if ent.IsMCBlock then return true end
			return false
		end
	}

	return tr.Entity
end

function ENT:GetBlockAtSide(side)
	side = side or mc.SIDE_FORWARD
	return self:GetBlockAtSideByVector(mc.GetSideVector(side))
end

function ENT:GetConnectedBlocks()
	local t = {}

	for k, side in ipairs(mc.SIDES) do
		t[side] = self:GetBlockAtSide(side)
	end

	return t
end

function ENT:GetNearBlocks()
	local t = {}

	t[mc.SIDE_LEFT] = self:GetBlockAtSide(mc.SIDE_LEFT)
	t[mc.SIDE_RIGHT] = self:GetBlockAtSide(mc.SIDE_RIGHT)
	t[mc.SIDE_FORWARD] = self:GetBlockAtSide(mc.SIDE_FORWARD)
	t[mc.SIDE_BACKWARD] = self:GetBlockAtSide(mc.SIDE_BACKWARD)

	return t
end

MCSWEP2.REPLACE_FOOTSOUND = CreateConVar('sv_mc_footsound', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Replace footstep sounds with MC sounds')

local function EntityEmitSound(data)
	if not IsValid(data.Entity) then return end
	if not data.Entity.IsMCBlock then return end

	if not string.find(data.SoundName, 'impact') then return end
	if not MCSWEP2.HaveImpactSound(data.Entity:GetMatType()) then return end
	data.SoundName = MCSWEP2.GetImpactSound(data.Entity:GetMatType())

	return true
end

hook.Add('EntityEmitSound', 'MCSWEP2.BlockSounds', EntityEmitSound)

if CLIENT then
	include('cl_block.lua')
end

scripted_ents.Register(ENT, 'dbot_mcblock')

mc.Fences = mc.Fences or {}

function mc.RegisterFenceModel(id, baseModel)
	mc.Fences[id] = baseModel
end

function mc.GetFenceModel(id)
	return mc.Fences[id]
end

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.PrintName = 'Minecraft Block'
ENT.Spawnable = false
ENT.Base = 'dbot_mcblock'
ENT.IsMCFence = true
ENT.Suffix = {
	[0] = 'post.mdl',
	[1] = '1side.mdl',
	[2] = '2sides.mdl',
	[3] = '3sides.mdl',
	[4] = '4sides.mdl',
}

function ENT:Initialize()
	self:DrawShadow(false)

	if CLIENT then return end

	self.BaseModel = 'models/mcmodelpack/fences/fence-'

	self:DuplicatorFunc()

	self.FirstThink = true
	self:SetTrigger(true)

	self:SetModel(self.BaseModel .. 'post.mdl')

	self:CreateWireOutputs()
end

function ENT:CanChoke()
	return false
end

function ENT:InitializeBlockID(id, hp, noupdate)
	self:SetBlockID(id)
	self:UpdateData(keephp)
	self.DUPE_BLOCK_ID = id
	self.NOT_INITALIZED = nil

	self.BaseModel = mc.GetFenceModel(id)

	if not noupdate then
		self:TriggerUpdate()
		self:BlockUpdate()
	end

	self:SetupWireConstants()
end

function ENT:SetModelNum(num)
	self:SetModel(self.BaseModel .. self.Suffix[num])
end

function ENT:CanBeRotated()
	return true
end

function ENT:CanBeFlipped()
	return false
end

function ENT:DrawLines()
	mc.DrawLines(self:GetPos(), self:GetAngles(), self:OBBMins(), self:OBBMaxs())
end

local Cases = {
	[mc.SIDE_LEFT .. ' ' .. mc.SIDE_FORWARD] = mc.ROTATE_EAST,
	[mc.SIDE_RIGHT .. ' ' .. mc.SIDE_FORWARD] = mc.ROTATE_SOUTH,
	[mc.SIDE_RIGHT .. ' ' .. mc.SIDE_BACKWARD] = mc.ROTATE_WEST,
	[mc.SIDE_LEFT .. ' ' .. mc.SIDE_BACKWARD] = mc.ROTATE_NORTH,
	[mc.SIDE_LEFT .. ' ' .. mc.SIDE_RIGHT .. ' ' .. mc.SIDE_FORWARD] = mc.ROTATE_EAST,
	[mc.SIDE_RIGHT .. ' ' .. mc.SIDE_FORWARD .. ' ' .. mc.SIDE_BACKWARD] = mc.ROTATE_SOUTH,
	[mc.SIDE_LEFT .. ' ' .. mc.SIDE_FORWARD .. ' ' .. mc.SIDE_BACKWARD] = mc.ROTATE_NORTH,
	[mc.SIDE_LEFT .. ' ' .. mc.SIDE_RIGHT .. ' ' .. mc.SIDE_BACKWARD] = mc.ROTATE_WEST,
}

function ENT:BlockUpdate()
	self.BaseClass.BlockUpdate(self)

	if CLIENT then return end

	if self.CAN_NOT_BE_UPATED then return end
	local id = self:GetBlockID()

	local blocks = self:GetConnectedBlocks()

	local valid = {}

	for k, v in pairs(blocks) do
		if k == mc.SIDE_TOP or k == mc.SIDE_DOWN then continue end
		if IsValid(v) and (v:IsOpaque() or v.IsMCFence) then
			table.insert(valid, {v, k})
		end
	end

	local count = #valid

	--Making cases checks
	if count ~= 0 then
		if count == 1 then
			self:SetAngles(mc.GetSideAngle(valid[1][2]) + Angle(0, -90, 0))
			self:SetModelNum(count)
		elseif count == 2 then
			local t1, t2 = valid[1], valid[2]
			local case1 = t1[2] .. ' ' .. t2[2]
			local case = Cases[case1]

			if case then
				self:SetModel(self.BaseModel .. 'corner.mdl')
				self:SetRotate(case)
				self:PreformRotate()
			else
				self:SetAngles(mc.GetSideAngle(valid[1][2]) + Angle(0, 90, 0))
				self:SetModelNum(count)
			end

		elseif count == 3 then
			local t1, t2, t3 = valid[1], valid[2], valid[3]
			local case1 = t1[2] .. ' ' .. t2[2] .. ' ' .. t3[2]

			local case = Cases[case1]

			if case then
				self:SetRotate(case)
				self:PreformRotate()
			else
				self:SetAngles(mc.GetSideAngle(valid[1][2]) + Angle(0, -90, 0))
			end

			self:SetModelNum(count)
		else
			self:SetModelNum(count)
		end
	else
		self:SetModelNum(0)
	end
end

function ENT:IsOpaque()
	return false
end

scripted_ents.Register(ENT, 'dbot_mcblock_fence')

--Need to create multiblock base

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.PrintName = 'Minecraft Door'
ENT.Spawnable = false
ENT.Base = 'dbot_mcblock'
ENT.IsMCDoor = true
ENT.CustomWireOutputs = {'IsOpen'}

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 10, 'IsOpen')
	self:NetworkVar('Int', 10, 'OpenDirection')
	self.BaseClass.SetupDataTables(self)
end

function ENT:GetBlockHeight()
	return 2
end

function ENT:CanChoke()
	return false
end

function ENT:GetBlockWidth()
	return 1
end

function ENT:CanBeRotated()
	return true
end

function ENT:CanBeFlipped()
	return false
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	if CLIENT then return end
	self:SetIsOpen(false)
	self:SetOpenDirection(mc.SIDE_FORWARD)
	self:SetUseType(SIMPLE_USE)

	self.RealPos = self:GetPos()

	self.Inputs = mc.SafeWireInputs(self, {'Open', 'Close'})
	mc.SafeTriggerOutput(self, 'IsOpen', 0)
end

function ENT:TriggerInput(id, val)
	if not tobool(val) then return end

	if id == 'Open' and not self:GetIsOpen() then
		self:OpenSwitch(self:GetOpenDirection())
	elseif id == 'Close' and self:GetIsOpen() then
		self:OpenSwitch(self:GetOpenDirection())
	end
end

function ENT:OpenSwitch(dir)
	self:SetOpenDirection(dir)
	self:PreformRotate()
	self:SetIsOpen(not self:GetIsOpen())

	if self:GetIsOpen() then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:EmitSound('minecraft/door_close.ogg')
	else
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:EmitSound('minecraft/door_open.ogg')
	end

	mc.SafeTriggerOutput(self, 'IsOpen', self:GetIsOpen() and 1 or 0)
end

function ENT:FixedMove()
	self:PreformRotate(true)
	self.BaseClass.FixedMove(self)
	self.RealPos = self:GetPos()
end

function ENT:RotateOpen()
	local ang = self:GetAngles()
	local lpos = self.RealPos
	local dir = self:GetOpenDirection()

	if dir == mc.SIDE_FORWARD then
		ang.y = ang.y + 90
	else
		ang.y = ang.y - 90
	end

	local add = Vector(mc.STEP / 2, 0, 0)
	add:Rotate(ang)

	self:SetAngles(ang)
	self:SetPos(lpos + add)
end

function ENT:PreformRotate(noopen)
	self.BaseClass.PreformRotate(self)

	if not noopen then
		if self:GetIsOpen() then
			self:RotateOpen()
		else
			self:SetPos(self.RealPos)
		end
	end
end

function ENT:IsOpaque()
	return false
end

function ENT:Use(ply)
	local lpos = self:GetPos()
	local delta = (ply:GetPos() - lpos)
	local ang = delta:Angle()

	if ang.y > 0 and ang.y <= 180 then
		self:OpenSwitch(mc.SIDE_FORWARD)
	else
		self:OpenSwitch(mc.SIDE_BACKWARD)
	end
end

function ENT:DrawLines()
	mc.DrawLines(self:GetPos(), self:GetAngles(), self:OBBMins(), self:OBBMaxs())
end

scripted_ents.Register(ENT, 'dbot_mcblock_door')

mc.TreeTypes = mc.TreeTypes or {}

function mc.RegisterTree(sapid, func, mult)
	mc.TreeTypes[sapid] = {
		spawn = func,
		mult = mult,
	}
end

local ENT = {}
ENT.Type = 'anim'
ENT.Base = 'dbot_mcblock'
ENT.Author = 'DBot'
ENT.Category = 'MCSWEP2'
ENT.PrintName = 'Sapling'

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:InitializeBlockID(id, ...)
	self.BaseClass.InitializeBlockID(self, id, ...)
	self.GrowAt = CurTimeL() + 180 * mc.TreeTypes[id].mult
end

function ENT:CanChoke()
	return false
end

function ENT:IsOpaque()
	return false
end

function ENT:BlockUpdate()
	self.BaseClass.BlockUpdate(self)

	if CLIENT then return end
	local block = self:GetBlockAtSide(mc.SIDE_DOWN)

	if IsValid(block) then
		if not (block:GetMatType() == mc.MAT_DIRT or block:GetMatType() == mc.MAT_GRASS) then
			self:OnDestruct()
		end
	end
end

function ENT:CanFloat()
	return false
end

function ENT:CanBeFlipped()
	return false
end

function ENT:CanBeRotated()
	return false
end

function ENT:Grow()
	self.MC_IGNORE = true
	local func = mc.TreeTypes[self:GetBlockID()].spawn

	if func then
		func(self)
	end

	self:Hook('OnGrow')
	self:Remove()
end

function ENT:Think()
	self.BaseClass.Think(self)
	if CLIENT then return end

	if self.GrowAt < CurTimeL() then
		self:Grow()
	end
end

scripted_ents.Register(ENT, 'dbot_mcblock_sapling')

mc.FenceGates = mc.FenceGates or {}

function mc.RegisterFenceGateModel(id, baseModel)
	mc.Fences[id] = baseModel
end

function mc.GetFenceGateModel(id)
	return mc.Fences[id]
end

local ENT = {}
ENT.Type = 'anim'
ENT.Author = 'DBot'
ENT.PrintName = 'Minecraft Block'
ENT.Spawnable = false
ENT.Base = 'dbot_mcblock'
ENT.IsMCFence = true

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 10, 'IsOpen')
	self:NetworkVar('Bool', 11, 'OpenSide')
	self.BaseClass.SetupDataTables(self)
end

function ENT:CanChoke()
	return false
end

function ENT:CanBeRotated()
	return true
end

function ENT:CanBeFlipped()
	return false
end

function ENT:IsOpaque()
	return false
end

ENT.CustomWireOutputs = {'IsOpen'}

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	if CLIENT then return end

	self:SetOpenSide(false)
	self:SetIsOpen(false)
	self:SetUseType(SIMPLE_USE)

	self.BaseModel = 'models/mcmodelpack/fences/fence-gate'

	timer.Simple(0, function()
		if IsValid(self) then self:TriggerUpdate() end
	end)

	self.Inputs = mc.SafeWireInputs(self, {'Open', 'Close'})
	mc.SafeTriggerOutput(self, 'IsOpen', 0)
end

function ENT:TriggerInput(id, val)
	if not tobool(val) then return end

	if id == 'Open' and not self:GetIsOpen() then
		self:OpenSwitch(self:GetOpenSide())
	elseif id == 'Close' and self:GetIsOpen() then
		self:OpenSwitch(self:GetOpenSide())
	end
end

function ENT:InitializeBlockID(id, ...)
	self.BaseClass.InitializeBlockID(self, id, ...)
	self.BaseModel = mc.GetFenceGateModel(id)
end

function ENT:OpenSwitch(dir)
	self:SetIsOpen(not self:GetIsOpen())
	self:SetOpenSide(dir)

	if self:GetIsOpen() then
		self:SetModel(self.BaseModel .. '-open.mdl')
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:EmitSound('minecraft/door_open.ogg')
	else
		self:SetModel(self.BaseModel .. '.mdl')
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:EmitSound('minecraft/door_close.ogg')
	end

	mc.SafeTriggerOutput(self, 'IsOpen', self:GetIsOpen() and 1 or 0)

	self:PreformRotate()
	self:TriggerUpdate()
end

function ENT:PreformRotate()
	self.BaseClass.PreformRotate(self)

	local ang = self:GetAngles()

	ang.y = ang.y - 90

	if self:GetOpenSide() then
		ang.y = ang.y - 90
	else
		ang.y = ang.y + 90
	end

	self:SetAngles(ang)
end

function ENT:Use(ply)
	local lpos = self:GetPos()
	local delta = (ply:GetPos() - lpos)
	local ang = delta:Angle()

	ang.y = ang.y + 90

	if ang.y > 0 and ang.y <= 180 then
		self:OpenSwitch(true)
	else
		self:OpenSwitch(false)
	end
end

function ENT:DrawLines()
	mc.DrawLines(self:GetPos(), self:GetAngles(), self:OBBMins(), self:OBBMaxs())
end

scripted_ents.Register(ENT, 'dbot_mcblock_fencegate')

local ENT = {}
ENT.Type = 'anim'
ENT.Base = 'dbot_mcblock'
ENT.Author = 'DBot'
ENT.Category = 'MCSWEP2'
ENT.PrintName = 'Decoration'

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:BlockUpdate()
	self.BaseClass.BlockUpdate(self)

	if CLIENT then return end
	local block = self:GetBlockAtSide(mc.SIDE_DOWN)

	if IsValid(block) then
		if not (block:GetMatType() == mc.MAT_DIRT or block:GetMatType() == mc.MAT_GRASS) then
			self:OnDestruct()
		end
	end
end

function ENT:CanChoke()
	return false
end

function ENT:IsOpaque()
	return false
end

function ENT:CanFloat()
	return false
end

function ENT:CanBeFlipped()
	return false
end

function ENT:CanBeRotated()
	return false
end

function ENT:FixedMove()
	self.BaseClass.FixedMove(self)

	local pos = self:GetPos()
	local rand = VectorRand() * mc.STEP * .25
	rand.z = 0

	self:SetPos(pos + rand)
end

ENT.PhysMins = Vector(-5, -5, 0)
ENT.PhysMaxs = Vector(5, 5, 15)

function ENT:UpdatePhysics()
	self:PhysicsInitBox(self.PhysMins, self.PhysMaxs)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self.phys = self:GetPhysicsObject()
	self.phys:Sleep()
	self.phys:EnableMotion(false)
end

function ENT:DrawLines()
	mc.DrawLines(self:GetPos(), self:GetAngles(), self:OBBMins(), self:OBBMaxs())
end

scripted_ents.Register(ENT, 'dbot_mcblock_decoration')

--Default content!
include('sh_blocks.lua')
