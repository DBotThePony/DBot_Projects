
-- Copyright (C) 2018 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

if not spawnmenu then return end

local spawnmenu = spawnmenu
local DLib = DLib
local DToyBox = DToyBox
local vgui = vgui
local TOP = TOP
local FILL = FILL
local RIGHT = RIGHT

surface.CreateFont('DToyBox.LoadButtonText', {
	font = 'Roboto',
	size = 18,
	weight = 500
})

function DToyBox.BuildMenu()
	local canvas = vgui.Create('EditablePanel')
	local controls = vgui.Create('EditablePanel', canvas)
	controls:Dock(TOP)
	controls:SetSize(0, 34)

	local currentURL = 'https://steamcommunity.com/app/4000/workshop/'
	local wsid

	local loadThisAddon = vgui.Create('DButton', controls)
	loadThisAddon:Dock(RIGHT)
	loadThisAddon:SetText('gui.toybox.controls.button.browse')

	if not DToyBox.CanCommand() then
		loadThisAddon:SetText('gui.toybox.controls.button.not_avaliable')
	end

	loadThisAddon:SetEnabled(false)
	loadThisAddon:SetSize(190, 0)
	loadThisAddon:DockMargin(10, 0, 10, 0)
	loadThisAddon:SetFont('DToyBox.LoadButtonText')

	function loadThisAddon:UpdateStatus()
		if not DToyBox.CanCommand() then
			self:SetText('gui.toybox.controls.button.not_avaliable')
			self:SetEnabled(false)
			return
		end

		if wsid then
			if not DToyBox.ShouldLoadAddon(wsid) then
				self:SetText('gui.toybox.controls.button.enabled')
				self:SetEnabled(false)
			else
				self:SetText('gui.toybox.controls.button.ready')
				self:SetEnabled(true)
			end
		else
			self:SetText('gui.toybox.controls.button.browse')
			self:SetEnabled(false)
		end
	end

	function loadThisAddon:DoClick()
		if not wsid then return end
		if not DToyBox.ShouldLoadAddon(wsid) then return end
		DToyBox.RequestServerLoadAddon(wsid)
		self:SetText('gui.toybox.controls.button.busy')
		self:SetEnabled(false)
	end

	function loadThisAddon:OnItemAdded(itemid)
		if wsid == itemid then
			self:SetText('gui.toybox.controls.button.enabled')
			self:SetEnabled(false)
		end
	end

	hook.Add('DToyBox.ItemAdded', loadThisAddon, loadThisAddon.OnItemAdded)

	local HTML = vgui.Create('DHTML', canvas)
	HTML:Dock(FILL)
	HTML:OpenURL(currentURL)
	HTML:DockMargin(0, 10, 0, 0)

	hook.Add('VGUIMousePressed', HTML, function(self, pnlFocus)
		if self == pnlFocus then
			self:RequestFocus()
		end
	end)

	local htmlcontrols = vgui.Create('DHTMLControls', controls)
	htmlcontrols:Dock(FILL)
	htmlcontrols:SetHTML(HTML)
	htmlcontrols.AddressBar:SetText(currentURL)

	local oldCallback = HTML.OnBeginLoadingDocument

	HTML.OnBeginLoadingDocument = function(self, url)
		oldCallback(self, url)
		currentURL = url

		if url:startsWith('https://steamcommunity.com/sharedfiles/filedetails/?id=') then
			wsid = tonumber(url:sub(56):match('^[0-9]+'))
		else
			wsid = nil
		end

		loadThisAddon:UpdateStatus()
	end

	canvas:SetKeyboardInputEnabled(true)
	canvas:SetMouseInputEnabled(true)
	controls:SetKeyboardInputEnabled(true)
	controls:SetMouseInputEnabled(true)

	return canvas
end

spawnmenu.AddCreationTab('gui.toybox.tab', DToyBox.BuildMenu, 'icon16/wrench_orange.png', 1400, 'gui.toybox.tab_tip')
