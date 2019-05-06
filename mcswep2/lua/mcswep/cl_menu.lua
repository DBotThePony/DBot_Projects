
--[[
Copyright (C) 2016-2019 DBotThePony


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

]]

local self = MCSWEP2
local mc = MCSWEP2

self.MouseX = self.MouseX or ScrWL() / 2
self.MouseY = self.MouseY or ScrHL() / 2

function self.OpenMenu()
	if not IsValid(self.MENU) then self.MENU = self.BuildMenu() end
	gui.SetMousePos(self.MouseX, self.MouseY)
	self.MENU:SetVisible(true)
	self.MENU:Center()
	self.MENU:MakePopup()
	return self.MENU
end

function self.CloseMenu()
	if not IsValid(self.MENU) then self.MENU = self.BuildMenu() end
	self.MouseX, self.MouseY = gui.MousePos()
	self.MENU:Close()
end

local SpawnWidth = 64
local SpawnHeight = 64
local Spacing = 66

local function SpawniconClick(self)
	RunConsoleCommand('cl_mc_blockid', self.BlockID)
	RunConsoleCommand('cl_mc_blockskin', self.CSkin)
	mc.CloseMenu()
	surface.PlaySound('ui/buttonclickrelease.wav')
end

surface.CreateFont('MCSWEP2.MaterialName', {
	font = 'Roboto',
	size = 32,
	weight = 600,
})

local function Populate(canvas)
	if not IsValid(canvas) then return end

	canvas:Clear()

	local w, h = canvas:GetSize()
	local takenx = 0
	local takeny = -1

	local t = {}

	for id, data in pairs(mc.GetRegisteredBlocks()) do
		t[data.material] = t[data.material] or {}
		t[data.material][id] = data
	end

	local shifty = 0

	for mat, mdata in pairs(t) do
		local lab = canvas:Add('DLabel')
		lab:SetText(MCSWEP2.GetMaterialName(mat))
		lab:SetFont('MCSWEP2.MaterialName')
		lab:SizeToContents()

		takeny = takeny + 1
		lab:SetPos(4, takeny * Spacing + 16)
		takeny = takeny + 1
		takenx = 0

		for id, data in pairs(mdata) do
			for skinid, skin in ipairs(data.skins) do
				if takenx + Spacing > w then
					takenx = 0
					takeny = takeny + 1
				end

				local icon = canvas:Add('SpawnIcon')
				icon:SetPos(takenx, takeny * Spacing)
				icon:SetSize(SpawnWidth, SpawnHeight)
				icon:SetModel(data.model, skin)
				icon.Model = data.model
				icon.BlockID = id
				icon.DoClick = SpawniconClick
				icon.CSkin = skin

				icon:SetTooltip(('Name: %s\nMaterial: %s\nModel: %s\nSkin: %s\nHealth: %s'):format(data.name, MCSWEP2.GetMaterialName(data.material), data.model, skin, data.health))

				takenx = takenx + Spacing
			end
		end
	end

	canvas:SetSize(w, takeny * Spacing + Spacing)
	canvas.scroll:InvalidateLayout()
end

local Meta = {
	Paint = function(self, w, h)
		surface.SetDrawColor(200, 200, 200)
		surface.DrawRect(0, 0, w, h)
	end,

	OnMousePressed = function(self, key)
		if key ~= MOUSE_LEFT then return end
		self.Trap = true
		self.StartX, self.StartY = gui.MousePos()
		self.WindowX, self.WindowY = self.pnl:GetPos()
	end,

	OnMouseReleased = function(self)
		self.Trap = false
	end,

	Think = function(self)
		if not self.Trap then return end

		if not input.IsMouseDown(MOUSE_LEFT) then
			self.Trap = false
			return
		end

		local pnl = self.pnl

		local cx, cy = gui.MousePos()
		local x, y = cx - self.WindowX + 16, cy - self.WindowY + 16

		pnl:SetSize(x, y)

		if x ~= self.lx or y ~= self.ly then
			Populate(pnl.canvas)
		end

		self.lx = x
		self.ly = y
	end,
}

