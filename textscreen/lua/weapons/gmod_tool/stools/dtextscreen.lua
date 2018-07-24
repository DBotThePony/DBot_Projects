
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

local TOOL = TOOL
local DLib = DLib
local vgui = vgui
local CLIENT = CLIENT
local SERVER = SERVER
local pairs = pairs
local RunConsoleCommand = RunConsoleCommand

TOOL.Category = 'Construction'
TOOL.Name = 'Textscreens'

local perCategory = {}

for i = 1, 16 do
	perCategory[i] = {
		['text_' .. i] = '',
		['newline_' .. i] = '1',
		['align_left_' .. i] = '0',
		['align_right_' .. i] = '0',
		['align_top_' .. i] = '0',
		['align_down_' .. i] = '0',
		['font_' .. i] = '0',
		['size_' .. i] = '24',
		['color_' .. i .. '_r'] = '200',
		['color_' .. i .. '_g'] = '200',
		['color_' .. i .. '_b'] = '200',
		['color_' .. i .. '_a'] = '255'
	}
end

for i, category in ipairs(perCategory) do
	for k, v in pairs(category) do
		TOOL.ClientConVar[k] = v
	end
end

if CLIENT then
	TOOL.Information = {
		{name = 'left'},
		{name = 'right'},
	}

	--DLib.i18n.RegisterProxy('tool.dtextscreen.left', 'gui.tool.dtextscreen.left')
	DLib.i18n.RegisterProxy('tool.dtextscreen.left')
	DLib.i18n.RegisterProxy('tool.dtextscreen.right')

	local function AddLine(self, id)

	end

	function TOOL:BuildCPanel()
		if not IsValid(self) then return end

		self:Button('gui.tool.textscreens.reset').DoClick = function()
			for k, v in pairs(TOOL.ClientConVar) do
				RunConsoleCommand('dtextscreen_' .. k, v)
			end
		end

		for i = 1, 16 do
			local spoiler = vgui.Create('DCollapsibleCategory', self)
			spoiler:Dock(TOP)
			spoiler:SetExpanded(false)
			spoiler:SetLabel('gui.tool.textscreens.spoiler', i)
			spoiler:DockMargin(0, 8, 0, 8)

			local canvas = vgui.Create('EditablePanel', spoiler)

			local toparent = self:Button('gui.tool.textscreens.reset_this')

			toparent.DoClick = function()
				for k, v in pairs(perCategory[i]) do
					RunConsoleCommand('dtextscreen_' .. k, v)
				end
			end

			toparent:SetParent(canvas)
			toparent:Dock(TOP)
			toparent:DockMargin(8, 8, 8, 8)

			local toparent, toparent2 = self:ComboBox('gui.tool.textscreens.font')
			toparent2:SetParent(canvas)
			toparent2:Dock(TOP)
			toparent2:DockMargin(8, 8, 8, 8)
			toparent:SetParent(canvas)
			toparent:Dock(TOP)
			toparent:DockMargin(8, 8, 8, 8)

			for i, fontdata in ipairs(TEXT_SCREEN_AVALIABLE_FONTS) do
				toparent:AddChoice(fontdata.name)
			end

			toparent:SetValue(TEXT_SCREEN_AVALIABLE_FONTS[(GetConVar('dtextscreen_font_' .. i):GetInt() + 1):clamp(1, #TEXT_SCREEN_AVALIABLE_FONTS + 1)].name)

			toparent.OnSelect = function(_, index, value)
				RunConsoleCommand('dtextscreen_font_' .. i, tostring(index - 1))
			end

			toparent, toparent2 = self:TextEntry('gui.tool.textscreens.text', 'dtextscreen_text_' .. i)
			toparent2:SetParent(canvas)
			toparent2:Dock(TOP)
			toparent2:DockMargin(8, 8, 8, 8)
			toparent:SetParent(canvas)
			toparent:Dock(TOP)
			toparent:DockMargin(8, 8, 8, 8)

			toparent = self:NumSlider('gui.tool.textscreens.fontsize', 'dtextscreen_size_' .. i, 8, 128, 0)
			toparent:SetParent(canvas)
			toparent:Dock(TOP)
			toparent:DockMargin(8, 8, 8, 8)

			toparent = self:CheckBox('gui.tool.textscreens.newline', 'dtextscreen_newline_' .. i)
			toparent:SetParent(canvas)
			toparent:Dock(TOP)
			toparent:DockMargin(8, 8, 8, 8)

			local mixer = vgui.Create('DColorMixer', spoiler)
			mixer:Dock(TOP)
			mixer:DockMargin(8, 8, 8, 8)
			mixer:SetAlphaBar(true)
			mixer:SetConVarR('dtextscreen_color_' .. i .. '_r')
			mixer:SetConVarG('dtextscreen_color_' .. i .. '_g')
			mixer:SetConVarB('dtextscreen_color_' .. i .. '_b')
			mixer:SetConVarA('dtextscreen_color_' .. i .. '_a')

			spoiler:SetContents(canvas)
		end
	end
end

local IsValid = FindMetaTable('Entity').IsValid
local net = net
local undo = undo
local tonumber = tonumber
local tobool = tobool

if SERVER then
	net.pool('dtextscreen_copy')
end

cleanup.Register('dtextscreen')
DLib.util.CreateSharedConvar('sbox_maxdtextscreens', '10', 'Maximal amount of text screens per player')

local CopySettings

if CLIENT then
	function CopySettings(ent)
		for i = 1, 16 do
			local size = ent['GetTextSize' .. i](ent)
			local font = ent['GetFontID' .. i](ent)
			local align = ent['GetAlign' .. i](ent)
			local color = ent['GetColor' .. i](ent)

			RunConsoleCommand('dtextscreen_font_' .. i, font:tostring())
			RunConsoleCommand('dtextscreen_size_' .. i, size:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_r', color.r:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_g', color.g:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_b', color.b:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_a', color.a:tostring())
		end

		local textraw = ent:GetTextSlot1() .. ent:GetTextSlot2() .. ent:GetTextSlot3() .. ent:GetTextSlot4()
		local text = textraw:split('\n')
		local total = 1
		local nextnewline = false

		for i, line in ipairs(text) do
			local split = line:split('\2')

			if #split == 1 then
				RunConsoleCommand('dtextscreen_text_' .. total, line)
				RunConsoleCommand('dtextscreen_newline_' .. total, '1')
				nextnewline = false

				total = total + 1

				if total == 17 then break end
			else
				for i2, str in ipairs(split) do
					RunConsoleCommand('dtextscreen_text_' .. total, str)
					RunConsoleCommand('dtextscreen_newline_' .. total, nextnewline and '1' or '0')
					nextnewline = false

					total = total + 1

					if total == 17 then break end
				end

				--RunConsoleCommand('dtextscreen_newline_' .. (total - 1), '1')
				nextnewline = true
			end

			if total == 17 then break end
		end
	end

	net.receive('dtextscreen_copy', function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		if ent:GetClass() ~= 'dbot_textscreen' then return end
		CopySettings(ent)
	end)
end

function TOOL:RightClick(tr)
	local ent = tr.Entity

	if not IsValid(ent) or ent:GetClass() ~= 'dbot_textscreen' then return false end

	if CLIENT then
		CopySettings(ent)
		return true
	end

	if not game.SinglePlayer() then return true end

	net.Start('dtextscreen_copy')
	net.WriteEntity(ent)
	net.Send(self:GetOwner())

	return true
end

function TOOL:LeftClick(tr)
	local ent = tr.Entity

	if ent == NULL then return false end
	if IsValid(ent) and (ent:IsPlayer() or ent:IsVehicle() or ent:IsNPC()) then return false end

	local textscreen, isnew = nil, false
	local ply = self:GetOwner()

	if IsValid(ent) and ent:GetClass() == 'dbot_textscreen' then
		if ent:GetIsPersistent() then return false end
		textscreen = ent
	else
		if not ply:CheckLimit('dtextscreens') then return false end
		if CLIENT then return true end
		textscreen = ents.Create('dbot_textscreen')
		textscreen:SetPos(tr.HitPos + tr.HitNormal * 6)

		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), -90)

		textscreen:SetAngles(ang)

		isnew = true

		undo.Create('DTextscreen')
		undo.AddEntity(textscreen)
		undo.SetPlayer(ply)
		undo.Finish()

		ply:AddCleanup('dtextscreen', textscreen)
		ply:AddCount('dtextscreens', textscreen)
	end

	if CLIENT then return true end

	local finaltext

	for i = 1, 16 do
		local text = (self:GetClientInfo('text_' .. i) or ''):replace('\n', ':lul:'):replace('\0', ':lul:'):replace('\2', ':lul:')

		if text ~= '' then
			local newline = tobool(self:GetClientInfo('newline_' .. i))
			local font = tonumber(self:GetClientInfo('font_' .. i)) or 0
			local size = tonumber(self:GetClientInfo('size_' .. i)) or 24
			local r = tonumber(self:GetClientInfo('color_' .. i .. '_r')) or 200
			local g = tonumber(self:GetClientInfo('color_' .. i .. '_g')) or 200
			local b = tonumber(self:GetClientInfo('color_' .. i .. '_b')) or 200
			local a = tonumber(self:GetClientInfo('color_' .. i .. '_a')) or 200

			if finaltext then
				if newline then
					finaltext = finaltext .. '\n' .. text
				else
					finaltext = finaltext .. '\2' .. text
				end
			else
				finaltext = text
			end

			textscreen['SetColor' .. i](textscreen, Color(r, g, b, a))
			textscreen['SetTextSize' .. i](textscreen, size:clamp(8, 128))
			textscreen['SetFontID' .. i](textscreen, font:clamp(0, #TEXT_SCREEN_AVALIABLE_FONTS - 1))
			textscreen['SetAlign' .. i](textscreen, 0)
		else
			textscreen['SetTextColor' .. i](textscreen, -0x37373701)
			textscreen['SetTextSize' .. i](textscreen, 24)
			textscreen['SetFontID' .. i](textscreen, 0)
			textscreen['SetAlign' .. i](textscreen, 0)
		end
	end

	if finaltext then
		textscreen:SetTextSlot1(finaltext:sub(1, 0xFFF))
		textscreen:SetTextSlot2(finaltext:sub(0x1000, 0x1FFF))
		textscreen:SetTextSlot3(finaltext:sub(0x2000, 0x2FFF))
		textscreen:SetTextSlot4(finaltext:sub(0x3000, 0x3FFF))
	else
		textscreen:SetTextSlot1('')
		textscreen:SetTextSlot2('')
		textscreen:SetTextSlot3('')
		textscreen:SetTextSlot4('')
	end

	if isnew then
		textscreen:Spawn()
		textscreen:Activate()
	end

	return true
end
