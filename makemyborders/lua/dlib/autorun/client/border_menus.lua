
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
local render = render
local math = math
local Color = Color

local input = input
local IN_DUCK = IN_DUCK
local IN_USE = IN_USE
local Vector = Vector

local function readBorder(borderData)
	local output = {}
	output.id = net.ReadUInt(32)
	output.pos = net.ReadVectorDouble()
	output.mins = net.ReadVectorDouble()
	output.maxs = net.ReadVectorDouble()
	output.yaw = net.ReadDouble()

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

	return output
end

local HOLDER, lastPos, STATUS_SIGN
local WAITING_WINDOW
local isHidden = false

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
		borderData.yaw = math.NormalizeAngle(ang.y - 90)

		for i, var in ipairs(borders[classname]) do
			borderData[var.name] = var.defaultLua
		end
	end

	local self = vgui.Create('DLib_WindowScroll')
	WAITING_WINDOW = self

	local hide = vgui.Create('DButton', self)
	hide:SetPos(350, 3)
	hide:SetText('Hide')
	hide:SetSize(120, 20)

	function hide.DoClick()
		self:SetVisible(false)
		self:KillFocus()
		isHidden = true
		messages.AddChat('To get back to editing window, press <' .. input.LookupBinding('+duck'):upper() .. '> + <' .. input.LookupBinding('use'):upper() .. '>')
	end

	self:SetSize(600, 800)
	self:Center()

	if isNew then
		self:SetTitle(' * New Border creation menu - ' .. classname)
	else
		self:SetTitle('Border edit menu - ' .. borderData.id .. ' [' .. classname .. ']')
	end

	self:Label('Position'):DockMargin(5, 5, 5, 5)
	local X = self:AddPanel('DLib_NumberInputLabeledBare')
	X:SetTitle('X')
	X:SetValue(borderData.pos.x)
	local Y = self:AddPanel('DLib_NumberInputLabeledBare')
	Y:SetTitle('Y')
	Y:SetValue(borderData.pos.y)
	local Z = self:AddPanel('DLib_NumberInputLabeledBare')
	Z:SetTitle('Z')
	Z:SetValue(borderData.pos.z)

	self:Label('Minimals'):DockMargin(5, 5, 5, 5)
	local MINSX = self:AddPanel('DLib_NumberInputLabeledBare')
	MINSX:SetTitle('X')
	MINSX:SetValue(borderData.mins.x)
	local MINSY = self:AddPanel('DLib_NumberInputLabeledBare')
	MINSY:SetTitle('Y')
	MINSY:SetValue(borderData.mins.y)
	local MINSZ = self:AddPanel('DLib_NumberInputLabeledBare')
	MINSZ:SetTitle('Z')
	MINSZ:SetValue(borderData.mins.z)

	self:Label('Maximals'):DockMargin(5, 5, 5, 5)
	local MAXSX = self:AddPanel('DLib_NumberInputLabeledBare')
	MAXSX:SetTitle('X')
	MAXSX:SetValue(borderData.maxs.x)
	local MAXSY = self:AddPanel('DLib_NumberInputLabeledBare')
	MAXSY:SetTitle('Y')
	MAXSY:SetValue(borderData.maxs.y)
	local MAXSZ = self:AddPanel('DLib_NumberInputLabeledBare')
	MAXSZ:SetTitle('Z')
	MAXSZ:SetValue(borderData.maxs.z)

	local YAW = self:AddPanel('DLib_NumberInputLabeledBare')
	YAW:SetTitle('Yaw')
	YAW:SetValue(borderData.yaw)

	self.XPanel = X
	self.YPanel = Y
	self.ZPanel = Z

	self.MAXSX = MAXSX
	self.MAXSY = MAXSY
	self.MAXSZ = MAXSZ

	self.MINSX = MINSX
	self.MINSY = MINSY
	self.MINSZ = MINSZ

	self.YAW = YAW

	local specific = {}

	self:Label('Border specific data'):DockMargin(5, 5, 5, 5)
	for i, var in ipairs(borders[classname]) do
		if var.check2 == 'boolean' then
			local panel = self:AddPanel('DCheckBoxLabel')
			panel:SetChecked(borderData[var[1]])
			panel:SetText(var[1])
			specific[var[1]] = function() return panel:GetChecked() end
		elseif var.check2 == 'int' then
			local panel = self:AddPanel('DLib_NumberInputLabeledBare')
			panel:SetIsFloatAllowed(false)
			panel:SetValue(borderData[var[1]])
			panel:SetTitle(var[1])
			specific[var[1]] = function() return panel:GetNumber() end
		elseif var.check2 == 'float' then
			local panel = self:AddPanel('DLib_NumberInputLabeledBare')
			panel:SetValue(borderData[var[1]])
			panel:SetTitle(var[1])
			specific[var[1]] = function() return panel:GetNumber() end
		elseif var.check2 == 'string' then
			local panel = self:AddPanel('DLib_TextInputLabeledBare')
			panel:SetValue(borderData[var[1]])
			panel:SetTitle(var[1])
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
		net.WriteDouble(borderData.yaw)

		for i, var in ipairs(borders[classname]) do
			var.nwwrite(specific[var[1]]())
		end

		net.SendToServer()

		self:Close()
	end
