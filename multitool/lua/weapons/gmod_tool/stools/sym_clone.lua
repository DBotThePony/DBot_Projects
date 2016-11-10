
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

local CURRENT_TOOL_MODE = 'sym_clone'
local CURRENT_TOOL_MODE_VARS = CURRENT_TOOL_MODE .. '_'

TOOL.Name = 'Symmetry Cloner'
TOOL.Category = 'Construction'

if CLIENT then
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.name', 'Symmetry Cloner')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.desc', 'Mirror entities')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.0', '')
	
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left', 'Select entity to mirror')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.left_use', 'Auto select entities to mirror')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right', 'Select entity as mirror point')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.right_use', 'Make a clone!')
	language.Add('tool.' .. CURRENT_TOOL_MODE .. '.reload', 'Clear selection')
else
	util.AddNetworkString('' .. CURRENT_TOOL_MODE .. '.action')
end

TOOL.Information = {
	{name = 'left'},
	{name = 'left_use'},
	{name = 'right'},
	{name = 'right_use'},
	{name = 'reload'},
}

TOOL.ClientConVar = {
	select_r = 0,
	select_g = 255,
	select_b = 255,
	
	select2_r = 0,
	select2_g = 255,
	select2_b = 165,
	
	select3_r = 187,
	select3_g = 190,
	select3_b = 95,
	
	angle_p = 0,
	angle_y = 0,
	angle_r = 0,
	
	select_by_model = 0,
	select_only_constrained = 1,
	select_mode = 0,
	select_by_material = 0,
	select_size = 512,
	select_invert = 0,
	
	deselect = 1,
	display_mode = 0,
	ghost_obey_colors = 1,
}

local function CanUse(ply, ent)
	return IsValid(ent) and
		not ent:IsPlayer() and
		not ent:IsNPC() and
		not ent:IsVehicle() and
		(not ent.CPPICanTool or ent:CPPICanTool(ply, CURRENT_TOOL_MODE))
end

local function DuplicateVectors(tab)
	for k, v in pairs(tab) do
		if type(v) == 'Vector' then
			tab[k] = Vector(v)
		elseif type(v) == 'Angle' then
			tab[k] = Angle(v.p, v.y, v.r)
		elseif type(v) == 'table' then
			DuplicateVectors(v)
		end
	end
	
	return tab
end

function TOOL:SelectEntities(tr)
	local vars = {}
	
	for k, v in pairs(self.ClientConVar) do
		vars[k] = self:GetClientNumber(k, v)
	end
	
	vars.select_size = math.Clamp(vars.select_size, 1, 1024)
	
	local bools = {}
	
	for k, v in pairs(vars) do
		bools[k] = tobool(vars[k])
	end
	
	local MEM = {}
	
	if IsValid(tr.Entity) then
		for k, v in pairs(constraint.GetAllConstrainedEntities(tr.Entity)) do
			MEM[v] = v
		end
	end
	
	if not bools.select_only_constrained then
		local MDL, MTRL
		
		if IsValid(tr.Entity) then
			MDL = tr.Entity:GetModel()
			MTRL = tr.Entity:GetMaterial()
		end
		
		for i, ent in ipairs(bools.select_mode and ents.FindInBox(tr.HitPos, vars.select_size) or ents.FindInSphere(tr.HitPos, vars.select_size)) do
			if bools.select_by_material then
				if MTRL ~= ent:GetMaterial() then continue end
			end
			
			if bools.select_by_model then
				if MDL ~= ent:GetModel() then continue end
			end
			
			MEM[ent] = ent
		end
	end
	
	local reply = {}
	
	local ply = self:GetOwner()
	
	for k, v in pairs(MEM) do
		if CanUse(ply, v) then
			local phys = v:GetPhysicsObject()
			
			if phys:IsValid() then
				table.insert(reply, {v, phys})
			end
		end
	end
	
	return reply
end

