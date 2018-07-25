
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
