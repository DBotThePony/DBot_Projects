
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

local ENT = MCSWEP2.BLOCK_ENT

MCSWEP2.DRAW_TIME = 0

--Use custom hooks to draw blocks
--https://dbot.serealia.ca/ss+(2016-06-09+at+03.31.10).jpg
MCSWEP2.ToDraw = MCSWEP2.ToDraw or {}

MCSWEP2.DRAW_FILTER = CreateConVar('cl_mc_filter', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Force "point" texture filter on minecraft blocks.')

function ENT:IsRendering()
	return true
end

local GlowHalf = Vector(0, 0, 1) * MCSWEP2.STEP / 2

function ENT:RealDraw()
	if not self.GetIsFalling then return end

	if self:CanFall() then
		if self:GetIsFalling() then
			self:SetRenderOrigin(self:GetFallPosition())
		end

		self:DrawModel()

		self:SetRenderOrigin()
	else
		self:DrawModel()
	end

	if self:CanGlow() then
		local dlight = DynamicLight(self:EntIndex())

		if dlight then
			local r, g, b = self:GetGlowColor()
			local mult = self:GetGlowMultipler()

			dlight.Pos = self:GetPos() + GlowHalf
			dlight.r = r
			dlight.g = g
			dlight.b = b
			dlight.Brightness = mult
			dlight.Decay = 1
			dlight.Size = 256 * mult
			dlight.DieTime = CurTimeL() + 0.2
		end
	end
end

function ENT:Draw()
	if MCSWEP2.DISABLE_DRAW:GetBool() then return end
	if MCSWEP2.DRAW_FILTER:GetBool() then
		render.PushFilterMag(TEXFILTER.POINT)
		render.PushFilterMin(TEXFILTER.POINT)
	end

	self:RealDraw()

	if MCSWEP2.DRAW_FILTER:GetBool() then
		render.PopFilterMag()
		render.PopFilterMin()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

local DRAW_LINES = CreateConVar('cl_mc_drawlines', '1', FCVAR_ARCHIVE, 'Draw lines on blocks')
local REPLACE_FOOTSOUND = MCSWEP2.REPLACE_FOOTSOUND

local function PlayerFootstep(ply, pos, foot, sound, volume)
	if not REPLACE_FOOTSOUND:GetInt() then return end
	volume = volume or 1

	local tr = util.TraceHull{
		start = pos,
		endpos = pos + Vector(0, 0, -5),
		filter = ply,
		mins = ply:OBBMins() * 0.7,
		maxs = ply:OBBMaxs() * 0.7,
	}

	if not tr.Hit then return end
	if not IsValid(tr.Entity) then return end
	if not tr.Entity.IsMCBlock then return end

	if not MCSWEP2.HaveWalkSound(tr.Entity:GetMatType()) then return end
	local snd = MCSWEP2.GetWalkSound(tr.Entity:GetMatType())

	if ply == LocalPlayer() then
		ply:EmitSound(snd, 55, 100, math.min(0.3, volume))
	else
		ply:EmitSound(snd, 65, 100, volume)
	end

	return true
end

local maxdist = 256 ^ 2

local function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not DRAW_LINES:GetBool() then return end

	local ply = LocalPlayer()
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	if not IsValid(ent) then return end
	if not ent.IsMCBlock then return end

	local pos = ent:GetPos()

	if pos:DistToSqr(ply:GetPos()) > maxdist then return end
	ent:DrawLines()
end

hook.Add('PostDrawTranslucentRenderables', 'MCSWEP2.BlockLines', PostDrawTranslucentRenderables)
hook.Add('PlayerFootstep', 'MCSWEP2.BlockSounds', PlayerFootstep)

language.Add('dbot_mcblock', 'Minecraft Block')
language.Add('dbot_mcblock_choke', 'Choke')
language.Add('dbot_mcblock_fencegate', 'Minecraft Block')
language.Add('dbot_mcblock_sapling', 'Sapling')
language.Add('dbot_mcblock_door', 'Door')
language.Add('dbot_mcblock_fence', 'Fence')
