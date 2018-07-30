
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
		['shadow_' .. i] = '0',
		['align_left_' .. i] = '0',
		['align_right_' .. i] = '0',
		['align_top_' .. i] = '0',
		['align_bottom_' .. i] = '0',
		['font_' .. i] = '0',
		['size_' .. i] = '24',
		['rotate_' .. i] = '0',
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

TOOL.ClientConVar['overall_size'] = '10'
TOOL.ClientConVar['movable'] = '0'
TOOL.ClientConVar['doubledraw'] = '1'
TOOL.ClientConVar['always_draw'] = '0'
TOOL.ClientConVar['never_draw'] = '0'

if CLIENT then
	TOOL.Information = {
		{name = 'left'},
		{name = 'right'},
	}

	function TOOL:BuildCPanel()
		if not IsValid(self) then return end

		local manager = vgui.Create('ControlPresets', self)
		self:AddItem(manager)

		for k, v in pairs(TOOL.ClientConVar) do
			manager:AddConVar('dtextscreen_' .. k)
		end

		local oldOnSelect = manager.OnSelect

		function manager:OnSelect(...)
			oldOnSelect(self, ...)
			hook.Run('DTextScreen.SettingsUpdate')
		end

		manager:SetPreset('dtextscreens')

		self:Button('gui.tool.textscreens.reset').DoClick = function()
			for k, v in pairs(TOOL.ClientConVar) do
				RunConsoleCommand('dtextscreen_' .. k, v)
			end

			hook.Run('DTextScreen.SettingsUpdate')
		end

		self:CheckBox('gui.tool.textscreens.movable', 'dtextscreen_movable')
		self:CheckBox('gui.tool.textscreens.doubledraw', 'dtextscreen_doubledraw')
		self:CheckBox('gui.tool.textscreens.alwaysdraw', 'dtextscreen_always_draw')
		self:CheckBox('gui.tool.textscreens.neverdraw', 'dtextscreen_never_draw')

		local combobox = self:ComboBox('gui.tool.textscreens.font_all')

		for i, fontdata in ipairs(DTextScreens.FONTS) do
			combobox:AddChoice(fontdata.name)
		end

		combobox:SetValue(DTextScreens.FONTS[1].name)
		combobox.OnSelect = function(_, index, value)
			for i = 1, 16 do
				RunConsoleCommand('dtextscreen_font_' .. i, tostring(index - 1))
			end

			hook.Run('DTextScreen.SettingsUpdate')
		end

		self:NumSlider('gui.tool.textscreens.overall_size', 'dtextscreen_overall_size', 0.1, 60, 2)

		for i = 1, 16 do
			local spoiler = vgui.Create('DForm', self)
			spoiler:Dock(TOP)
			spoiler:SetExpanded(false)
			spoiler:SetLabel('gui.tool.textscreens.spoiler', i)
			spoiler:DockMargin(0, 8, 0, 8)

			local toparent = spoiler:Button('gui.tool.textscreens.reset_this')

			toparent.DoClick = function()
				for k, v in pairs(perCategory[i]) do
					RunConsoleCommand('dtextscreen_' .. k, v)
				end

				hook.Run('DTextScreen.SettingsUpdate')
			end

			if i ~= 16 and i ~= 1 then
				local toparent = spoiler:Button('gui.tool.textscreens.reset_this_under')

				toparent.DoClick = function()
					for i2 = i, 16 do
						for k, v in pairs(perCategory[i2]) do
							RunConsoleCommand('dtextscreen_' .. k, v)
						end
					end

					hook.Run('DTextScreen.SettingsUpdate')
				end
			end

			local toparent = spoiler:ComboBox('gui.tool.textscreens.font')

			for i, fontdata in ipairs(DTextScreens.FONTS) do
				toparent:AddChoice(fontdata.name)
			end

			hook.Add('DTextScreen.SettingsUpdate', toparent, function()
				toparent:SetValue(DTextScreens.FONTS[(GetConVar('dtextscreen_font_' .. i):GetInt() + 1):clamp(1, #DTextScreens.FONTS + 1)].name)
			end)

			toparent.OnSelect = function(_, index, value)
				RunConsoleCommand('dtextscreen_font_' .. i, tostring(index - 1))
			end

			local toparent = spoiler:ComboBox('gui.tool.textscreens.align.line')

			toparent:AddChoice('gui.tool.textscreens.align.center')
			toparent:AddChoice('gui.tool.textscreens.align.right')
			toparent:AddChoice('gui.tool.textscreens.align.left')

			hook.Add('DTextScreen.SettingsUpdate', toparent, function()
				toparent:SetValue(
					GetConVar('dtextscreen_align_left_' .. i):GetBool() and 'gui.tool.textscreens.align.left' or
					GetConVar('dtextscreen_align_right_' .. i):GetBool() and 'gui.tool.textscreens.align.right' or
					'gui.tool.textscreens.align.center'
				)
			end)

			toparent.OnSelect = function(_, index, value)
				RunConsoleCommand('dtextscreen_align_left_' .. i, index == 3 and '1' or '0')
				RunConsoleCommand('dtextscreen_align_right_' .. i, index == 2 and '1' or '0')
			end

			local toparent = spoiler:ComboBox('gui.tool.textscreens.align.row')

			toparent:AddChoice('gui.tool.textscreens.align.center')
			toparent:AddChoice('gui.tool.textscreens.align.top')
			toparent:AddChoice('gui.tool.textscreens.align.bottom')

			hook.Add('DTextScreen.SettingsUpdate', toparent, function()
				toparent:SetValue(
					GetConVar('dtextscreen_align_top_' .. i):GetBool() and 'gui.tool.textscreens.align.top' or
					GetConVar('dtextscreen_align_bottom_' .. i):GetBool() and 'gui.tool.textscreens.align.bottom' or
					'gui.tool.textscreens.align.center'
				)
			end)

			toparent.OnSelect = function(_, index, value)
				RunConsoleCommand('dtextscreen_align_top_' .. i, index == 2 and '1' or '0')
				RunConsoleCommand('dtextscreen_align_bottom_' .. i, index == 3 and '1' or '0')
			end

			spoiler:TextEntry('gui.tool.textscreens.text', 'dtextscreen_text_' .. i)
			spoiler:NumSlider('gui.tool.textscreens.fontsize', 'dtextscreen_size_' .. i, 8, 128, 0)
			spoiler:NumSlider('gui.tool.textscreens.rotate', 'dtextscreen_rotate_' .. i, -180, 180, 2)
			spoiler:CheckBox('gui.tool.textscreens.newline', 'dtextscreen_newline_' .. i)
			spoiler:CheckBox('gui.tool.textscreens.shadow', 'dtextscreen_shadow_' .. i)

			local mixer = vgui.Create('DColorMixer', spoiler)
			mixer:Dock(TOP)
			mixer:DockMargin(8, 8, 8, 8)
			mixer:SetAlphaBar(true)
			mixer:SetConVarR('dtextscreen_color_' .. i .. '_r')
			mixer:SetConVarG('dtextscreen_color_' .. i .. '_g')
			mixer:SetConVarB('dtextscreen_color_' .. i .. '_b')
			mixer:SetConVarA('dtextscreen_color_' .. i .. '_a')

			spoiler:AddItem(mixer)
		end

		hook.Run('DTextScreen.SettingsUpdate')
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
			local shadow = ent['GetShadow' .. i](ent)
			local rotate = ent['GetTextRotation' .. i](ent)

			local left, right, top, bottom =
				align:band(DTextScreens.ALIGN_LEFT) == DTextScreens.ALIGN_LEFT,
				align:band(DTextScreens.ALIGN_RIGHT) == DTextScreens.ALIGN_RIGHT,
				align:band(DTextScreens.ALIGN_TOP) == DTextScreens.ALIGN_TOP,
				align:band(DTextScreens.ALIGN_BOTTOM) == DTextScreens.ALIGN_BOTTOM,

			RunConsoleCommand('dtextscreen_align_left_' .. i, left and '1' or '0')
			RunConsoleCommand('dtextscreen_align_right_' .. i, right and '1' or '0')
			RunConsoleCommand('dtextscreen_align_top_' .. i, top and '1' or '0')
			RunConsoleCommand('dtextscreen_align_bottom_' .. i, bottom and '1' or '0')
			RunConsoleCommand('dtextscreen_shadow_' .. i, shadow and '1' or '0')
			RunConsoleCommand('dtextscreen_font_' .. i, font:tostring())
			RunConsoleCommand('dtextscreen_size_' .. i, size:tostring())
			RunConsoleCommand('dtextscreen_rotate_' .. i, rotate:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_r', color.r:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_g', color.g:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_b', color.b:tostring())
			RunConsoleCommand('dtextscreen_color_' .. i .. '_a', color.a:tostring())
		end

		RunConsoleCommand('dtextscreen_doubledraw', ent:GetDoubleDraw() and '1' or '0')
		RunConsoleCommand('dtextscreen_always_draw', ent:GetAlwaysDraw() and '1' or '0')
		RunConsoleCommand('dtextscreen_never_draw', ent:GetNeverDraw() and '1' or '0')
		RunConsoleCommand('dtextscreen_movable', ent:GetIsMovable() and '1' or '0')

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

		for i = total, 16 do
			RunConsoleCommand('dtextscreen_text_' .. i, '')
			RunConsoleCommand('dtextscreen_newline_' .. i, '1')
		end

		hook.Run('DTextScreen.SettingsUpdate')
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

		textscreen:SetAlwaysDraw(tobool(self:GetClientInfo('always_draw')))
		textscreen:SetNeverDraw(tobool(self:GetClientInfo('never_draw')))

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

	textscreen:SetDoubleDraw(tobool(self:GetClientInfo('doubledraw')))
	textscreen:SetIsMovable(tobool(self:GetClientInfo('movable')))
	textscreen:SetOverallSize(self:GetClientNumber('overall_size', 10):clamp(0.1, 60))

	local finaltext

	for i = 1, 16 do
		local text = (self:GetClientInfo('text_' .. i) or ''):replace('\n', ':lul:'):replace('\0', ':lul:'):replace('\2', ':lul:')

		if text ~= '' then
			local newline = tobool(self:GetClientInfo('newline_' .. i))
			local shadow = tobool(self:GetClientInfo('shadow_' .. i))
			local left = tobool(self:GetClientInfo('align_left_' .. i))
			local right = tobool(self:GetClientInfo('align_right_' .. i))
			local top = tobool(self:GetClientInfo('align_top_' .. i))
			local bottom = tobool(self:GetClientInfo('align_bottom_' .. i))

			local font = self:GetClientNumber('font_' .. i, 0)
			local size = self:GetClientNumber('size_' .. i, 24)
			local rotate = self:GetClientNumber('rotate_' .. i, 0):clamp(-180, 180)
			local r = self:GetClientNumber('color_' .. i .. '_r', 200)
			local g = self:GetClientNumber('color_' .. i .. '_g', 200)
			local b = self:GetClientNumber('color_' .. i .. '_b', 200)
			local a = self:GetClientNumber('color_' .. i .. '_a', 200)

			local alignFlags = 0

			if left then
				alignFlags = alignFlags + DTextScreens.ALIGN_LEFT
			end

			if right then
				alignFlags = alignFlags + DTextScreens.ALIGN_RIGHT
			end

			if top then
				alignFlags = alignFlags + DTextScreens.ALIGN_TOP
			end

			if bottom then
				alignFlags = alignFlags + DTextScreens.ALIGN_BOTTOM
			end

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
			textscreen['SetFontID' .. i](textscreen, font:clamp(0, #DTextScreens.FONTS - 1))
			textscreen['SetAlign' .. i](textscreen, alignFlags)
			textscreen['SetShadow' .. i](textscreen, shadow)
			textscreen['SetTextRotation' .. i](textscreen, rotate)
		else
			textscreen['SetTextColor' .. i](textscreen, -0x37373701)
			textscreen['SetTextSize' .. i](textscreen, 24)
			textscreen['SetFontID' .. i](textscreen, 0)
			textscreen['SetAlign' .. i](textscreen, 0)
			textscreen['SetShadow' .. i](textscreen, false)
			textscreen['SetTextRotation' .. i](textscreen, 0)
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
