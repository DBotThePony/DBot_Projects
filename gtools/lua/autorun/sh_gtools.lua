
--[[
Copyright (C) 2016-2017 DBot

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

local Green = Color(0, 200, 0)
local Gray = Color(200, 200, 200)

GTools.Grey = Gray
GTools.Gray = Gray
GTools.Green = Green

function Message(...)
	MsgC(Green, '[GTools] ', Gray, ...)
	MsgC('\n')
end

function AddAutoSelectConVars(tab)
	tab.select_material = 0
	tab.select_model = 0
	tab.select_color = 0
	tab.select_only_constrained = 1
	tab.select_range = 512
	tab.select_sort = 2
	tab.select_invert = 0
	tab.select_print = 0
	tab.select_owned = 0
end

function CheckColor(col)
	return col.r ~= 255 or col.g ~= 255 or col.b ~= 255
end

function WriteEntityList(tab)
	local toSend = {}
	
	for k, v in ipairs(tab) do
		if IsValid(v) and v:EntIndex() > 0 then
			table.insert(toSend, v)
		end
	end
	
	net.WriteUInt(#toSend, 12)
	
	for k, v in ipairs(toSend) do
		net.WriteUInt(v:EntIndex(), 12)
	end
end

function ReadEntityList()
	local max = net.ReadUInt(12)
	local reply = {}
	
	for i = 1, max do
		local ent = Entity(net.ReadUInt(12))
		
		if ent:IsValid() then
			table.insert(reply, ent)
		end
	end
	
	return reply
end

function GenericTableClear(Tab)
	local toRemove = {}
	
	for k, v in ipairs(Tab) do
		if not v:IsValid() then
			table.insert(toRemove, k)
		end
	end
	
	for k, v in ipairs(toRemove) do
		table.remove(Tab, v - k + 1)
	end
	
	return tab, #toRemove ~= 0
end

function HasValueFast(arr, val)
	for i = 1, #arr do
		if arr[i] == val then return true end
	end
	
	return false
end

HaveValueFast = HasValueFast

function PrintEntity(ent)
	Message(color_white, tostring(ent), GTools.Grey, ', class ', color_white, ent:GetClass())
end

function Prepend(arr, val)
	for i = #arr, 1, -1 do
		arr[i + i] = arr[i]
	end
	
	arr[1] = val
end
