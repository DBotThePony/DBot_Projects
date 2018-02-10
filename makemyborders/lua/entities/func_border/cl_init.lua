
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
local math = math
local color_white = color_white

local STENCIL_REPLACE = STENCIL_REPLACE
local STENCIL_KEEP = STENCIL_KEEP
local STENCIL_NOTEQUAL = STENCIL_NOTEQUAL
local STENCIL_EQUAL = STENCIL_EQUAL

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

local white = CreateMaterial('func_border_stencil3', 'UnlitGeneric', {
	['$basetexture'] = 'models/debug/debugwhite',
	['$color'] = '1 1 1',
	['$alpha'] = '0.001'
})

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

	render.SetMaterial(white)

	local W = maxs.x - mins.x
	local H = maxs.z - mins.z

	local widths = math.max(math.floor(W / 256), 1)
	local heights = math.max(math.floor(H / 256), 1)

	render.SetStencilEnable(true)
	render.ClearStencil()

	render.SetStencilReferenceValue(1)
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilPassOperation(STENCIL_INCRSAT)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)

	render.SetStencilCompareFunction(STENCIL_NOTEQUAL)

	render.DrawQuadEasy(pos, ang:Right(), W, H, color_white, 0)
	render.DrawQuadEasy(pos, ang:Right() * -1, W, H, color_white, 0)

	render.SetStencilCompareFunction(STENCIL_EQUAL)

	render.SetMaterial(FUNC_BORDER_TEXTURE)

	for i = -1, widths + 1 do
		for i2 = -1, heights do
			local add = Vector(i * 256, 0, i2 * 256)
			add:Rotate(ang)

			render.DrawQuadEasy(pos + add, ang:Right(), 256, 256, color, 180)
			render.DrawQuadEasy(pos + add, ang:Right() * -1, 256, 256, color, 0)
		end
	end

	render.ClearStencil()
	render.SetStencilEnable(false)
end
