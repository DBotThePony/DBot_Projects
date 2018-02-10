
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

function ENT:CInitialize()
	-- self.borderPatternColor1 = Color(100, 200, 100)
	-- self.borderPatternColor2 = Color(255, 255, 255)
	-- self.blending = 100
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
end

local white = Material('models/debug/debugwhite')

function ENT:Draw()
	local pos = self:GetRenderOrigin() or self:GetPos()
	local ang = self:GetRenderAngles() or self:GetRealAngle() or self:GetAngles()

	local mins = self:GetCollisionMins()
	local maxs = self:GetCollisionMaxs()

	render.SetMaterial(FUNC_BORDER_TEXTURE)
	render.DrawQuadEasy(pos, ang:Right(), maxs.x - mins.x, maxs.z - mins.z, Color(255, 255, 255), 180)
end
