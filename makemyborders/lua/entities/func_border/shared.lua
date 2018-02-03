
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

ENT.Type = 'point'
ENT.PrintName = 'World Border/Player Clip'
ENT.Author = 'DBotThePony'
ENT.IS_FUNC_BORDER = true

local TRANSMIT_ALWAYS = TRANSMIT_ALWAYS
local CLIENT = CLIENT
local ipairs = ipairs
local hook = hook
local MOVETYPE_NOCLIP = MOVETYPE_NOCLIP
local type = type
local IsValid = IsValid
local Entity = Entity
local NULL = NULL
local Vector = Vector

function ENT:Initialize()
	if CLIENT then
		self:CInitialize()
	else
		self:SInitialize()
	end

	self:SetCustomCollisionCheck(true)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

local mappings = {
	'ShowVisuals',
	'ShowVisualBorder',
	'ShowVisualVignette',
	'AllowNoclip',
}

function ENT:SetupDataTables()
	self:NetworkVar('Bool', 0, 'ShowVisuals')
	self:NetworkVar('Bool', 1, 'ShowVisualBorder')
	self:NetworkVar('Bool', 2, 'ShowVisualVignette')
	self:NetworkVar('Bool', 3, 'PlaySound')
	self:NetworkVar('Bool', 4, 'AllowNoclip')

	self:NetworkVar('Vector', 0, 'CollisionMins')
	self:NetworkVar('Vector', 1, 'CollisionMaxs')

	self:SetShowVisuals(true)
	self:SetVisualBorder(true)
	self:SetShowVisualVignette(true)
	self:SetPlaySound(true)
	self:SetAllowNoclip(false)

	self:SetCollisionMins(Vector(-5, -1, -5))
	self:SetCollisionMaxs(Vector(5, 1, 5))

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
	end
end

function ENT:CollisionRulesChanges(var, old, new)
	if old == new then return end
	self:CollisionRulesChanged()
end

function ENT:AllowObjectPass(objectIn, ifNothing)
	local typeIn = type(objectIn)

	if typeIn == 'string' then
		return ifNothing
	end

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
			return self:AllowNoclip() and objectIn:GetMoveType() == MOVETYPE_NOCLIP
		end

		return false
	end

	return typeIn ~= 'Vehicle' and typeIn ~= 'NPC' and (typeIn ~= 'Entity' or not objectIn:GetClass():startsWith('prop_'))
end
