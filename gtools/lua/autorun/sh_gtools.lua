
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
