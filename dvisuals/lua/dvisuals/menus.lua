
-- Enhanced Visuals for GMod
-- Copyright (C) 2018 DBot

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local function PopulateClient(self)
	if not IsValid(self) then return end

	self:Help('gui.dvisuals.override')

	for i, data in ipairs(DVisuals.ClientCVars) do
		local cvar = data[1]
		local desc = data[2]

		local checkbox = self:CheckBox(desc, cvar:GetName())
		checkbox:SetTooltip(DLib.i18n.localize(desc) .. '\n\n' .. DLib.i18n.localize('gui.dvisuals.cvarname', cvar:GetName()))
	end
end

hook.Add('PopulateToolMenu', 'HUDCommons.PopulateMenus', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'DVisuals.CLSettings', 'DVisuals', '', '', PopulateClient)
end)
