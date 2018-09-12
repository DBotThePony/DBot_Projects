
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


local DLib = DLib
local properties = properties
local IsValid = FindMetaTable('Entity').IsValid
local hook = hook

if not DTextScreens.FONTS then
	DLib.Message('FATAL: Unable to find DTextScreens.FONTS for textscreens!')
	return
end

DLib.RegisterAddonName('TextScreens')

for k, font in pairs(DTextScreens.FONTS) do
	if font.definition then
		surface.CreateFont(font.id, font.definition)
	end
end

local privs = DLib.CAMIWatchdog('dtextscreen', nil, 'dtextscreen_new', 'dtextscreen_remove', 'dtextscreen_reload')

properties.Add('dtextscreen_new', {
	Type = 'simple',
	MenuLabel = 'gui.property.dtextscreens.new',
	Order = 1920,
	MenuIcon = 'icon16/font_add.png',

	Filter = function(self, ent)
		if not privs:HasPermission('dtextscreen_new') then return false end
		if not IsValid(ent) then return false end
		if ent:GetClass() ~= 'dbot_textscreen' then return false end
		if ent:GetIsPersistent() then return false end
		return true
	end,

	Action = function(self, ent, tr)
		RunConsoleCommand('dtextscreen_new', ent:EntIndex())
	end
})

properties.Add('dtextscreen_remove', {
	Type = 'simple',
	MenuLabel = 'gui.property.dtextscreens.remove',
	Order = 1921,
	MenuIcon = 'icon16/font_delete.png',

	Filter = function(self, ent)
		if not privs:HasPermission('dtextscreen_remove') then return false end
		if not IsValid(ent) then return false end
		if ent:GetClass() ~= 'dbot_textscreen' then return false end
		if not ent:GetIsPersistent() then return false end
		return true
	end,

	Action = function(self, ent, tr)
		RunConsoleCommand('dtextscreen_remove', ent:EntIndex())
	end
})
