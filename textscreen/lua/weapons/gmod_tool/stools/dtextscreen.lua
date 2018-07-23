
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
		['align_' .. i] = '0',
		['font_' .. i] = '0',
		['size_' .. i] = '24',
		['color_' .. i .. '_r'] = '200',
		['color_' .. i .. '_g'] = '200',
		['color_' .. i .. '_b'] = '200',
		['color_' .. i .. '_a'] = '200'
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

			local canvas = vgui.Create('EditablePanel', spoiler)

			local toparent = self:Button('gui.tool.textscreens.reset_this')

			toparent.DoClick = function()
				for k, v in pairs(perCategory[i]) do
					RunConsoleCommand('dtextscreen_' .. k, v)
				end
			end

			toparent:SetParent(canvas)
			toparent:Dock(TOP)

			local toparent, toparent2 = self:TextEntry('gui.tool.textscreens.text', 'dtextscreen_text_' .. i)
			toparent2:SetParent(canvas)
			toparent2:Dock(TOP)
			toparent:SetParent(canvas)
			toparent:Dock(TOP)
			toparent = self:NumSlider('gui.tool.textscreens.fontsize', 'dtextscreen_size_' .. i, 8, 128, 0)
			toparent:SetParent(canvas)
			toparent:Dock(TOP)
			toparent = self:CheckBox('gui.tool.textscreens.newline', 'dtextscreen_newline_' .. i)
			toparent:SetParent(canvas)
			toparent:Dock(TOP)

			local mixer = vgui.Create('DColorMixer', spoiler)
			mixer:Dock(TOP)
			mixer:SetAlphaBar(true)
			mixer:SetConVarR('dtextscreen_color_' .. i .. '_r')
			mixer:SetConVarG('dtextscreen_color_' .. i .. '_g')
			mixer:SetConVarB('dtextscreen_color_' .. i .. '_b')
			mixer:SetConVarA('dtextscreen_color_' .. i .. '_a')

			spoiler:SetContents(canvas)
		end
	end
end
