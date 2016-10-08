
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

local self = MCSWEP2

self.CURRENT_BLOCK_ID = CreateConVar('cl_mc_blockid', '2', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Current selected block ID')
self.CURRENT_BLOCK_SKIN = CreateConVar('cl_mc_blockskin', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Current selected block skin')
self.SWAP_PLACE_REMOVE = CreateConVar('cl_mc_swap', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Swap place/delete mouse buttons')
self.PREFFER_USER_ANGLES = CreateConVar('cl_mc_rotate_ang', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Use player angles only when rotating blocks')
self.DISABLE_DRAW = CreateConVar('cl_mc_nodraw', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'DEBUG: Do not draw blocks')
self.DRAW_DIRECTION = CreateConVar('cl_mc_drawwdir', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block place position')
self.DRAW_BLOCKPLACE = CreateConVar('cl_mc_drawblock', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block ghost model')
self.DRAW_BLOCKPLACE_COLOR = CreateConVar('cl_mc_drawblock_color', '1', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block ghost model in color')

self.DRAW_BLOCKPLACE_COLOR_R = CreateConVar('cl_mc_drawblock_color_r', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block ghost red channel')
self.DRAW_BLOCKPLACE_COLOR_G = CreateConVar('cl_mc_drawblock_color_g', '50', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block ghost green channel')
self.DRAW_BLOCKPLACE_COLOR_B = CreateConVar('cl_mc_drawblock_color_b', '255', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block ghost blue channel')

self.DRAW_BLOCKPLACE_DCOLOR_R = CreateConVar('cl_mc_drawblock_dcolor_r', '200', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block remove ghost red channel')
self.DRAW_BLOCKPLACE_DCOLOR_G = CreateConVar('cl_mc_drawblock_dcolor_g', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block remove ghost green channel')
self.DRAW_BLOCKPLACE_DCOLOR_B = CreateConVar('cl_mc_drawblock_dcolor_b', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Draw block remove ghost blue channel')

function self.GetVisualPlaceColor()
	return Color(self.DRAW_BLOCKPLACE_COLOR_R:GetInt(), self.DRAW_BLOCKPLACE_COLOR_B:GetInt(), self.DRAW_BLOCKPLACE_COLOR_B:GetInt())
end

function self.GetVisualPlaceColor2()
	return self.DRAW_BLOCKPLACE_COLOR_R:GetInt(), self.DRAW_BLOCKPLACE_COLOR_B:GetInt(), self.DRAW_BLOCKPLACE_COLOR_B:GetInt()
end

function self.GetVisualPlaceColorBlend()
	return self.DRAW_BLOCKPLACE_COLOR_R:GetInt() / 255, self.DRAW_BLOCKPLACE_COLOR_B:GetInt() / 255, self.DRAW_BLOCKPLACE_COLOR_B:GetInt() / 255
end

function self.GetVisualRemoveColor()
	return Color(self.DRAW_BLOCKPLACE_DCOLOR_R:GetInt(), self.DRAW_BLOCKPLACE_DCOLOR_B:GetInt(), self.DRAW_BLOCKPLACE_DCOLOR_B:GetInt())
end

function self.GetVisualRemoveColor2()
	return self.DRAW_BLOCKPLACE_DCOLOR_R:GetInt(), self.DRAW_BLOCKPLACE_DCOLOR_B:GetInt(), self.DRAW_BLOCKPLACE_DCOLOR_B:GetInt()
end

function self.GetVisualRemoveColorBlend()
	return self.DRAW_BLOCKPLACE_DCOLOR_R:GetInt() / 255, self.DRAW_BLOCKPLACE_DCOLOR_B:GetInt() / 255, self.DRAW_BLOCKPLACE_DCOLOR_B:GetInt() / 255
end

local SparkleGravity = Vector(0, 0, -30)

function self.Sparkles(pos)
	local emmiter = ParticleEmitter(pos)
	
	for i = 1, math.random(8, 30) do
		local p = emmiter:Add('particle/fire', pos + Vector(math.random(-MCSWEP2.STEP / 2, MCSWEP2.STEP / 2), math.random(-MCSWEP2.STEP / 2, MCSWEP2.STEP / 2), math.random(0, MCSWEP2.STEP)))
		p:SetColor(200, 200, 200)
		p:SetStartSize(math.random() * 8)
		p:SetEndSize(0)
		p:SetDieTime(math.random() * 5)
		p:SetGravity(SparkleGravity)
		p:SetVelocity(VectorRand() * math.random(1, 25))
	end
	
	emmiter:Finish()
end

local ExplosionGravity = Vector(0, 0, -5)

function self.Explosion(pos)
	local emmiter = ParticleEmitter(pos)
	
	--White
	for i = 1, math.random(80, 200) do
		local p = emmiter:Add('particles/minecraft/smoke' .. math.random(1, 5), pos)
		p:SetColor(255, 255, 255)
		p:SetStartSize(math.random() * 8)
		p:SetEndSize(0)
		p:SetDieTime(math.random() * 5)
		p:SetGravity(ExplosionGravity)
		p:SetVelocity(VectorRand() * math.random(170, 230))
	end
	
	--Gray
	for i = 1, math.random(80, 200) do
		local p = emmiter:Add('particles/minecraft/smoke' .. math.random(1, 5), pos)
		p:SetColor(150, 150, 150)
		p:SetStartSize(math.random() * 8)
		p:SetEndSize(0)
		p:SetDieTime(math.random() * 5)
		p:SetGravity(ExplosionGravity)
		p:SetVelocity(VectorRand() * math.random(80, 120))
	end
	
	emmiter:Finish()
end

local function RotatedVector(x, y, z, ang)
	local vec = Vector(x, y, z)
	vec:Rotate(ang)
	return vec
end

function self.DrawLines(pos, ang, mins, maxs)
	--Down
	render.DrawLine(pos + RotatedVector(mins.x, mins.y, mins.z, ang), pos + RotatedVector(maxs.x, mins.y, mins.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(maxs.x, mins.y, mins.z, ang), pos + RotatedVector(maxs.x, maxs.y, mins.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(mins.x, mins.y, mins.z, ang), pos + RotatedVector(mins.x, maxs.y, mins.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(mins.x, maxs.y, mins.z, ang), pos + RotatedVector(maxs.x, maxs.y, mins.z, ang), color_black, false)
	
	--Top
	render.DrawLine(pos + RotatedVector(mins.x, mins.y, maxs.z, ang), pos + RotatedVector(maxs.x, mins.y, maxs.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(maxs.x, mins.y, maxs.z, ang), pos + RotatedVector(maxs.x, maxs.y, maxs.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(mins.x, mins.y, maxs.z, ang), pos + RotatedVector(mins.x, maxs.y, maxs.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(mins.x, maxs.y, maxs.z, ang), pos + RotatedVector(maxs.x, maxs.y, maxs.z, ang), color_black, false)
	
	--Walls
	render.DrawLine(pos + RotatedVector(mins.x, mins.y, mins.z, ang), pos + RotatedVector(mins.x, mins.y, maxs.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(maxs.x, mins.y, mins.z, ang), pos + RotatedVector(maxs.x, mins.y, maxs.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(mins.x, maxs.y, mins.z, ang), pos + RotatedVector(mins.x, maxs.y, maxs.z, ang), color_black, false)
	render.DrawLine(pos + RotatedVector(maxs.x, maxs.y, mins.z, ang), pos + RotatedVector(maxs.x, maxs.y, maxs.z, ang), color_black, false)
end

net.Receive('MCSWEP2.Sparkles', function()
	self.Sparkles(net.ReadVector())
end)

net.Receive('MCSWEP2.Explosion', function()
	self.Explosion(net.ReadVector())
end)

net.Receive('MCSWEP2.DebugPrint', function()
	chat.AddText(unpack(net.ReadTable()))
end)

include('cl_menu.lua')
