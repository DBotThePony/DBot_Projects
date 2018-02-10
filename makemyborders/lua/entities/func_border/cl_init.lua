
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

include('shared.lua')

local ipairs = ipairs
local render = render
local LocalPlayer = LocalPlayer
local Vector = Vector

function ENT:SetupRenderVariables()
	self.blend = 100
	self.colorIfPass = Color(66, 217, 87)
	self.colorIfBlock = Color(218, 127, 127)
	self.colorIfInactive = Color(138, 169, 128)
end

function ENT:CInitialize()
	self:SetupRenderVariables()
	self:MarkShadowAsDirty()
	self:DestroyShadow()
end

function ENT:RegisterNWWatcher(varName, callback)
	table.insert(self.collisionRules, {varName, self[varName](self), self['Get' .. varName], callback})
end

function ENT:Think()
	for i, data in ipairs(self.collisionRules) do
		local new = data[3](self)

		if new ~= data[2] then
			data[4](self, data[1], data[2], new)
			data[2] = new
		end
	end

	self.colorIfBlock.a = self.blend
	self.colorIfPass.a = self.blend
	self.colorIfInactive.a = self.blend
end

local white = Material('models/debug/debugwhite')

function ENT:FindPassEntity()
	return LocalPlayer()
end

function ENT:Draw()
	local pos = self:GetRenderOrigin() or self:GetPos()
	local ang = self:GetRenderAngles() or self:GetRealAngle() or self:GetAngles()

	local mins = self:GetCollisionMins()
	local maxs = self:GetCollisionMaxs()

	pos.z = pos.z + maxs.z * 0.5

	local color

	if self:IsEnabled() then
		local toPass = self:FindPassEntity()
		local allowedToPass = self:AllowObjectPass(toPass, true)
		color = allowedToPass and self.colorIfPass or self.colorIfBlock
	else
		color = self.colorIfInactive
	end

	FUNC_BORDER_TEXTURE:SetVector('$color', color:ToVector())
	FUNC_BORDER_TEXTURE:SetFloat('$alpha', color.a / 255)

	render.SetMaterial(FUNC_BORDER_TEXTURE)
	render.DrawQuadEasy(pos, ang:Right(), maxs.x - mins.x, maxs.z - mins.z, color, 180)
	render.DrawQuadEasy(pos, ang:Right() * -1, maxs.x - mins.x, maxs.z - mins.z, color, 0)
end
