
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

local messages = DLib.chat.registerWithMessages({}, 'Borders')
local borders = func_border_data_ref
local LocalPlayer = LocalPlayer
local IsValid = IsValid

local function readBorder(borderData)
	local output = {}
	output.id = net.ReadUInt(64)
	output.pos = net.ReadVectorDouble()
	output.mins = net.ReadVectorDouble()
	output.maxs = net.ReadVectorDouble()
	output.yaw = net.ReadDouble()

	output.lastmodified = net.ReadUInt(64)
	output.modifiedby = net.ReadString()
	output.modifiedid = net.ReadString()
	output.createdby = net.ReadString()
	output.createdid = net.ReadString()

	for i, var in ipairs(borderData) do
		output[var[1]] = var.nwread()
	end

	return output
end

local function readBorderList()
	local str = net.ReadString()
	if str == '' then return false end

	local data = {}
	data.classname = str
	data.list = {}
	local amount = net.ReadUInt(16)

	for i = 1, amount do
		table.insert(data.list, readBorder(assert(borders[str], 'No reference data found for border ' .. str .. '!')))
	end

	return data
end

local function readBorders()
	local output = {}

	while true do
		local read = readBorderList()
		if not read then break end
		output[read.classname] = read
	end

	return read
end

local HOLDER, lastPos, STATUS_SIGN
local WAITING_WINDOW

local function openBorderEdit(borderData, classname, mins, maxs)
	local isNew = borderData == nil or borderData.id == nil

	if isNew then
		borderData = borderData or {}
		local ply = LocalPlayer()
		local tr = ply:GetEyeTrace()

		if not tr.Hit then
			Derma_Message('You are looking into void! wtf?', 'Error extracting eye trace', 'Okay :\'(')
			return
		end

		local pos = tr.HitPos
		local ang = (pos - ply:EyePos()):Angle()
		ang.p = 0
		ang.r = 0
		ang.y = math.floor(ang.y / 90 + 0.5) * 90

		borderData.pos = pos
		borderData.mins = borderData.mins or Vector(-250, 1, 0)
		borderData.maxs = borderData.maxs or Vector(250, 1, 500)
		borderData.yaw = ang.y

		for i, var in ipairs(borders[classname]) do
			borderData[var.name] = var.defaultLua
		end
	end

	local self = vgui.Create('DLib_WindowScroll')

	if isNew then
		self:SetTitle(' * New Border creation menu - ' .. classname)
		self:Label('Created by: ---')
		self:Label('Author SteamID: ---')
		self:Label('Last modified: ---')
		self:Label('Last modified by: ---')
		self:Label('Last modified SteamID: ---')
	else
		self:SetTitle('Border edit menu - ' .. borderData.id .. ' [' .. classname .. ']')
		self:Label('Created by: ' .. borderData.createdby)
		self:Label('Author SteamID: ' .. borderData.createdid)
		self:Label('Last modified: ' .. borderData.lastmodified)
		self:Label('Last modified by: ' .. borderData.modifiedby)
		self:Label('Last modified SteamID: ' .. borderData.modifiedid)
	end

	self:Label('Position')
	local X = self:AddPanel('DLib_NumberInput')
	X:SetText('X')
	X:SetValue(borderData.pos.x)
	local Y = self:AddPanel('DLib_NumberInput')
	Y:SetText('Y')
	Y:SetValue(borderData.pos.y)
	local Z = self:AddPanel('DLib_NumberInput')
	Z:SetText('Z')
	Z:SetValue(borderData.pos.z)

	self:Label('Minimals')
	local MINSX = self:AddPanel('DLib_NumberInput')
	X:SetText('X')
	X:SetValue(borderData.mins.x)
	local MINSY = self:AddPanel('DLib_NumberInput')
	Y:SetText('Y')
	Y:SetValue(borderData.mins.y)
	local MINSZ = self:AddPanel('DLib_NumberInput')
	Z:SetText('Z')
	Z:SetValue(borderData.mins.z)

	self:Label('Maximals')
	local MAXSX = self:AddPanel('DLib_NumberInput')
	X:SetText('X')
	X:SetValue(borderData.maxs.x)
	local MAXSY = self:AddPanel('DLib_NumberInput')
	Y:SetText('Y')
	Y:SetValue(borderData.maxs.y)
	local MAXSZ = self:AddPanel('DLib_NumberInput')
	Z:SetText('Z')
	Z:SetValue(borderData.maxs.z)

	local YAW = self:AddPanel('DLib_NumberInput')
	YAW:SetText('Yaw')
	YAW:SetValue(borderData.yaw)

	local specific = {}

	self:Label('Border specific data')
	for i, var in ipairs(borders[classname]) do
		if var.check2 == 'boolean' then
			local panel = self:AddPanel('DCheckBoxLabel')
			panel:SetChecked(borderData[var[1]])
			panel:SetText(var[1])
			specific[var[1]] = function() return panel:GetChecked() end
		elseif var.check2 == 'int' then
			local panel = self:AddPanel('DLib_NumberInput')
			panel:SetIsFloatAllowed(false)
			panel:SetValue(borderData[var[1]])
			panel:SetText(var[1])
			specific[var[1]] = function() return panel:GetNumber() end
		elseif var.check2 == 'float' then
			local panel = self:AddPanel('DLib_NumberInput')
			panel:SetValue(borderData[var[1]])
			panel:SetText(var[1])
			specific[var[1]] = function() return panel:GetNumber() end
		elseif var.check2 == 'string' then
			local panel = self:AddPanel('DLib_TextInput')
			panel:SetValue(borderData[var[1]])
			panel:SetText(var[1])
			specific[var[1]] = function() return panel:GetValue() end
		end
	end

	local apply = self:AddPanel('DButton')
	apply:SetText('Apply changes')

	function apply.DoClick()
		net.Start('func_border_edit')
		net.WriteBool(isNew)
		net.WriteString(classname)

		if not isNew then
			net.WriteUInt32(borderData.id)
		end

		borderData.pos = Vector(X:GetNumber(), Y:GetNumber(), Z:GetNumber())
		borderData.mins = Vector(MINSX:GetNumber(), MINSY:GetNumber(), MINSZ:GetNumber())
		borderData.maxs = Vector(MAXSX:GetNumber(), MAXSY:GetNumber(), MAXSZ:GetNumber())
		borderData.yaw = YAW:GetNumber()

		net.WriteVectorDouble(borderData.pos)
		net.WriteVectorDouble(borderData.mins)
		net.WriteVectorDouble(borderData.maxs)
		net.WriteVectorDouble(borderData.yaw)

		for i, var in ipairs(borders[classname]) do
			var.nwwrite(specific[var[1]]())
		end

		net.SendToServer()

		self:Close()
	end
