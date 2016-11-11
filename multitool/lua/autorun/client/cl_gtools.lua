
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

module('GTools', package.seeall)

surface.CreateFont('MultiTool.ScreenHeader', {
	font = 'Roboto',
	size = 48,
	weight = 800,
})

function MultiTool_AddSorterChoices(pnl)
	pnl:AddChoice('Unsorted', '1')
	pnl:AddChoice('Select the nearests to fire point first', '2')
	pnl:AddChoice('Select the far to fire point first', '3')
	pnl:AddChoice('Select x - X', '4')
	pnl:AddChoice('Select X - x', '5')
	pnl:AddChoice('Select y - Y', '6')
	pnl:AddChoice('Select Y - y', '7')
	
	pnl:AddChoice('Select x+y - X+Y', '8')
	pnl:AddChoice('Select X+Y - x+y', '9')
	pnl:AddChoice('Select x+Y - X+y', '10')
	pnl:AddChoice('Select X+y - x+Y', '11')
end

_G.MultiTool_AddSorterChoices = MultiTool_AddSorterChoices

function BuildPhysgunMenu(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	Panel:CheckBox('Draw physgun beams', 'physgun_drawbeams')
	Panel:CheckBox('Draw physgun halos', 'physgun_halo')
	Panel:NumSlider('Sensitivity', 'physgun_rotation_sensitivity', 0, 2, 4)
	Panel:NumSlider('Wheel speed', 'physgun_wheelspeed', 0, 5000, 0)
	
	local button = Panel:Button('Reset to default')
	
	function button:DoClick()
		RunConsoleCommand('physgun_drawbeams', '1')
		RunConsoleCommand('physgun_halo', '1')
		RunConsoleCommand('physgun_rotation_sensitivity', '0.05')
		RunConsoleCommand('physgun_wheelspeed', '10')
	end
end

PhysgunVars = {
	{'physgun_DampingFactor', 'Damping Factor', 0, 4, 2},
	{'physgun_maxAngular', 'Max Angular Velocity', 0, 32000, 0},
	{'physgun_maxAngularDamping', 'Max Angular Velocity Damping', 0, 32000, 0},
	{'physgun_maxrange', 'Max Range', 0, 8192, 0},
	{'physgun_maxSpeed', 'Max Speed', 0, 32000, 0},
	{'physgun_maxSpeedDamping', 'Max Speed Damping', 0, 32000, 0},
	{'physgun_timeToArrive', 'Time to arrive', 0, 4, 2},
	{'physgun_timeToArriveRagdoll', 'Time to arrive for ragdoll', 0, 4, 2},
}

PhysgunVarsDefault = {
	{'physgun_DampingFactor', '0.8'},
	{'physgun_limited', '0'},
	{'physgun_maxAngular', '5000'},
	{'physgun_maxAngularDamping', '10000'},
	{'physgun_maxrange', '4096'},
	{'physgun_maxSpeed', '5000'},
	{'physgun_maxSpeedDamping', '10000'},
	{'physgun_rotation_sensitivity', '0.05'},
	{'physgun_teleportDistance', '0'},
	{'physgun_timeToArrive', '0.05'},
	{'physgun_timeToArriveRagdoll', '0.01'},
}

Sliders = Sliders or {}

function BuildPhysgunMenuAdmin(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	local lab = Label('Only super admin can change this settings', Panel)
	lab:SetDark(true)
	Panel:AddItem(lab)
	
	local lab = Label('If you are an server owner and want to disable this menu\nyou need to set gtools_disable_physgun_config to 1 in server console.', Panel)
	lab:SetDark(true)
	lab:SetTooltip(lab:GetText())
	lab:SizeToContents()
	Panel:AddItem(lab)
	
	for k, data in ipairs(PhysgunVars) do
		local slider = Panel:NumSlider(data[2], '', data[3], data[4], data[5])
		slider:SetTooltip(data[2])
		
		Sliders[data[1]] = slider
		
		local ignore = true
		
		function slider:OnValueChanged(val)
			if ignore then return end
			
			timer.Create('_g_set_' .. data[1], 1, 1, function()
				RunConsoleCommand('_g_' .. data[1], tostring(val))
			end)
			
			timer.Create('_g_get_' .. data[1], 2, 1, function()
				if not IsValid(slider) then return end
				slider:SetValue(tonumber(GetGlobalString(data[1], 0) or 0) or 0)
			end)
		end
		
		timer.Simple(0.5, function()
			if IsValid(slider) then
				ignore = true
				slider:SetValue(tonumber(GetGlobalString(data[1], 0) or 0) or 0)
				ignore = false
			end
		end)
	end
	
	local button = Panel:Button('Reset to default')
	
	function button:DoClick()
		for i, data in ipairs(PhysgunVarsDefault) do
			if IsValid(Sliders[data[1]]) then
				Sliders[data[1]]:SetValue(tonumber(data[2]))
			end
		end
	end
end

function About(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()
	
	local lab = Label('GTools: By DBotThePony(Robot)', Panel)
	lab:SetDark(true)
	Panel:AddItem(lab)
	
	local button = Panel:Button('GTools workshop link')
	
	function button:DoClick()
		gui.OpenURL('http://steamcommunity.com/sharedfiles/filedetails/?id=796786540')
	end
	
	local button = Panel:Button('GTools repository')
	
	function button:DoClick()
		gui.OpenURL('https://git.dbot.serealia.ca/dbot/dbot_projects')
	end
end

function PreRender()
	if not LocalPlayer():IsValid() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not wep:IsValid() then return end
	
	if wep:GetClass() ~= 'gmod_tool' then return end
	
	pcall(hook.Run, 'PreDrawAnythingToolgun', LocalPlayer(), wep, wep:GetMode())
end

function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not LocalPlayer():IsValid() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not wep:IsValid() then return end
	
	if wep:GetClass() ~= 'gmod_tool' then return end
	
	hook.Run('PostDrawWorldToolgun', LocalPlayer(), wep, wep:GetMode())
end

function PreDrawOpaqueRenderables(a, b)
	if a or b then return end
	if not LocalPlayer():IsValid() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not wep:IsValid() then return end
	
	if wep:GetClass() ~= 'gmod_tool' then return end
	
	hook.Run('PreDrawWorldToolgun', LocalPlayer(), wep, wep:GetMode())
end

hook.Add('PopulateToolMenu', 'GTools.SpawnMenu', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'GTool.About', 'About GTools', '', '', About)
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'GTool.PhysgunSettings', 'Physgun Settings', '', '', BuildPhysgunMenu)
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'GTool.PhysgunSettingsAdmin', 'Physgun Settings', '', '', BuildPhysgunMenuAdmin)
end)

hook.Add('PostDrawTranslucentRenderables', 'GTools.DrawHooks', PostDrawTranslucentRenderables)
hook.Add('PreDrawOpaqueRenderables', 'GTools.DrawHooks', PreDrawOpaqueRenderables)
hook.Add('PreRender', 'GTools.DrawHooks', PreRender)
