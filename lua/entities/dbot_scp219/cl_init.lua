
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

include('shared.lua')

local function OpenMenu()
	local ent = net.ReadEntity()
	
	if not IsValid(ent) then return end
	
	local self = vgui.Create('DFrame')
	self:SetSize(200, 200)
	self:SetTitle('SCP-219')
	self:Center()
	self:MakePopup()
	
	local lab = self:Add('DLabel')
	lab:SetText('Strength (min 1):')
	lab:Dock(TOP)
	
	local entry = self:Add('DTextEntry')
	entry:SetText('1')
	entry:Dock(TOP)
	
	local lab = self:Add('DLabel')
	lab:SetText('Duration (min 6):')
	lab:Dock(TOP)
	
	local entry2 = self:Add('DTextEntry')
	entry2:SetText('15')
	entry2:Dock(TOP)
	
	local button = self:Add('DButton')
	button:SetText('Launch')
	button.DoClick = function()
		local strength = tonumber(entry:GetText())
		local duration = tonumber(entry2:GetText())
		
		if strength and duration and strength >= 1 and duration > 5 then
			net.Start('SCP-219Menu')
			net.WriteEntity(ent)
			net.WriteUInt(math.ceil(strength), 32)
			net.WriteUInt(math.ceil(duration), 32)
			net.SendToServer()
		end
		
		self:Close()
	end
	
	button:Dock(TOP)
end

net.Receive('SCP-219Menu', OpenMenu)
