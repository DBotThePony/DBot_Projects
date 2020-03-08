
-- Copyright (C) 2018-2019 DBotThePony

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

local stripper = {}
local entMeta = FindMetaTable('Entity')

local ipairs = ipairs
local pairs = pairs
local ents = ents
local table = table
local string = string

DLib.CMessage(stripper, 'StripperExport')

function stripper.PropsOf(ply)
	if not entMeta.CPPIGetOwner then
		stripper.Message('Stripper Exporter REQUIRES a CPPI compatible prop protection to be installed! (DPP/FPP for example)')
		return {}
	end

	local output = {}

	for i, ent in ipairs(ents.GetAll()) do
		local owner = ent:CPPIGetOwner()

		--if owner == ply and not ent:IsWeapon() and not ent:IsVehicle() and not ent:IsNPC() then
		if owner == ply and not ent:IsWeapon() and not ent:IsVehicle() then
			table.insert(output, ent)
		end
	end

	return output
end

local function sprintfn(numIn)
	return string.format('%.2f', numIn)
end

-- Physics Impact Damage Scale (physdamagescale) <float>
-- Multiplies damage received from physics impacts. 0 means the feature is disabled for backwards compatibility.
-- Impact damage type (Damagetype) <boolean>
-- If true (1), damage type is sharp and the object can slice others.
-- Damaging it Doesn't Push It (nodamageforces) <boolean>
-- Whether damaging the entity applies force to it.
-- Scale Factor For Inertia (inertiascale) <float>
-- Scales the angular mass of an object. Used to hack angular damage and collision response.
--  Confirm:	Doesn't actually affect inertia?
-- Mass Scale (massscale) <float>
-- Multiplier for the object's mass.
-- Override Parameters (overridescript) <string>
-- A list of physics keyvalues that are usually embedded in the model. Format is key,value,key,value,....
-- Health Level to Override Motion (damagetoenablemotion) <integer>
-- If specified, this object will start with motion disabled. Once its health has dropped below this specified amount, it will enable motion.
-- Physics Impact Force to Override Motion (forcetoenablemotion) <float>
-- If specified, this object will start motion disabled. Any impact that imparts a force greater than this value will enable motion.

-- massscale                     =           0,
-- max_health                    =           1,
-- minhealthdmg                  =           0,
-- model                         = "models/props_borealis/borealis_door001a.mdl",
-- modelindex                    =         400,
-- modelscale                    =           1,
-- nextthink                     = -0x0002f9a5,
-- overridescript                = "",
-- parentname                    = "",
-- physdamagescale               =           0.10000000149012,
-- playbackrate                  =           0,
-- puntsound                     = "",
-- rendercolor                   = "255 255 255 255",
-- renderfx                      =           0,
-- rendermode                    =           0,
-- sequence                      =           0,
-- shadowcastdist                =           0,
-- skin                          =           0,
-- spawnflags                    =           0,
-- speed                         =           0,
-- target                        = "",
-- texframeindex                 =           0,
-- touchStamp                    =          43,
-- velocity                      = Vector (          0                 ,           0                 ,           0                 ),
-- view_ofs                      = Vector (          0                 ,           0                 ,           0                 ),
-- waterlevel                    =           0

local safeValues = {
	'BreakModelMessage',
	'Damagetype',
	'ExplodeDamage',
	'ExplodeRadius',
	'LightingOrigin',
	'LightingOriginHack',
	'ResponseContext',
	'SetBodyGroup',
	'damagefilter',
	'damagetoenablemotion',
	'forcetoenablemotion',
	'friction',
	'health',
	'm_CollisionGroup',
	'm_bAnimatedEveryTick',
	'm_bBlockLOSSetByPropData',
	'm_bClientSideAnimation',
	'm_bClientSideFrameReset',
	'm_bFirstCollisionAfterLaunch',
	'm_bIsWalkableSetByPropData',
	'max_health',
	'modelindex',
	'modelscale',
	'parentname',
	'physdamagescale',
	'rendercolor',
	'renderfx',
	'rendermode',
	'sequence',
	'shadowcastdist',
	'skin',
	'spawnflags',
	'target',
	'texframeindex',
}

local tostring2 = tostring

local function tostring(val)
	if type(val) == 'boolean' then
		return val and '1' or '0'
	end

	return tostring2(val)
end

local function getKeyValuesSafe(ent)
	local output = {}
	local kv = ent:GetSaveTable()

	for i, key in ipairs(safeValues) do
		if kv[key] ~= nil and kv[key] ~= '' then
			if type(kv[key]) == 'number' then
				output[key] = sprintfn(kv[key])
			else
				output[key] = tostring(kv[key])
			end
		end
	end

	return output
end

function stripper.PropTable(ent)
	local proplist = getKeyValuesSafe(ent)
	local lpos = ent:GetPos()
	local lang = ent:GetAngles()

	proplist.origin = sprintfn(lpos.x) .. ' ' .. sprintfn(lpos.y) .. ' ' .. sprintfn(lpos.z)
	proplist.angles = sprintfn(lang.p) .. ' ' .. sprintfn(lang.y) .. ' ' .. sprintfn(lang.r)
	proplist.model = ent:GetModel()

	if proplist.model then
		proplist.model = proplist.model:lower()
	end

	local color = ent:GetColor()

	if color.r ~= 255 or color.g ~= 255 or color.b ~= 255 then
		proplist.rendercolor = color.r .. ' ' .. color.g .. ' ' .. color.b
	end

	if ent:GetModelScale() ~= 1 then
		proplist.scale = ent:GetModelScale()
	end

	proplist.classname = ent:GetClass()

	if proplist.classname == 'prop_physics' then
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) and not phys:IsMotionEnabled() then
			proplist.classname = 'prop_dynamic'
		end
	end

	return proplist
end

function stripper.ListFromArray(arrIn)
	local output = {}

	for i, ent in ipairs(arrIn) do
		table.insert(output, stripper.PropTable(ent))
	end

	return output
end

local function escape(strIn)
	return '"' .. strIn:gsub('"', "'"):gsub('\\', '\\\\') .. '"'
end

function stripper.Serialize(propStruct)
	local stringbuilder = {}

	for key, value in pairs(propStruct) do
		table.insert(stringbuilder, escape(key) .. ' ' .. escape(value))
	end

	return '{\n' .. table.concat(stringbuilder, '\n') .. '\n}\n'
end

local IsValid = IsValid
local game = game
local Entity = Entity

file.mkdir('stripper')

concommand.Add('stripper_export', function(ply, cmd, args)
	if not IsValid(ply) then
		if game.SinglePlayer() then
			ply = Entity(1)
		else
			stripper.Message('You are console')
			return
		end
	end

	if not ply:IsSuperAdmin() then
		stripper.MessagePlayer(ply, 'Not a super admin!')
		return
	end

	local entlist = stripper.PropsOf(ply)

	if #entlist == 0 then
		stripper.MessagePlayer(ply, 'Nothing to export!')
		return
	end

	local fpath = 'stripper/export_' .. game.GetMap() .. '_' .. os.date('%H_%M_%S-%Y-%m-%d', os.time()) .. '.txt'
	local writable = file.Open(fpath, 'wb', 'DATA')

	for i, propStruct in ipairs(stripper.ListFromArray(entlist)) do
		writable:Write(stripper.Serialize(propStruct))
	end

	writable:Flush()
	writable:Close()

	stripper.MessagePlayer(ply, 'File saved to ' .. fpath .. ' on the server.')
	stripper.Message(ply, ' exported his props as Stripper: Source file as ' .. fpath)
end)