end

local function receive()
	if not IsValid(HOLDER) then return end
	HOLDER:Clear()
	lastPos = nil

	local status = net.ReadUInt(8)

	if status == 2 then
		STATUS_SIGN:SetText('Status: No save data!')
		return
	elseif status == 1 then
		STATUS_SIGN:SetText('Status: No access!')
		return
	end

	local readData = readBorders()
	for borderClass, borderData in pairs(readData) do
		local id = borderData.id
		local x = borderData.pos.x
		local y = borderData.pos.y
		local z = borderData.pos.z
		local yaw = borderData.yaw
		local wide = borderData.maxs.x - borderData.mins.x
		local tall = borderData.maxs.y - borderData.mins.y
		local height = borderData.maxs.y - borderData.mins.y
		local line = HOLDER:AddLine(id, x, y, z, yaw, wide, tall, height, borderClass, '0')
		line.borderData = borderData
		line.classname = borderClass
	end

	HOLDER:SortByColumn(10)
end

local function Think()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if not IsValid(HOLDER) then return end
	if not HOLDER:IsVisible() then return end
	local pos = ply:EyePos()

	if lastPos and lastPos:Distance(pos) < 80 then return end
	lastPos = pos

	for i, line in pairs(HOLDER:GetLines()) do
		local x, y, z = line:GetValue(2), line:GetValue(3), line:GetValue(4)
		line:SetColumnText(10, string.format('%i Hu', Vector(x, y, z):Distance(pos)))
	end
end

local cami = DLib.CAMIWatchdog('func_border_menu')
cami:Track('func_border_view')

local function populate(self)
	if not IsValid(self) then return end

	self:Help('This tab holds all the borders stored for current map.\nIf you want to remove a border, you can do it here\nor right click on needed border')

	local list = vgui.Create(self, 'DListView')
	HOLDER = list
	list:Clear()
	list:AddColumn('Border ID')
	list:AddColumn('X')
	list:AddColumn('Y')
	list:AddColumn('Z')
	list:AddColumn('Yaw')
	list:AddColumn('Wide')
	list:AddColumn('Tall')
	list:AddColumn('Height')
	list:AddColumn('Type')
	list:AddColumn('Distance')

	list:SetMultiSelect(false)
	list:SortByColumn(10)

	function list:OnRowRightClick(id, line)
		local menu = vgui.Create('DLib_Menu')

		if cami:HasPermission('func_border_view') then
			menu:AddOption('Edit...', function() openBorderEdit(line.borderData, line.classname, line.borderData.mins, borderData.maxs) end)
		end

		menu:AddCopyOption('Copy Position', tostring(line.borderData.pos))
		menu:AddCopyOption('Copy Yaw', tostring(line.borderData.yaw))
		menu:AddCopyOption('Copy Mins', tostring(line.borderData.mins))
		menu:AddCopyOption('Copy Maxs', tostring(line.borderData.maxs))
		menu:AddCopyOption('Copy author\'s name', line.borderData.createdby)
		menu:AddCopyOption('Copy author\'s SteamID', line.borderData.createdid)
		menu:AddSteamID('Open author\'s steam', line.borderData.createdid)
		menu:AddCopyOption('Copy modifiers\'s name', line.borderData.modifiedby)
		menu:AddCopyOption('Copy modifiers\'s SteamID', line.borderData.modifiedid)
		menu:AddSteamID('Open modifiers\'s steam', line.borderData.modifiedid)

		menu:Open()
	end

	STATUS_SIGN = self:Help('Status: Updating...')

	if cami:HasPermission('func_border_view') then
		net.Start('func_border_request')
		net.SendToServer()
	else
		STATUS_SIGN:SetText('Status: No access!')
	end

	for classname, borderData in pairs(borders) do
		local button = vgui.Create(self, 'DButton')
		button:SetText('Create new ' .. classname)
		button:SetEnabled(cami:HasPermission('func_border_edit'))
		cami:HandlePanel('func_border_edit', button)

		function button.DoClick()
			openBorderEdit(nil, classname, borderData.mins, borderData.maxs)
		end
	end
end

hook.Add('PopulateToolMenu', 'func_border', function()
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'func_border', 'Borders', '', '', populate)
end)

net.receive('func_border_request', receive)
hook.Add('Think', 'func_border_updateMenu', Think)
