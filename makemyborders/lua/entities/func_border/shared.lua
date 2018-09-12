
-- Copyright (C) 2018 DBot

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


ENT.Type = 'anim'
ENT.PrintName = 'World Border/Player Clip'
ENT.Author = 'DBotThePony'
ENT.IS_FUNC_BORDER = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local TRANSMIT_ALWAYS = TRANSMIT_ALWAYS
local CLIENT = CLIENT
local SERVER = SERVER
local ipairs = ipairs
local hook = hook
local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
local type = type
local IsValid = IsValid
local Entity = Entity
local NULL = NULL
local Vector = Vector
local GetTable = FindMetaTable('Entity').GetTable

function ENT:Initialize()
	self:SetCustomCollisionCheck(true)
	self:DrawShadow(false)
	self.dirtyStatus = {}

	if CLIENT then
		self:CInitialize()
	else
		self:SInitialize()
	end
end

function ENT:PhysgunPickup()
	return false
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

local mappings = {
	'ShowVisuals',
	'ShowVisualBorder',
	'ShowVisualVignette',
	'AllowNoclip',
	'IsEnabled',
	'DrawIfCanPass',
}

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'ShowVisuals')
	self:NetworkVar('Bool', 1, 'ShowVisualBorder')
	self:NetworkVar('Bool', 2, 'ShowVisualVignette')
	self:NetworkVar('Bool', 3, 'PlaySound')
	self:NetworkVar('Bool', 4, 'AllowNoclip')
	self:NetworkVar('Bool', 5, 'IsEnabled')
	self:NetworkVar('Bool', 7, 'DrawIfCanPass')

	self:NetworkVar('Vector', 0, 'CollisionMins')
	self:NetworkVar('Vector', 1, 'CollisionMaxs')
	self:NetworkVar('Angle', 0, 'RealAngle')

	if SERVER then
		self:SetShowVisuals(true)
		self:SetShowVisualBorder(true)
		self:SetShowVisualVignette(true)
		self:SetPlaySound(true)
		self:SetAllowNoclip(true)
		self:SetIsEnabled(true)
		self:SetDrawIfCanPass(true)

		self:SetCollisionMins(Vector(-50, -1, 0))
		self:SetCollisionMaxs(Vector(50, 1, 100))
	end

	for i, map in ipairs(mappings) do
		self[map] = self['Get' .. map]
	end

	if SERVER then
		self:NetworkVarNotify('CollisionMins', self.UpdateCollisionRules)
		self:NetworkVarNotify('CollisionMaxs', self.UpdateCollisionRules)

		self:NetworkVarNotify('AllowNoclip', self.CollisionRulesChanges)
	else
		self.collisionRules = {}
		self:RegisterNWWatcher('AllowNoclip', self.CollisionRulesChanges)

		self:RegisterNWWatcher('CollisionMins', self.UpdateBounds)
		self:RegisterNWWatcher('CollisionMaxs', self.UpdateBounds)
	end
end

function ENT:CollisionRulesChanges(var, old, new)
	if old == new then return end
	self:CollisionRulesChanged()
	self.dirtyStatus = {}
end

function ENT:MarkDirty()
	self.isDirty = true
end

function ENT:Think()
	if CLIENT then
		self:CThink()
	else
		self:SThink()
	end

	if self.isDirty then
		self:CollisionRulesChanged()
		self.isDirty = false
		self.dirtyStatus = {}
	end
end

function ENT:AllowObjectPassFallback(objectIn, ifNothing)
	local typeIn = type(objectIn)

	if typeIn == 'string' then
		return ifNothing
	end

	if objectIn == NULL then
		return ifNothing
	end

	return nil
end

function ENT:AllowObjectPass(objectIn, ifNothing)
	local fallback = self:AllowObjectPassFallback(objectIn, ifNothing)

	if fallback ~= nil then
		return fallback
	end

	local typeIn = type(objectIn)

	if typeIn == 'number' then
		objectIn = Entity(objectIn)
		typeIn = type(objectIn)
	end

	if typeIn == NULL then
		return ifNothing
	end

	if typeIn == 'Player' then
		if hook.Run('Border_AllowPlayerPass', self, objectIn) == true then
			return true
		end

		if self:AllowNoclip() then
			return objectIn:GetMoveType() == MOVETYPE_NOCLIP
		end

		return false
	end

	return typeIn ~= 'Vehicle' and typeIn ~= 'NPC' and (typeIn ~= 'Entity' or not objectIn:GetClass():startsWith('prop_'))
end

function ENT:ShouldCollide(target)
	if self.dirtyStatus[target] ~= nil then return self.dirtyStatus[target] end
	return not self:AllowObjectPass(target, false)
end

local IsValid = FindMetaTable('Entity').IsValid

hook.Add('ShouldCollide', 'func_border', function(ent1, ent2)
	local tab1 = GetTable(ent1)
	local tab2
	local status

	if tab1 and tab1.IS_FUNC_BORDER then
		status = ent1:ShouldCollide(ent2)

		if tab1.isDirty then
			return status
		end
	end

	if status == nil then
		tab2 = GetTable(ent2)

		if tab2 and tab2.IS_FUNC_BORDER then
			status = ent2:ShouldCollide(ent1)

			if tab2.isDirty then
				return status
			end
		end
	end

	if status ~= nil and IsValid(ent1) and IsValid(ent2) then
		local entity = tab1 and tab1.IS_FUNC_BORDER and tab2 or tab1
		local entityE = tab1 and tab1.IS_FUNC_BORDER and ent2 or ent1
		local border = tab1 and tab1.IS_FUNC_BORDER and ent1 or ent2
		local oldStatus = entity[border]

		-- oshit
		if oldStatus ~= nil and oldStatus ~= status then
			border:MarkDirty()
			border.dirtyStatus[entityE] = oldStatus
			entity[border] = status
			return oldStatus
		end
	end

	return status
end, -1)
