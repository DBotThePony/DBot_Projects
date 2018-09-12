
-- Copyright (C) 2016-2018 DBot

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


DLib.RegisterAddonName('BlackFlat Skin')

_G.DFlatBlack = _G.DFlatBlack or {}
local FontIsOverrided = false

local function OverrideFont(status)
	if not status and FontIsOverrided then
		surface.CreateFont('DermaDefault', {
			font = system.IsOSX() and 'Helvetica' or system.IsLinux() and 'Roboto' or 'Tahoma',
			size = 13,
			weight = 500,
			extended = true,
			antialias = true,
		})

		surface.CreateFont('DermaDefaultBold', {
			font = system.IsOSX() and 'Helvetica' or system.IsLinux() and 'Roboto' or 'Tahoma',
			size = 13,
			weight = 700,
			extended = true,
			antialias = false,
		})

		FontIsOverrided = false
	elseif status and not FontIsOverrided then
		surface.CreateFont('DermaDefault', {
			font = 'Roboto',
			size = 16,
			weight = 500,
			extended = true,
			antialias = true,
		})

		surface.CreateFont('DermaDefaultBold', {
			font = 'Roboto',
			size = 17,
			weight = 600,
			extended = true,
			antialias = true,
		})

		FontIsOverrided = true
	end
end

local ENABLE_SMOOTH = CreateClientConVar('cl_flatblack_smoothbar', '1', true, false, 'Enable smooth bars')
local ENABLE = CreateClientConVar('cl_flatblack', '1', true, false, 'Enable Flat Black skin')

cvars.AddChangeCallback('cl_flatblack', derma.RefreshSkins, 'FlatBlack')

hook.Add('ForceDermaSkin', 'DSkin_Flat', function()
	if ENABLE:GetBool() then
		OverrideFont(true)
		return 'DLib_Black'
	else
		OverrideFont(false)
	end
end)

derma.RefreshSkins()

local function smoothEnabled()
	return ENABLE:GetBool() and ENABLE_SMOOTH:GetBool()
end

local reOverride

local function fuckupCheck(self)
	local weAreFuckedUp =
		self.GetScroll ~= getScroll or
		self.SetScroll ~= setScroll or
		self.GetOffset ~= getOffset

	if weAreFuckedUp then
		reOverride(self)
	end
end

local function realUpdate(self)
	fuckupCheck(self)
	self:InvalidateLayout()

	if self:GetParent().OnVScroll then
		self:GetParent():OnVScroll(self:GetOffset())
	else
		self:GetParent():InvalidateLayout()
	end
end

local function updateFunction(self)
	fuckupCheck(self)
	if not self.Enabled then
		self.Scroll = 0
		self.RealScroll = 0
		return
	end

	if not smoothEnabled() then
		realUpdate(self)
		return
	end

	self.RealScroll = self.RealScroll or 0
	local Update = self.Scroll ~= self.RealScroll

	if smoothEnabled() then
		self.Scroll = Lerp(FrameTime() * 4, self.Scroll, self.RealScroll)
	else
		self.Scroll = self.RealScroll
	end

	if not Update then return end
	realUpdate(self)
end

local function getScroll(self)
	fuckupCheck(self)
	if not self.Enabled then return 0 end
	self.RealScroll = self.RealScroll or 0
	return self.RealScroll
end

local function barThink(self)
	fuckupCheck(self)
	if smoothEnabled() then
		self:UpdateScroll()
	end

	if self.olderBarThink then
		return self:olderBarThink()
	elseif self.oldBarThink then
		return self:oldBarThink()
	end
end

local function setScroll(self, scrll)
	self.RealScroll = math.Clamp(scrll, 0, self.CanvasSize)
	self:UpdateScroll()
end

local function getOffset(self)
	fuckupCheck(self)
	if not self.Enabled then return 0 end

	if smoothEnabled() then
		return -self.Scroll
	else
		return -(self.RealScroll or 0)
	end
end

function reOverride(self)
	self.GetScroll = getScroll
	self.SetScroll = setScroll
	self.GetOffset = getOffset
	self.Think = barThink
	self.UpdateScroll = updateFunction
end

local function UpdateScrollBar()
	local get = vgui.GetControlTable('DVScrollBar')

	DFlatBlack.DVScrollBar = DFlatBlack.DVScrollBar or get and table.Copy(get)
	local DVScrollBar = DFlatBlack.DVScrollBar

	if not DVScrollBar then return end

	local DVScrollBar = table.Copy(DVScrollBar)

	DVScrollBar.oldBarThink = DVScrollBar.Think
	reOverride(DVScrollBar)

	derma.DefineControl("DVScrollBar", "A Scrollbar", DVScrollBar, "Panel")
end

timer.Simple(0, UpdateScrollBar)