end

local function CreateMove(cmd)
	local self = WAITING_WINDOW
	if not IsValid(self) then return end
	if not isHidden then return end

	if cmd:KeyDown(IN_DUCK) and cmd:KeyDown(IN_USE) then
		isHidden = false
		self:SetVisible(true)
		self:MakePopup()
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

	local read = readBorders()
	for borderClass, readData in pairs(read) do
		for i, borderData in ipairs(readData.list) do
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
	end

	STATUS_SIGN:SetText('Status: Ready.')

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

local function PostDrawTranslucentRenderables()
	local self = WAITING_WINDOW
	if not IsValid(self) then return end

	local pos = Vector(self.XPanel:GetNumber(), self.YPanel:GetNumber(), self.ZPanel:GetNumber())
	local mins = Vector(self.MINSX:GetNumber(), self.MINSY:GetNumber(), self.MINSZ:GetNumber())
	local maxs = Vector(self.MAXSX:GetNumber(), self.MAXSY:GetNumber(), self.MAXSZ:GetNumber())
	local ang = Angle(0, self.YAW:GetNumber(), 0)

	local faces = DLib.vector.ExtractFaces(mins, maxs)

	render.SetColorMaterial()
	local time = RealTime()
	local color = Color(math.sin(time * 0.1) * 128 + 127, math.cos(time * 0.1) * 128 + 127, math.sin(time * 0.1 + 0.5) * 128 + 127)

	for i, faceData in ipairs(faces) do
		local one, two, three, four = faceData[1], faceData[2], faceData[3], faceData[4]

		one:Rotate(ang)
		two:Rotate(ang)
		three:Rotate(ang)
		four:Rotate(ang)

		one = one + pos
		two = two + pos
		three = three + pos
		four = four + pos

		render.CullMode(0)
		render.DrawQuad(one, two, three, four, color)
		render.CullMode(1)
		render.DrawQuad(one, two, three, four, color)
	end

	render.CullMode(0)
end

local cami = DLib.CAMIWatchdog('func_border_menu')
cami:Track('func_border_view')

local function populate(self)
	if not IsValid(self) then return end

	self:Help('This tab holds all the borders stored for current map.\nIf you want to remove a border, you can do it here\nor right click on needed border')

	local list = vgui.Create('DListView', self)
	list:Dock(TOP)
	list:SetSize(0, 600)
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
			menu:AddOption('Delete...', function()
				Derma_Query(
					'Are you sure in deleting border ' .. line.classname .. ' with ID ' .. line.borderData.id .. '?',
					'Confirm deletion',
					'Confirm',
					function()
						net.Start('func_border_delete')
						net.WriteUInt32(line.borderData.id)
						net.WriteString(line.classname)
						net.SendToServer()
					end,
					'Cancel'
				)
			end)
		end

		menu:AddCopyOption('Copy ID', tostring(line.borderData.id))
		menu:AddCopyOption('Copy classname', tostring(line.classname))
		menu:AddCopyOption('Copy Position', tostring(line.borderData.pos))
		menu:AddCopyOption('Copy Yaw', tostring(line.borderData.yaw))
		menu:AddCopyOption('Copy Mins', tostring(line.borderData.mins))
		menu:AddCopyOption('Copy Maxs', tostring(line.borderData.maxs))

		menu:Open()
	end

	function list:DoDoubleClick(id, line)
		if not cami:HasPermission('func_border_view') then return end
		openBorderEdit(line.borderData, line.classname, line.borderData.mins, borderData.maxs)
	end

	STATUS_SIGN = self:Help('Status: Updating...')

	if cami:HasPermission('func_border_view') then
		net.Start('func_border_request')
		net.SendToServer()
	else
		STATUS_SIGN:SetText('Status: No access!')
	end

	STATUS_SIGN:DockMargin(5, 5, 5, 5)

	local button = vgui.Create('DButton', self)
	button:SetText('Refresh list')
	button:Dock(TOP)
	cami:HandlePanel('func_border_edit', button)
	button:DockMargin(0, 5, 0, 5)

	function button.DoClick()
		if cami:HasPermission('func_border_view') then
			net.Start('func_border_request')
			net.SendToServer()
		else
			STATUS_SIGN:SetText('Status: No access!')
		end
	end

	for classname, borderData in pairs(borders) do
		local button = vgui.Create('DButton', self)
		button:SetText('Create new ' .. classname)
		button:Dock(TOP)
		cami:HandlePanel('func_border_edit', button)

		function button.DoClick()
			if IsValid(WAITING_WINDOW) then
				WAITING_WINDOW:SetVisible(true)
				WAITING_WINDOW:Center()
				WAITING_WINDOW:MakePopup()
				return
			end

			openBorderEdit(nil, classname, borderData.mins, borderData.maxs)
		end
	end
end

hook.Add('PopulateToolMenu', 'func_border', function()
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'func_border', 'Borders', '', '', populate)
end)

net.receive('func_border_request', receive)
hook.Add('Think', 'func_border_updateMenu', Think)
hook.Add('PostDrawTranslucentRenderables', 'func_border_drawFromMenu', PostDrawTranslucentRenderables, 5)
hook.Add('CreateMove', 'func_border_drawFromMenu', CreateMove, -10)
