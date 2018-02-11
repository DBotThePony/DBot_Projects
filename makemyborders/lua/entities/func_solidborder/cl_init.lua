
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
local cam = cam
local type = type
local EyePos = EyePos
local ents = ents
local IsValid = IsValid
local table = table
local DLib = DLib

function ENT:Draw()
	if not self:ShowVisuals() or not self:ShowVisualBorder() then return end
	if not self.ENABLE_VISUALS:GetBool() then return end
	local pos = self:GetRenderOrigin() or self:GetPos()
	if EyePos():Distance(pos) > self.sphereCheckSize * 1.5 then return end

	local mins = self:GetCollisionMins()
	local maxs = self:GetCollisionMaxs()
	local color = self:GetDrawColor()

	FUNC_BORDER_TEXTURE:SetVector('$color', color:ToVector())
	FUNC_BORDER_TEXTURE:SetFloat('$alpha', color.a / 255)

	local entsFound = self:FindEntities()

	local faces = DLib.vector.ExtractFacesAndCentre(mins, maxs)
	local Centre = DLib.vector.Centre(mins, maxs)

	for i, faceData in ipairs(faces) do
		local W, H = DLib.vector.FindQuadSize(faceData[1], faceData[2], faceData[3], faceData[4])
		local widths = math.max(math.floor(W / 256), 1)
		local heights = math.max(math.floor(H / 256), 1)
		local ang = faceData[5]:Angle()

		self:actuallyDraw(pos + faceData[6], widths, heights, faceData[5], 0, entsFound, W, H, ang)
		self:actuallyDraw(pos + faceData[6], widths, heights, faceData[5] * -1, 180, entsFound, W, H, ang)
	end
end