function self.BuildMenu()
	local self = vgui.Create('DFrame')
	self:SetTitle('MCSwep/2')
	self:SetSize(ScrWL() - 100, ScrHL() - 100)
	self:Center()
	self:MakePopup()
	self:SetDeleteOnClose(false)

	local bottom = self:Add('EditablePanel')
	bottom:Dock(BOTTOM)
	bottom:SetHeight(20)

	local dragbutton = bottom:Add('EditablePanel')
	dragbutton:Dock(RIGHT)
	dragbutton:SetSize(18, 18)
	dragbutton:DockMargin(1, 1, 1, 1)
	dragbutton:SetCursor('sizenwse')
	for k, v in pairs(Meta) do
		dragbutton[k] = v
	end
	dragbutton.pnl = self

	local ResetButton = bottom:Add('DLabel')
	ResetButton:SetText('Reset window size')
	ResetButton:SetMouseInputEnabled(true)
	ResetButton:SetCursor('hand')
	ResetButton.DoClick = function()
		self:SetSize(ScrWL() - 100, ScrHL() - 100)
		self:Center()

		timer.Simple(0, function()
			if not IsValid(self) then return end
			Populate(self.canvas)
		end)
	end
	ResetButton:Dock(RIGHT)
	ResetButton:SizeToContents()
	ResetButton:DockMargin(4, 0, 4, 0)

	local scroll = self:Add('DScrollPanel')
	scroll:Dock(FILL)
	scroll:DockMargin(4, 4, 4, 4)

	local right = self:Add('EditablePanel')
	right:Dock(RIGHT)
	right:SetWidth(300)

	local button = right:Add('DButton')
	button:SetText('Rebuild this menu')
	button.DoClick = function()
		mc.MouseX, mc.MouseY = gui.MousePos()
		self:Remove()
		mc.OpenMenu()
	end

	button:Dock(BOTTOM)

	local dpanel = right:Add('DPanel')
	dpanel:Dock(FILL)

	local scroll2 = dpanel:Add('DScrollPanel')
	scroll2:Dock(FILL)

	local form = scroll2:Add('DForm')
	scroll2:AddItem(form)

	form:SetName('Options')
	form:SetWidth(300)
	form:CheckBox('Swap place/delete mouse buttons', 'cl_mc_swap')
	form:CheckBox('Use player angles only when\nrotating blocks', 'cl_mc_rotate_ang')
	form:CheckBox('Draw lines on blocks', 'cl_mc_drawlines')
	form:CheckBox('Draw place position', 'cl_mc_drawwdir')
	form:CheckBox('Draw block ghost model', 'cl_mc_drawblock')
	form:CheckBox('Draw block ghost model in color', 'cl_mc_drawblock_color')
	form:CheckBox('Force blocks to render with "point"\ntexture filter. Due to unknown GMod bug,\nthis breaks texture filtering for all things\nin unknown cases', 'cl_mc_filter')
	form:CheckBox('DEBUG: Do not draw blocks', 'cl_mc_nodraw')

	local lab = Label('Block place ghost color', form)
	form:AddItem(lab)
	lab:SetDark(true)

	local button = vgui.Create('DButton', form)
	form:AddItem(button)
	button:SetText('Reset place Color')
	button.DoClick = function()
		RunConsoleCommand('cl_mc_drawblock_color_r', '0')
		RunConsoleCommand('cl_mc_drawblock_color_g', '50')
		RunConsoleCommand('cl_mc_drawblock_color_b', '255')
	end

	local mixer = vgui.Create('DColorMixer', form)
	form:AddItem(mixer)
	mixer:SetConVarR('cl_mc_drawblock_color_r')
	mixer:SetConVarG('cl_mc_drawblock_color_g')
	mixer:SetConVarB('cl_mc_drawblock_color_b')
	mixer:SetAlphaBar(false)

	local lab = Label('Block remove ghost color', form)
	form:AddItem(lab)
	lab:SetDark(true)

	local button = vgui.Create('DButton', form)
	form:AddItem(button)
	button:SetText('Reset remove Color')
	button.DoClick = function()
		RunConsoleCommand('cl_mc_drawblock_dcolor_r', '200')
		RunConsoleCommand('cl_mc_drawblock_dcolor_g', '0')
		RunConsoleCommand('cl_mc_drawblock_dcolor_b', '0')
	end

	local mixer = vgui.Create('DColorMixer', form)
	form:AddItem(mixer)
	mixer:SetConVarR('cl_mc_drawblock_dcolor_r')
	mixer:SetConVarG('cl_mc_drawblock_dcolor_g')
	mixer:SetConVarB('cl_mc_drawblock_dcolor_b')
	mixer:SetAlphaBar(false)

	local canvas = self:Add('EditablePanel')
	scroll:AddItem(canvas)
	canvas:Dock(FILL)
	canvas.scroll = scroll
	self.canvas = canvas

	function self:OnClose()
		local x, y = gui.MousePos()
		if x == 0 and y == 0 then return end
		mc.MouseX, mc.MouseY = x, y
	end

	canvas.PerformLayout = function()
		if not self.Populated then
			self.Populated = true
			timer.Simple(0, function() Populate(canvas) end)
		end
	end

	return self
end

net.Receive('MCSWEP2.OpenMenu', self.OpenMenu)

