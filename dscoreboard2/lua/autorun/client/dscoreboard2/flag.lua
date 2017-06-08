
--
-- Copyright (C) 2016-2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local board = DScoreBoard2

local PANEL = {}
PANEL.Mat = Material('models/debug/debugwhite')

board.MAT_CACHE = board.MAT_CACHE or {}

function PANEL:Init()
	self:SetSize(23, 11)
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	
	self.CurrentImage = ''
	self.FlagSetup = true
end

function PANEL:SetupFlag(code)
	local country = code or board.GetPlayerCountry(self.ply)
	
	if country == 'Unknown' then return end
	
	self.FlagSetup = true
	
	if board.MAT_CACHE[country] == nil then
		local path = string.lower(country)
		
		if not file.Exists('materials/flags16/' .. path .. '.png', 'GAME') then
			board.MAT_CACHE[country] = false
			return
		end
		
		board.MAT_CACHE[country] = Material('flags16/' .. path .. '.png')
	end
	
	if not board.MAT_CACHE[country] then return end
	
	self.Mat = board.MAT_CACHE[country]
end

function PANEL:Think()
	if not self.FlagSetup and IsValid(self.ply) then
		self:SetupFlag()
	end
end

function PANEL:SetPlayer(ply)
	self.FlagSetup = false
	self.ply = ply
	
	self:SetupFlag()
end

function PANEL:SetFlagCode(code)
	self.FlagSetup = false
	
	self:SetupFlag(code)
end

function PANEL:Paint(w, h)
	if not self.FlagSetup then
		surface.SetTextColor(color_white)
		surface.SetTextPos(0, 0)
		surface.SetFont(DScoreBoard2.FONT_PLAYERINFO)
		surface.DrawText('???')
	else
		surface.SetDrawColor(color_white)
		surface.SetMaterial(self.Mat)
		surface.DrawTexturedRect(0, 0, w, h)
		draw.NoTexture()
	end
end

vgui.Register('DScoreBoard2_CountryFlag', PANEL, 'EditablePanel')