function TOOL.BuildCPanel(Panel)
	Panel:CheckBox('Clear selection after paste', CURRENT_TOOL_MODE_VARS .. 'deselect')
	Panel:CheckBox('Display ghosts only when you hold toolgun', CURRENT_TOOL_MODE_VARS .. 'display_mode')
	Panel:CheckBox('Ghost entities in original color, if it is not white', CURRENT_TOOL_MODE_VARS .. 'ghost_obey_colors')
	Panel:NumSlider('Symmetry Angle Pith', CURRENT_TOOL_MODE_VARS .. 'angle_p', -180, 180, 0)
	Panel:NumSlider('Symmetry Angle Yaw', CURRENT_TOOL_MODE_VARS .. 'angle_y', -180, 180, 0)
	Panel:NumSlider('Symmetry Angle Roll', CURRENT_TOOL_MODE_VARS .. 'angle_r', -180, 180, 0)
	
	local cancel = Panel:Button('Reset angle')
	
	function cancel:DoClick()
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'angle_p', '0')
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'angle_y', '0')
		RunConsoleCommand(CURRENT_TOOL_MODE_VARS .. 'angle_r', '0')
	end
	
	local lab = Label('Color for clone objects', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE .. '_select_r')
	mixer:SetConVarG(CURRENT_TOOL_MODE .. '_select_g')
	mixer:SetConVarB(CURRENT_TOOL_MODE .. '_select_b')
	mixer:SetAlphaBar(false)
	
	local lab = Label('Color for symmetry object', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE .. '_select2_r')
	mixer:SetConVarG(CURRENT_TOOL_MODE .. '_select2_g')
	mixer:SetConVarB(CURRENT_TOOL_MODE .. '_select2_b')
	mixer:SetAlphaBar(false)
	
	local lab = Label('Color for visual clone plane', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(CURRENT_TOOL_MODE .. '_select3_r')
	mixer:SetConVarG(CURRENT_TOOL_MODE .. '_select3_g')
	mixer:SetConVarB(CURRENT_TOOL_MODE .. '_select3_b')
	mixer:SetAlphaBar(false)
	
	local lab = Label('Autoselect options', Panel)
	Panel:AddItem(lab)
	lab:SetDark(true)
	
	Panel:CheckBox('Auto Select only constrained', CURRENT_TOOL_MODE_VARS .. 'select_only_constrained')
	Panel:CheckBox('Auto Select by Model', CURRENT_TOOL_MODE_VARS .. 'select_by_model')
	Panel:CheckBox('Auto Select by Material', CURRENT_TOOL_MODE_VARS .. 'select_by_material')
	Panel:NumSlider('Auto Select Range', CURRENT_TOOL_MODE_VARS .. 'select_size', 1, 1024, 0)
	Panel:CheckBox('False - Sphere, True - Box', CURRENT_TOOL_MODE_VARS .. 'select_mode')
	Panel:CheckBox('Invert entities status on auto select', CURRENT_TOOL_MODE_VARS .. 'select_invert')
end

local SELECTED_ENTITY
local SELECT_TABLE = {}

local function GrabAngle(ply)
	return Angle(
		math.Clamp(
			tonumber(ply:GetInfo(CURRENT_TOOL_MODE_VARS .. 'angle_p') or 0) or 0,
			-180,
			180
		),
		
		math.Clamp(
			tonumber(ply:GetInfo(CURRENT_TOOL_MODE_VARS .. 'angle_y') or 0) or 0,
			-180,
			180
		),
		
		math.Clamp(
			tonumber(ply:GetInfo(CURRENT_TOOL_MODE_VARS .. 'angle_r') or 0) or 0,
			-180,
			180
		)
	)
end

local function SymmetryPositions(tabIn, pos, ang)
	local tabOut = {}
	
	for k, entry in ipairs(tabIn) do
		--[[
			This is done through WorldToLocal function
			when i was trying to done this using analytic geometry
			The theory: WorldToLocal creates new coordinate system, where (0; 0)
			is the point of third (pos) argument. When we specify valid angles,
			our line of symmetry is lying on X line.
			
			Without this function, it is harder to make the line math.
			But - We can do it by ourselves - Create local coordinate system,
			and just simply negate the Y.
		]]
		
		local localPos, localAng = WorldToLocal(entry[1], entry[2], pos, ang)
		localPos.y = -localPos.y
		
		localAng.y = -localAng.y
		localAng.r = -localAng.r
		
		table.insert(tabOut, {LocalToWorld(localPos, localAng, pos, ang)})
	end
	
	return tabOut
end

local function DoSafeCopy(data, ent)
	local newEnt = ents.Create(ent:GetClass())
	newEnt:SetPos(data[1])
	newEnt:SetAngles(data[2])
	newEnt:SetModel(ent:GetModel())
	
	newEnt:Spawn()
	
	newEnt:SetModel(ent:GetModel())
	
	newEnt:SetSkin(ent:GetSkin() or 0)
	newEnt:SetModelScale(ent:GetModelScale() or 1)
	newEnt:SetMaterial(ent:GetMaterial() or '')
	newEnt:SetHealth(ent:Health() or 0)
	newEnt:SetMaxHealth(ent:GetMaxHealth() or 0)
	newEnt:SetColor(ent:GetColor())
	
	newEnt:Activate()
	
	local getBG = ent:GetBodyGroups()
	
	if getBG then
		for i, data in ipairs(getBG) do
			if data.id > 0 then
				newEnt:SetBodygroup(data.id, ent:GetBodygroup(data.id))
			end
		end
	end
	
	local netVars
	
	if ent.GetNetworkVars then
		netVars = ent:GetNetworkVars()
	end
	
	if newEnt.RestoreNetworkVars and netVars then
		newEnt:RestoreNetworkVars(netVars)
	end
	
	local deepCopy = table.Copy(ent:GetTable())
	
	for k, val in pairs(deepCopy) do
		if type(val) == 'function' then
			deepCopy[k] = nil
		end
	end
	
	local phys = ent:GetPhysicsObject()
	local newPhys = newEnt:GetPhysicsObject()
	
	-- Physical copy
	if IsValid(phys) and IsValid(newPhys) then
		newPhys:SetMass(phys:GetMass())
		newPhys:EnableDrag(phys:IsDragEnabled())
		newPhys:EnableCollisions(phys:IsCollisionEnabled())
		newPhys:EnableGravity(phys:IsGravityEnabled())
		
		if phys:IsAsleep() then
			newPhys:Sleep()
		else
			newPhys:Wake()
		end
		
		newPhys:EnableMotion(phys:IsMotionEnabled())
	end
	
	return newEnt
end

local function Catch(err)
	print('[CATCHED ERROR] ', err)
	print(debug.traceback())
end

local function DPP_AntiSpamEnt(self, ply, ent)
	if ent == self then return false end
end

local function FastHaveValue(arr, val)
	for i = 1, #arr do
		if val == arr[i] then return true end
	end
	
	return false
end

local function CreateConstraintByTable(fEnt, sEnt, cData, doSymmetry)
	cData = DuplicateVectors(table.Copy(cData))
	
	local tp = cData.Type
	local func = constraint[tp]
	
	if not func then
		print('[Symmetry Clonner] Unknown Constraint Type: ' .. tp .. '!')
		return false
	end
	
	local args = {fEnt, sEnt, cData.Bone1 or 0, cData.Bone2 or 0}
	
	if tp == 'Weld' then
		table.insert(args, cData.forcelimit)
		table.insert(args, cData.nocollide)
	elseif tp == 'Elastic' then
		if doSymmetry then
			cData.Entity[1].LPos.y = -cData.Entity[1].LPos.y
			cData.Entity[2].LPos.y = -cData.Entity[2].LPos.y
		end
		
		table.insert(args, cData.Entity[1].LPos)
		table.insert(args, cData.Entity[2].LPos)
		table.insert(args, cData.constant)
		table.insert(args, cData.damping)
		table.insert(args, cData.rdamping)
		table.insert(args, cData.material)
		table.insert(args, cData.width)
		table.insert(args, tobool(cData.stretchonly))
	elseif tp == 'Rope' then
		if doSymmetry then
			cData.Entity[1].LPos.y = -cData.Entity[1].LPos.y
			cData.Entity[2].LPos.y = -cData.Entity[2].LPos.y
		end
		
		table.insert(args, cData.Entity[1].LPos)
		table.insert(args, cData.Entity[2].LPos)
		table.insert(args, cData.length)
		table.insert(args, cData.addlength)
		table.insert(args, cData.forcelimit)
		table.insert(args, cData.width)
		table.insert(args, cData.material)
		table.insert(args, cData.rigid)
	elseif tp == 'Slider' then
		if doSymmetry then
			cData.Entity[1].LPos.y = -cData.Entity[1].LPos.y
			cData.Entity[2].LPos.y = -cData.Entity[2].LPos.y
		end
		
		table.insert(args, cData.Entity[1].LPos)
		table.insert(args, cData.Entity[2].LPos)
		table.insert(args, cData.width)
		table.insert(args, cData.material)
	elseif tp == 'Axis' then
		if doSymmetry then
			cData.Entity[1].LPos.y = -cData.Entity[1].LPos.y
			cData.Entity[2].LPos.y = -cData.Entity[2].LPos.y
		end
		
		table.insert(args, cData.Entity[1].LPos)
		table.insert(args, cData.Entity[2].LPos)
		table.insert(args, cData.forcelimit)
		table.insert(args, cData.torquelimit)
		table.insert(args, cData.friction)
		table.insert(args, cData.nocollide)
	elseif tp == 'Ballsocket' then
		table.insert(args, cData.LPos)
		table.insert(args, cData.forcelimit)
		table.insert(args, cData.torquelimit)
		table.insert(args, cData.nocollide)
	end
	
	local status, constraintEntity = pcall(func, unpack(args))
	
	if not status then
		print('[CAUGHT ERROR] ' .. constraintEntity)
		return false
	elseif constraintEntity then
		return constraintEntity
	end
end

function SymmetryClonner_Clone(entPoint, Ents, ply)
	local pos, ang = entPoint:GetPos(), entPoint:GetAngles()
	local grabAng
	
	if ply then
		grabAng = GrabAngle(ply)
	else
		grabAng = Angle(0, 0, 0)
	end
	
	local realAng = ang + grabAng
	
	local input = {}
	local INPUT_MEM = {}
	local CONSTRAINT_MEM = {}
	
	local entPointConstraints = {}
	
	for k, ent in ipairs(Ents) do
		table.insert(input, {ent:GetPos(), ent:GetAngles()})
		INPUT_MEM[ent] = ent
	end
	
	for k, ent in ipairs(Ents) do
		CONSTRAINT_MEM[ent] = CONSTRAINT_MEM[ent] or {}
		local constr = constraint.GetTable(ent)
		
		for i, data in ipairs(constr) do
			if data.Ent1 == entPoint or data.Ent2 == entPoint then
				table.insert(entPointConstraints, data)
				continue
			end
			
			if not INPUT_MEM[data.Ent1] or not INPUT_MEM[data.Ent2] then continue end -- Not our constraint!
			
			if data.Ent1 == ent then
				CONSTRAINT_MEM[ent][data.Ent2] = CONSTRAINT_MEM[ent][data.Ent2] or {}
				table.insert(CONSTRAINT_MEM[ent][data.Ent2], data)
				
				CONSTRAINT_MEM[data.Ent2] = CONSTRAINT_MEM[data.Ent2] or {}
				CONSTRAINT_MEM[data.Ent2][ent] = CONSTRAINT_MEM[data.Ent2][ent] or {}
				
				table.insert(CONSTRAINT_MEM[data.Ent2][ent], data)
			elseif data.Ent2 == ent then
				CONSTRAINT_MEM[ent][data.Ent1] = CONSTRAINT_MEM[ent][data.Ent1] or {}
				table.insert(CONSTRAINT_MEM[ent][data.Ent1], data)
				
				CONSTRAINT_MEM[data.Ent1] = CONSTRAINT_MEM[data.Ent1] or {}
				CONSTRAINT_MEM[data.Ent1][ent] = CONSTRAINT_MEM[data.Ent1][ent] or {}
				
				table.insert(CONSTRAINT_MEM[data.Ent1][ent], data)
			end
		end
	end
	
	local output = SymmetryPositions(input, pos, realAng)
	local newEnts = {}
	
	local ASSOCIATION = {}
	local ASSOCIATION_REVERSE = {}
	
	for i, data in ipairs(output) do
		local ent = Ents[i]
		
		if ply then
			local class = ent:GetClass()
			
			if class == 'prop_physics' then
				local can = hook.Run('PlayerSpawnProp', ply, ent:GetModel())
				if can == false then continue end
			elseif class == 'prop_ragdoll' then
				local can = hook.Run('PlayerSpawnRagdoll', ply, ent:GetModel())
				if can == false then continue end
			elseif ent:IsWeapon() then
				local can = hook.Run('PlayerSpawnSWEP', ply, class, weapons.Get(class) or {})
				if can == false then continue end
			else
				local can = hook.Run('PlayerSpawnSENT', ply, class)
				if can == false then continue end
			end
		end
		
		local status, newEnt = xpcall(DoSafeCopy, Catch, data, ent)
		
		if status and newEnt then
			table.insert(newEnts, newEnt)
			ASSOCIATION[newEnt] = ent
			ASSOCIATION_REVERSE[ent] = newEnt
		end
	end
	
	local toContinue = {}
	
	for i, ent in ipairs(newEnts) do
		-- Bypass DPP antispam checks
		
		if ply then
			hook.Add('DPP_AntiSpamEnt', ent, DPP_AntiSpamEnt)
			
			if ent.CPPISetOwner then
				ent:CPPISetOwner(ply)
			end
			
			local class = ent:GetClass()
			
			if class == 'prop_physics' then
				local can = hook.Run('PlayerSpawnedProp', ply, ent:GetModel(), ent)
				if can == false then
					SafeRemoveEntity(ent)
					continue
				end
			elseif class == 'prop_ragdoll' then
				local can = hook.Run('PlayerSpawnedRagdoll', ply, ent:GetModel(), ent)
				if can == false then
					SafeRemoveEntity(ent)
					continue
				end
			elseif ent:IsWeapon() then
				local can = hook.Run('PlayerSpawnedSWEP', ply, ent)
				if can == false then
					SafeRemoveEntity(ent)
					continue
				end
			else
				local can = hook.Run('PlayerSpawnedSENT', ply, ent)
				if can == false then
					SafeRemoveEntity(ent)
					continue
				end
			end
		end
		
		table.insert(toContinue, ent)
	end
	
	if #toContinue == 0 then return {} end -- Oops
	
	local createdEntities = {}
	
	local DONE_MEM = {}
	
	if ply then
		undo.Create('Mirror')
		undo.SetPlayer(ply)
	end
	
	for i, ent in ipairs(toContinue) do
		table.insert(createdEntities, ent)
		
		if ply then
			undo.AddEntity(ent)
		end
		
		local parent = ASSOCIATION[ent]
		
		if not parent then continue end
		
		DONE_MEM[ent] = DONE_MEM[ent] or {}
		
		local constraints = CONSTRAINT_MEM[parent]
		
		if not constraints then continue end
		
		for fakeEnt, Data in pairs(constraints) do
			local cEnt = ASSOCIATION_REVERSE[fakeEnt]
			if not cEnt then continue end
			
			if DONE_MEM[ent][cEnt] then continue end
			
			DONE_MEM[cEnt] = DONE_MEM[cEnt] or {}
			if DONE_MEM[cEnt][ent] then continue end
			
			DONE_MEM[cEnt][ent] = true
			DONE_MEM[ent][cEnt] = true
			
			for i, cData in ipairs(Data) do
				local constraintEntity = CreateConstraintByTable(ent, cEnt, cData)
				
				if constraintEntity then
					table.insert(createdEntities, constraintEntity)
					
					if ply then
						undo.AddEntity(constraintEntity)
					end
				end
			end
		end
	end
	
	for i, cData in ipairs(entPointConstraints) do
		local myEntity = cData.Ent1 ~= entPoint and cData.Ent1 or cData.Ent2
		local ent = ASSOCIATION_REVERSE[myEntity]
		
		if not IsValid(ent) then continue end
		
		local constraintEntity
		
		local data = DuplicateVectors(table.Copy(cData))
		
		data.Entity[2].LPos = data.Entity[2].LPos or Vector()
		data.Entity[2].LPos.y = -data.Entity[2].LPos.y
		
		data.Entity[1].LPos = data.Entity[1].LPos or Vector()
		data.Entity[1].LPos.y = -data.Entity[1].LPos.y
		
		if myEntity == data.Ent1 then
			constraintEntity = CreateConstraintByTable(ent, entPoint, data)
		else
			constraintEntity = CreateConstraintByTable(entPoint, ent, data)
		end
		
		if constraintEntity then
			table.insert(createdEntities, constraintEntity)
			
			if ply then
				undo.AddEntity(constraintEntity)
			end
		end
	end
	
	if ply then
		undo.Finish()
	end
	
	return createdEntities
end

local function Request(ply)
	print(ply:Nick() .. ' is symmetrying entities')
	
	local entPoint = net.ReadEntity()
	if not IsValid(entPoint) then return end
	
	local Ents = {}
	local count = net.ReadUInt(12)
	
	for i = 1, count do
		local read = net.ReadEntity()
		
		if CanUse(ply, read) then
			table.insert(Ents, read)
		end
	end
	
	SymmetryClonner_Clone(entPoint, Ents, ply)
end

local function GetEntityDummy(ent)
	if IsValid(ent.__SYMMETRY_TOOL_GHOST) then
		return ent.__SYMMETRY_TOOL_GHOST
	end
	
	ent.__SYMMETRY_TOOL_GHOST = ClientsideModel(ent:GetModel())
	local new = ent.__SYMMETRY_TOOL_GHOST
	new:SetNoDraw(true)
	
	hook.Add('Think', new, function()
		if not IsValid(ent) then
			new:Remove()
		end
	end)
	
	new:SetPos(ent:GetPos())
	new:SetAngles(ent:GetAngles())
	
	return new
end

if CLIENT then
	local vars = {}
	
	for k, v in pairs(TOOL.ClientConVar) do
		vars[k] = CreateConVar(CURRENT_TOOL_MODE .. '_' .. k, tostring(v), {FCVAR_ARCHIVE, FCVAR_USERINFO}, '')
	end
	
	local function DoAdd(ent)
		local status = vars.select_invert:GetBool()
		
		for i = 1, #SELECT_TABLE do
			if SELECT_TABLE[i] == ent then
				if status then
					table.remove(SELECT_TABLE, i)
					return true
				else
					return false
				end
			end
		end
		
		table.insert(SELECT_TABLE, ent)
		return true
	end
	
	local function ClearSelectedItems()
		if not IsValid(SELECTED_ENTITY) then
			SELECTED_ENTITY = nil
		end
		
		local toRemove = {}
		
		for i, ent in ipairs(SELECT_TABLE) do
			if not IsValid(ent) then
				table.insert(toRemove, i)
			end
		end
		
		for i, v in ipairs(toRemove) do
			table.remove(SELECT_TABLE, v - i + 1)
		end
	end
	
	local Receivers = {
		select_main = function()
			local new = net.ReadEntity()
			if not IsValid(new) then return end
			
			if new ~= SELECTED_ENTITY then
				SELECTED_ENTITY = new
				chat.AddText('Primary Entity selected')
			else
				SELECTED_ENTITY = nil
				chat.AddText('Primary Entity unselected')
			end
			
			for i, ent in ipairs(SELECT_TABLE) do
				if ent == new then
					table.remove(SELECT_TABLE, i)
				end
			end
		end,
		
		select = function()
			local read = net.ReadEntity()
			
			if not IsValid(read) then return end
			
			for i, ent in ipairs(SELECT_TABLE) do
				if ent == read then
					table.remove(SELECT_TABLE, i)
					return
				end
			end
			
			if read == SELECTED_ENTITY then
				SELECTED_ENTITY = nil
				chat.AddText('Primary Entity unselected')
			end
			
			table.insert(SELECT_TABLE, read)
		end,
		
		multi = function()
			local count = net.ReadUInt(12)
			local newCount = 0
			local read = {}
			
			for i = 1, count do
				local get = net.ReadEntity()
				
				if IsValid(get) and get ~= SELECTED_ENTITY then
					local status = DoAdd(get)
					
					if status then
						newCount = newCount + 1
					end
				end
			end
			
			chat.AddText('Auto Selected ' .. newCount .. ' entities')
		end,
		
		clear = function()
			SELECTED_ENTITY = nil
			SELECT_TABLE = {}
			
			chat.AddText('Selection Cleared')
		end,
		
		paste = function()
			chat.AddText('Selection is about to be applied!')
			
			ClearSelectedItems()
			
			net.Start(CURRENT_TOOL_MODE .. '.action')
			
			net.WriteString('paste')
			net.WriteEntity(SELECTED_ENTITY)
			
			net.WriteUInt(#SELECT_TABLE, 12)
			
			for k, v in ipairs(SELECT_TABLE) do
				net.WriteEntity(v)
			end
			
			net.SendToServer()
			
			if vars.deselect:GetBool() then
				SELECTED_ENTITY = nil
				SELECT_TABLE = {}
			end
		end,
	}
	
	net.Receive('' .. CURRENT_TOOL_MODE .. '.action', function()
		Receivers[net.ReadString()]()
	end)
	
	hook.Add('PostDrawTranslucentRenderables', CURRENT_TOOL_MODE, function(a, b)
		if a or b then return end
		
		if vars.display_mode:GetBool() then
			if not LocalPlayer():IsValid() then return end
			local wep = LocalPlayer():GetActiveWeapon()
			if not wep:IsValid() then return end
			
			if wep:GetClass() ~= 'gmod_tool' then return end
			if wep:GetMode() ~= CURRENT_TOOL_MODE then return end
		end
		
		ClearSelectedItems()
		
		local symmAngle
		
		if IsValid(SELECTED_ENTITY) then
			local select_red = vars.select_r:GetInt() / 255
			local select_green = vars.select_g:GetInt() / 255
			local select_blue = vars.select_b:GetInt() / 255
			render.SetColorModulation(select_red, select_green, select_blue)
			SELECTED_ENTITY:DrawModel()
			
			local pos, ang = SELECTED_ENTITY:GetPos(), SELECTED_ENTITY:GetAngles()
			local mins, maxs = SELECTED_ENTITY:OBBMins(), SELECTED_ENTITY:OBBMaxs()
			
			local deltaX = maxs.x - mins.x
			local deltaZ = maxs.z - mins.z
			
			local newAng = Angle(vars.angle_p:GetInt() + ang.p, vars.angle_y:GetInt() + ang.y, vars.angle_r:GetInt() + ang.r)
			symmAngle = Angle(newAng.p, newAng.y, newAng.r)
			newAng:Normalize()
			
			newAng:RotateAroundAxis(newAng:Right(), 90)
			newAng:RotateAroundAxis(newAng:Forward(), 90)
			newAng:RotateAroundAxis(newAng:Up(), 90)
			
			local Add = Vector(-deltaX * 1.5, deltaZ * .5, 0)
			Add:Rotate(newAng)
			
			local select3_red = vars.select3_r:GetInt()
			local select3_green = vars.select3_g:GetInt()
			local select3_blue = vars.select3_b:GetInt()
			
			cam.Start3D2D(pos + Add, newAng, 3)
			
			surface.SetDrawColor(select3_red, select3_green, select3_blue)
			surface.DrawRect(0, 0, deltaX, deltaZ * .5)
			
			cam.End3D2D()
		end
		
		local select_red = vars.select2_r:GetInt() / 255
		local select_green = vars.select2_g:GetInt() / 255
		local select_blue = vars.select2_b:GetInt() / 255
		
		local toMirror = {}
		
		local obey = vars.ghost_obey_colors:GetBool()
		
		for k, ent in ipairs(SELECT_TABLE) do
			local col = ent:GetColor()
			local nonDefaultCol = col.r ~= 255 or col.g ~= 255 or col.b ~= 255
			
			if not nonDefaultCol or not obey then
				render.SetColorModulation(select_red, select_green, select_blue)
				ent:DrawModel()
			end
			
			table.insert(toMirror, {ent:GetPos(), ent:GetAngles()})
		end
		
		if IsValid(SELECTED_ENTITY) then
			local get = SymmetryPositions(toMirror, SELECTED_ENTITY:GetPos(), symmAngle)
			
			render.SetColorModulation(select_red, select_green, select_blue)
			render.SetBlend(0.7 + math.sin(CurTime() * 3) * .1)
			
			for i, v in ipairs(get) do
				local ent = SELECT_TABLE[i]
				local ent2 = GetEntityDummy(ent)
				local mat = ent:GetMaterial()
				local col = ent:GetColor()
				
				ent2:SetPos(v[1])
				ent2:SetAngles(v[2])
				ent2:SetMaterial(mat)
				
				local nonDefaultCol = col.r ~= 255 or col.g ~= 255 or col.b ~= 255
				
				if nonDefaultCol and obey then
					render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
				end
				
				ent2:DrawModel()
				
				if nonDefaultCol and obey then
					render.SetColorModulation(select_red, select_green, select_blue)
				end
			end
		end
		
		render.SetColorModulation(1, 1, 1)
	end)
else
	net.Receive(CURRENT_TOOL_MODE .. '.action', function(len, ply)
		local mode = net.ReadString()
		
		if mode == 'paste' then
			Request(ply)
		end
	end)
end

function TOOL:LeftClick(tr)
	if not self:GetOwner():KeyDown(IN_USE) then
		if not CanUse(self:GetOwner(), tr.Entity) then return false end
	end
	
	if SERVER then
		if not self:GetOwner():KeyDown(IN_USE) then
			net.Start('sym_clone.action')
			net.WriteString('select')
			net.WriteEntity(tr.Entity)
			net.Send(self:GetOwner())
		else
			net.Start('sym_clone.action')
			net.WriteString('multi')
			
			local get = self:SelectEntities(tr)
			local c = #get
			
			net.WriteUInt(c, 12)
			
			for i = 1, c do
				net.WriteEntity(get[i][1])
			end
			
			net.Send(self:GetOwner())
		end
	end
	
	return true
end

function TOOL:RightClick(tr)
	self:GetSWEP().SymmLastRightClick = self:GetSWEP().SymmLastRightClick or CurTime()
	if self:GetSWEP().SymmLastRightClick > CurTime() then
		if SERVER then
			self:GetOwner():ChatPrint('Stop spamming!')
		end
		
		return false
	end
	
	self:GetSWEP().SymmLastRightClick = CurTime() + 2
	
	if not self:GetOwner():KeyDown(IN_USE) then
		if not CanUse(self:GetOwner(), tr.Entity) then return false end
	end
	
	if SERVER then
		if not self:GetOwner():KeyDown(IN_USE) then
			net.Start('sym_clone.action')
			net.WriteString('select_main')
			net.WriteEntity(tr.Entity)
			net.Send(self:GetOwner())
		else
			net.Start('sym_clone.action')
			net.WriteString('paste')
			net.Send(self:GetOwner())
		end
	end
	
	return true
end

function TOOL:Reload(tr)
	if SERVER then
		net.Start('sym_clone.action')
		net.WriteString('clear')
		net.Send(self:GetOwner())
	end
	
	return true
end
